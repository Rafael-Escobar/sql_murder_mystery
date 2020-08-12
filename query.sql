--A crime has taken place and the detective needs your help. The detective gave you the crime scene report, but you somehow lost it. You vaguely remember that the crime was a ​murder​ that occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​. Start by retrieving the corresponding crime scene report from the police department’s database.
SELECT * FROM crime_scene_report WHERE date=20180115 and type='murder' and city='SQL City';

-- The first witness lives at the last house on "Northwestern Dr". 
SELECT * FROM person 
WHERE address_street_name='Northwestern Dr' 
Order by address_number desc
LIMIT 1;

--The second witness, named Annabel, lives someWHERE on "Franklin Ave".
SELECT * FROM person 
WHERE 
	address_street_name='Franklin Ave' AND 	name like 'Annabel%';

    SELECT p.name,p.id,i.transcript 
FROM interview as i
JOIN person as p on p.id=i.person_id
WHERE i.person_id in (14887,16371);

-- What they told

SELECT p.name,p.id,i.transcript 
FROM interview as i
JOIN person as p on p.id=i.person_id
WHERE i.person_id in (14887,16371);

-- First clue
SELECT 
	p.name, p.id,
	d.id as license, d.age, d.height, d.eye_color as eye, 
	d.hair_color as hair, d.gender, d.plate_number,
	d.car_make as brand, d.car_model as model
FROM drivers_license as d 
JOIN person as p on d.id = p.license_id
WHERE d.plate_number like '%H42W%';

--Second clue
SELECT * FROM get_fit_now_member WHERE id like '48Z%' AND membership_status='gold';

--Third clue
SELECT 
	m.id as membership_id,
	m.person_id,
	m.name,
	m.membership_start_date as start_date,
	m.membership_status as status,
	c.check_in_time as entre,
	c.check_out_time as out
FROM get_fit_now_check_in as c 
JOIN get_fit_now_member as m on m.id=c.membership_id
WHERE c.check_in_date = 20180109;

--Combine the clues
SELECT m.name , m.person_id
FROM get_fit_now_member as m
JOIN get_fit_now_check_in as c on m.id=c.membership_id
WHERE m.id like '48Z%' 
and m.membership_status='gold'
and c.check_in_date = 20180109;


--The main suspect 
SELECT * FROM interview WHERE person_id =67318;

--Verify what the suspect told:
--I know she's around 5'5" (65") or 5'7" (67"). She has red hair. I know that she attended the SQL Symphony Concert 3 times in December 2017.
SELECT 
	p.name,
	d.hair_color,
	d.height,
	p.id,
	f.event_id,
	f.event_name,
	f.date
FROM facebook_event_checkin as f
JOIN person as p on p.id=f.person_id
JOIN drivers_license as d on d.id=p.license_id
WHERE 
	f.event_id=1143
and
	d.hair_color='red'
and 
	d.gender='female'
and 
	d.height between 65 and 67
and 
	f.date between 20171201 and 20171231;

--I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S.
SELECT 
	p.name, p.id,p.address_street_name as stree,p.ssn,
	d.id as license, d.age, d.height, d.eye_color as eye, 
	d.hair_color as hair, d.gender, d.plate_number,
	d.car_make as brand, d.car_model as model
FROM drivers_license as d 
JOIN person as p on d.id = p.license_id
WHERE 
	d.car_make='Tesla' 
and 
	d.car_model='Model S'
and
	d.hair_color='red'
and 
	d.gender='female'
and 
	d.height between 65 and 67;