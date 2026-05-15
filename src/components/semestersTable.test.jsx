import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import SemestersTable from "./semestersTable";

// fake course data for the tests
const fakeCourses = [
  { id: "CSC-151", code: "CSC151", name: "Functional Problem Solving", credits: 4 },
  { id: "CSC-161", code: "CSC161", name: "Imperative Problem Solving", credits: 4 },
  { id: "MAT-131", code: "MAT131", name: "Calculus I", credits: 4 },
  { id: "MAT-133", code: "MAT133", name: "Calculus II", credits: 4 },
];

// helper to make a blank plan
function makeBlankPlan() {
  return [
    { name: "Fall 1st Year",   courses: [null, null, null, null] },
    { name: "Spring 1st Year", courses: [null, null, null, null] },
    { name: "Fall 2nd Year",   courses: [null, null, null, null] },
    { name: "Spring 2nd Year", courses: [null, null, null, null] },
    { name: "Fall 3rd Year",   courses: [null, null, null, null] },
    { name: "Spring 3rd Year", courses: [null, null, null, null] },
    { name: "Fall 4th Year",   courses: [null, null, null, null] },
    { name: "Spring 4th Year", courses: [null, null, null, null] },
  ];
}

describe("SemestersTable", () => {

  it("shows the title", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    expect(screen.getByText(/full course plan/i)).toBeInTheDocument();
  });

  it("shows the first semester", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    expect(screen.getByText("Fall 1st Year")).toBeInTheDocument();
  });

  it("shows the last semester too", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    expect(screen.getByText("Spring 4th Year")).toBeInTheDocument();
  });

  it("shows add course in empty slots", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    const slots = screen.getAllByText("+ Add course");
    expect(slots.length).toBe(32);
  });

  it("shows the course name in a filled slot", () => {
    const plan = makeBlankPlan();
    plan[0].courses[0] = "CSC-151";

    render(
      <SemestersTable
        semesters={plan}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    expect(screen.getByText("CSC-151")).toBeInTheDocument();
  });

  it("opens dropdown when clicking empty slot", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    const slot = screen.getAllByText("+ Add course")[0];
    fireEvent.click(slot);

    expect(screen.getByText("Select a department")).toBeInTheDocument();
  });

  it("has CSC as a department option", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    expect(screen.getByRole("option", { name: "CSC" })).toBeInTheDocument();
  });

  it("has MAT as a department option", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    expect(screen.getByRole("option", { name: "MAT" })).toBeInTheDocument();
  });

  it("shows course list after picking a department", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    const dropdown = screen.getByRole("combobox");
    fireEvent.change(dropdown, { target: { value: "CSC" } });

    expect(screen.getByText("Select a course")).toBeInTheDocument();
  });

  it("only shows CSC courses when CSC is picked", () => {
    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );
    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    const dropdown = screen.getByRole("combobox");
    fireEvent.change(dropdown, { target: { value: "CSC" } });

    expect(screen.getByRole("option", { name: /CSC-151/ })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: /MAT-131/ })).not.toBeInTheDocument();
  });

  it("calls onCourseSelect when you pick a course", () => {
    const mockSelect = vi.fn(() => true);

    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={mockSelect}
        courseOptions={fakeCourses}
      />
    );

    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    const deptDropdown = screen.getByRole("combobox");
    fireEvent.change(deptDropdown, { target: { value: "CSC" } });

    const allDropdowns = screen.getAllByRole("combobox");
    fireEvent.change(allDropdowns[1], { target: { value: "CSC-151" } });

    expect(mockSelect).toHaveBeenCalledWith(0, 0, "CSC-151");
  });

  it("opens dropdown when clicking a filled slot", () => {
    const plan = makeBlankPlan();
    plan[0].courses[0] = "CSC-151";

    render(
      <SemestersTable
        semesters={plan}
        onCourseSelect={() => true}
        courseOptions={fakeCourses}
      />
    );

    fireEvent.click(screen.getByText("CSC-151"));
    expect(screen.getByText("Select a department")).toBeInTheDocument();
  });

  // when onCourseSelect returns false (e.g. a prereq is missing), the dropdown
  // should stay open so the student can pick a different course
  it("keeps the dropdown open when the course is rejected", () => {
    const alwaysReject = vi.fn(() => false);

    render(
      <SemestersTable
        semesters={makeBlankPlan()}
        onCourseSelect={alwaysReject}
        courseOptions={fakeCourses}
      />
    );

    fireEvent.click(screen.getAllByText("+ Add course")[0]);

    const deptDropdown = screen.getByRole("combobox");
    fireEvent.change(deptDropdown, { target: { value: "CSC" } });

    const allDropdowns = screen.getAllByRole("combobox");
    fireEvent.change(allDropdowns[1], { target: { value: "CSC-151" } });

    // dropdown should still be visible because the placement was rejected
    expect(screen.getByText("Select a department")).toBeInTheDocument();
  });

});
