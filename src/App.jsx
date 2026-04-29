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

  function countCSCoursesInSemester(semester) {
    return semester.courses.filter(
      (course) => course && normalizeCourse(course).startsWith("CSC"),
    ).length;
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
    const cscCount = countCSCoursesInSemester(plan[semesterIndex]);

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

    const isFirstTwoYears = semesterIndex <= 3;
    const currentSemesterCourses = plan[semesterIndex].courses
      .filter(Boolean)
      .map(normalizeCourse);

    const currentCSCourses = currentSemesterCourses.filter((course) =>
      course.startsWith("CSC"),
    );

    if (normalizedCode.startsWith("CSC")) {
      if (isFirstTwoYears) {
        const has208Already = currentCSCourses.includes("CSC208");
        const isAdding208 = normalizedCode === "CSC208";

        if (has208Already || isAdding208) {
          if (currentCSCourses.length >= 2) {
            return false;
          }
        } else {
          if (currentCSCourses.length >= 1) {
            return false;
          }
        }
      } else {
        if (cscCount >= 2) {
          return false;
        }
      }
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

    return (coursesData?.courses || [])
      .filter((course) => {
        const normalized = normalizeCourse(course.code);
        if (alreadyTaken.has(normalized)) return false;
        if (majorCodes.has(normalized)) return false;

        const number = getCourseNumber(normalized);
        return number >= 100 && number < 200;
      })
      .sort((first, second) => first.id.localeCompare(second.id));
  }

  function buildRemainingRequirements(alreadyTaken) {
    if (!majorRequirements) {
      return { remainingSingles: [], remainingGroups: [] };
    }

    const remainingSingles = [];
    const remainingGroups = [];

    for (const block of majorRequirements.blocks || []) {
      const normalizedValues = block.courseCodes.map(normalizeCourse);
      if (normalizedValues.length === 0) continue;

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

    let electivePool = getValidElectives(alreadyTaken);
    const maxSlots = Math.max(
      ...updated.map((semester) => semester.courses.length),
    );

    for (let slotIndex = 0; slotIndex < maxSlots; slotIndex++) {
      for (
        let semesterIndex = 0;
        semesterIndex < updated.length;
        semesterIndex++
      ) {
        if (slotIndex >= updated[semesterIndex].courses.length) continue;
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

        if (validOptions.length > 0) {
          const choice = getBestSequencedOption(validOptions, semesterIndex);
          updated[semesterIndex].courses[slotIndex] = courseMap[choice.code].id;

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

          continue;
        }

        const electives = electivePool.filter((course) =>
          canPlaceCourse(updated, semesterIndex, course.code),
        );

        if (electives.length > 0) {
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

          continue;
        }

        const fillerCourses = getGeneralFillerCourses(updated).filter((course) =>
          canPlaceCourse(updated, semesterIndex, course.code),
        );

        if (fillerCourses.length > 0) {
          const choice = getBestSequencedOption(
            fillerCourses.map((course) => ({ code: course.code, course })),
            semesterIndex,
          ).course;
          updated[semesterIndex].courses[slotIndex] = choice.id;
        }
      }
    }

    setSemesters(updated);
    setCheckedSemesters(null);
  }

  return (
    <div className="app">
      <h1 style={{ color: "black" }}>Grinnell 4-Year Planner</h1>
      <p style={{ color: "black", marginTop: "10px" }}>
        Click any course slot to enter a class and see degree requirements
        update automatically.
      </p>

      <div
        style={{
          marginTop: "20px",
          marginBottom: "20px",
          display: "flex",
          gap: "12px",
          alignItems: "center",
          flexWrap: "wrap",
        }}
      >
        <label style={{ color: "black", fontWeight: "600" }}>
          Major{" "}
          <select
            value={selectedMajorCode}
            onChange={(event) => {
              setSelectedMajorCode(event.target.value);
              resetPlan();
              setCheckedSemesters(null);
            }}
            style={{
              border: "1px solid #bbb",
              borderRadius: "6px",
              padding: "10px",
              color: "black",
              backgroundColor: "white",
              fontSize: "16px",
            }}
          >
            {majors.map((major) => (
              <option key={major.code} value={major.code}>
                {major.name}
              </option>
            ))}
          </select>
        </label>

        <button
          onClick={autoFillPlan}
          style={{
            padding: "12px 20px",
            backgroundColor: "#cc0033",
            color: "white",
            border: "none",
            borderRadius: "8px",
            cursor: "pointer",
            fontSize: "16px",
          }}
        >
          Auto-Fill Remaining Plan
        </button>

        <button
          onClick={checkPlan}
          style={{
            padding: "12px 20px",
            backgroundColor: "#111",
            color: "white",
            border: "none",
            borderRadius: "8px",
            cursor: "pointer",
            fontSize: "16px",
          }}
        >
          Check Requirements
        </button>

        <button
          onClick={resetPlan}
          style={{
            padding: "12px 20px",
            backgroundColor: "#666",
            color: "white",
            border: "none",
            borderRadius: "8px",
            cursor: "pointer",
            fontSize: "16px",
          }}
        >
          Reset Plan
        </button>
      </div>

      {warningMessage && (
        <div
          style={{
            marginBottom: "20px",
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
            marginBottom: "20px",
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
        <p style={{ color: "black" }}>Loading planner data from SQL...</p>
      )}

      {coursesData && majorRequirements && (
        <>
          <SemestersTable
            semesters={semesters}
            onCourseSelect={handleManualCourseSelect}
            courseOptions={majorCourseOptions}
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
