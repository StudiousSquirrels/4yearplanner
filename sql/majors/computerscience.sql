BEGIN;

-- ============================================================
-- Computer Science (CSC)
-- ============================================================

-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('CSC', 'Computer Science')
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('CSC',105,'CSC 105','The Digital Age',4),
('CSC',151,'CSC 151','Functional Problem Solving',4),
('CSC',161,'CSC 161','Imperative Problem Solving and Data Structures',4),
('CSC',205,'CSC 205','Computational Linguistics',4),
('CSC',207,'CSC 207','Algorithms and Object-Oriented Design',4),
('CSC',208,'CSC 208','Discrete Structures',4),
('CSC',211,'CSC 211','Computer Organization and Architecture',4),
('CSC',213,'CSC 213','Operating Systems and Parallel Algorithms',4),
('CSC',214,'CSC 214','Computer and Network Security',2),
('CSC',216,'CSC 216','Computer Networks',2),
('CSC',232,'CSC 232','Human-Computer Interaction',2),
('CSC',261,'CSC 261','Artificial Intelligence',4),
('CSC',262,'CSC 262','Computer Vision',4),
('CSC',281,'CSC 281','Life Beyond Grinnell - Learning from Computer Science Alumni',1),
('CSC',282,'CSC 282','Thinking in C and Unix',1),
('CSC',301,'CSC 301','Analysis of Algorithms',4),
('CSC',312,'CSC 312','Programming Language Implementation',2),
('CSC',321,'CSC 321','Software Development Principles and Practices',2),
('CSC',322,'CSC 322','Team Software Development for Community Organizations',2),
('CSC',324,'CSC 324','Software Design and Development with Lab',4),
('CSC',326,'CSC 326','Advanced Software Development / Variable Credit',2),
('CSC',341,'CSC 341','Automata, Formal Languages, and Computational Complexity',4),

('LIN',114,'LIN 114','Introduction to General Linguistics',4),
('PSY',113,'PSY 113','Introduction to Psychology',4),
('TEC',154,'TEC 154','Evolution of Technology',4),

('MAT',124,'MAT 124','Functions and Integral Calculus',4),
('MAT',131,'MAT 131','Calculus I',4),
('MAT',133,'MAT 133','Calculus II',4),
('MAT',215,'MAT 215','Linear Algebra',4),
('MAT',208,'MAT 208','Discrete Structures',4),
('MAT',218,'MAT 218','Discrete Bridges to Advanced Mathematics',4),

('STA',209,'STA 209','Applied Statistics',4),
('MAT',335,'MAT 335',NULL,4),
('STA',335,'STA 335',NULL,4),
('MAT',336,'MAT 336',NULL,4),
('STA',336,'STA 336',NULL,4)

ON CONFLICT (course_code) DO UPDATE
SET title = EXCLUDED.title,
    credits = EXCLUDED.credits,
    active = TRUE;

-- ------------------------------------------------------------
-- Course offering terms used by the planner
-- ------------------------------------------------------------
DELETE FROM course_terms
USING courses c
WHERE course_terms.course_id = c.id
  AND c.course_code IN (
    'CSC 105','CSC 151','CSC 161','CSC 205','CSC 207','CSC 208',
    'CSC 211','CSC 213','CSC 214','CSC 216','CSC 232','CSC 261',
    'CSC 262','CSC 281','CSC 282','CSC 301','CSC 312','CSC 321',
    'CSC 322','CSC 324','CSC 326','CSC 341',
    'MAT 124','MAT 131','MAT 133','MAT 208','MAT 215','MAT 218'
  );

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('CSC 105','Spring'),
  ('CSC 151','Fall'), ('CSC 151','Spring'),
  ('CSC 161','Fall'), ('CSC 161','Spring'),
  ('CSC 205','Fall'),
  ('CSC 207','Fall'), ('CSC 207','Spring'),
  ('CSC 208','Spring'),
  ('CSC 211','Fall'), ('CSC 211','Spring'),
  ('CSC 213','Fall'), ('CSC 213','Spring'),
  ('CSC 214','Fall'), ('CSC 214','Spring'),
  ('CSC 216','Fall'), ('CSC 216','Spring'),
  ('CSC 232','Fall'), ('CSC 232','Spring'),
  ('CSC 261','Fall'),
  ('CSC 262','Spring'),
  ('CSC 281','Fall'),
  ('CSC 282','Spring'),
  ('CSC 301','Fall'),
  ('CSC 312','Fall'), ('CSC 312','Spring'),
  ('CSC 321','Fall'), ('CSC 321','Spring'),
  ('CSC 322','Fall'), ('CSC 322','Spring'),
  ('CSC 324','Fall'), ('CSC 324','Spring'),
  ('CSC 326','Fall'), ('CSC 326','Spring'),
  ('CSC 341','Spring'),
  ('MAT 124','Fall'), ('MAT 124','Spring'),
  ('MAT 131','Fall'), ('MAT 131','Spring'),
  ('MAT 133','Fall'), ('MAT 133','Spring'),
  ('MAT 215','Fall'), ('MAT 215','Spring'),
  ('MAT 208','Spring'),
  ('MAT 218','Fall'), ('MAT 218','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- Course prerequisites used by the planner
-- ------------------------------------------------------------
DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN (
    'CSC 161','CSC 205','CSC 207','CSC 208','CSC 211','CSC 213',
    'CSC 214','CSC 216','CSC 232','CSC 261','CSC 262','CSC 281',
    'CSC 282','CSC 301','CSC 312','CSC 321','CSC 322','CSC 324',
    'CSC 326','CSC 341'
  );

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN (
    'CSC 161','CSC 205','CSC 207','CSC 208','CSC 211','CSC 213',
    'CSC 214','CSC 216','CSC 232','CSC 261','CSC 262','CSC 281',
    'CSC 282','CSC 301','CSC 312','CSC 321','CSC 322','CSC 324',
    'CSC 326','CSC 341'
  );

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('CSC 161','csc151','CSC 151',false),
  ('CSC 205','lin114','LIN 114',false),
  ('CSC 205','csc151','CSC 151',false),
  ('CSC 207','csc161','CSC 161',false),
  ('CSC 208','csc151','CSC 151',false),
  ('CSC 208','math','MAT 124',false),
  ('CSC 208','math','MAT 131',false),
  ('CSC 211','csc161','CSC 161',false),
  ('CSC 213','csc161','CSC 161',false),
  ('CSC 214','csc161','CSC 161',false),
  ('CSC 216','csc161','CSC 161',false),
  ('CSC 232','intro','CSC 105',false),
  ('CSC 232','intro','CSC 151',false),
  ('CSC 232','intro','PSY 113',false),
  ('CSC 232','intro','TEC 154',false),
  ('CSC 261','csc161','CSC 161',false),
  -- Catalog says "CSC 161, or both CSC 151 and MAT 215".
  -- The current planner prerequisite model cannot express that nested OR exactly.
  ('CSC 262','csc161','CSC 161',false),
  ('CSC 281','csc151','CSC 151',false),
  ('CSC 282','csc161','CSC 161',false),
  ('CSC 301','csc207','CSC 207',false),
  ('CSC 301','discrete','MAT 218',false),
  ('CSC 301','discrete','CSC 208',false),
  ('CSC 301','discrete','MAT 208',false),
  ('CSC 312','csc207','CSC 207',false),
  ('CSC 321','csc207','CSC 207',false),
  ('CSC 322','csc207','CSC 207',false),
  ('CSC 322','csc321','CSC 321',true),
  ('CSC 324','csc207','CSC 207',false),
  ('CSC 326','csc324','CSC 324',false),
  ('CSC 341','csc161','CSC 161',false),
  ('CSC 341','discrete','MAT 218',false),
  ('CSC 341','discrete','CSC 208',false),
  ('CSC 341','discrete','MAT 208',false)
) AS v(course_code, group_code, prerequisite_code, can_be_corequisite)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

