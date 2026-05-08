import "./App.css";
import { useEffect, useMemo, useState } from "react";
import SemestersTable from "./components/semestersTable.jsx";
import MajorRequirements from "./components/major_requirements.jsx";

function App() {
  const initialSemesters = [
    { name: "Fall 1st Year", courses: [null, null, null, null] },
    { name: "Spring 1st Year", courses: [null, null, null, null] },
    { name: "Fall 2nd Year", courses: [null, null, null, null] },
    { name: "Spring 2nd Year", courses: [null, null, null, null] },
    { name: "Fall 3rd Year", courses: [null, null, null, null] },
    { name: "Spring 3rd Year", courses: [null, null, null, null] },
    { name: "Fall 4th Year", courses: [null, null, null, null] },
    { name: "Spring 4th Year", courses: [null, null, null, null] },
  ];

  function getFreshSemesters() {
    return initialSemesters.map((semester) => ({
      ...semester,
      courses: [...semester.courses],
    }));
  }

  const [semesters, setSemesters] = useState(getFreshSemesters());
  const [checkedSemesters, setCheckedSemesters] = useState(null);
  const [warningMessage, setWarningMessage] = useState("");
  const [majors, setMajors] = useState([]);
  const [selectedMajorCode, setSelectedMajorCode] = useState("CSC");
  const [coursesData, setCoursesData] = useState(null);
  const [majorRequirements, setMajorRequirements] = useState(null);
  const [loadError, setLoadError] = useState("");
  // Stores the user's explicit choice for each or_group: { [parentCode]: chosenChildCode }
  const [orGroupSelections, setOrGroupSelections] = useState({});

  useEffect(() => {
    async function loadPlannerData() {
      try {
        const [coursesResponse, majorsResponse] = await Promise.all([
          fetch("/api/courses"),
          fetch("/api/majors"),
        ]);

        if (!coursesResponse.ok || !majorsResponse.ok) {
          throw new Error("Could not load planner data from SQL.");
        }

        const [courses, majorsList] = await Promise.all([
          coursesResponse.json(),
          majorsResponse.json(),
        ]);

        setCoursesData(courses);
        setMajors(majorsList.majors);
      } catch (error) {
        setLoadError(error.message);
      }
    }

    loadPlannerData();
  }, []);

  useEffect(() => {
    async function loadMajorRequirements() {
      try {
        setLoadError("");
        setMajorRequirements(null);

        const requirementsResponse = await fetch(
          `/api/majors/${selectedMajorCode}/requirements`,
        );

        if (!requirementsResponse.ok) {
          throw new Error("Could not load major requirements from SQL.");
        }

        setMajorRequirements(await requirementsResponse.json());
      } catch (error) {
        setLoadError(error.message);
      }
    }

    loadMajorRequirements();
  }, [selectedMajorCode]);

  function normalizeCourse(course) {
    return course
      ? course.toUpperCase().replaceAll("-", "").replaceAll(" ", "")
      : "";
  }

  const courseMap = useMemo(() => {
    const map = {};

    for (const course of coursesData?.courses || []) {
      map[normalizeCourse(course.code)] = course;
      map[normalizeCourse(course.id)] = course;
    }

    return map;
  }, [coursesData]);

  const majorCourseOptions = useMemo(() => {
    if (!coursesData || !majorRequirements) return [];

    const allowedCodes = new Set();

    for (const block of majorRequirements.blocks || []) {
      for (const code of block.courseCodes || []) {
        allowedCodes.add(normalizeCourse(code));
      }
    }

    return coursesData.courses
      .filter((course) => allowedCodes.has(normalizeCourse(course.code)))
      .sort((first, second) => first.id.localeCompare(second.id));
  }, [coursesData, majorRequirements]);

  function getTermFromSemesterName(name) {
    return name.includes("Fall") ? "Fall" : "Spring";
  }

  function getCompletedBeforeSemester(plan, semesterIndex) {
    const completed = new Set();

    for (let i = 0; i < semesterIndex; i++) {
      for (const course of plan[i].courses) {
        if (course) {
          completed.add(normalizeCourse(course));
        }
      }
    }

    return completed;
  }

  function getCoursesInSemester(plan, semesterIndex) {
    return new Set(plan[semesterIndex].courses.filter(Boolean).map(normalizeCourse));
  }

  function isCourseAlreadyPlanned(plan, code) {
    const normalized = normalizeCourse(code);

    return plan.some((semester) =>
      semester.courses.some(
        (course) => course && normalizeCourse(course) === normalized,
      ),
    );
  }

  function getCourseNumber(code) {
    const match = normalizeCourse(code).match(/\d+/);
    return match ? parseInt(match[0], 10) : 0;
  }

  function getPreferredSemesterIndex(code) {
    const number = getCourseNumber(code);

    if (selectedMajorCode === "ANTH") {
      if (code === "ANT104") return 0;
      if (code === "SST115" || code === "STA209") return 1;
      if (code.startsWith("ANT") && number >= 200 && number < 280) return 2;
      if (code === "ANT280") return 3;
      if (["ANT265", "ANT290", "ANT291", "ANT292", "ANT293"].includes(code)) {
        return 3;
      }
      if (code.startsWith("ANT") && number >= 300 && number < 400) return 5;
      if (code === "ANT499") return 6;
    }

    if (number >= 400) return 6;
    if (number >= 300) return 4;
    if (number >= 200) return 2;
    return 0;
  }

  function getSequenceScore(code, semesterIndex) {
    const preferred = getPreferredSemesterIndex(code);
    const number = getCourseNumber(code);

    if (semesterIndex < preferred) {
      return 1000 + (preferred - semesterIndex) * 100 + number;
    }

    return Math.abs(semesterIndex - preferred) * 10 + number / 1000;
  }

  function getBestSequencedOption(options, semesterIndex) {
    const sortedOptions = [...options].sort((first, second) => {
      return (
        getSequenceScore(first.code, semesterIndex) -
        getSequenceScore(second.code, semesterIndex)
      );
    });

    const bestScore = getSequenceScore(sortedOptions[0].code, semesterIndex);
    const nearBestOptions = sortedOptions.filter((option) => {
      return getSequenceScore(option.code, semesterIndex) <= bestScore + 10;
    });

    return nearBestOptions[Math.floor(Math.random() * nearBestOptions.length)];
  }

  function countPriorCoursesMatchingRule(completedBefore, rule) {
    if (!rule?.minPriorCoursesDept) return 0;

    return Array.from(completedBefore).filter((code) => {
      if (!code.startsWith(rule.minPriorCoursesDept)) return false;

      const number = getCourseNumber(code);
      if (
        rule.minPriorCoursesMinNumber !== null &&
        number < rule.minPriorCoursesMinNumber
      ) {
        return false;
      }

      if (
        rule.minPriorCoursesMaxNumber !== null &&
        number > rule.minPriorCoursesMaxNumber
      ) {
        return false;
      }

      return true;
    }).length;
  }

  function canPlaceCourse(plan, semesterIndex, code) {
    const normalizedCode = normalizeCourse(code);
    const course = courseMap[normalizedCode];
    if (!course) return false;

    const term = getTermFromSemesterName(plan[semesterIndex].name);
    const completedBefore = getCompletedBeforeSemester(plan, semesterIndex);
    const currentSemester = getCoursesInSemester(plan, semesterIndex);

    if (isCourseAlreadyPlanned(plan, normalizedCode)) return false;
    if (course.offered?.length && !course.offered.includes(term)) return false;

    const rule = course.registrationRule;
    if (
      rule?.minSemesterIndex !== null &&
      rule?.minSemesterIndex !== undefined &&
      semesterIndex < rule.minSemesterIndex
    ) {
      return false;
    }

    if (
      rule?.minPriorCoursesCount &&
      countPriorCoursesMatchingRule(completedBefore, rule) <
        rule.minPriorCoursesCount
    ) {
      return false;
    }

    const isFirstYear = semesterIndex <= 1;
    const currentSemesterCourses = plan[semesterIndex].courses
      .filter(Boolean)
      .map(normalizeCourse);

    const dept = normalizedCode.match(/^[A-Z]+/)?.[0] ?? "";
    const sameDeptCourses = currentSemesterCourses.filter(
      (c) => c.match(/^[A-Z]+/)?.[0] === dept,
    );

    if (isFirstYear) {
      // First year: max 1 per dept. Exception: CSC-208 may share a semester
      // with one other CSC course (e.g. CSC-161 + CSC-208 in Spring 1st Year).
      if (normalizedCode.startsWith("CSC")) {
        const has208Already = sameDeptCourses.includes("CSC208");
        const isAdding208 = normalizedCode === "CSC208";
        if (has208Already || isAdding208) {
          if (sameDeptCourses.length >= 2) return false;
        } else {
          if (sameDeptCourses.length >= 1) return false;
        }
      } else {
        if (sameDeptCourses.length >= 1) return false;
      }
    } else {
      if (sameDeptCourses.length >= 2) return false;
    }
    const prereqGroups = course.prerequisiteGroups || [];

    // Level-based guardrail: prevent ungated courses from appearing too early.
    // Only applies when no explicit prerequisites and no explicit min_semester_index.
    const hasExplicitMinSemester =
      rule?.minSemesterIndex !== null && rule?.minSemesterIndex !== undefined;
    if (prereqGroups.length === 0 && !hasExplicitMinSemester) {
      const courseNum = getCourseNumber(normalizedCode);
      if (courseNum >= 300 && semesterIndex < 4) return false;
      if (courseNum >= 200 && semesterIndex < 2) return false;
    }

    for (const group of prereqGroups) {
      const isSatisfied = group.options.some((prereq) => {
        const normalizedPrereq = normalizeCourse(prereq);
        return (
          completedBefore.has(normalizedPrereq) ||
          (group.canBeCorequisite && currentSemester.has(normalizedPrereq))
        );
      });

      if (!isSatisfied) {
        return false;
      }
    }

    return true;
  }

  function getPlacementError(plan, semesterIndex, code) {
    const normalizedCode = normalizeCourse(code);
    const course = courseMap[normalizedCode];

    if (!course) return "";

    const term = getTermFromSemesterName(plan[semesterIndex].name);
    const completedBefore = getCompletedBeforeSemester(plan, semesterIndex);
    const currentSemester = getCoursesInSemester(plan, semesterIndex);

    if (isCourseAlreadyPlanned(plan, normalizedCode)) {
      return `${course.id} is already in the plan.`;
    }

    if (course.offered?.length && !course.offered.includes(term)) {
      return `${course.id} is not offered in ${term}.`;
    }

    const rule = course.registrationRule;
    if (
      rule?.minSemesterIndex !== null &&
      rule?.minSemesterIndex !== undefined &&
      semesterIndex < rule.minSemesterIndex
    ) {
      return `${course.id} requires ${rule.notes || "later class standing"}.`;
    }

    if (
      rule?.minPriorCoursesCount &&
      countPriorCoursesMatchingRule(completedBefore, rule) <
        rule.minPriorCoursesCount
    ) {
      return `${course.id} requires ${rule.notes || "more prior coursework"}.`;
    }

    const prereqGroups = course.prerequisiteGroups || [];
    for (const group of prereqGroups) {
      const isSatisfied = group.options.some((prereq) => {
        const normalizedPrereq = normalizeCourse(prereq);
        return (
          completedBefore.has(normalizedPrereq) ||
          (group.canBeCorequisite && currentSemester.has(normalizedPrereq))
        );
      });

      if (!isSatisfied) {
        const options = group.options.join(" or ");
        const timing = group.canBeCorequisite
          ? "before or with"
          : "before";
        return `${course.id} requires ${options} ${timing} this course.`;
      }
    }

    return "";
  }

  function handleManualCourseSelect(semesterIndex, courseIndex, newCourse) {
    const updated = semesters.map((semester) => ({
      ...semester,
      courses: [...semester.courses],
    }));

    updated[semesterIndex].courses[courseIndex] = null;

    const normalized = normalizeCourse(newCourse);
    const knownCourse = courseMap[normalized];

    if (knownCourse) {
      const error = getPlacementError(updated, semesterIndex, normalized);

      if (error) {
        setWarningMessage(error);
        return false;
      }
    }

    updated[semesterIndex].courses[courseIndex] = newCourse.toUpperCase();
    setSemesters(updated);
    setWarningMessage("");
    return true;
  }

  function resetPlan() {
    setSemesters(getFreshSemesters());
    setCheckedSemesters(null);
    setWarningMessage("");
  }

  function checkPlan() {
    setCheckedSemesters(
      semesters.map((semester) => ({
        ...semester,
        courses: [...semester.courses],
      })),
    );
    setWarningMessage("");
  }

  function getValidElectives(alreadyTaken) {
    if (!majorRequirements || !coursesData) return [];

    const electiveReq = majorRequirements.requirements.electives;
    if (!electiveReq) return [];

    return coursesData.courses.filter((course) => {
      const normalized = normalizeCourse(course.code);
      const number = parseInt(normalized.replace(/\D/g, ""), 10);

      if (alreadyTaken.has(normalized)) return false;

      const hasAllowedPrefix = electiveReq.allowedPrefixes.some((prefix) =>
        normalized.startsWith(prefix),
      );
      if (!hasAllowedPrefix) return false;

      if (number < electiveReq.minLevel) return false;

      const excluded = electiveReq.excludedCourses.map(normalizeCourse);
      if (excluded.includes(normalized)) return false;

      return true;
    });
  }

  function getGeneralFillerCourses(plan) {
    const alreadyTaken = new Set(
      plan
        .flatMap((semester) => semester.courses)
        .filter(Boolean)
        .map(normalizeCourse),
    );
    const majorCodes = new Set(
      (majorRequirements?.blocks || []).flatMap((block) =>
        block.courseCodes.map(normalizeCourse),
      ),
    );

    const specialSuffixes = [397, 398, 399, 495, 499];

    return (coursesData?.courses || []).filter((course) => {
      const normalized = normalizeCourse(course.code);
      if (alreadyTaken.has(normalized)) return false;
      if (majorCodes.has(normalized)) return false;
      const num = getCourseNumber(course.code);
      if (specialSuffixes.includes(num)) return false;
      return true;
    });
  }

  function buildRemainingRequirements(alreadyTaken) {
    if (!majorRequirements) {
      return { remainingSingles: [], remainingGroups: [] };
    }

    const remainingSingles = [];
    const remainingGroups = [];

    // For each or_group, use the student's explicit selection.
    // Fall back to the first child if no selection has been made yet.
    const chosenOrChild = {};
    for (const block of majorRequirements.blocks || []) {
      if (block.ruleType !== "or_group" || !block.orChildCodes?.length) continue;
      const childBlocks = (majorRequirements.blocks || []).filter((b) =>
        block.orChildCodes.includes(b.code),
      );
      const explicitChoice = orGroupSelections[block.code];
      if (explicitChoice && childBlocks.some((c) => c.code === explicitChoice)) {
        chosenOrChild[block.code] = explicitChoice;
      } else {
        chosenOrChild[block.code] = childBlocks[0]?.code;
      }
    }

    for (const block of majorRequirements.blocks || []) {
      const normalizedValues = block.courseCodes.map(normalizeCourse);
      if (normalizedValues.length === 0) continue;

      // Skip or_group parent blocks — their chosen child handles the work
      if (block.ruleType === "or_group") continue;

      // For or_group children: only process the chosen one, skip the rest
      if (block.orParentCode) {
        if (chosenOrChild[block.orParentCode] !== block.code) continue;
        // Check if the chosen child is already fully satisfied — if so, skip it too
        const needed = block.minCount || 1;
        const taken = normalizedValues.filter((c) => alreadyTaken.has(c)).length;
        if (taken >= needed) continue;
      }

      if (block.ruleType === "must_take") {
        for (const code of normalizedValues) {
          if (!alreadyTaken.has(code)) {
            remainingSingles.push(code);
          }
        }
      }

      if (["choose_one", "choose_n"].includes(block.ruleType)) {
        const alreadySatisfied = normalizedValues.some((code) =>
          alreadyTaken.has(code),
        );

        if (!alreadySatisfied) {
          remainingGroups.push({
            needed: block.minCount || 1,
            neededCredits: null,
            codes: normalizedValues,
          });
        }
      }

      if (block.ruleType === "choose_credits") {
        const completedCredits = normalizedValues.reduce((total, code) => {
          if (!alreadyTaken.has(code)) return total;
          return total + (courseMap[code]?.credits || 0);
        }, 0);

        if (completedCredits < (block.minCredits || 0)) {
          remainingGroups.push({
            needed: null,
            neededCredits: (block.minCredits || 0) - completedCredits,
            codes: normalizedValues.filter((code) => !alreadyTaken.has(code)),
          });
        }
      }

      if (block.ruleType === "custom") {
        if ((block.minCredits || 0) > 0) {
          const completedCredits = normalizedValues.reduce((total, code) => {
            if (!alreadyTaken.has(code)) return total;
            return total + (courseMap[code]?.credits || 0);
          }, 0);
          if (completedCredits < block.minCredits) {
            remainingGroups.push({
              needed: null,
              neededCredits: block.minCredits - completedCredits,
              codes: normalizedValues.filter((code) => !alreadyTaken.has(code)),
            });
          }
        } else if ((block.minCount || 0) > 0) {
          const takenCount = normalizedValues.filter((code) =>
            alreadyTaken.has(code),
          ).length;
          if (takenCount < block.minCount) {
            remainingGroups.push({
              needed: block.minCount - takenCount,
              neededCredits: null,
              codes: normalizedValues.filter((code) => !alreadyTaken.has(code)),
            });
          }
        }
      }
    }

    return { remainingSingles, remainingGroups };
  }

  function autoFillPlan() {
    if (!majorRequirements || !coursesData) return;

    const updated = semesters.map((semester) => ({
      ...semester,
      courses: [...semester.courses],
    }));

    const alreadyTaken = new Set(
      updated
        .flatMap((semester) => semester.courses)
        .filter(Boolean)
        .map(normalizeCourse),
    );

    const { remainingSingles, remainingGroups } =
      buildRemainingRequirements(alreadyTaken);

    // TUT-100 is a universal Grinnell requirement for all first-year students.
    // Inject it at the front of remainingSingles so Pass 1 places it first.
    const tutCode = normalizeCourse("TUT 100");
    if (!alreadyTaken.has(tutCode) && courseMap[tutCode]) {
      remainingSingles.unshift(tutCode);
    }

    // Pass 1: required courses only — repeat until no more can be placed.
    // The while loop handles prerequisite chains: placing CSC-151 unlocks
    // CSC-161 in the next round, which unlocks CSC-207, etc.
    let madeProgress = true;
    while (madeProgress) {
      madeProgress = false;
      for (
        let semesterIndex = 0;
        semesterIndex < updated.length;
        semesterIndex++
      ) {
        for (
          let slotIndex = 0;
          slotIndex < updated[semesterIndex].courses.length;
          slotIndex++
        ) {
          if (updated[semesterIndex].courses[slotIndex]) continue;

          const validOptions = [];

          for (const code of remainingSingles) {
            if (canPlaceCourse(updated, semesterIndex, code)) {
              validOptions.push({ type: "single", code });
            }
          }

          for (
            let groupIndex = 0;
            groupIndex < remainingGroups.length;
            groupIndex++
          ) {
            for (const code of remainingGroups[groupIndex].codes) {
              if (canPlaceCourse(updated, semesterIndex, code)) {
                validOptions.push({ type: "group", code, groupIndex });
              }
            }
          }

          if (validOptions.length === 0) continue;

          const choice = getBestSequencedOption(validOptions, semesterIndex);
          updated[semesterIndex].courses[slotIndex] = courseMap[choice.code].id;
          madeProgress = true;

          if (choice.type === "single") {
            const indexToRemove = remainingSingles.indexOf(choice.code);
            if (indexToRemove !== -1) {
              remainingSingles.splice(indexToRemove, 1);
            }
          } else {
            const group = remainingGroups[choice.groupIndex];
            if (group.neededCredits !== null) {
              group.neededCredits -= courseMap[choice.code]?.credits || 0;
            } else {
              group.needed -= 1;
            }
            group.codes = group.codes.filter((code) => code !== choice.code);
            if (
              (group.needed !== null && group.needed <= 0) ||
              (group.neededCredits !== null && group.neededCredits <= 0) ||
              group.codes.length === 0
            ) {
              remainingGroups.splice(choice.groupIndex, 1);
            }
          }
        }
      }
    }

    // Pass 2: electives — recalculate pool so it excludes anything placed in pass 1.
    const takenAfterRequired = new Set(
      updated.flatMap((s) => s.courses).filter(Boolean).map(normalizeCourse),
    );
    let electivePool = getValidElectives(takenAfterRequired);

    for (
      let semesterIndex = 0;
      semesterIndex < updated.length;
      semesterIndex++
    ) {
      for (
        let slotIndex = 0;
        slotIndex < updated[semesterIndex].courses.length;
        slotIndex++
      ) {
        if (updated[semesterIndex].courses[slotIndex]) continue;

        const electives = electivePool.filter((course) =>
          canPlaceCourse(updated, semesterIndex, course.code),
        );

        if (electives.length === 0) continue;

        const choice = getBestSequencedOption(
          electives.map((course) => ({ code: course.code, course })),
          semesterIndex,
        ).course;
        updated[semesterIndex].courses[slotIndex] = choice.id;

        const indexToRemove = electivePool.findIndex(
          (course) =>
            normalizeCourse(course.code) === normalizeCourse(choice.code),
        );
        if (indexToRemove !== -1) {
          electivePool.splice(indexToRemove, 1);
        }
      }
    }

    // Pass 3: fill remaining empty slots with any valid course.
    for (
      let semesterIndex = 0;
      semesterIndex < updated.length;
      semesterIndex++
    ) {
      for (
        let slotIndex = 0;
        slotIndex < updated[semesterIndex].courses.length;
        slotIndex++
      ) {
        if (updated[semesterIndex].courses[slotIndex]) continue;

        const fillerCourses = getGeneralFillerCourses(updated).filter(
          (course) => canPlaceCourse(updated, semesterIndex, course.code),
        );

        if (fillerCourses.length === 0) continue;

        const choice =
          fillerCourses[Math.floor(Math.random() * fillerCourses.length)];
        updated[semesterIndex].courses[slotIndex] = choice.id;
      }
    }

    setSemesters(updated);
    setCheckedSemesters(null);
  }

  return (
    <div className="app">
      {/* Header bar */}
      <header
        style={{
          width: "100%",
          backgroundColor: "#cc0033",
          display: "flex",
          alignItems: "center",
          padding: "0 32px",
          height: "64px",
          boxSizing: "border-box",
          boxShadow: "0 2px 8px rgba(0,0,0,0.18)",
        }}
      >
        <img
          src="/src/assets/grinnell-logo.png"
          alt="Grinnell College logo"
          style={{
            height: "42px",
            width: "auto",
            flexShrink: 0,
            marginRight: "14px",
            filter: "brightness(0) invert(1)",
          }}
        />
        <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.2 }}>
          <span
            style={{
              color: "white",
              fontWeight: "700",
              fontSize: "17px",
              fontFamily: "Georgia, serif",
              letterSpacing: "0.3px",
            }}
          >
            Grinnell College
          </span>
          <span
            style={{
              color: "rgba(255,255,255,0.75)",
              fontSize: "12px",
              letterSpacing: "0.5px",
              textTransform: "uppercase",
            }}
          >
            4-Year Planner
          </span>
        </div>
      </header>

      {/* Campus banner image */}
      <div style={{ width: "100%", lineHeight: 0 }}>
        <img
          src="/src/assets/grinnell-campus.jpg"
          alt="Grinnell College campus"
          style={{
            width: "100%",
            height: "220px",
            objectFit: "cover",
            objectPosition: "center 65%",
            display: "block",
          }}
        />
      </div>

      <div className="controls-bar">
        <label className="major-label">
          Major
          <select
            className="major-select"
            value={selectedMajorCode}
            onChange={(event) => {
              setSelectedMajorCode(event.target.value);
              resetPlan();
              setCheckedSemesters(null);
              setOrGroupSelections({});
            }}
          >
            {majors.map((major) => (
              <option key={major.code} value={major.code}>
                {major.name}
              </option>
            ))}
          </select>
        </label>

        <button className="btn btn-primary" onClick={autoFillPlan}>
          Auto-Fill Remaining Plan
        </button>

        <button className="btn btn-secondary" onClick={checkPlan}>
          Check Requirements
        </button>

        <button className="btn btn-neutral" onClick={resetPlan}>
          Reset Plan
        </button>
      </div>

      {/* Sequence selector — shown only when the major has or_group blocks */}
      {majorRequirements && (majorRequirements.blocks || []).some((b) => b.ruleType === "or_group") && (
        <div style={{ padding: "0 32px 16px", display: "flex", flexDirection: "column", gap: "10px" }}>
          {(majorRequirements.blocks || [])
            .filter((b) => b.ruleType === "or_group" && b.orChildCodes?.length)
            .map((orBlock) => {
              const childBlocks = (majorRequirements.blocks || []).filter((b) =>
                orBlock.orChildCodes.includes(b.code),
              );
              const selected = orGroupSelections[orBlock.code] || childBlocks[0]?.code;
              return (
                <div key={orBlock.code} style={{ display: "flex", alignItems: "center", gap: "8px", flexWrap: "wrap" }}>
                  <span style={{ fontSize: "13px", fontWeight: 600, color: "#374151" }}>
                    {orBlock.title}:
                  </span>
                  {childBlocks.map((child) => {
                    const isSelected = selected === child.code;
                    const label = child.title.replace(/^Sequence ([A-Z]):.*/, "Sequence $1");
                    return (
                      <button
                        key={child.code}
                        onClick={() => setOrGroupSelections((prev) => ({ ...prev, [orBlock.code]: child.code }))}
                        style={{
                          padding: "5px 14px",
                          borderRadius: "7px",
                          fontSize: "13px",
                          fontWeight: 600,
                          cursor: "pointer",
                          border: isSelected ? "none" : "1.5px solid #e5e7eb",
                          backgroundColor: isSelected ? "#cc0033" : "white",
                          color: isSelected ? "white" : "#6b7280",
                          transition: "all 0.15s ease",
                          boxShadow: isSelected ? "0 1px 3px rgba(204,0,51,0.25)" : "none",
                        }}
                      >
                        {label}
                      </button>
                    );
                  })}
                </div>
              );
            })}
        </div>
      )}

      <div className="app-alerts">
        {warningMessage && (
          <div
            style={{
              marginBottom: "16px",
              padding: "12px 16px",
              borderRadius: "8px",
              backgroundColor: "#fff3cd",
              border: "1px solid #ffe69c",
              color: "#856404",
              fontWeight: "500",
            }}
          >
            {warningMessage}
          </div>
        )}

        {loadError && (
          <div
            style={{
              marginBottom: "16px",
              padding: "12px 16px",
              borderRadius: "8px",
              backgroundColor: "#f8d7da",
              border: "1px solid #f5c2c7",
              color: "#842029",
              fontWeight: "500",
            }}
          >
            {loadError}
          </div>
        )}

        {!loadError && (!coursesData || !majorRequirements) && (
          <p style={{ color: "#6b7280" }}>Loading planner data…</p>
        )}
      </div>

      {coursesData && majorRequirements && (
        <>
          <SemestersTable
            semesters={semesters}
            onCourseSelect={handleManualCourseSelect}
            courseOptions={coursesData?.courses || []}
          />
          <MajorRequirements
            semesters={checkedSemesters}
            coursesData={coursesData}
            majorRequirements={majorRequirements}
          />
        </>
      )}
    </div>
  );
}

export default App;
