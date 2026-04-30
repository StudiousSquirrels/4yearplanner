import express from "express";
import { pool } from "./db.js";

const app = express();
const port = process.env.API_PORT || 3001;

app.use(express.json());

const supportedMajorCatalogOrder = [
  "ANTH",
  "ARH",
  "BCM",
  "BIO",
  "CHM",
  "CSC",
  "ECN",
  "ENG",
  "HIS",
  "MAT",
  "PHY",
  "POL",
  "PSY",
  "SOC",
];

const catalogProgramUrls = {
  ANTH: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2777&returnto=6360",
  ARH: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2775&returnto=6360",
  BCM: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2779&returnto=6360",
  BIO: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2778&returnto=6360",
  CHM: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2780&returnto=6360",
  CSC: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2783&returnto=6360",
  ECN: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2785&returnto=6360",
  ENG: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2787&returnto=6360",
  HIS: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2795&returnto=6360",
  MAT: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2799&returnto=6360",
  PHY: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2803&returnto=6360",
  POL: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2805&returnto=6360",
  PSY: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2806&returnto=6360",
  SOC: "https://catalog.grinnell.edu/preview_program.php?catoid=38&poid=2810&returnto=6360",
};

function normalizeCourseCode(courseCode) {
  return courseCode.replace(/\s+/g, "");
}

function displayCourseId(courseCode) {
  return courseCode.replace(/\s+/, "-");
}

function mapCourse(row, prerequisiteGroups, registrationRule) {
  const legacyPrerequisites = row.prerequisites?.length
    ? row.prerequisites.map(normalizeCourseCode)
    : [];
  const groups =
    prerequisiteGroups.length > 0
      ? prerequisiteGroups
      : legacyPrerequisites.map((code) => ({
          groupCode: code,
          options: [code],
          canBeCorequisite: false,
        }));

  return {
    id: displayCourseId(row.course_code),
    code: normalizeCourseCode(row.course_code),
    name: row.title || row.course_code,
    credits: row.credits,
    prerequisites: groups.flatMap((group) => group.options),
    prerequisiteGroups: groups,
    registrationRule,
    offered: row.offered_terms || [],
    subfields: row.subfields || [],
  };
}

async function getCourses() {
  const { rows } = await pool.query(`
    SELECT
      c.id,
      c.course_code,
      c.title,
      c.credits,
      COALESCE(
        array_remove(array_agg(DISTINCT prereq.course_code), NULL),
        ARRAY[]::text[]
      ) AS prerequisites,
      COALESCE(
        array_remove(array_agg(DISTINCT ct.term), NULL),
        ARRAY[]::text[]
      ) AS offered_terms,
      COALESCE(
        array_remove(array_agg(DISTINCT s.code), NULL),
        ARRAY[]::text[]
      ) AS subfields
    FROM courses c
    LEFT JOIN course_prerequisites cp ON cp.course_id = c.id
    LEFT JOIN courses prereq ON prereq.id = cp.prerequisite_course_id
    LEFT JOIN course_terms ct ON ct.course_id = c.id
    LEFT JOIN course_subfields cs ON cs.course_id = c.id
    LEFT JOIN subfields s ON s.id = cs.subfield_id
    WHERE c.active = TRUE
    GROUP BY c.id
    ORDER BY c.dept, c.number
  `);

  const courseIds = rows.map((row) => row.id);
  const prerequisiteGroupsByCourseId = new Map();
  const registrationRulesByCourseId = new Map();

  if (courseIds.length > 0) {
    const { rows: groupRows } = await pool.query(
      `
        SELECT
          cpg.course_id,
          cpg.group_code,
          bool_or(cpg.can_be_corequisite) AS can_be_corequisite,
          array_agg(prereq.course_code ORDER BY prereq.course_code) AS options
        FROM course_prerequisite_groups cpg
        JOIN courses prereq ON prereq.id = cpg.prerequisite_course_id
        WHERE cpg.course_id = ANY($1::bigint[])
        GROUP BY cpg.course_id, cpg.group_code
        ORDER BY cpg.course_id, cpg.group_code
      `,
      [courseIds],
    );

    for (const row of groupRows) {
      const groups = prerequisiteGroupsByCourseId.get(row.course_id) || [];
      groups.push({
        groupCode: row.group_code,
        options: row.options.map(normalizeCourseCode),
        canBeCorequisite: row.can_be_corequisite,
      });
      prerequisiteGroupsByCourseId.set(row.course_id, groups);
    }

    const { rows: ruleRows } = await pool.query(
      `
        SELECT
          course_id,
          min_semester_index,
          min_prior_courses_dept,
          min_prior_courses_min_number,
          min_prior_courses_max_number,
          min_prior_courses_count,
          notes
        FROM course_registration_rules
        WHERE course_id = ANY($1::bigint[])
      `,
      [courseIds],
    );

    for (const row of ruleRows) {
      registrationRulesByCourseId.set(row.course_id, {
        minSemesterIndex: row.min_semester_index,
        minPriorCoursesDept: row.min_prior_courses_dept,
        minPriorCoursesMinNumber: row.min_prior_courses_min_number,
        minPriorCoursesMaxNumber: row.min_prior_courses_max_number,
        minPriorCoursesCount: row.min_prior_courses_count,
        notes: row.notes,
      });
    }
  }

  return rows.map((row) =>
    mapCourse(
      row,
      prerequisiteGroupsByCourseId.get(row.id) || [],
      registrationRulesByCourseId.get(row.id) || null,
    ),
  );
}

