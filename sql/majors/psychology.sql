BEGIN;
 
-- ============================================================
-- Psychology (PSY)
-- ============================================================
 
-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('PSY', 'Psychology')
ON CONFLICT (code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
-- Core
('PSY',113,'PSY 113','Introduction to Psychology',4),
('PSY',225,'PSY 225','Research Methods',4),
('PSY',495,'PSY 495','Senior Seminar',4),
 
-- 200-level electives (excludes PSY 225/297/299)
('PSY',214,'PSY 214','Social Psychology',4),
('PSY',220,'PSY 220','Decision-Making',4),
('PSY',222,'PSY 222','Industrial Psychology',4),
('PSY',232,'PSY 232','Human-Computer Interaction',2),
('PSY',233,'PSY 233','Developmental Psychology',4),
('PSY',243,'PSY 243','Behavior Analysis',4),
('PSY',246,'PSY 246','Physiological Psychology',4),
('PSY',248,'PSY 248','Abnormal Psychology',4),
('PSY',250,'PSY 250','Health Psychology',4),
('PSY',260,'PSY 260','Cognitive Psychology',4),
('PSY',297,'PSY 297','Special Studies (ineligible for 200-level elective)',4),
('PSY',299,'PSY 299','Mentored Advanced Project (ineligible for 200-level elective)',4),
 
-- 300/400-level electives (excludes PSY 495)
('PSY',311,'PSY 311','History of Psychological Theories',4),
('PSY',315,'PSY 315','Advanced Social Psychology: Cross-Cultural Differences in Self-Construal',4),
('PSY',317,'PSY 317','Personality Psychology',4),
('PSY',332,'PSY 332','Advanced Developmental Psychology',4),
('PSY',334,'PSY 334','Adult Development',4),
('PSY',335,'PSY 335','Psychology of Motivation',4),
('PSY',336,'PSY 336','Advanced Behavioral Neuroscience',4),
('PSY',337,'PSY 337','Psychological Measurement',4),
('PSY',345,'PSY 345','Psychopharmacology',4),
('PSY',348,'PSY 348','Behavioral Medicine',4),
('PSY',349,'PSY 349','Counseling Psychology',4),
('PSY',355,'PSY 355','Psychology of Language',4),
('PSY',360,'PSY 360','Advanced Cognitive Psychology',4),
('PSY',370,'PSY 370','Multicultural Psychology',4),
('PSY',394,'PSY 394','Advanced Topics: Special Studies',4),
('PSY',397,'PSY 397','Special Studies (max 4 credits toward 300/400 elective)',4),
('PSY',399,'PSY 399','Mentored Advanced Project (max 4 credits toward 300/400 elective)',4),
('PSY',499,'PSY 499','Senior Thesis (max 4 credits toward 300/400 elective)',4),
 
-- Statistics (also required)
('MAT',115,'MAT 115','Introduction to Statistics',4),
('MAT',209,'MAT 209','Applied Statistics',4),
('SST',115,'SST 115','Introduction to Statistics',4),
('STA',209,'STA 209','Applied Statistics',4),
('NRS',250,'NRS 250',NULL,4),
('CSC',105,'CSC 105','The Digital Age',4),
('CSC',151,'CSC 151','Functional Problem Solving',4),
('TEC',154,'TEC 154','Evolution of Technology',4)
 
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
    'PSY 113','PSY 214','PSY 220','PSY 222','PSY 225','PSY 232',
    'PSY 233','PSY 243','PSY 246','PSY 248','PSY 250','PSY 260',
    'PSY 311','PSY 315','PSY 317','PSY 332','PSY 334','PSY 335',
    'PSY 336','PSY 337','PSY 345','PSY 348','PSY 349','PSY 355',
    'PSY 360','PSY 370','PSY 495'
  );

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('PSY 113','Fall'), ('PSY 113','Spring'),
  ('PSY 214','Fall'),
  ('PSY 220','Spring'),
  ('PSY 222','Fall'),
  ('PSY 225','Fall'), ('PSY 225','Spring'),
  ('PSY 232','Fall'), ('PSY 232','Spring'),
  ('PSY 233','Spring'),
  ('PSY 243','Spring'),
  ('PSY 246','Fall'),
  ('PSY 248','Spring'),
  ('PSY 250','Fall'),
  ('PSY 260','Spring'),
  ('PSY 311','Fall'),
  ('PSY 315','Spring'),
  ('PSY 317','Spring'),
  ('PSY 332','Fall'),
  ('PSY 334','Fall'),
  ('PSY 335','Fall'),
  ('PSY 336','Spring'),
  ('PSY 337','Fall'),
  ('PSY 345','Spring'),
  ('PSY 348','Fall'),
  ('PSY 349','Fall'),
  ('PSY 355','Fall'),
  ('PSY 360','Fall'),
  ('PSY 370','Fall'),
  ('PSY 495','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN (
    'PSY 214','PSY 220','PSY 222','PSY 225','PSY 232','PSY 233',
    'PSY 243','PSY 246','PSY 248','PSY 250','PSY 260','PSY 311',
    'PSY 315','PSY 317','PSY 332','PSY 334','PSY 335','PSY 336',
    'PSY 337','PSY 345','PSY 348','PSY 349','PSY 355','PSY 360',
    'PSY 370','PSY 495'
  );

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN (
    'PSY 214','PSY 220','PSY 222','PSY 225','PSY 232','PSY 233',
    'PSY 243','PSY 246','PSY 248','PSY 250','PSY 260','PSY 311',
    'PSY 315','PSY 317','PSY 332','PSY 334','PSY 335','PSY 336',
    'PSY 337','PSY 345','PSY 348','PSY 349','PSY 355','PSY 360',
    'PSY 370','PSY 495'
  );

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('PSY 214','psy113','PSY 113',false),
  ('PSY 214','stats','MAT 115',true),
  ('PSY 214','stats','SST 115',true),
  ('PSY 214','stats','MAT 209',true),
  ('PSY 220','psy113','PSY 113',false),
  ('PSY 220','stats','MAT 115',false),
  ('PSY 220','stats','SST 115',false),
  ('PSY 220','stats','MAT 209',false),
  ('PSY 222','psy113','PSY 113',false),
  ('PSY 222','stats','MAT 115',false),
  ('PSY 222','stats','SST 115',false),
  ('PSY 222','stats','MAT 209',false),
  ('PSY 225','psy113','PSY 113',false),
  ('PSY 225','stats','MAT 115',false),
  ('PSY 225','stats','SST 115',false),
  ('PSY 225','stats','MAT 209',false),
  ('PSY 232','intro','CSC 105',false),
  ('PSY 232','intro','CSC 151',false),
  ('PSY 232','intro','PSY 113',false),
  ('PSY 232','intro','TEC 154',false),
  ('PSY 233','psy113','PSY 113',false),
  ('PSY 233','stats','MAT 115',false),
  ('PSY 233','stats','SST 115',false),
  ('PSY 233','stats','MAT 209',false),
  ('PSY 243','psy113','PSY 113',false),
  ('PSY 243','stats','MAT 115',false),
  ('PSY 243','stats','SST 115',false),
  ('PSY 243','stats','MAT 209',false),
  ('PSY 246','psy113','PSY 113',false),
  ('PSY 248','psy113','PSY 113',false),
  ('PSY 250','psy113','PSY 113',false),
  ('PSY 250','stats','MAT 115',true),
  ('PSY 250','stats','SST 115',true),
  ('PSY 250','stats','MAT 209',true),
  ('PSY 260','psy113','PSY 113',false),
  ('PSY 260','stats','MAT 115',false),
  ('PSY 260','stats','SST 115',false),
  ('PSY 260','stats','MAT 209',false),
  ('PSY 311','stats','MAT 115',false),
  ('PSY 311','stats','SST 115',false),
  ('PSY 311','stats','MAT 209',false),
  ('PSY 315','psy214','PSY 214',false),
  ('PSY 315','psy225','PSY 225',false),
  ('PSY 317','psy225','PSY 225',false),
  ('PSY 332','psy225','PSY 225',false),
  ('PSY 332','psy233','PSY 233',false),
  ('PSY 334','psy225','PSY 225',false),
  ('PSY 335','psy225','PSY 225',false),
  ('PSY 335','neuro','PSY 246',false),
  ('PSY 335','neuro','NRS 250',false),
  ('PSY 336','psy225','PSY 225',false),
  ('PSY 336','psy246','PSY 246',false),
  ('PSY 337','psy225','PSY 225',false),
  ('PSY 345','psy225','PSY 225',false),
  ('PSY 345','neuro','NRS 250',false),
  ('PSY 345','neuro','PSY 246',false),
  ('PSY 348','psy225','PSY 225',false),
  ('PSY 348','psy243','PSY 243',false),
  ('PSY 349','psy225','PSY 225',false),
  ('PSY 349','psy248','PSY 248',false),
  ('PSY 355','psy225','PSY 225',false),
  ('PSY 355','psy260','PSY 260',false),
  ('PSY 360','psy225','PSY 225',false),
  ('PSY 360','psy260','PSY 260',false),
  ('PSY 370','psy225','PSY 225',false)
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
  ('PSY 311',NULL,'PSY',200,499,2,'Two psychology courses numbered 200 or above.'),
  ('PSY 317',NULL,'PSY',200,499,2,'Two additional psychology courses numbered 200 or above.'),
  ('PSY 332',NULL,'PSY',200,499,1,'One additional psychology course numbered 200 or above.'),
  ('PSY 334',NULL,'PSY',200,499,2,'Two psychology courses numbered 200 or above.'),
  ('PSY 335',NULL,'PSY',200,499,1,'One additional psychology course numbered 200 or above.'),
  ('PSY 337',NULL,'PSY',200,499,2,'Two additional psychology courses numbered 200 or above.'),
  ('PSY 370',NULL,'PSY',200,499,2,'Two additional psychology courses numbered 200 or above.'),
  ('PSY 495',6,NULL,NULL,NULL,NULL,'Senior psychology majors.')
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
-- 3) Core: PSY 113
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'PSY_CORE_113', 'PSY 113 Introduction to Psychology', 'must_take', 10
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 4) Core: PSY 225
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'PSY_CORE_225', 'PSY 225 Research Methods', 'must_take', 20
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 5) Core: PSY 495
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'PSY_CORE_495', 'PSY 495 Senior Seminar', 'must_take', 30
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 6) 200-level Electives: 12 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'PSY_200_ELECTIVES',
       '200-level Electives: 12 credits',
       'custom',
       12,
       'Any 200-level Psychology course except PSY 225, PSY 297, and PSY 299. Only 2 credits from Plus-2 courses may apply toward this requirement.',
       40
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 7) 300/400-level Electives: 8 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'PSY_300_ELECTIVES',
       '300/400-level Electives: 8 credits',
       'custom',
       8,
       'Any 300- or 400-level Psychology course except PSY 495. Only 4 credits from PSY 397, PSY 399, or PSY 499 combined may apply. PSY 225 (Research Methods) is a prerequisite for all 300-level courses except PSY 311.',
       50
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 8) Laboratory requirement
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'PSY_LAB_REQ',
       'Laboratory Requirement: at least 2 lab courses above 100-level',
       'custom',
       2,
       'At least two courses above the 100-level must be laboratory courses. These may overlap with the 200-level or 300/400-level elective requirements.',
       60
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 9) Statistics (also required, not counted in 32 credits)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'PSY_STATS',
       'Statistics: MAT 115/SST 115 or MAT 209 (also required)',
       'choose_one',
       1,
       'Complete MAT 115/SST 115 (Introduction to Statistics) or MAT 209 (Applied Statistics). Students are encouraged to take this early in their college career.',
       70
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 10) Overall totals
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'PSY_TOTALS',
       'Major totals and policy constraints',
       'custom',
       32,
       'Minimum 32 credits: 12 core (PSY 113 + PSY 225 + PSY 495), 12 credits of 200-level electives, 8 credits of 300/400-level electives. At least 2 lab courses above 100-level required. MAT 115/SST 115 or MAT 209 also required. Only 2 Plus-2 credits may count toward 200-level electives; only 4 credits from PSY 397/399/499 may count toward 300/400-level electives.',
       80
