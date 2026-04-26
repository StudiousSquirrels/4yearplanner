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
 
-- 200-level electives (representative list; excludes PSY 225/297/299)
('PSY',214,'PSY 214','Behavioral Neuroscience',4),
('PSY',217,'PSY 217','Abnormal Psychology',4),
('PSY',218,'PSY 218','Health Psychology',4),
('PSY',220,'PSY 220','Cognitive Psychology',4),
('PSY',222,'PSY 222','Developmental Psychology',4),
('PSY',223,'PSY 223','Social Psychology',4),
('PSY',226,'PSY 226','Sensation and Perception',4),
('PSY',230,'PSY 230','Industrial/Organizational Psychology',4),
('PSY',247,'PSY 247','Psychology of Language',4),
('PSY',248,'PSY 248','Animal Behavior',4),
('PSY',250,'PSY 250','Personality',4),
('PSY',270,'PSY 270','Cross-Cultural Psychology',4),
('PSY',297,'PSY 297','Special Studies (ineligible for 200-level elective)',4),
('PSY',299,'PSY 299','Mentored Advanced Project (ineligible for 200-level elective)',4),
 
-- 300/400-level electives (excludes PSY 495)
('PSY',311,'PSY 311','History and Systems of Psychology',4),
('PSY',315,'PSY 315','Advanced Behavioral Neuroscience',4),
('PSY',320,'PSY 320','Advanced Cognitive Psychology',4),
('PSY',325,'PSY 325','Advanced Developmental Psychology',4),
('PSY',330,'PSY 330','Advanced Social Psychology',4),
('PSY',336,'PSY 336','Psychology of Prejudice and Discrimination',4),
('PSY',350,'PSY 350','Advanced Topics in Psychology',4),
('PSY',394,'PSY 394','Advanced Topics: Special Studies',4),
('PSY',397,'PSY 397','Special Studies (max 4 credits toward 300/400 elective)',4),
('PSY',399,'PSY 399','Mentored Advanced Project (max 4 credits toward 300/400 elective)',4),
('PSY',499,'PSY 499','Senior Thesis (max 4 credits toward 300/400 elective)',4),
 
-- Statistics (also required)
('SST',115,'SST 115','Introduction to Statistics',4),
('STA',209,'STA 209','Applied Statistics',4)
 
ON CONFLICT (course_code) DO NOTHING;
 
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
       'Statistics: SST 115 or STA 209 (also required)',
       'choose_one',
       1,
       'Complete SST 115 (Introduction to Statistics) or STA 209 (Applied Statistics). Students are encouraged to take this early in their college career.',
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
       'Minimum 32 credits: 12 core (PSY 113 + PSY 225 + PSY 495), 12 credits of 200-level electives, 8 credits of 300/400-level electives. At least 2 lab courses above 100-level required. SST 115 or STA 209 also required. Only 2 Plus-2 credits may count toward 200-level electives; only 4 credits from PSY 397/399/499 may count toward 300/400-level electives.',
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
  'PSY 214','PSY 217','PSY 218','PSY 220','PSY 222','PSY 223',
  'PSY 226','PSY 230','PSY 247','PSY 248','PSY 250','PSY 270'
)
WHERE m.code = 'PSY' AND b.code = 'PSY_200_ELECTIVES'
ON CONFLICT DO NOTHING;
 
-- 300/400-level electives
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'PSY 311','PSY 315','PSY 320','PSY 325','PSY 330',
  'PSY 336','PSY 350','PSY 394','PSY 397','PSY 399','PSY 499'
)
WHERE m.code = 'PSY' AND b.code = 'PSY_300_ELECTIVES'
ON CONFLICT DO NOTHING;
 
-- Statistics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('SST 115','STA 209')
WHERE m.code = 'PSY' AND b.code = 'PSY_STATS'
ON CONFLICT DO NOTHING;
 
COMMIT;