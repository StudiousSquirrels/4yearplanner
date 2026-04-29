BEGIN;
 
-- ============================================================
-- Political Science (POL)
-- ============================================================
 
-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('POL', 'Political Science')
ON CONFLICT (code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('POL',101,'POL 101','Introduction to Political Science',4),
 
-- American Politics
('POL',216,'POL 216','Politics of Congress',4),
('POL',219,'POL 219','Constitutional Law and Politics',4),
('POL',220,'POL 220','Foundations of Policy Analysis',4),
('POL',222,'POL 222','American Immigration Politics',4),
('POL',237,'POL 237','Political Parties',4),
('POL',239,'POL 239','The Presidency',4),
 
-- Comparative Politics
('POL',255,'POL 255','The Politics of New Europe',4),
('POL',257,'POL 257','Nationalisms',4),
('POL',258,'POL 258','Democratization and the Politics of Regime Change',4),
('POL',261,'POL 261','State and Society in Latin America',4),
('POL',262,'POL 262','African Politics',4),
('POL',263,'POL 263','Political Theory I',4),
('POL',264,'POL 264','Political Theory II',4),
('POL',273,'POL 273','Politics of Russia',4),
 
-- International Politics
('POL',250,'POL 250','Politics of International Relations',4),
('POL',251,'POL 251','International Political Economy',4),
('POL',259,'POL 259','Human Rights: Foundations, Challenges, and Choices',4),
 
-- Special Topics (shared across subfields)
('POL',295,'POL 295','Special Topic (Approved by Department)',4),
 
-- 300-level Seminars
('POL',310,'POL 310','Advanced Seminar in American Politics',4),
('POL',319,'POL 319','Advanced Seminar in Constitutional Law',4),
('POL',320,'POL 320','Applied Policy Analysis',4),
('POL',325,'POL 325','Development in Fragile and Conflict-Affected Countries',4),
('POL',335,'POL 335','Advanced Seminar in Comparative Politics',4),
('POL',350,'POL 350','International Politics of Land and Sea Resources',4),
('POL',352,'POL 352','Advanced Seminar on the U.S. Foreign Policymaking Process',4),
('POL',354,'POL 354','Political Economy of Developing Countries',4),
('POL',355,'POL 355','Courts and Politics in Comparative Perspective',4),
('POL',356,'POL 356','Islam and Politics',4),
('POL',357,'POL 357','Direct Democracy and Referenda',4),
 
('MAT',115,'MAT 115','Introduction to Statistics',4),
('MAT',209,'MAT 209','Applied Statistics',4),
('SST',115,'SST 115','Introduction to Statistics',4),
('STA',209,'STA 209','Applied Statistics',4),
('ECN',111,'ECN 111','Introduction to Economics',4),
('PST',220,'PST 220','Foundations of Policy Analysis',4),
('PST',320,'PST 320','Applied Policy Analysis',4),
('PHI',263,'PHI 263','Political Theory I',4),
('PHI',264,'PHI 264','Political Theory II',4)
 
ON CONFLICT (course_code) DO UPDATE
SET title = COALESCE(EXCLUDED.title, courses.title),
    credits = EXCLUDED.credits,
    active = TRUE;

-- ------------------------------------------------------------
-- Course offering terms and prerequisites used by the planner
-- Keep course-level rules here, not in server/index.js.
-- ------------------------------------------------------------
DELETE FROM course_terms
USING courses c
WHERE course_terms.course_id = c.id
  AND c.course_code IN (
    'POL 101','POL 216','POL 219','POL 220','POL 222','POL 237',
    'POL 239','POL 250','POL 251','POL 255','POL 257','POL 258',
    'POL 259','POL 261','POL 262','POL 263','POL 264','POL 273',
    'POL 310','POL 319','POL 320','POL 350','POL 352','POL 354',
    'POL 355','POL 356'
  );

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('POL 101','Fall'), ('POL 101','Spring'),
  ('POL 216','Fall'),
  ('POL 219','Fall'),
  ('POL 220','Spring'),
  ('POL 222','Fall'), ('POL 222','Spring'),
  ('POL 237','Fall'),
  ('POL 239','Spring'),
  ('POL 250','Fall'), ('POL 250','Spring'),
  ('POL 251','Fall'),
  ('POL 255','Spring'),
  ('POL 257','Fall'),
  ('POL 258','Fall'), ('POL 258','Spring'),
  ('POL 259','Spring'),
  ('POL 261','Fall'),
  ('POL 262','Spring'),
  ('POL 263','Fall'), ('POL 263','Spring'),
  ('POL 264','Fall'), ('POL 264','Spring'),
  ('POL 273','Spring'),
  ('POL 310','Fall'),
  ('POL 319','Spring'),
  ('POL 320','Fall'),
  ('POL 350','Spring'),
  ('POL 352','Fall'),
  ('POL 354','Fall'),
  ('POL 355','Fall'),
  ('POL 356','Fall'), ('POL 356','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN (
    'POL 216','POL 219','POL 220','POL 222','POL 237','POL 239',
    'POL 250','POL 251','POL 255','POL 257','POL 258','POL 259',
    'POL 261','POL 262','POL 273','POL 310','POL 319','POL 320',
    'POL 350','POL 352','POL 354','POL 355','POL 356'
  );

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN (
    'POL 216','POL 219','POL 220','POL 222','POL 237','POL 239',
    'POL 250','POL 251','POL 255','POL 257','POL 258','POL 259',
    'POL 261','POL 262','POL 273','POL 310','POL 319','POL 320',
    'POL 350','POL 352','POL 354','POL 355','POL 356'
  );

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('POL 216','pol101','POL 101',false),
  ('POL 219','pol101','POL 101',false),
  ('POL 220','pol101','POL 101',false),
  ('POL 222','pol101','POL 101',false),
  ('POL 237','pol101','POL 101',false),
  ('POL 239','pol101','POL 101',false),
  ('POL 250','pol101','POL 101',false),
  ('POL 251','pol101','POL 101',false),
  ('POL 255','pol101','POL 101',false),
  ('POL 257','pol101','POL 101',false),
  ('POL 258','pol101','POL 101',true),
  ('POL 259','pol101','POL 101',false),
  ('POL 261','pol101','POL 101',false),
  ('POL 262','pol101','POL 101',false),
  ('POL 273','pol101','POL 101',false),
  ('POL 310','stats','MAT 115',false),
  ('POL 310','stats','MAT 209',false),
  ('POL 310','american','POL 216',false),
  ('POL 310','american','POL 222',false),
  ('POL 310','american','POL 237',false),
  ('POL 310','american','POL 239',false),
  ('POL 310','american','POL 220',false),
  ('POL 310','american','PST 220',false),
  ('POL 319','pol219','POL 219',false),
  ('POL 320','policy','POL 216',false),
  ('POL 320','policy','POL 220',false),
  ('POL 320','policy','PST 220',false),
  ('POL 320','policy','POL 222',false),
  ('POL 320','policy','POL 239',false),
  ('POL 320','policy','POL 250',false),
  ('POL 350','ir','POL 250',false),
  ('POL 350','ir','POL 251',false),
  ('POL 350','ir','POL 259',false),
  ('POL 352','ir','POL 250',false),
  ('POL 352','ir','POL 251',false),
  ('POL 352','ir','POL 259',false),
  ('POL 354','comparative','POL 250',false),
  ('POL 354','comparative','POL 251',false),
  ('POL 354','comparative','POL 257',false),
  ('POL 354','comparative','POL 258',false),
  ('POL 354','comparative','POL 261',false),
  ('POL 354','comparative','POL 262',false),
  ('POL 354','comparative','POL 273',false),
  ('POL 355','comparative','POL 216',false),
  ('POL 355','comparative','POL 219',false),
  ('POL 355','comparative','POL 239',false),
  ('POL 355','comparative','POL 255',false),
  ('POL 355','comparative','POL 258',false),
  ('POL 355','comparative','POL 261',false),
  ('POL 355','comparative','POL 273',false),
  ('POL 356','comparative','POL 255',false),
  ('POL 356','comparative','POL 257',false),
  ('POL 356','comparative','POL 258',false),
  ('POL 356','comparative','POL 261',false),
  ('POL 356','comparative','POL 262',false),
  ('POL 356','comparative','POL 273',false),
  ('POL 356','stats','MAT 115',false),
  ('POL 356','stats','MAT 209',false)
) AS v(course_code, group_code, prerequisite_code, can_be_corequisite)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

