-- Write queries that directly answer predetermined questions from a business stakeholder

-- Questions
-- 1) What are the top 5 brands by receipts scanned for most recent month?
-- 2) How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
-- 3) When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
-- 4) When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
-- 5) Which brand has the most spend among users who were created within the past 6 months?
-- 6) Which brand has the most transactions among users who were created within the past 6 months?



-- ###### QUESTION 1 ######
-- I am making the assumption that to identify a Brand then we need the actual Brands name, so I will only be evaluating receipts that have a match in the Brands table via the brand code
-- The brand code is pretty much a match for the brand name, but again I will be making the assumption that we want the actual "Brand Name" from the data
-- When using the above assumption, the most recent month in the data (2021-03) doesn't return any data, and the month before that only returns 1 row. This is because there are no matches or almost no matches between the two tables. This is a data quality issue.
-- Because of this data quality issue, for this question I will be analyzing the rank 2 months ago which provides more than 5 rows of brands to rank.
-- Our join key (brand code) should theoretically be unique in the brand table, but there are a handful of duplicates.
-- This could cause fanout but for simplicity sake we will assume it's unique. The duplicates are 'HUGGIES' and 'GOODNITES' which are not even in the top 5 so it shouldn't cause error in this one analysis.
-- I'm ranking by receipts scanned as the question asks, but I'm using the total number of items purchased as a tiebreaker
select
    receipt_items.brand_code,
    brands.brand_name,
    to_varchar(receipt_items.scanned_date, 'YYYY-MM') as month,
    count(distinct receipt_items.receipt_id) as receipts_scanned,
    sum(receipt_items.quantity_purchased) as total_items_purchased,
    rank() over (order by count(distinct receipt_items.receipt_id) desc, sum(receipt_items.quantity_purchased) desc) as ranking
from fetch_db.fetch.receipt_items
inner join fetch_db.fetch.brands
    on receipt_items.brand_code = brands.brand_code
