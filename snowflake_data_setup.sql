-- ######## STEP 1: INITIALIZE DATABASE AND SCHEMAS ########
--For simplicity's sake (and if possible) run as admin or another role that can create databases, schemas, and tables.
CREATE DATABASE IF NOT EXISTS fetch_db;
CREATE SCHEMA IF NOT EXISTS fetch_raw;
CREATE SCHEMA IF NOT EXISTS fetch;


-- ######## STEP 2: UPLOAD FILES LOCALLY ########
-- To get up and running quickly and because of small file sizes, unzip and download JSON files locally and upload the files using the Snowflake UI "Upload local files" capability
-- Upload the files to the "fetch_db.fetch_raw" schema.
-- How to upload locally --> https://docs.snowflake.com/en/user-guide/data-load-web-ui


-- ######## STEP 3: CREATE STRUCTURED TABLES FROM THE UPLOADED JSON
-- Create 4 tables from the 3 JSON files.
-- Do some recasting and renaming (because I like snake_case much better than camelCase)

-- Users
CREATE OR REPLACE TABLE fetch_db.fetch.users as
SELECT
    variant_col:_id."$oid"::STRING as user_id,
    variant_col:active::BOOLEAN as active,
    to_timestamp((variant_col:createdDate."$date")::STRING) as created_date,
    to_timestamp((variant_col:lastLogin."$date")::STRING) as last_login_date,
    variant_col:role::STRING as role,
    variant_col:signUpSource::STRING as sign_up_source,
    variant_col:state::STRING as state,
    variant_col as raw_json
FROM fetch_db.fetch_raw.users_raw;

-- Brands
CREATE OR REPLACE TABLE fetch_db.fetch.brands as
SELECT
    variant_col:_id."$oid"::STRING as brand_id,
    variant_col:barcode::STRING as barcode,
    variant_col:brandCode::STRING as brand_code,
    variant_col:category::STRING as category,
    variant_col:categoryCode::STRING as category_code,
    variant_col:cpg."$id"."$oid"::STRING as cpg_id,
    variant_col:cpg."$ref"::STRING as cpg_collection,
    variant_col:name::STRING as brand_name,
    variant_col:topBrand::BOOLEAN as top_brand,
    variant_col as raw_json
FROM fetch_db.fetch_raw.brands_raw;

-- Receipts
CREATE OR REPLACE TABLE fetch_db.fetch.receipts as
SELECT
    variant_col:_id."$oid"::STRING as receipt_id,
    variant_col:bonusPointsEarned::INT as bonus_points_earned,
    variant_col:bonusPointsEarnedReason::STRING as bonus_points_earned_reason,
    to_timestamp((variant_col:createDate."$date")::STRING) as create_date,
    to_timestamp((variant_col:dateScanned."$date")::STRING) as scanned_date,
    to_timestamp((variant_col:finishedScanned."$date")::STRING) as finished_date,
    to_timestamp((variant_col:modifyDate."$date")::STRING) as modify_date,
    to_timestamp((variant_col:pointsAwardedDate."$date")::STRING) as points_awarded_date,
    variant_col:pointsEarned::FLOAT as points_earned,
    to_timestamp((variant_col:purchaseDate."$date")::STRING) as purchase_date,
    variant_col:purchasedItemCount::INT as purchased_item_count,
    variant_col:rewardsReceiptItemList::VARIANT as rewards_receipt_item_list,
    variant_col:rewardsReceiptStatus::STRING as rewards_receipt_status,
    variant_col:totalSpent::FLOAT as total_spent,
    variant_col:userId::STRING as user_id,
    variant_col as raw_json
FROM fetch_db.fetch_raw.receipts_raw;

-- Receipt Items
-- Unnest the rewardsReceiptItemList field from receipts
CREATE OR REPLACE TABLE fetch_db.fetch.receipt_items as
SELECT
    receipt_id,
    scanned_date,
    user_id,
    value:itemNumber::STRING as item_number,
    value:barcode::STRING as barcode,
    value:description::STRING as description,
    value:finalPrice::FLOAT as final_price_total,
    value:itemPrice::FLOAT as item_price_total,
    (value:itemPrice / value:quantityPurchased)::FLOAT as item_price,
    value:quantityPurchased::INT as quantity_purchased,
    value:userFlaggedBarcode::STRING as user_flagged_barcode,
    value:userFlaggedNewItem::BOOLEAN as user_flagged_new_item,
    value:userFlaggedQuantity::INT as user_flagged_quantity,
    value:userFlaggedDescription::STRING as user_flagged_description,
    value:userFlaggedPrice::FLOAT as user_flagged_price,
    value:originalMetaBriteQuantityPurchased::INT as original_meta_brite_quantity_purchased,
    value:originalMetaBriteBarcode::STRING as original_meta_brite_barcode,
    value:originalMetaBriteDescription::STRING as original_meta_brite_description,
    value:metabriteCampaignId::STRING as meta_brite_campaign_id,
    value:pointsNotAwardedReason::STRING as points_not_awarded_reason,
    value:pointsPayerId::STRING as points_payer_id,
    value:rewardsGroup::STRING as rewards_group,
    value:rewardsProductPartnerId::STRING as rewards_product_partner_id,
    value:brandCode::STRING as brand_code,
    value:competitorRewardsGroup::STRING as competitor_rewards_group,
    value:discountedItemPrice::FLOAT as discounted_item_price,
    value:originalReceiptItemText::STRING as original_receipt_item_text,
    value:needsFetchReview::BOOLEAN as needs_fetch_review,
    value:needsFetchReviewReason::STRING as needs_fetch_review_reason,
    value:targetPrice::FLOAT as target_price,
    value:competitiveProduct::BOOLEAN as competitive_product,
    value:deleted::BOOLEAN as deleted,
    value:partnerItemId::STRING as partner_item_id,
    value:pointsEarned::FLOAT as points_earned,
    value:priceAfterCoupon::FLOAT as price_after_coupon,
    value:preventTargetGapPoints::BOOLEAN as prevent_target_gap_points,
    raw_receipt_json,
    raw_item_list_json
FROM (
    SELECT
        variant_col as raw_receipt_json,
        variant_col:userId::STRING as user_id,
        variant_col:rewardsReceiptItemList as raw_item_list_json,
        variant_col:_id."$oid"::STRING as receipt_id,
        to_timestamp((variant_col:dateScanned."$date")::STRING) as scanned_date,
        value
    FROM fetch_db.fetch_raw.receipts_raw,
    LATERAL FLATTEN(input => variant_col:rewardsReceiptItemList)
);