FROM majors m
WHERE m.code = 'PSY'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 11) Attach course options
-- ------------------------------------------------------------
 
-- Core
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'PSY 113'
WHERE m.code = 'PSY' AND b.code = 'PSY_CORE_113'
ON CONFLICT DO NOTHING;
 
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'PSY 225'
WHERE m.code = 'PSY' AND b.code = 'PSY_CORE_225'
ON CONFLICT DO NOTHING;
 
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'PSY 495'
WHERE m.code = 'PSY' AND b.code = 'PSY_CORE_495'
ON CONFLICT DO NOTHING;
 
-- 200-level electives
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'PSY 214','PSY 220','PSY 222','PSY 232','PSY 233','PSY 243',
  'PSY 246','PSY 248','PSY 250','PSY 260'
)
WHERE m.code = 'PSY' AND b.code = 'PSY_200_ELECTIVES'
ON CONFLICT DO NOTHING;
 
-- 300/400-level electives
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'PSY 311','PSY 315','PSY 317','PSY 332','PSY 334','PSY 335',
  'PSY 336','PSY 337','PSY 345','PSY 348','PSY 349','PSY 355',
  'PSY 360','PSY 370','PSY 394','PSY 397','PSY 399','PSY 499'
)
WHERE m.code = 'PSY' AND b.code = 'PSY_300_ELECTIVES'
ON CONFLICT DO NOTHING;
 
-- Statistics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 115','SST 115','MAT 209')
WHERE m.code = 'PSY' AND b.code = 'PSY_STATS'
ON CONFLICT DO NOTHING;
 
COMMIT;
