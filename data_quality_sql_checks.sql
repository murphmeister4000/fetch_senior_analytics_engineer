-- PRIMARY KEY CHECK: Check columns for uniqueness. No data returned means the column has uniqueness and could possibly be used as the primary key

--Receipts Check
select receipt_id, count(*) from fetch_db.fetch.receipts
group by 1
having count(*) > 1
order by 2 desc;

--Users Check
select user_id, count(*) from fetch_db.fetch.users
group by 1
having count(*) > 1
order by 2 desc;

--Brands Check
select brand_id, count(*) from fetch_db.fetch.brands
group by 1
having count(*) > 1
order by 2 desc;

select barcode, count(*) from fetch_db.fetch.brands
group by 1
having count(*) > 1
order by 2 desc;

select brand_code, count(*) from fetch_db.fetch.brands
group by 1
having count(*) > 1
order by 2 desc;

select brand_name, count(*) from fetch_db.fetch.brands
group by 1
having count(*) > 1
order by 2 desc;

--Receipt Items Check
--Table inherently lacks a primary key so assume item_number is like the items id and check if combining receipt_id and item_number create a unique surrogate key
select
    md5(cast(
        coalesce(cast(item_number as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(receipt_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT
        )
    ) as surrogate_key,
    count(*) from fetch_db.fetch.receipt_items
group by 1
having count(*) > 1
order by 2 desc;



-- AD-HOC QUESTION SPECIFIC DATA CHECKS: Data checks I did as I was trying to answer the the questions in part 2 of the exercise. Primarily for questions 1 and 2.

-- Questions 1 and 2
-- I noticed only certain months had valid brand codes and barcodes. Check the receipt item table individually for months with gaps in these columns
select distinct date_trunc('month', scanned_date) from fetch_db.fetch.receipt_items where brand_code is not null order by 1 desc;
select distinct date_trunc('month', scanned_date) from fetch_db.fetch.receipt_items where barcode is not null order by 1 desc;

-- I noticed only certain months had valid brand codes and barcodes. Join the brand table to see which months have gaps in these columns after the join
-- Can test out join on brand_code vs. barcode to see which one gives better results
select distinct date_trunc('month', scanned_date) from fetch_db.fetch.receipt_items
inner join fetch_db.fetch.brands
    -- on receipt_items.brand_code = brands.brand_code
    on receipt_items.barcode = brands.barcode
order by 1 desc;

-- Just to reiterate the above on joining brand_code vs. barode, check which join key produces more matches.
-- Can toggle between join keys by uncommenting the ON clause
select count(*) from fetch_db.fetch.receipt_items
inner join fetch_db.fetch.brands
    -- on receipt_items.brand_code = brands.brand_code; --count = 635
    on receipt_items.barcode = brands.barcode; --count = 89

-- Check if joining on BOTH brand_code and barcode produces better results
-- Spoiler Alert...it doesn't. Both have huge gaps for months outside of Jan 2021 either because their source table has gaps or there are not many matching keys between receipt/receipt_items and brands
select
    coalesce(b1.brand_name, b2.brand_name) as brand_name,
    to_varchar(receipt_items.scanned_date, 'YYYY-MM') as month,
    count(distinct receipt_items.receipt_id) as receipts_scanned,
    sum(receipt_items.quantity_purchased) as total_items_purchased,
    rank() over (order by count(distinct receipt_items.receipt_id) desc, sum(receipt_items.quantity_purchased)) as ranking
from fetch_db.fetch.receipt_items
left join fetch_db.fetch.brands as b1
    on receipt_items.brand_code = b1.brand_code
left join fetch_db.fetch.brands as b2
    on receipt_items.barcode = b2.barcode
where 1=1
    and (b1.brand_code is not null or b2.barcode is not null)
group by 1,2
order by 2 desc, 5
;