INSERT INTO course_prerequisites(course_id, prerequisite_course_id)
SELECT course.id, prereq.id
FROM (VALUES
  ('MAT 133','MAT 131'),
  ('MAT 215','MAT 133'),
  ('MAT 208','MAT 215'),
  ('MAT 218','MAT 215')
) AS v(course_code, prerequisite_code)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3) Introductory Sequence
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_INTRO_151', 'CSC 151', 'must_take', 10
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_INTRO_161', 'CSC 161', 'must_take', 20
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_INTRO_207', 'CSC 207', 'must_take', 30
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 4) Systems
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'CSC_SYSTEMS',
       'Systems: CSC 211 or CSC 213',
       'choose_one',
       1,
       'Systems requires one of CSC 211 or CSC 213. Taking both is recommended; if both are taken, one may count toward the elective requirement.',
       40
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 5) Upper-Level Theory
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_THEORY_301', 'CSC 301', 'must_take', 50
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_THEORY_341', 'CSC 341', 'must_take', 60
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 6) Software Development
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'CSC_SOFTWARE_324', 'CSC 324', 'must_take', 70
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 7) Elective
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'CSC_ELECTIVE',
       'Elective: 4 credits in CSC at 200-level or higher',
       'custom',
       4,
       'Need 4 credits in Computer Science at the 200-level or higher. CSC 281, CSC 282, guided reading, independent study, directed research, and MAPs may not be used. Up to 2 credits of CSC 326 may count. If both CSC 211 and CSC 213 are taken, one may be used for the elective requirement.',
       80
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 8) Also Required: discrete structures
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'CSC_DISCRETE',
       'Discrete Structures requirement',
       'choose_one',
       1,
       'Complete one of MAT 208, CSC 208, or MAT 218.',
       90
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 9) Math elective
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'CSC_MATH_ELECTIVE',
       'Math elective',
       'custom',
       4,
       'Complete one math course numbered above MAT 131, or any statistics course creditable toward the Mathematics major.',
       100
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 10) Summary / policy constraints
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'CSC_TOTALS_AND_POLICIES',
       'Major totals and policy constraints',
       'custom',
       32,
       'Need at least 32 credits for the major. Computer Science courses below CSC 151 do not satisfy the major. No more than 4 credits taken outside of Grinnell may count toward the 16 required credits in systems, upper-level theory, and software development. Students must complete at least 20 credits of CSC coursework creditable toward the major at Grinnell College.',
       110
FROM majors m
WHERE m.code = 'CSC'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 11) Attach course options
-- ------------------------------------------------------------

-- Intro sequence
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 151'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_INTRO_151'
ON CONFLICT DO NOTHING;

INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 161'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_INTRO_161'
ON CONFLICT DO NOTHING;

INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 207'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_INTRO_207'
ON CONFLICT DO NOTHING;

-- Systems
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('CSC 211','CSC 213')
WHERE m.code = 'CSC'
  AND b.code = 'CSC_SYSTEMS'
ON CONFLICT DO NOTHING;

-- Theory
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 301'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_THEORY_301'
ON CONFLICT DO NOTHING;

INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 341'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_THEORY_341'
ON CONFLICT DO NOTHING;

-- Software Development
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CSC 324'
WHERE m.code = 'CSC'
  AND b.code = 'CSC_SOFTWARE_324'
ON CONFLICT DO NOTHING;

-- Discrete requirement
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 208','CSC 208','MAT 218')
WHERE m.code = 'CSC'
  AND b.code = 'CSC_DISCRETE'
ON CONFLICT DO NOTHING;

COMMIT;
