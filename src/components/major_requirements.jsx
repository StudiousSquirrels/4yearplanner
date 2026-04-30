import { useState } from "react";

function MajorRequirements({ semesters, coursesData, majorRequirements }) {
  const [collapsed, setCollapsed] = useState({});

  function normalizeCourse(course) {
    return course
      ? course.toUpperCase().replaceAll("-", "").replaceAll(" ", "")
      : "";
  }

  const checkedSemesters = semesters || [];
  const hasCheckedPlan = Boolean(semesters);

  const plannedCourses = new Set(
    checkedSemesters
      .flatMap((s) => s.courses)
      .filter(Boolean)
      .map(normalizeCourse),
  );

  const courseMap = {};
  for (const course of coursesData.courses) {
    courseMap[normalizeCourse(course.code)] = course;
    courseMap[normalizeCourse(course.id)] = course;
  }

  function getCourseNumber(code) {
    const match = normalizeCourse(code).match(/\d+/);
    return match ? parseInt(match[0], 10) : 0;
  }

  function getUsedRequiredCourses() {
    const used = new Set();
    for (const block of majorRequirements.blocks) {
      if (block.code === "CSC_ELECTIVE") continue;
      if (!["must_take", "choose_one", "choose_n"].includes(block.ruleType)) continue;
      if (block.ruleType === "must_take") {
        for (const code of block.courseCodes) {
          const n = normalizeCourse(code);
          if (plannedCourses.has(n)) used.add(n);
        }
      }
      if (block.ruleType === "choose_one") {
        const chosen = block.courseCodes.map(normalizeCourse).find((c) => plannedCourses.has(c));
        if (chosen) used.add(chosen);
      }
      if (block.ruleType === "choose_n") {
        for (const code of block.courseCodes.map(normalizeCourse)) {
          if (plannedCourses.has(code)) used.add(code);
        }
      }
    }
    return used;
  }

  function getBlockStatus(block) {
    const completedCourses = block.courseCodes.filter((c) =>
      plannedCourses.has(normalizeCourse(c)),
    );
    const completedCredits = completedCourses.reduce(
      (t, code) => t + (courseMap[normalizeCourse(code)]?.credits || 0),
      0,
    );

    if (block.code === "ANTH_FOUR_FIELDS") {
      const usedSubfields = new Set();
      const usedCourses = [];
      for (const code of plannedCourses) {
        const course = courseMap[code];
        if (!course || !code.startsWith("ANT") || getCourseNumber(code) < 200) continue;
        for (const sf of course.subfields || []) usedSubfields.add(sf);
        if (course.subfields?.length) usedCourses.push(code);
      }
      return { completed: usedSubfields.size >= 3, completedCourses: usedCourses, completedCredits: usedCourses.length * 4, detail: `${usedSubfields.size} / 3 subfields` };
    }

    if (block.code === "ANTH_ADV_PATH_B") {
      const hasThesis = plannedCourses.has("ANT499");
      const adv = Array.from(plannedCourses).filter((c) => c.startsWith("ANT") && getCourseNumber(c) >= 300);
      return { completed: hasThesis && adv.length >= 1, completedCourses: [...adv, ...(hasThesis ? ["ANT499"] : [])], completedCredits: adv.length * 4 + (hasThesis ? 4 : 0) };
    }

    if (block.code === "CSC_ELECTIVE") {
      const requiredCodes = getUsedRequiredCourses();
      const usedElectives = [];
      let credits = 0;
      for (const code of plannedCourses) {
        const course = courseMap[code];
        if (!course || !code.startsWith("CSC")) continue;
        if (requiredCodes.has(code) || ["CSC281", "CSC282"].includes(code) || getCourseNumber(code) < 200) continue;
        credits += code === "CSC326" ? Math.min(course.credits || 0, 2) : course.credits || 0;
        usedElectives.push(code);
      }
      const sys = ["CSC211", "CSC213"].filter((c) => plannedCourses.has(c));
      if (sys.length === 2) {
        const extra = sys.find((c) => !usedElectives.includes(c));
        if (extra) { credits += courseMap[extra]?.credits || 0; usedElectives.push(extra); }
      }
      return { completed: credits >= (block.minCredits || 4), completedCourses: usedElectives, completedCredits: credits, detail: `${credits} / ${block.minCredits || 4} cr` };
    }

    if (block.code === "CSC_MATH_ELECTIVE") {
      const used = Array.from(plannedCourses).filter(
        (c) => (c.startsWith("MAT") && getCourseNumber(c) > 131) || c.startsWith("STA"),
      );
      return { completed: used.length >= 1, completedCourses: used, completedCredits: used.reduce((t, c) => t + (courseMap[c]?.credits || 0), 0) };
    }

    if (block.code === "CSC_TOTALS_AND_POLICIES") {
      const used = Array.from(plannedCourses).filter(
        (c) => (c.startsWith("CSC") && getCourseNumber(c) >= 151) || ["MAT208", "MAT218"].includes(c),
      );
      const credits = used.reduce((t, c) => t + (courseMap[c]?.credits || 0), 0);
      return { completed: credits >= (block.minCredits || 32), completedCourses: used, completedCredits: credits, detail: `${credits} / ${block.minCredits || 32} cr` };
    }

    if (block.ruleType === "must_take") return { completed: block.courseCodes.length > 0 && completedCourses.length === block.courseCodes.length, completedCourses, completedCredits };
    if (block.ruleType === "choose_one") return { completed: completedCourses.length >= 1, completedCourses, completedCredits };
    if (block.ruleType === "choose_n") return { completed: completedCourses.length >= (block.minCount || 1), completedCourses, completedCredits };
    if (block.ruleType === "choose_credits") return { completed: completedCredits >= (block.minCredits || 0), completedCourses, completedCredits };
    return { completed: false, completedCourses, completedCredits };
  }

  function getRuleLabel(block) {
    if (block.ruleType === "must_take") return "Required";
    if (block.ruleType === "choose_one") return "Choose 1";
    if (block.ruleType === "choose_n") return `Choose ${block.minCount || 1}`;
    if (block.ruleType === "choose_credits") return `${block.minCredits || 0} credits`;
    if (block.ruleType === "or_group") return "One path";
    return "See notes";
  }

  const canAutoCheckCodes = new Set([
    "ANTH_FOUR_FIELDS", "ANTH_ADV_PATH_B",
    "CSC_ELECTIVE", "CSC_MATH_ELECTIVE", "CSC_TOTALS_AND_POLICIES",
  ]);

  const blocks = majorRequirements.blocks.map((block) => {
    const status = getBlockStatus(block);
    const canAutoCheck =
      ["must_take", "choose_one", "choose_n", "choose_credits"].includes(block.ruleType) ||
      canAutoCheckCodes.has(block.code);
    const completed = canAutoCheck && status.completed;
    return { block, status, canAutoCheck, completed };
  });

  const completedCount = blocks.filter((b) => b.completed).length;
  const total = blocks.length;
  const pct = total ? Math.round((completedCount / total) * 100) : 0;

  return (
    <div style={{ marginTop: "40px", textAlign: "left" }}>

      {/* ── Header ── */}
      <div style={{
        background: "white",
        border: "1px solid #e5e7eb",
        borderRadius: "12px",
        padding: "18px 22px 16px",
        marginBottom: "20px",
        boxShadow: "0 1px 3px rgba(0,0,0,0.06)",
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
          <div>
            <h2 style={{ margin: 0, fontSize: "17px", fontWeight: 700, color: "#111", letterSpacing: "-0.2px" }}>
              {majorRequirements.major.name} Requirements
            </h2>
            <p style={{ margin: "3px 0 0", fontSize: "13px", color: "#6b7280" }}>
              {majorRequirements.major.description}
            </p>
          </div>

          <div style={{
            flexShrink: 0,
            padding: "5px 12px",
            borderRadius: "999px",
            fontSize: "13px",
            fontWeight: 700,
            backgroundColor: !hasCheckedPlan ? "#f3f4f6" : completedCount === total ? "#dcfce7" : "#fee2e2",
            color: !hasCheckedPlan ? "#9ca3af" : completedCount === total ? "#15803d" : "#b91c1c",
            border: `1px solid ${!hasCheckedPlan ? "#e5e7eb" : completedCount === total ? "#86efac" : "#fca5a5"}`,
          }}>
            {completedCount} / {total}
          </div>
        </div>

        <div style={{ marginTop: "12px", height: "5px", borderRadius: "999px", backgroundColor: "#f1f5f9", overflow: "hidden" }}>
          <div style={{
            height: "100%", borderRadius: "999px",
            width: `${hasCheckedPlan ? pct : 0}%`,
            backgroundColor: completedCount === total ? "#16a34a" : "#cc0033",
            transition: "width 0.4s ease",
          }} />
        </div>

        {!hasCheckedPlan && (
          <p style={{ margin: "8px 0 0", fontSize: "12px", color: "#9ca3af", fontStyle: "italic" }}>
            Add courses and click Check Requirements to see your progress.
          </p>
        )}
      </div>

      {/* ── Tree ── */}
      <div style={{ position: "relative", paddingLeft: "32px" }}>

        {/* Vertical spine */}
        <div style={{
          position: "absolute", left: "10px", top: "8px", bottom: "20px",
          width: "2px", backgroundColor: "#e5e7eb", borderRadius: "1px",
        }} />

        {blocks.map(({ block, status, canAutoCheck, completed }, idx) => {
          const isOpen = collapsed[block.code] !== true;
          const hasCourses = block.courseCodes.length > 0;

          const dotColor = !hasCheckedPlan || !canAutoCheck
            ? "#d1d5db"
            : completed ? "#16a34a" : "#ef4444";

          const borderColor = !hasCheckedPlan || !canAutoCheck
            ? "#e5e7eb"
            : completed ? "#bbf7d0" : "#fecaca";

          const rowBg = !hasCheckedPlan || !canAutoCheck
            ? "#fafafa"
            : completed ? "#f0fdf4" : "#fff5f5";

          return (
            <div key={block.code} style={{ position: "relative", marginBottom: "6px" }}>

              {/* Connector tick */}
              <div style={{
                position: "absolute", left: "-22px", top: "18px",
                width: "14px", height: "2px", backgroundColor: "#e5e7eb",
              }} />

              {/* Status dot */}
              <div style={{
                position: "absolute", left: "-28px", top: "12px",
                width: "13px", height: "13px", borderRadius: "50%",
                backgroundColor: dotColor,
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: "8px", fontWeight: 700, color: "white",
                boxShadow: "0 0 0 3px white",
                zIndex: 1,
              }}>
                {hasCheckedPlan && canAutoCheck && (completed ? "✓" : "")}
              </div>

              {/* Block row */}
              <div
                onClick={() => hasCourses && setCollapsed((p) => ({ ...p, [block.code]: !p[block.code] }))}
                style={{
                  display: "flex", alignItems: "center", gap: "8px",
                  padding: "9px 13px",
                  borderRadius: "9px",
                  border: `1px solid ${borderColor}`,
                  backgroundColor: rowBg,
                  cursor: hasCourses ? "pointer" : "default",
                  userSelect: "none",
                  borderLeft: `3px solid ${dotColor}`,
                  transition: "background 0.15s",
                }}
              >
                {/* Chevron */}
                {hasCourses && (
                  <svg
                    width="12" height="12" viewBox="0 0 12 12"
                    style={{ flexShrink: 0, color: "#9ca3af", transition: "transform 0.2s", transform: isOpen ? "rotate(90deg)" : "rotate(0deg)" }}
                  >
                    <path d="M4 2l4 4-4 4" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                )}

                {/* Title */}
                <span style={{ flex: 1, fontWeight: 600, fontSize: "13.5px", color: "#1e293b" }}>
                  {block.title}
                </span>

                {/* Progress detail */}
                {(status.detail || (block.ruleType === "choose_credits" && hasCheckedPlan)) && (
                  <span style={{ fontSize: "11.5px", color: "#64748b", fontVariantNumeric: "tabular-nums" }}>
                    {status.detail || `${status.completedCredits} / ${block.minCredits || 0} cr`}
                  </span>
                )}

                {/* Rule badge */}
                <span style={{
                  padding: "2px 8px", borderRadius: "999px",
                  fontSize: "11px", fontWeight: 600,
                  backgroundColor: "#f1f5f9", color: "#475569",
                  border: "1px solid #e2e8f0", whiteSpace: "nowrap",
                }}>
                  {getRuleLabel(block)}
                </span>
              </div>

              {/* Notes */}
              {block.notes && (
                <div style={{
                  margin: "3px 0 3px 12px",
                  padding: "6px 12px",
                  borderRadius: "7px",
                  backgroundColor: "#f8fafc",
                  border: "1px solid #f1f5f9",
                  borderLeft: "3px solid #e2e8f0",
                  fontSize: "12px", color: "#64748b", fontStyle: "italic", lineHeight: 1.5,
                }}>
                  {block.notes}
                </div>
              )}

              {/* Course list */}
              {hasCourses && isOpen && (
                <div style={{
                  margin: "3px 0 0 12px",
                  borderRadius: "8px",
                  border: "1px solid #f1f5f9",
                  overflow: "hidden",
                  backgroundColor: "white",
                }}>
                  {block.courseCodes.map((code, i) => {
                    const norm = normalizeCourse(code);
                    const isPlanned = plannedCourses.has(norm);
                    const course = courseMap[norm];
                    const label = course ? course.id : code;
                    const name = course?.name || "";
                    const isLast = i === block.courseCodes.length - 1;

                    return (
                      <div key={code} style={{
                        display: "flex", alignItems: "center", gap: "9px",
                        padding: "7px 12px",
                        backgroundColor: hasCheckedPlan && isPlanned ? "#f0fdf4" : "white",
                        borderBottom: isLast ? "none" : "1px solid #f8fafc",
                      }}>
                        {/* Leaf dot */}
                        <div style={{
                          width: "7px", height: "7px", borderRadius: "50%", flexShrink: 0,
                          backgroundColor: hasCheckedPlan && isPlanned ? "#16a34a" : "#d1d5db",
                        }} />
                        <span style={{ fontSize: "13px", color: hasCheckedPlan && isPlanned ? "#166534" : "#374151" }}>
                          <span style={{ fontWeight: 600 }}>{label}</span>
                          {name && <span style={{ color: hasCheckedPlan && isPlanned ? "#16a34a" : "#9ca3af" }}> — {name}</span>}
                        </span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default MajorRequirements;