INSERT INTO course_registration_rules(
  course_id,
  min_semester_index,
  min_prior_courses_dept,
  min_prior_courses_min_number,
  min_prior_courses_max_number,
  min_prior_courses_count,
  notes
)
SELECT c.id,
       v.min_semester_index,
       v.min_prior_courses_dept,
       v.min_prior_courses_min_number,
       v.min_prior_courses_max_number,
       v.min_prior_courses_count,
       v.notes
FROM courses c
JOIN (VALUES
  ('POL 220',2,NULL,NULL,NULL,NULL,'Second-year standing.'),
  ('POL 310',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 319',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 320',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 350',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 352',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 354',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 355',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.'),
  ('POL 356',4,NULL,NULL,NULL,NULL,'Third- or fourth-year standing.')
) AS v(
  course_code,
  min_semester_index,
  min_prior_courses_dept,
  min_prior_courses_min_number,
  min_prior_courses_max_number,
  min_prior_courses_count,
  notes
) ON v.course_code = c.course_code
ON CONFLICT (course_id) DO UPDATE
SET min_semester_index = EXCLUDED.min_semester_index,
    min_prior_courses_dept = EXCLUDED.min_prior_courses_dept,
    min_prior_courses_min_number = EXCLUDED.min_prior_courses_min_number,
    min_prior_courses_max_number = EXCLUDED.min_prior_courses_max_number,
    min_prior_courses_count = EXCLUDED.min_prior_courses_count,
    notes = EXCLUDED.notes;
 
-- ------------------------------------------------------------
-- 3) Core: POL 101
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'POL_CORE_101', 'POL 101 Introduction to Political Science', 'must_take', 10
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 4) Subfield: American Politics (choose 1)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'POL_AMERICAN',
       'Subfield: American Politics (choose 1)',
       'choose_one',
       1,
       'Choose one course from the American Politics subfield: POL 216, POL 219, POL 220, POL 222, POL 237, POL 239, or POL 295 as approved.',
       20
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 5) Subfield: Comparative Politics (choose 1)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'POL_COMPARATIVE',
       'Subfield: Comparative Politics (choose 1)',
       'choose_one',
       1,
       'Choose one course from the Comparative Politics subfield: POL 255, POL 257, POL 258, POL 261, POL 262, POL 273, or POL 295 as approved.',
       30
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 6) Subfield: International Politics (choose 1)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'POL_INTERNATIONAL',
       'Subfield: International Politics (choose 1)',
       'choose_one',
       1,
       'Choose one course from the International Politics subfield: POL 250, POL 251, POL 259, or POL 295 as approved. Political theory courses POL 263 and POL 264 may also count where approved by the department.',
       40
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 7) 300-level requirement: 8 credits (2 seminars)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'POL_300_LEVEL',
       '300-level Seminars: 8 credits',
       'custom',
       8,
       'Must complete 8 credits (two courses) at the 300-level after completing the appropriate 200-level prerequisite for each. Third- or fourth-year status is a prerequisite for all 300-level courses. POL 320 or PST 320 counts toward this requirement only if taught by a political scientist and the formal 200-level prerequisite is met. Courses entered without following the specified prerequisite sequence cannot be used to fulfill this requirement.',
       50
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 8) Statistics requirement (outside the 32 credits)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'POL_STATS',
       'Statistics requirement: MAT 115/SST 115 or MAT 209 (not counted in 32 credits)',
       'choose_one',
       1,
       'Students must take MAT 115/SST 115 or MAT 209 at Grinnell. AP Statistics and transfer credits do not apply. This requirement is in addition to the 32 major credits.',
       60
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 9) Outside department electives (up to 8 credits)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'POL_OUTSIDE_CAP',
       'Outside department: up to 8 credits with advisor approval',
       'custom',
       0,
       'With advisor approval, up to 8 of the 32 required credits may be taken in related studies outside the department, at the 200-level or above.',
       70
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 10) Overall totals
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'POL_TOTALS',
       'Major totals and policy constraints',
       'custom',
       32,
       'Minimum 32 credits total, including POL 101, one course in each of three subfields (American, Comparative, International), and 8 credits at the 300-level. Statistics (MAT 115/SST 115 or MAT 209) is required in addition to the 32 credits. Up to 8 credits may be taken outside the department with advisor approval.',
       80
