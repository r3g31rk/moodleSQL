SELECT DISTINCT

-- INFOS PROFIL
u.city,
CONCAT('<a target="_<new"
href="%%WWWROOT%%/user/view.php?id=',u.id,'"><b>',u.email,'</b></a>') AS
username,
u.institution AS cursus,
u.department AS spe,

-- INFOS STATUT
CASE WHEN ra.roleid = 5 THEN 'student' WHEN ra.roleid = 12 THEN 'resp' WHEN
ra.roleid = 9 THEN 'pedago' ELSE 'unknown' END AS "role",
u.suspended AS "gandalfSusp",
CASE WHEN date_part('day',now() - to_timestamp(u.lastaccess)) > 365 THEN 365
ELSE  date_part('day',now() - to_timestamp(u.lastaccess)) END as
"gandalfAccess",
ue.status AS "courseSusp",
COALESCE((SELECT  date_part('days',now() - to_timestamp(ul.timeaccess)) FROM
prefix_user_lastaccess ul WHERE ul.userid = u.id AND ul.courseid = c.id), 365)
as "courseAccess",

-- INFOS GROUPES
(SELECT COUNT(g5.id) FROM prefix_course c5 JOIN prefix_groups g5 ON g5.courseid
= c5.id JOIN prefix_groups_members gm5 ON gm5.groupid = g5.id JOIN prefix_user
u5 ON u5.id = gm5.userid JOIN prefix_groupings_groups gpg5 ON gpg5.groupid =
g5.id JOIN prefix_groupings gp5 ON gp5.id=gpg5.groupingid WHERE u5.id=u.id AND
c5.id = c.id AND gp5.name = 'cities') AS "nbCityGrp",
(SELECT g5.name FROM prefix_course c5 JOIN prefix_groups g5 ON g5.courseid =
c5.id JOIN prefix_groups_members gm5 ON gm5.groupid = g5.id JOIN prefix_user u5
ON u5.id = gm5.userid JOIN prefix_groupings_groups gpg5 ON gpg5.groupid = g5.id
JOIN prefix_groupings gp5 ON gp5.id=gpg5.groupingid WHERE u5.id=u.id AND c5.id =
c.id AND gp5.name = 'cities' LIMIT 1) AS "1stCityGrp",
(SELECT COUNT(g4.id) FROM prefix_course c4 JOIN prefix_groups g4 ON g4.courseid
= c4.id JOIN prefix_groups_members gm4 ON gm4.groupid = g4.id JOIN prefix_user
u4 ON u4.id = gm4.userid JOIN prefix_groupings_groups gpg4 ON gpg4.groupid =
g4.id JOIN prefix_groupings gp4 ON gp4.id=gpg4.groupingid WHERE u4.id=u.id AND
c4.id = c.id AND gp4.name SIMILAR TO '(project|day|digitalResume)%') AS
"nbProjectGrp",
(SELECT g4.name FROM prefix_course c4 JOIN prefix_groups g4 ON g4.courseid =
c4.id JOIN prefix_groups_members gm4 ON gm4.groupid = g4.id JOIN prefix_user u4
ON u4.id = gm4.userid JOIN prefix_groupings_groups gpg4 ON gpg4.groupid = g4.id
JOIN prefix_groupings gp4 ON gp4.id=gpg4.groupingid WHERE u4.id=u.id AND c4.id =
c.id AND gp4.name SIMILAR TO '(project|day|digitalResume)%' LIMIT 1) AS
"1stProjectGrp",

-- INFOS EVALUATIONS
(SELECT COUNT(*) FROM prefix_competency_coursecomp cpc JOIN prefix_competency cp
ON cp.id=cpc.competencyid WHERE cpc.courseid = c.id AND cp.idnumber ~
'^MSC\d.\d.B(\d){2}-') AS "total",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id  WHERE ev.course = c.id AND cp.idnumber ~
'^MSC\d.\d.B(\d){2}-' AND evu.user_id = u.id AND evu.grade IS NOT NULL) AS
"evaluated",
CASE WHEN ra.roleid = 5 THEN (SELECT COUNT(*) FROM prefix_evaluations ev JOIN
prefix_evaluations_users evu ON evu.evaluations_id = ev.id JOIN
prefix_competency cp ON cp.id = evu.competency_id  WHERE ev.course = c.id AND
cp.idnumber ~ '^MSC\d.\d.B(\d){2}-' AND evu.user_id = u.id AND evu.grade IS NOT
NULL) - (SELECT COUNT(*) FROM prefix_competency_coursecomp cpc JOIN
prefix_competency cp ON cp.id=cpc.competencyid WHERE cpc.courseid = c.id AND
cp.idnumber ~ '^MSC\d.\d.B(\d){2}-') ELSE 0 END AS "unevaluated",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id WHERE ev.course = c.id AND cp.idnumber ~ '^MSC\d.\d.B(\d){2}-'
AND evu.user_id = u.id AND evu.grade = 1) AS "NA",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id WHERE ev.course = c.id AND cp.idnumber ~ '^MSC\d.\d.B(\d){2}-'
AND evu.user_id = u.id AND evu.grade = 2) AS "missing",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id WHERE ev.course = c.id AND cp.idnumber ~ '^MSC\d.\d.B(\d){2}-'
AND evu.user_id = u.id AND evu.grade = 3) AS "below",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id WHERE ev.course = c.id AND cp.idnumber ~ '^MSC\d.\d.B(\d){2}-'
AND evu.user_id = u.id AND evu.grade = 4) AS "meets",
(SELECT COUNT(*) FROM prefix_evaluations ev JOIN prefix_evaluations_users evu ON
evu.evaluations_id = ev.id JOIN prefix_competency cp ON cp.id =
evu.competency_id WHERE ev.course = c.id AND cp.idnumber ~ '^MSC\d.\d.B(\d){2}-'
AND evu.user_id = u.id AND evu.grade = 5) AS "above",
(SELECT evg.commentary FROM prefix_evaluations ev JOIN prefix_evaluations_users
evu ON evu.evaluations_id = ev.id JOIN prefix_evaluations_groups evg ON
evg.evaluations_id = ev.id AND evg.group_id = evu.group_id WHERE ev.course =
c.id AND evu.user_id = u.id LIMIT 1) AS "evalComment"

FROM prefix_course AS c
JOIN prefix_context AS ctx ON c.id = ctx.instanceid
JOIN prefix_role_assignments AS ra ON ra.contextid = ctx.id
JOIN prefix_user AS u ON u.id = ra.userid
JOIN prefix_enrol e ON e.courseid = c.id
JOIN prefix_user_enrolments ue ON ue.enrolid = e.id AND ue.userid = u.id

WHERE c.id = %%COURSEID%%
AND u.suspended = 0 		   -- users NON suspendus plateforme
AND ue.status = 0 		       -- users NON suspendus du cours

AND u.city LIKE (SELECT city FROM prefix_user WHERE id = %%USERID%%) -- display
only users from the same city as current user

-- AND ra.roleid = 5 			   -- users avec rôle student
-- AND u.idnumber LIKE 'msc202%'   -- avoid fake students
