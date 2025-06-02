<h1>SQL Assignment-I</h1>

<p><h3>1. New Customers Acquired in June 2023</h3>
Business Problem:
The marketing team ran a campaign in June 2023 and wants to see how many new customers signed up during that period.
</p>
Fields to Retrieve:
- PARTY_ID
- FIRST_NAME
- LAST_NAME
- EMAIL
- PHONE
- ENTRY_DATE

```sql
select 
  per.PARTY_ID, 
  pr.CREATED_STAMP as ENTRY_DATE,
  per.FIRST_NAME,
  per.LAST_NAME,
  (select cm.INFO_STRING from contact_mech cm join party_contact_mech pcm 
  on per.PARTY_ID = pcm.PARTY_ID and cm.CONTACT_MECH_ID =pcm.CONTACT_MECH_ID and CONTACT_MECH_TYPE_ID ='EMAIL_ADDRESS' limit 1) as EMAIL,
  (select contact_number from telecom_number tn join party_contact_mech pcm  
  on pcm.party_id=per.party_id and tn.contact_mech_id = pcm.contact_mech_id limit 1) as PHONE
from person as per
join party_role as pr on per.PARTY_ID = pr.PARTY_ID and pr.role_type_id = 'CUSTOMER' and pr.CREATED_STAMP < "2023-07-01" and pr.CREATED_STAMP>="2023-06-01";
```
**Explanation:** 
<p> Used subqueries instead of joining the contact_mech table for email and phone details, as joins were resulting in duplicate records. Subqueries in SELECT clause gets executed individually for each matching record, preventing duplication.</p>

**Total Query Cost: 4043**
<hr>

<p><h3>2. List All Active Physical Products</h3>
Business Problem:
Merchandising teams often need a list of all physical products to manage logistics, warehousing, and shipping.
</p>
Fields to Retrieve:
- PRODUCT_ID
- PRODUCT_TYPE_ID
- INTERNAL_NAME

```sql
select 
    p.PRODUCT_ID, 
    p.PRODUCT_TYPE_ID, 
    p.INTERNAL_NAME 
from product p  
join product_type pt 
on p.PRODUCT_TYPE_ID=pt.PRODUCT_TYPE_ID
where pt.IS_PHYSICAL="Y";
```
**Explanation:** 
<p>The product type determines whether a product is physical or not. This query retrieves product details by joining the product table with the product type and filtering only those products where IS_PHYSICAL = 'Y'.</p>

**Total Query Cost: 155962**
<hr>

<p><h3>3. Products Missing NetSuite ID</h3>
Business Problem:
A product cannot sync to NetSuite unless it has a valid NetSuite ID. The OMS needs a list of all products that still need to be created or updated in NetSuite.
</p>
Fields to Retrieve:
- PRODUCT_ID
- INTERNAL_NAME
- PRODUCT_TYPE_ID
- NETSUITE_ID

```sql
select 
    p.PRODUCT_ID, 
    p.INTERNAL_NAME, 
    p.PRODUCT_TYPE_ID
from product p 
left join good_identification gi 
on p.PRODUCT_ID = gi.PRODUCT_ID  
and gi.GOOD_IDENTIFICATION_TYPE_ID = "ERP_ID"
and gi.ID_VALUE is null;
```
**Explanation:** 
<p>Here using left join so that the product with missing ERP_ID will also be listed with products having ERP_ID as good identification type but null id value.</p>

**Total Query Cost: 830242**
<hr>

<p><h3>4. Product IDs Across Systems</h3>
Business Problem:
To sync an order or product across multiple systems (e.g., Shopify, HotWax, ERP/NetSuite), the OMS needs to know each system’s unique identifier for that product. This query retrieves the Shopify ID, HotWax ID, and ERP ID (NetSuite ID) for all products.
</p>
Fields to Retrieve:
- PRODUCT_ID (internal OMS ID)
- SHOPIFY_ID
- HOTWAX_ID
- ERP_ID or NETSUITE_ID 

```sql
select 
    gi.PRODUCT_ID,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID  = 'SHOPIFY_PROD_ID' then ID_VALUE end) as SHOPIFY_PROD_ID,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'SHOPIFY_PROD_SKU' then ID_VALUE end) as SHOPIFY_PROD_SKU,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'SKU' then ID_VALUE end) as SKU,
    max(case when gi.GOOD_IDENTIFICATION_TYPE_ID = 'ERP_ID' then ID_VALUE end) as ERP_ID
from good_identification as gi
group by PRODUCT_ID;
```
**Explanation:** 
<p>For a product there can be multiple records so grouped them all and to make it in single row the I have used CASE to apply conditions. There can be multiple values for a gi type so using an aggregate function max will return single but lexically largest id value.</p>

**Total Query Cost: 271924**
<hr>

<p><h3>5. Completed Orders in August 2023</h3>
Business Problem:
After running similar reports for a previous month, you now need all completed orders in August 2023 for analysis.
</p>
Fields to Retrieve:
- PRODUCT_ID
- PRODUCT_TYPE_ID
- PRODUCT_STORE_ID
- TOTAL_QUANTITY
- INTERNAL_NAME
- FACILITY_ID
- EXTERNAL_ID
- FACILITY_TYPE_ID
- ORDER_HISTORY_ID
- ORDER_ID
- ORDER_ITEM_SEQ_ID
- SHIP_GROUP_SEQ_ID

```sql
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

```
**Explanation:** 
<p>
  Started from order item and simply joined the tables as per required fields. 
</p>

**Total Query Cost: 96682**
