import { test, expect } from "@playwright/test";

// some fake data to mock the API calls so we dont need the actual database running
const fakeCourses = {
  courses: [
    { id: "CSC-151", code: "CSC151", name: "Functional Problem Solving", credits: 4, offered: ["Fall", "Spring"], prerequisiteGroups: [], registrationRule: null },
    { id: "CSC-161", code: "CSC161", name: "Imperative Problem Solving", credits: 4, offered: ["Fall", "Spring"], prerequisiteGroups: [{ options: ["CSC151"], canBeCorequisite: false }], registrationRule: null },
    { id: "CSC-207", code: "CSC207", name: "Object-Oriented Problem Solving", credits: 4, offered: ["Fall", "Spring"], prerequisiteGroups: [{ options: ["CSC161"], canBeCorequisite: false }], registrationRule: null },
    { id: "CSC-301", code: "CSC301", name: "Analysis of Algorithms", credits: 4, offered: ["Fall", "Spring"], prerequisiteGroups: [{ options: ["CSC207"], canBeCorequisite: false }], registrationRule: null },
    { id: "MAT-131", code: "MAT131", name: "Calculus I", credits: 4, offered: ["Fall", "Spring"], prerequisiteGroups: [], registrationRule: null },
    { id: "TUT-100", code: "TUT100", name: "Tutorial", credits: 4, offered: ["Fall"], prerequisiteGroups: [], registrationRule: null },
  ],
};

const fakeMajors = {
  majors: [
    { code: "CSC", name: "Computer Science" },
    { code: "MAT", name: "Mathematics" },
  ],
};

const fakeRequirements = {
  major: { id: "csc", name: "Computer Science", totalCredits: 32 },
  blocks: [
    { code: "CSC_INTRO", title: "Intro Sequence", ruleType: "must_take", minCount: 1, minCredits: null, notes: null, courseCodes: ["CSC151"], orParentCode: null, orChildCodes: [] },
    { code: "CSC_CORE", title: "Core Courses", ruleType: "must_take", minCount: 1, minCredits: null, notes: null, courseCodes: ["CSC161", "CSC207"], orParentCode: null, orChildCodes: [] },
    { code: "CSC_THEORY", title: "Theory", ruleType: "choose_one", minCount: 1, minCredits: null, notes: null, courseCodes: ["CSC301"], orParentCode: null, orChildCodes: [] },
  ],
  requirements: {},
};

// helper to intercept all API calls before the page loads
async function mockAPIs(page) {
  await page.route("/api/courses", (route) =>
    route.fulfill({ contentType: "application/json", body: JSON.stringify(fakeCourses) })
  );
  await page.route("/api/majors", (route) =>
    route.fulfill({ contentType: "application/json", body: JSON.stringify(fakeMajors) })
  );
  await page.route("/api/majors/CSC/requirements", (route) =>
    route.fulfill({ contentType: "application/json", body: JSON.stringify(fakeRequirements) })
  );
  await page.route("/api/majors/MAT/requirements", (route) =>
    route.fulfill({ contentType: "application/json", body: JSON.stringify(fakeRequirements) })
  );
}

// ── Page load ────────────────────────────────────────────────────────────────

test("Grinnell College name shows in the header", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  // use the span inside the header, not the hidden h1
  await expect(page.locator("header span").filter({ hasText: "Grinnell College" })).toBeVisible();
});

test("shows the 4-Year Planner label in the header", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.locator("header span").filter({ hasText: "4-Year Planner" })).toBeVisible();
});

test("loads the course table after data comes in", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByText("Full Course Plan")).toBeVisible();
});

test("all 8 semesters show up", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByText("Fall 1st Year")).toBeVisible();
  await expect(page.getByText("Spring 4th Year")).toBeVisible();
});

// ── Adding a course ───────────────────────────────────────────────────────────

test("clicking an empty slot opens the department dropdown", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await page.getByText("+ Add course").first().click();
  // the planner-select element itself should be visible (options inside are hidden by default)
  await expect(page.locator("select.planner-select").first()).toBeVisible();
});

test("can pick a department from the dropdown", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await page.getByText("+ Add course").first().click();
  await page.locator("select.planner-select").first().selectOption("CSC");
  // after picking a dept, a second select should appear for the course
  await expect(page.locator("select.planner-select").nth(1)).toBeVisible();
});

test("only CSC courses appear after picking CSC", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await page.getByText("+ Add course").first().click();
  await page.locator("select.planner-select").first().selectOption("CSC");

  const courseDropdown = page.locator("select.planner-select").nth(1);
  await expect(courseDropdown.locator("option[value='CSC-151']")).toBeAttached();
  await expect(courseDropdown.locator("option[value='MAT-131']")).not.toBeAttached();
});

test("selecting a course closes the dropdown and shows the course id", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await page.getByText("+ Add course").first().click();

  await page.locator("select.planner-select").first().selectOption("CSC");
  await page.locator("select.planner-select").nth(1).selectOption("CSC-151");

  // the slot div should now show the course id instead of "+ Add course"
  await expect(page.locator(".course-slot").filter({ hasText: "CSC-151" })).toBeVisible();
});

// ── Buttons ───────────────────────────────────────────────────────────────────

test("Reset Plan button is visible", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByRole("button", { name: /reset plan/i })).toBeVisible();
});

test("Check Requirements button is visible", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByRole("button", { name: /check requirements/i })).toBeVisible();
});

test("Auto-Fill button is visible", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByRole("button", { name: /auto-fill/i })).toBeVisible();
});

test("clicking Reset Plan clears any added courses", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");

  // add a course first
  await page.getByText("+ Add course").first().click();
  await page.locator("select.planner-select").first().selectOption("CSC");
  await page.locator("select.planner-select").nth(1).selectOption("CSC-151");
  await expect(page.locator(".course-slot").filter({ hasText: "CSC-151" })).toBeVisible();

  // now reset
  await page.getByRole("button", { name: /reset plan/i }).click();
  await expect(page.locator(".course-slot").filter({ hasText: "CSC-151" })).not.toBeVisible();
});

// ── Major requirements panel ──────────────────────────────────────────────────

test("major requirements panel heading shows up", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByText(/computer science requirements/i)).toBeVisible();
});

test("clicking Check Requirements shows the requirements status", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await page.getByRole("button", { name: /check requirements/i }).click();
  // after checking, the hint message should be gone
  await expect(page.getByText(/add courses and click check requirements/i)).not.toBeVisible();
});

test("requirement blocks are listed in the panel", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.getByText("Intro Sequence")).toBeVisible();
  await expect(page.getByText("Core Courses")).toBeVisible();
});

// ── Major selector ────────────────────────────────────────────────────────────

test("major dropdown shows Computer Science by default", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");
  await expect(page.locator("select.major-select")).toHaveValue("CSC");
});

test("switching the major resets the plan", async ({ page }) => {
  await mockAPIs(page);
  await page.goto("/");

  // add a course
  await page.getByText("+ Add course").first().click();
  await page.locator("select.planner-select").first().selectOption("CSC");
  await page.locator("select.planner-select").nth(1).selectOption("CSC-151");
  await expect(page.locator(".course-slot").filter({ hasText: "CSC-151" })).toBeVisible();

  // switch major — this should reset the plan
  await page.locator("select.major-select").selectOption("MAT");
  await expect(page.locator(".course-slot").filter({ hasText: "CSC-151" })).not.toBeVisible();
});
