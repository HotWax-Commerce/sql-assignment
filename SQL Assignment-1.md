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

