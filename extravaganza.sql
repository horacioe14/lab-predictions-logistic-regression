''' Case 1:

Trying to predict if a customer will be renting a film this month based on their previous activity. 
We will first construct a table with:

Customer ID
City
Most rented film category
Total films rented
Total money spent
How many films rented last month (MAY/2005)
If the customer rented a movie this month (JUNE/2005)
Once you extract that information, and any other that seems fit, predict which customers will be renting this month ''' 

/* coalesce(cast(r.return_date as date), 'not returned') as return_date, */ 
/* case 
when cast(r.return_date as date) is null
then 'not returned' else cast(r.return_date as date) 
end as return_date */

use sakila;
create view loan_status_B as
select * from bank.loan
where status = 'B';



create or replace view table_1 as 
select p.customer_id, 
count(r.rental_date) as total_rented_films, 
sum(p.amount) as total_amount, 
datediff(max(cast(r.rental_date as date)),min(cast(r.rental_date as date))) as customer_longetivity,
case
when (sum(if(substr(rental_date,1,7) = '2005-06', 1,0)) >= 1)
then 1 else 0
end as if_rented_june_2005
from sakila.payment as p
join sakila.rental as r 
on p.rental_id = r.rental_id
join sakila.customer as c 
on c.customer_id = p.customer_id
join sakila.address as a 
on a.address_id = c.address_id
group by p.customer_id
order by customer_id asc;

select * from table_1;

use sakila;
create view table_2 as 
select customer_id, count(rental_id) as rented_may_2005
from rental
where substr(rental_date,1,7) = '2005-05'
group by customer_id
order by customer_id asc;
select * from table_2;





create or replace view table_3 as 
select customer_id, count(rental_id) as rented_june_2005
from rental
where substr(rental_date,1,7) = '2005-06'
group by customer_id
order by customer_id asc;
select * from table_3;

SELECT *
FROM table_1
LEFT JOIN table_2 using(customer_id)
LEFT JOIN table_3 using(customer_id);








# coalesce(return_date, 'not returned') other options 


select count(c.customer_id) as count_us
from sakila.customer as c 
join sakila.address as a 
on c.address_id = a.address_id
join sakila.city as ci 
on ci.city_id = a.city_id
join sakila.country as co
on co.country_id = ci.country_id
where co.country_id = 103;

select count(customer_id) as number_of_customers_in_US
from sakila.customer
where address_id in (
select address_id
from sakila.city
where city.country_id = 101
);

# City_id Store 1 = 300 city Lethbridge
# City id store 2 = 576 Woodridge





select c.first_name, c.last_name, count(r.customer_id) as rents_per_customer
from sakila.customer as c
join sakila.rental as r
on c.customer_id = r.customer_id
group by r.customer_id
order by count(r.customer_id) desc
limit 1;





-- how many stars actor in the film






/* Case 2:
We will be trying to predict if a film will be rented this month based on their previous activity and other details. We will first construct a table with:
Film ID
Category
Total number of copies
*Bonus - How many "stars" actrs. in the film *
How many times the film was rented last month (MAY/2005)
If the film was rented this month (JUNE/2005) */


create or replace view table_4 as 
select f.film_id, a.actor_id
from sakila.film as f
join sakila.film_actor as fa
on f.film_id = fa.film_id
join sakila.actor as a
on a.actor_id = fa.actor_id
where a.actor_id in (  #select only actor_id in subquery. Use =  instead of in
    select actor_id from (
    select a.actor_id, count(fa.film_id) as films_acted
    from sakila.film_actor as fa
    join sakila.actor as a
    on fa.actor_id = a.actor_id
    group by fa.actor_id, a.first_name
    order by films_acted desc
    limit 10) sub1
);

select * from table_4;


create or replace view table_5 as 
select film_id, count(inventory_id) as number_of_copies
from sakila.inventory
group by film_id;
select * from table_5;


create or replace view table_6 as 
select f.film_id, count(r.rental_id) as number_of_may_rentals
from sakila.film as f
join sakila.inventory as i
on f.film_id = i.film_id
join sakila.rental as r
on i.inventory_id = r.inventory_id
where substr(rental_date,1,7) = '2005-05'
group by f.film_id;
select * from table_6;

create or replace view table_7 as 
select f.film_id,
case
when sum((if(substr(rental_date,1,7) = '2005-06', 1,0)) >= 1)
then 1 else 0
end as if_rented_june_2005
from sakila.film as f
join sakila.inventory as i
on f.film_id = i.film_id
join sakila.rental as r
on i.inventory_id = r.inventory_id
group by f.film_id;
select * from table_7;

SELECT *
FROM table_7
LEFT JOIN table_5 using(film_id)
LEFT JOIN table_6 using(film_id)
LEFT JOIN table_4 using(film_id)
order by film_id asc;