-- Lab | SQL Advanced queries --
use sakila;

-- List each pair of actors that have worked together.
select * from film_actor;
select * from actor;

with cte_pairs_of_actors as (
select fa1.film_id, 
fa1.actor_id as first_actor_id, 
a1.first_name as first_actor_name, 
a1.last_name as first_actor_last_name,
fa2.actor_id as second_actor_id, 
a2.first_name as second_actor_first_name, 
a2.last_name as second_actor_last_name
from film_actor fa1
join film_actor fa2
on fa1.film_id = fa2.film_id
and fa1.actor_id <> fa2.actor_id
join actor a1 
on a1.actor_id = fa1.actor_id
join actor a2
on a2.actor_id = fa2.actor_id
order by a1.actor_id)
select * from cte_pairs_of_actors;


-- 2. For each film, list actor that has acted in more films.

select * from film;
select * from film_actor;
select * from actor;

-- step 1: Creating a view with all the movies played by actor

select actor_id, count(film_id) as total_films_played from film_actor group by actor_id order by count(film_id) desc;
create or replace view starring_actors as
with cte_actors_in_movies as (
select actor_id, count(film_id) as total_films_played
from film_actor
group by actor_id
order by count(film_id) desc
)
select * from cte_actors_in_movies;
select * from starring_actors;


-- step 2: Find all the actors who played in each film

select fa.film_id, title, concat(first_name, " ", last_name) as actor_name, sa.total_films_played
from starring_actors sa
join film_actor fa
on sa.actor_id = fa.actor_id
join film f
on fa.film_id = f.film_id
join actor a
on sa.actor_id = a.actor_id;

-- step 3: Ranking the actors per film


select *, row_number() over(partition by film_id order by total_films_played desc) as ranking
from (
	select fa.film_id, title, concat(first_name, " ", last_name) as actor_name, sa.total_films_played
	from starring_actors sa
	join film_actor fa
	on sa.actor_id = fa.actor_id
	join film f
	on fa.film_id = f.film_id
	join actor a
	on sa.actor_id = a.actor_id
)sub1;

-- step 4: final query


select film_id, title, actor_name, total_films_played from (
	select *, row_number() over(partition by film_id order by total_films_played desc) as ranking
	from (
		select fa.film_id, title, concat(first_name, " ", last_name) as actor_name, sa.total_films_played
		from starring_actors sa
		join film_actor fa
		on sa.actor_id = fa.actor_id
		join film f
		on fa.film_id = f.film_id
		join actor a
		on sa.actor_id = a.actor_id
	)sub1
)sub2
where ranking = 1;

#Note: Disclaimer: I worked with Victor on this Lab that's why our syntax is the same or almost the same.