async function getMajors() {
  const { rows } = await pool.query(
    `
    SELECT code, name
    FROM majors
    WHERE code = ANY($1::text[])
    ORDER BY array_position($1::text[], code)
  `,
    [supportedMajorCatalogOrder],
  );

  return rows.map((row) => ({
    code: row.code,
    name: row.name,
    catalogUrl: catalogProgramUrls[row.code],
  }));
}

async function getMajorRequirements(majorCode) {
  const { rows: majorRows } = await pool.query(
    "SELECT id, code, name FROM majors WHERE code = $1",
    [majorCode],
  );

  if (majorRows.length === 0) {
    return null;
  }

  const major = majorRows[0];
  const { rows: blockRows } = await pool.query(
    `
      SELECT
        rb.code AS block_code,
        rb.title,
        rb.rule_type,
        rb.min_count,
        rb.min_credits,
        rb.notes,
        COALESCE(
          array_remove(array_agg(c.course_code ORDER BY c.course_code), NULL),
          ARRAY[]::text[]
        ) AS course_codes
      FROM requirement_blocks rb
      LEFT JOIN block_course_options bco ON bco.block_id = rb.id
      LEFT JOIN courses c ON c.id = bco.course_id
      WHERE rb.major_id = $1
      GROUP BY rb.id
      ORDER BY rb.sort_order
    `,
    [major.id],
  );

  const requirements = {};
  const blocks = blockRows.map((block) => ({
    code: block.block_code,
    title: block.title,
    ruleType: block.rule_type,
    minCount: block.min_count,
    minCredits: block.min_credits,
    notes: block.notes,
    courseCodes: block.course_codes.map(normalizeCourseCode),
  }));

  for (const block of blockRows) {
    const courseCodes = block.course_codes.map(normalizeCourseCode);

    if (block.block_code === "CSC_INTRO_151") {
      requirements.Introductory = courseCodes;
    }

    if (["CSC_INTRO_161", "CSC_INTRO_207"].includes(block.block_code)) {
      requirements["Multi-paradigm"] = [
        ...(requirements["Multi-paradigm"] || []),
        ...courseCodes,
      ];
    }

    if (block.block_code === "CSC_DISCRETE") {
      requirements["Discrete Structures (one of)"] = courseCodes;
    }

    if (block.block_code === "CSC_SYSTEMS") {
      requirements.Systems = courseCodes;
    }

    if (["CSC_THEORY_301", "CSC_THEORY_341"].includes(block.block_code)) {
      requirements["Upper-level Theory"] = [
        ...(requirements["Upper-level Theory"] || []),
        ...courseCodes,
      ];
    }

    if (block.block_code === "CSC_SOFTWARE_324") {
      requirements["Software Development"] = courseCodes;
    }

    if (block.block_code === "CSC_ELECTIVE") {
      requirements.electives = {
        credits: block.min_credits || 4,
        allowedPrefixes: ["CSC"],
        minLevel: 200,
        excludedCourses: ["CSC281", "CSC282"],
        specialRules: {
          CSC326: { maxCredits: 2 },
          CSC211_CSC213: { maxCount: 1 },
        },
      };
    }

    if (block.block_code === "CSC_MATH_ELECTIVE") {
      requirements["Math Foundations"] = {
        type: "level-based",
        prefix: "MAT",
        minLevel: 133,
      };
    }
  }

  return {
    major: {
      id: major.code.toLowerCase(),
      name: major.name,
      totalCredits: 32,
      description: `Requirements for the ${major.name} major`,
    },
    blocks,
    requirements,
  };
}

app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ ok: true });
  } catch (error) {
    console.error("Health check error:", error);
    res.status(500).json({ ok: false, error: error.message });
  }
});

app.get("/api/courses", async (req, res) => {
  try {
    const courses = await getCourses();
    res.json({ courses });
  } catch (error) {
    console.error("Courses endpoint error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/majors", async (_req, res) => {
  try {
    const majors = await getMajors();
    res.json({ majors });
  } catch (error) {
    console.error("Majors endpoint error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/majors/:code/requirements", async (req, res) => {
  try {
    const requirements = await getMajorRequirements(req.params.code.toUpperCase());

    if (!requirements) {
      res.status(404).json({ error: "Major not found" });
      return;
    }

    res.json(requirements);
  } catch (error) {
    console.error("Requirements endpoint error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`SQL API listening on http://localhost:${port}`);
});
