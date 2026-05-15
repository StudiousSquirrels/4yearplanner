import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import MajorRequirements from "./major_requirements";

// ─── Mock data ───────────────────────────────────────────────────────────────

const courses = {
  courses: [
    { id: "CSC-151", code: "CSC151", name: "Functional Problem Solving", credits: 4 },
    { id: "CSC-161", code: "CSC161", name: "Imperative Problem Solving", credits: 4 },
    { id: "CSC-301", code: "CSC301", name: "Analysis of Algorithms", credits: 4 },
    { id: "CSC-341", code: "CSC341", name: "Automata, Formal Languages", credits: 4 },
    { id: "ANT-210", code: "ANT210", name: "Cultural Anthropology", credits: 4, subfields: ["Cultural"] },
    { id: "ANT-220", code: "ANT220", name: "Biological Anthropology", credits: 4, subfields: ["Biological"] },
    { id: "ANT-230", code: "ANT230", name: "Archaeological Methods", credits: 4, subfields: ["Archaeology"] },
  ],
};

const cscRequirements = {
  major: { id: "csc", name: "Computer Science", totalCredits: 32, description: "CS major requirements" },
  blocks: [
    { code: "CSC_INTRO", title: "Introductory Course", ruleType: "must_take", minCount: 1, minCredits: null, notes: null, courseCodes: ["CSC151"] },
    { code: "CSC_MULTI", title: "Multi-Paradigm Course", ruleType: "choose_one", minCount: 1, minCredits: null, notes: null, courseCodes: ["CSC161"] },
    { code: "CSC_THEORY", title: "Theory Courses", ruleType: "choose_n", minCount: 2, minCredits: null, notes: null, courseCodes: ["CSC301", "CSC341"] },
  ],
  requirements: {},
};

const anthRequirements = {
  major: { id: "anth", name: "Anthropology", totalCredits: 32, description: "Anthropology major requirements" },
  blocks: [
    { code: "ANTH_FOUR_FIELDS", title: "Four Fields Breadth", ruleType: "or_group", minCount: null, minCredits: null, notes: "Must cover 3 of the 4 subfields.", courseCodes: ["ANT210", "ANT220", "ANT230"] },
  ],
  requirements: {},
};

function plan(...codes) {
  return [
    { name: "Fall 1st Year",   courses: [...codes.slice(0, 4), null, null, null, null].slice(0, 4) },
    { name: "Spring 1st Year", courses: [null, null, null, null] },
    { name: "Fall 2nd Year",   courses: [null, null, null, null] },
    { name: "Spring 2nd Year", courses: [null, null, null, null] },
    { name: "Fall 3rd Year",   courses: [null, null, null, null] },
    { name: "Spring 3rd Year", courses: [null, null, null, null] },
    { name: "Fall 4th Year",   courses: [null, null, null, null] },
    { name: "Spring 4th Year", courses: [null, null, null, null] },
  ];
}

// ─── Tests ───────────────────────────────────────────────────────────────────

describe("before plan is checked (semesters = null)", () => {
  it("shows the major name heading", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByRole("heading", { name: /computer science requirements/i })).toBeInTheDocument();
  });

  it("shows the hint message to check requirements", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByText(/add courses and click check requirements/i)).toBeInTheDocument();
  });

  it("shows 0 / 3 in the progress badge", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByText("0 / 3")).toBeInTheDocument();
  });

  it("shows no checkmarks", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.queryByText("✓")).not.toBeInTheDocument();
  });
});

describe("must_take block", () => {
  it("shows a checkmark when the required course is planned", () => {
    render(<MajorRequirements semesters={plan("CSC-151")} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByText("✓")).toBeInTheDocument();
  });

  it("shows no checkmark when the required course is missing", () => {
    render(<MajorRequirements semesters={plan()} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.queryByText("✓")).not.toBeInTheDocument();
  });
});

describe("choose_one block", () => {
  it("marks complete when any listed course is planned", () => {
    render(<MajorRequirements semesters={plan("CSC-151", "CSC-161")} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getAllByText("✓")).toHaveLength(2);
  });
});

describe("choose_n block", () => {
  it("marks complete when the minimum number of courses are planned", () => {
    render(<MajorRequirements semesters={plan("CSC-151", "CSC-161", "CSC-301", "CSC-341")} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getAllByText("✓")).toHaveLength(3);
    expect(screen.getByText("3 / 3")).toBeInTheDocument();
  });

  it("stays incomplete when fewer than the minimum are planned", () => {
    render(<MajorRequirements semesters={plan("CSC-151", "CSC-161", "CSC-301")} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getAllByText("✓")).toHaveLength(2);
  });
});

describe("ANTH_FOUR_FIELDS block", () => {
  it("renders the four fields block title", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={anthRequirements} />);
    expect(screen.getByText("Four Fields Breadth")).toBeInTheDocument();
  });

  it("shows no checkmark when the block is not satisfied", () => {
    render(<MajorRequirements semesters={plan("ANT-210", "ANT-220")} coursesData={courses} majorRequirements={anthRequirements} />);
    expect(screen.queryByText("✓")).not.toBeInTheDocument();
  });
});

describe("collapsible tree", () => {
  it("shows courses by default", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByText("CSC-151")).toBeInTheDocument();
  });

  it("hides courses when the block row is clicked", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    fireEvent.click(screen.getByText("Introductory Course"));
    expect(screen.queryByText("CSC-151")).not.toBeInTheDocument();
  });

  it("shows courses again when clicked a second time", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    fireEvent.click(screen.getByText("Introductory Course"));
    fireEvent.click(screen.getByText("Introductory Course"));
    expect(screen.getByText("CSC-151")).toBeInTheDocument();
  });

  it("collapsing one block does not affect others", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    fireEvent.click(screen.getByText("Introductory Course"));
    expect(screen.queryByText("CSC-151")).not.toBeInTheDocument();
    expect(screen.getByText("CSC-161")).toBeInTheDocument();
  });
});

describe("notes and course names", () => {
  it("displays the full course name", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={cscRequirements} />);
    expect(screen.getByText(/functional problem solving/i)).toBeInTheDocument();
  });

  it("renders block notes when present", () => {
    render(<MajorRequirements semesters={null} coursesData={courses} majorRequirements={anthRequirements} />);
    expect(screen.getByText(/must cover 3 of the 4 subfields/i)).toBeInTheDocument();
  });
});
