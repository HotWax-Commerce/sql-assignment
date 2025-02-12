-- Question-1
-- Customer Service might need to verify addresses for orders placed or completed in October 2023. 
-- This helps ensure shipments are delivered correctly and prevents address-related issues.
select
	oh.ORDER_ID,
	ocm.CONTACT_MECH_ID,
	orr.PARTY_ID,
	concat(per.FIRST_NAME," ",per.LAST_NAME) as CUSTOMER_NAME,
	oh.STATUS_ID,
	ocm.CONTACT_MECH_PURPOSE_TYPE_ID,
	pa.ADDRESS1,
	pa.CITY,
	pa.COUNTRY_GEO_ID,
	pa.POSTAL_CODE,
	oh.ORDER_DATE
from order_header oh 
join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join order_status os on (oh.ORDER_ID = os.ORDER_ID and os.STATUS_ID="ORDER_COMPLETED" and os.STATUS_DATETIME>"2023-09-30" and os.STATUS_DATETIME<"2023-11-01")
join order_role orr on (oh.ORDER_ID = orr.ORDER_ID and orr.ROLE_TYPE_ID="SHIP_TO_CUSTOMER")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID)
join person per on(orr.PARTY_ID=per.PARTY_ID);


-- Question-2
-- Companies often want region-specific analysis to plan local marketing, staffing, or promotions in certain areas—here, specifically, New York.
select
	oh.ORDER_ID,
	ocm.CONTACT_MECH_ID,
	orr.PARTY_ID,
	concat(per.FIRST_NAME," ",per.LAST_NAME) as CUSTOMER_NAME,
	oh.STATUS_ID,
	oh.GRAND_TOTAL as TOTAL_AMOUNT,
	ocm.CONTACT_MECH_PURPOSE_TYPE_ID,
	pa.ADDRESS1,
	pa.STATE_PROVINCE_GEO_ID,
	pa.POSTAL_CODE,
	oh.ORDER_DATE
from order_header oh 
join order_contact_mech ocm on (oh.STATUS_ID="ORDER_COMPLETED" and oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join order_role orr on (oh.ORDER_ID = orr.ORDER_ID and orr.ROLE_TYPE_ID="PLACING_CUSTOMER")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID and pa.STATE_PROVINCE_GEO_ID="NY")
join person per on(orr.PARTY_ID=per.PARTY_ID);

-- Question-3
-- Merchandising teams need to identify the best-selling product(s) in a specific region (New York) for targeted restocking or promotions.

-- These are the top 10 best selling products-
select 
	oi.PRODUCT_ID, 
	p.INTERNAL_NAME,
	sum(oi.QUANTITY) as TOTAL_QUANTITY_SOLD,
	max(pa.CITY) as CITY,
	sum(oh.GRAND_TOTAL) as REVENUE
from order_item oi 
join order_header oh on (oi.ORDER_ID= oh.ORDER_ID and oh.STATUS_ID="ORDER_COMPLETED" and oh.ORDER_TYPE_ID="SALES_ORDER")
join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID and pa.STATE_PROVINCE_GEO_ID="NY")
join product p on p.PRODUCT_ID = oi.PRODUCT_ID
group by oi.PRODUCT_ID
order by TOTAL_QUANTITY_SOLD desc limit 10;

-- These are the products sold above average and can be considered as best selling
with PRODUCT_SALES as(
	select 
	oi.PRODUCT_ID, 
	p.INTERNAL_NAME,
	sum(oi.QUANTITY) as TOTAL_QUANTITY_SOLD,
	avg(sum(oi.QUANTITY)) over () as AVG_QUANTITY,
	max(pa.CITY) as CITY,
	sum(oh.GRAND_TOTAL) as REVENUE
	from order_item oi 
	join order_header oh on (oi.ORDER_ID= oh.ORDER_ID and oh.STATUS_ID="ORDER_COMPLETED" and oh.ORDER_TYPE_ID="SALES_ORDER")
	join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
	join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID and pa.STATE_PROVINCE_GEO_ID="NY")
	join product p on p.PRODUCT_ID = oi.PRODUCT_ID
	group by oi.PRODUCT_ID
)
select PRODUCT_ID, INTERNAL_NAME, TOTAL_QUANTITY_SOLD, CITY, REVENUE from PRODUCT_SALES
where TOTAL_QUANTITY_SOLD > AVG_QUANTITY 
order by TOTAL_QUANTITY_SOLD desc;

