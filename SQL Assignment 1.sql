-- for testing purpose --
select * from product p;
select * from product_type pt2;
select * from party_role pr;
select * from good_identification gi where gi.PRODUCT_ID="100000" ;
select * from good_identification_type ;
select * from good_identification where good_identification.GOOD_IDENTIFICATION_TYPE_ID  ="SKU";
select * from shopify_shop_product ssp ;


-- Question-1 (not completed)
-- The marketing team ran a campaign in June 2023 and wants to see how many new customers signed up during that period.
select per.PARTY_ID, per.FIRST_NAME, per.LAST_NAME, cm.INFO_STRING
from person per left join party_role pr on per.PARTY_ID= pr.PARTY_ID 
join party_contact_mech pcm on pcm.PARTY_ID= per.PARTY_ID 
join contact_mech cm on pcm.CONTACT_MECH_ID = cm.CONTACT_MECH_ID
where pr.ROLE_TYPE_ID="CUSTOMER"
and pr.CREATED_STAMP >='2023-06-01 00:00:00.000'  
and pr.CREATED_STAMP <'2023-07-01 00:00:00:000';

-- Question-2
-- Merchandising teams often need a list of all physical products to manage logistics, warehousing, and shipping.
select p.PRODUCT_ID, p.PRODUCT_TYPE_ID, p.INTERNAL_NAME 
from product p  
join product_type pt 
on p.PRODUCT_TYPE_ID=pt.PRODUCT_TYPE_ID
where pt.IS_PHYSICAL="Y";

-- Question-3
-- A product cannot sync to NetSuite unless it has a valid NetSuite ID. 
-- The OMS needs a list of all products that still need to be created or updated in NetSuite.
select distinct(p.PRODUCT_ID), p.INTERNAL_NAME, p.PRODUCT_TYPE_ID
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