--Filter for 2 months ago (January)
where 1=1
    and receipt_items.scanned_date >= ((select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '2 month')
    and receipt_items.scanned_date < ((select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '1 month')
group by 1,2,3
qualify ranking <= 5
order by 3 desc, 6
;
-- Answer: Pepsi, Kraft, Kleenex, KNORR, Doritos



-- ###### QUESTION 2 ######
-- I tried using the same assumption as in question 1 (we can only identify a brand by the actual "Brand Name" from the data)
-- However, when using that assumption, the only receipts that have a matching join from the brands table (using both brand_code and barcode as keys) are receipts from Jan 2021 and a few from Feb 2022 which are only associated with 1 Brand.
-- This doesn't give us the ability to answer the question properly, so instead I will be dumping that assumption and using a new assumption that we can properly identify a brand just by its brand code.
-- With this assumption I won't need to join the brands table to get the Brand Name and instead can directly use the brand code from the receipt_items table
-- But even this new assumtion doesn't produce great data. Still, only receipts from Jan 2021 and Feb 2021 have brand codes that aren't all NULL and even these months still have numerous receipts with NULL brand codes
-- February produces 3 aggregated non-null brand codes, so I will be comparing the Feb stats with Jan stats for those 3 brands instead of 5 brands as asked for in the question
with feb as (
    select
        brand_code,
        to_varchar(scanned_date, 'YYYY-MM') as month,
        count(distinct receipt_id) as receipts_scanned,
        sum(quantity_purchased) as total_items_purchased,
        rank() over (partition by to_varchar(scanned_date, 'YYYY-MM') order by count(distinct receipt_id) desc, sum(quantity_purchased) desc) as ranking
    from fetch_db.fetch.receipt_items
    --Filter for 1 & 2 months ago (Feb & Jan) and non-null brand codes
    where 1=1
        and scanned_date >= (select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '1 month'
        and scanned_date < (select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '0 month'
        and brand_code is not null
    group by 1,2
),
jan as (
    select
        brand_code,
        to_varchar(scanned_date, 'YYYY-MM') as month,
        count(distinct receipt_id) as receipts_scanned,
        sum(quantity_purchased) as total_items_purchased,
        rank() over (partition by to_varchar(scanned_date, 'YYYY-MM') order by count(distinct receipt_id) desc, sum(quantity_purchased) desc) as ranking
    from fetch_db.fetch.receipt_items
    --Filter for 1 & 2 months ago (Feb & Jan) and non-null brand codes
    where 1=1
        and scanned_date >= (select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '2 month'
        and scanned_date < (select date_trunc('month', max(scanned_date)) from fetch_db.fetch.receipts) - interval '1 month'
        and brand_code is not null
    group by 1,2
),
final as (
    select
        feb.brand_code,
        feb.receipts_scanned as feb_receipts_scanned,
        feb.total_items_purchased as feb_total_items_purchased,
        feb.ranking as feb_ranking,
        ifnull(jan.receipts_scanned, 0) as jan_receipts_scanned,
        ifnull(jan.total_items_purchased, 0) as jan_total_items_purchased,
        jan.ranking as jan_ranking
    from feb
    left join jan
        on feb.brand_code = jan.brand_code
    where feb.ranking <= 5
)
select * from final
order by 4
;
-- Answer: Brands "Brand" and "Mission" went from 12th and 13th ranking in Jan to ranking 1st and 2nd in Feb, respectively. Brand "Viva" went from unranked in Jan (no recipets scanned) to 3rd in Feb



-- ###### QUESTION 3 & QUESTION 4 ######
-- Can answer both questions 3 & 4 with a single query.
-- The status of "Accepted" doesn't exist in the data, so I will be assuming that "Finished" is the same as Accepted
select
    rewards_receipt_status,
    avg(total_spent) as avg_spent,
    sum(purchased_item_count) as total_purchased_items
from fetch_db.fetch.receipts
where lower(rewards_receipt_status) in ('finished', 'rejected')
group by 1
order by 2 desc
;
-- Answer:
--      Q3 - "Finished" / "Accepted" has a greater average spend.
--      Q4 - "Finished" / Accepted has a greater total number of items purchased



-- ###### QUESTION 5 ######
-- Because the data only goes to March 2021 and it is currently Jan 2025, I will be choosing users who were created within 6 months from the max receipt created date
-- The User ID field in the Users table should theoretically be unique, but there are a lot of duplicate values. This is going to cause fanout when joining users table.
-- To combat this I will assume Change Data Capture is not working properly and when User Profiles are updated a new row is appended to the Users table and the old data is not purged or moved to a CDC type historical table.
-- To deduplicate manually I will take the row with the most recent Create Date to assume this is the most up to date info we have on a user
-- Similar to question 1, I will again be assuming that we can only identify a brand by it's Brand Name so we will need to join the brands table
with receipt_items as (
    select * from fetch_db.fetch.receipt_items
),
brands as (
    select * from fetch_db.fetch.brands
),
users as (
    select * from fetch_db.fetch.users
    qualify row_number() over (partition by user_id order by created_date desc nulls last) = 1 --get most recent user record
),
final as (
    select
        brands.brand_name,
        sum(final_price_total) as total_spent
    from receipt_items
    inner join users
        on receipt_items.user_id = users.user_id
    inner join brands
        on receipt_items.brand_code = brands.brand_code
    where users.created_date >= ((select max(create_date) from fetch_db.fetch.receipts) - interval '6 month')
    group by 1
    order by 2 desc
)
select * from final
limit 5
;
-- Answer: Cracker Barrel Cheese, KNORR, Kleenex, Doritos, Pepsi.



-- ###### QUESTION 6 ######
-- I will be assuming that by transaction we mean a purchase AKA a single receipt.
-- Same exact query as Question 5, just with a different metric. Need a sepearate query to get the ranking correct for the new metric
with receipt_items as (
    select * from fetch_db.fetch.receipt_items
),
brands as (
    select * from fetch_db.fetch.brands
),
users as (
    select * from fetch_db.fetch.users
    qualify row_number() over (partition by user_id order by created_date desc nulls last) = 1 --get most recent user record
),
final as (
    select
        brands.brand_name,
        count(distinct receipt_id) as total_transactions
    from receipt_items
    inner join users
        on receipt_items.user_id = users.user_id
    inner join brands
        on receipt_items.brand_code = brands.brand_code
    where users.created_date >= ((select max(create_date) from fetch_db.fetch.receipts) - interval '6 month')
    group by 1
    order by 2 desc
)
select * from final
limit 5
;
-- Answer: Pepsi, Kleenex, Kraft, KNORR, Doritos
