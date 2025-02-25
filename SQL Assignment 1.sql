-- Question-2
-- Merchandising teams often need a list of all physical products to manage logistics, warehousing, and shipping.
select 
    p.PRODUCT_ID, 
    p.PRODUCT_TYPE_ID, 
    p.INTERNAL_NAME 
from product p  
join product_type pt 
on p.PRODUCT_TYPE_ID=pt.PRODUCT_TYPE_ID
where pt.IS_PHYSICAL="Y";


-- Question-3
-- A product cannot sync to NetSuite unless it has a valid NetSuite ID. 
-- The OMS needs a list of all products that still need to be created or updated in NetSuite.
select 
    distinct(p.PRODUCT_ID), 
    p.INTERNAL_NAME, 
    p.PRODUCT_TYPE_ID
from product p join good_identification gi 
on p.PRODUCT_ID=gi.PRODUCT_ID  
where gi.GOOD_IDENTIFICATION_TYPE_ID = "ERP_ID"
and gi.ID_VALUE is null;


-- Question-4
-- To sync an order or product across multiple systems (e.g., Shopify, HotWax, ERP/NetSuite), the OMS needs to know each system’s
-- unique identifier for that product. This query retrieves the Shopify ID, HotWax ID, and ERP ID (NetSuite ID) for all products.
select 
    gi.PRODUCT_ID,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID  = 'SHOPIFY_PROD_ID' then ID_VALUE end) as SHOPIFY_PROD_ID,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'SHOPIFY_PROD_SKU' then ID_VALUE end) as SHOPIFY_PROD_SKU,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'SKU' then ID_VALUE end) as SKU,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'ERP_ID' then ID_VALUE end) as ERP_ID
from good_identification as gi
group by PRODUCT_ID;


-- Question-5
-- After running similar reports for a previous month, you now need all completed orders in August 2023 for analysis.
select 
    p.PRODUCT_ID ,
    p.PRODUCT_TYPE_ID,
    psc.PRODUCT_STORE_ID,
    p.INTERNAL_NAME,
    oi.QUANTITY,
    oisg.FACILITY_ID,
    f.FACILITY_TYPE_ID,
    oi.EXTERNAL_ID,
    oi.ORDER_ID,
    oi.ORDER_ITEM_SEQ_ID,
    oi.SHIP_GROUP_SEQ_ID,
    oh.ORDER_HISTORY_ID 
from order_item oi
join order_status os on (os.ORDER_ID = oi.ORDER_ID and os.STATUS_ID="ORDER_COMPLETED" and (os.STATUS_DATETIME > "2023-08-01" and os.STATUS_DATETIME<"2023-09-01"))
join order_item_ship_group oisg on (oi.ORDER_ID = oisg.ORDER_ID and oi.SHIP_GROUP_SEQ_ID = oisg.SHIP_GROUP_SEQ_ID)
join order_history oh on (oi.ORDER_ID=oh.ORDER_ID and oi.ORDER_ITEM_SEQ_ID= oh.ORDER_ITEM_SEQ_ID and oi.SHIP_GROUP_SEQ_ID= oh.SHIP_GROUP_SEQ_ID)
join product p on p.PRODUCT_ID = oi.PRODUCT_ID
join product_store_catalog psc on oi.PROD_CATALOG_ID = psc.PROD_CATALOG_ID
join facility f on f.FACILITY_ID = oisg.FACILITY_ID ;


-- Question-7
-- Finance teams need to see new orders and their payment methods for reconciliation and fraud checks
select
    oh.ORDER_ID,
    p.AMOUNT as TOTAL_AMOUNT,
    opp.PAYMENT_METHOD_ID, 
    oh.EXTERNAL_ID as SHOPIFY_ORDER_ID
from order_header oh 
join order_payment_preference opp on oh.ORDER_ID=opp.ORDER_ID
join payment p on opp.ORDER_PAYMENT_PREFERENCE_ID=p.PAYMENT_PREFERENCE_ID;


-- 8 Payment Captured but Not Shipped(not completed)
-- Finance teams want to ensure revenue is recognized properly. If payment is captured but no shipment has occurred, it warrants further review.
select 
    oh.ORDER_ID,
    oh.STATUS_ID,
    p.STATUS_ID,
    s.STATUS_ID 
from  shipment s 
join order_header oh on oh.ORDER_ID = s.PRIMARY_ORDER_ID
join order_payment_preference opp on s.PRIMARY_ORDER_ID =opp.ORDER_ID
join payment p on p.PAYMENT_PREFERENCE_ID = opp.ORDER_PAYMENT_PREFERENCE_ID
where p.STATUS_ID="PMNT_RECEIVED" and s.STATUS_ID!="SHIPMENT_SHIPPED";



--- Question-9
-- Operations teams may want to see how orders complete across the day to schedule staffing.

-- hour trend for all order_date
select 
    hour(oh.ORDER_DATE) as HOUR, 
    count(*) as TOTAL_ORDERS 
from order_header oh 
group by HOUR 
order by HOUR;

-- For a specific date
select 
    hour(oh.ORDER_DATE) as HOUR, 
    count(*) as TOTAL_ORDERS 
from order_header oh 
where date(oh.ORDER_DATE) ="2024-11-11"
group by HOUR 
order by HOUR;



-- Question-10
-- BOPIS (Buy Online, Pickup In Store) is a key retail strategy. Finance wants to know the revenue from BOPIS orders for the previous year.
select 
    count(*) as TOTAL_ORDER,
    sum(oh.GRAND_TOTAL)
from order_header oh 
join shipment s 
on oh.ORDER_ID = s.PRIMARY_ORDER_ID
where oh.SALES_CHANNEL_ENUM_ID="WEB_SALES_CHANNEL" 
and s.SHIPMENT_METHOD_TYPE_ID = "STOREPICKUP"
and oh.ORDER_DATE>="2023-01-01" and oh.ORDER_DATE<="2023-12-31";


-- Question-11
-- The merchandising team needs to know how many orders were canceled in the previous month and their reasons.
select 
count(*) as TOTAL_ORDER, 
os.CHANGE_REASON 
from order_header oh 
join order_status os 
on oh.ORDER_ID= os.ORDER_ID 
where oh.STATUS_ID = "ORDER_CANCELLED" and (date(oh.ORDER_DATE)>="2024-10-31" and date(oh.ORDER_DATE)<="2024-11-30")
group by os.CHANGE_REASON;




