import { useState } from "react";

function SemestersTable({ semesters, onCourseSelect, courseOptions }) {
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [selectedDept, setSelectedDept] = useState(null);

  const departments = [
    ...new Set(
      courseOptions
        .map((course) => course.code.match(/^[A-Z]+/)?.[0])
        .filter(Boolean),
    ),
  ].sort();

  const deptCourses = selectedDept
    ? courseOptions
        .filter((c) => c.code.match(/^[A-Z]+/)?.[0] === selectedDept)
        .sort((a, b) => a.id.localeCompare(b.id))
    : [];

  function handleSlotClick(semesterIndex, courseIndex) {
    setSelectedSlot({ semesterIndex, courseIndex });
    setSelectedDept(null);
  }

  function handleDeptChange(event) {
    setSelectedDept(event.target.value || null);
  }

  function handleCourseChange(event) {
    if (!selectedSlot) return;

    const newCourse = event.target.value;
    if (!newCourse) return;

    let chosenCourse = newCourse;

    if (newCourse === "__CUSTOM__") {
      const customCourse = prompt("Enter a custom course, like ENG-101:");
      if (!customCourse) {
        setSelectedSlot(null);
        setSelectedDept(null);
        return;
      }
      chosenCourse = customCourse.toUpperCase();
    }

    const wasPlaced = onCourseSelect(
      selectedSlot.semesterIndex,
      selectedSlot.courseIndex,
      chosenCourse,
    );

    if (wasPlaced) {
      setSelectedSlot(null);
      setSelectedDept(null);
    }
  }

  return (
    <div className="semesters-section">
      <h2>Full Course Plan</h2>

      <div className="semesters-grid">
        {semesters.map((semester, semesterIndex) => (
          <div key={semester.name} className="semester-card">
            <h3>{semester.name}</h3>

            {semester.courses.map((course, index) => {
              const isSelected =
                selectedSlot &&
                selectedSlot.semesterIndex === semesterIndex &&
                selectedSlot.courseIndex === index;

              return (
                <div key={index}>
                  {isSelected ? (
                    <div style={{ display: "flex", flexDirection: "column" }}>
                      <select
                        autoFocus
                        className="planner-select"
                        value={selectedDept || ""}
                        onChange={handleDeptChange}
                      >
                        <option value="">Select a department</option>
                        {departments.map((dept) => (
                          <option key={dept} value={dept}>
                            {dept}
                          </option>
                        ))}
                      </select>

                      {selectedDept && (
                        <select
                          autoFocus
                          className="planner-select"
                          onChange={handleCourseChange}
                          defaultValue=""
                        >
                          <option value="">Select a course</option>
                          {deptCourses.map((courseOption) => (
                            <option key={courseOption.code} value={courseOption.id}>
                              {courseOption.id} — {courseOption.name}
                            </option>
                          ))}
                          <option value="__CUSTOM__">Custom course...</option>
                        </select>
                      )}
                    </div>
                  ) : (
                    <div
                      className={course ? "course-slot" : "course-slot-empty"}
                      onClick={() => handleSlotClick(semesterIndex, index)}
                    >
                      {course || "+ Add course"}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}

export default SemestersTable;
