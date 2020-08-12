# [The SQL Murder Mystery](http://mystery.knightlab.com/)

A crime has taken place and the detective needs your help. The detective gave you the crime scene report, but you somehow lost it. You vaguely remember that the crime was a __murder__ that occurred sometime on __Jan.15, 2018__ and that it took place in __SQL City__. Start by retrieving the corresponding crime scene report from the police department’s database.

### Searching for murder on __Jan.15, 2018__

~~~sql
SELECT * 
    FROM crime_scene_report 
    WHERE date=20180115 AND type='murder' AND city='SQL City';
~~~
Result:
|date|type|description|city|
| ------ | ------ | ------ | ------ |
|20180115|murder|Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".|SQL City|

### Seeking the witnesses

#### The first witness, the one who lives in the last house of "Northwestern Dr".
~~~sql
SELECT * FROM person 
WHERE address_street_name='Northwestern Dr' 
Order by address_number desc
LIMIT 1
~~~
Result:
|id|name|license_id |address_number|address_street_name|ssn|
| ------ | ------ | ------ | ------ | ------ |------ |
|14887|Morty Schapiro|118009|4919|Northwestern Dr|111564949|

#### The second witness, the one who is named Annabel, lives somewhere on "Franklin Ave".
~~~sql
SELECT * FROM person 
WHERE 
	address_street_name='Franklin Ave' 
AND 
	name like 'Annabel%'
~~~
Result:
|id|name|license_id |address_number|address_street_name|ssn|
| ------ | ------ | ------ | ------ | ------ |------ |
|16371|Annabel Miller|490173|103|Franklin Ave|318771143|

### What the witnesses told
~~~sql
SELECT p.name,p.id,i.transcript 
FROM interview as i
JOIN person as p on p.id=i.person_id
WHERE i.person_id in (14887,16371)
~~~
Result:
|name|id|transcript |
| ------ | ------ | ------ |
|Morty Schapiro|14887|I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".|
|Annabel Miller|16371|I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.|

#### Verifying what Morty Schapiro said

>'I heard a gunshot and then saw a man run out.  
> He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z".
> Only gold members have those bags. The man got into a car with a plate that included "H42W".
##### Cheking __clue__: The man got into a car with a plate that included "H42W"

~~~sql
SELECT 
	p.name, p.id,
	d.id as license, d.age, d.height, d.eye_color as eye, 
	d.hair_color as hair, d.gender, d.plate_number,
	d.car_make as brand, d.car_model as model
FROM drivers_license as d 
JOIN person as p on d.id = p.license_id
WHERE d.plate_number like '%H42W%'
~~~
Result:
|name|id|license|age|height|eye|hair|gender|plate_number|brand|model|
|------|------|------|------|------|------|------|------|------|------|------|
|Tushar Chandra|51739|664760|21|71|black|black|male|4H42WR|Nissan|Altima
|Jeremy Bowers|67318|423327|30|70|brown|brown|male|0H42W2|Chevrolet|Spark LS|
|Maxine Whitely|78193|183779|21|65|blue|blonde|female|H42W0X|Toyota|Prius|
##### Cheking __clue__: He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags.

~~~sql
SELECT * FROM get_fit_now_member WHERE id like '48Z%' AND membership_status='gold'
~~~
Result:
|id|person_id|name|membership_start_date|membership_status|
|------|------|------|------|------|
|48Z7A|28819|Joe Germuska|20160305|gold|
|48Z55|67318|Jeremy Bowers|20160101|gold|

#### Verifying what Annabel Miller said

>I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
##### Cheking __clue__: I saw the murder happen, and I recognized the killer FROM my gym when I was working out last week on January the 9th.

~~~sql
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
WHERE c.check_in_date = 20180109
~~~
Result:

|membership_id|person_id|name|start_date|status|entre|out|
|------|------|------|------|------|------|------|
|X0643|15247|Shondra Ledlow|20170521|silver|957|1164|
|UK1F2|28073|Zackary Cabotage|20170818|silver|344|518|
|XTE42|55662|Sarita Bartosh|20170524|gold|486|1124|
|1AE2H|10815|Adriane Pelligra|20170816|silver|461|944|
|6LSTG|83186|Burton Grippe|20170214|gold|399|515|
|7MWHJ|31523|Blossom Crescenzo|20180309|regular|273|885|
|GE5Q8|92736|Carmen Dimick|20170618|gold|367|959|
|48Z7A|28819|Joe Germuska|20160305|gold|1600|1730|
|48Z55|67318|Jeremy Bowers|20160101|gold|1530|1700|
|90081|16371|Annabel Miller|20160208|gold|1600|1700|

#### Combine two clues:
> 'I saw the murder happen, and I recognized the killer FROM my gym when I was working out last week on January the 9th.' 
>and
>'He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags.'
~~~sql
SELECT m.name , m.person_id
FROM get_fit_now_member as m
JOIN get_fit_now_check_in as c on m.id=c.membership_id
WHERE m.id like '48Z%' 
and m.membership_status='gold'
and c.check_in_date = 20180109
~~~
|name|person_id|
|------|------|
|Joe Germuska|28819|
|Jeremy Bowers|67318|

### Interview of the main suspect: __Jeremy Bowers__

~~~sql
SELECT * FROM interview WHERE person_id =67318
~~~
Result:
|person_id|transcript|
|------|------|
|67318|I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.|

#### Verifying what __Jeremy Bowers__ said:
> I know she's around 5'5" (65") or 5'7" (67").
> She has red hair.
> I know that she attended the SQL Symphony Concert 3 times in December 2017.

~~~sql
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
~~~
Result:
|name|hair_color|height|id|event_id|event_name|date|
|------|------|------|------|------|------|------|
|Miranda Priestly|red|66|99716|1143|SQL Symphony Concert|20171206|
|Miranda Priestly|red|66|99716|1143|SQL Symphony Concert|20171212|
|Miranda Priestly|red|66|99716|1143|SQL Symphony Concert|20171229|
>I know she's around 5'5" (65") or 5'7" (67"). 
>She has red hair and she drives a Tesla Model S..
~~~sql
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
	d.height between 65 and 67
~~~
Result:
|name|id|license|age|height|eye|hair|gender|plate_number|brand|model|
|------|------|------|------|------|------|------|------|------|------|------|
|Red Korb|78881|918773|48|65|black|red|female|917UU3|Tesla|Model S|
|Regina George|90700|291182|65|66|blue|red|female|08CM64|Tesla|Model S|
|Miranda Priestly|99716|202298|68|66|green|red|female|500123|Tesla|Model S|

## Resolution

~~~sql
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
SELECT value FROM solution;
~~~
|Value|
|------|
|Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villian behind this crime. If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries. Use this same INSERT statement to check your answer.|

~~~sql
INSERT INTO solution VALUES (1, 'Miranda Priestly');
SELECT value FROM solution;
~~~
|Value|
|------|
|Congrats, you found the brains behind the murder! Everyone in SQL City hails you as the greatest SQL detective of all time. Time to break out the champagne!|