FROM majors m
WHERE m.code = 'POL'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 11) Attach course options
-- ------------------------------------------------------------
 
-- Core: POL 101
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'POL 101'
WHERE m.code = 'POL'
  AND b.code = 'POL_CORE_101'
ON CONFLICT DO NOTHING;
 
-- American Politics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'POL 216','POL 219','POL 220','POL 222','POL 237','POL 239','POL 295'
)
WHERE m.code = 'POL'
  AND b.code = 'POL_AMERICAN'
ON CONFLICT DO NOTHING;
 
-- Comparative Politics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'POL 255','POL 257','POL 258','POL 261','POL 262','POL 273','POL 295'
)
WHERE m.code = 'POL'
  AND b.code = 'POL_COMPARATIVE'
ON CONFLICT DO NOTHING;
 
-- International Politics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'POL 250','POL 251','POL 259','POL 263','POL 264','POL 295'
)
WHERE m.code = 'POL'
  AND b.code = 'POL_INTERNATIONAL'
ON CONFLICT DO NOTHING;
 
-- 300-level seminars
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'POL 310','POL 319','POL 320','POL 350',
  'POL 352','POL 354','POL 355','POL 356',
  'PST 320'
)
WHERE m.code = 'POL'
  AND b.code = 'POL_300_LEVEL'
ON CONFLICT DO NOTHING;
 
-- Statistics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 115','SST 115','MAT 209')
WHERE m.code = 'POL'
  AND b.code = 'POL_STATS'
ON CONFLICT DO NOTHING;
 
COMMIT;
