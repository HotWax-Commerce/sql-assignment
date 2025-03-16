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
    p.PRODUCT_ID, 
    p.PRODUCT_TYPE_ID, 
    p.INTERNAL_NAME 
from product p  
join product_type pt 
on p.PRODUCT_TYPE_ID=pt.PRODUCT_TYPE_ID
where pt.IS_PHYSICAL="Y":
```
**Explanation:** 
<p>The product type determines whether a product is physical or not. This query retrieves product details by joining the product table with the product type and filtering only those products where IS_PHYSICAL = 'Y'.</p>

**Total Query Cost: 7.81**
    
  
