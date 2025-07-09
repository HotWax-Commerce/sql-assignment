<h1>SQL Assignment-II</h1>

<p><h3>1. Shipping Addresses for October 2023 Orders</h3>
Business Problem:
Customer Service might need to verify addresses for orders placed or completed in October 2023. This helps ensure shipments are delivered correctly and prevents address-related issues.
</p>
Fields to Retrieve:
- ORDER_ID
- PARTY_ID (Customer ID)
- CUSTOMER_NAME (or FIRST_NAME / LAST_NAME)
- STREET_ADDRESS
- CITY
- STATE_PROVINCE
- POSTAL_CODE
- COUNTRY_CODE
- ORDER_STATUS
- ORDER_DATE

```sql
select
	oh.ORDER_ID, ocm.CONTACT_MECH_ID, orr.PARTY_ID, concat(per.FIRST_NAME," ",per.LAST_NAME) as CUSTOMER_NAME, oh.STATUS_ID,
	ocm.CONTACT_MECH_PURPOSE_TYPE_ID, pa.ADDRESS1, pa.CITY, pa.COUNTRY_GEO_ID, pa.POSTAL_CODE, oh.ORDER_DATE
from order_header oh 
join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join order_status os on (oh.ORDER_ID = os.ORDER_ID and os.STATUS_ID="ORDER_COMPLETED" and os.STATUS_DATETIME>"2023-09-30" and os.STATUS_DATETIME<"2023-11-01")
join order_role orr on (oh.ORDER_ID = orr.ORDER_ID and orr.ROLE_TYPE_ID="SHIP_TO_CUSTOMER")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID)
join person per on(orr.PARTY_ID=per.PARTY_ID);
```
**Explanation:** 
<p> 
	
</p>

**Total Query Cost: **
<hr>

<p><h3>2. Orders from New York</h3>
Business Problem:
Companies often want region-specific analysis to plan local marketing, staffing, or promotions in certain areas—here, specifically, New York.
</p>
Fields to Retrieve:
- ORDER_ID
- CUSTOMER_NAME
- STREET_ADDRESS (or shipping address detail)
- CITY
- STATE_PROVINCE
- POSTAL_CODE
- TOTAL_AMOUNT
- ORDER_DATE
- ORDER_STATUS

```sql
select
	oh.ORDER_ID, ocm.CONTACT_MECH_ID, orr.PARTY_ID, concat(per.FIRST_NAME," ",per.LAST_NAME) as CUSTOMER_NAME, oh.STATUS_ID,
	ocm.CONTACT_MECH_PURPOSE_TYPE_ID, pa.ADDRESS1, pa.CITY, pa.COUNTRY_GEO_ID, pa.POSTAL_CODE, oh.ORDER_DATE
from order_header oh 
join order_status os on (oh.ORDER_ID = os.ORDER_ID and os.STATUS_ID="ORDER_COMPLETED" and os.STATUS_DATETIME>"2023-09-30" and os.STATUS_DATETIME<"2023-11-01")
join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join order_role orr on (oh.ORDER_ID = orr.ORDER_ID and orr.ROLE_TYPE_ID="SHIP_TO_CUSTOMER")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID)
join person per on(orr.PARTY_ID=per.PARTY_ID);
```
**Explanation:** 
<p> 
Joined OrderStatus at the first to process only orders' with completed status, then connected with OCM for shipping location and OrderRole for ShipToCustomer
</p>

**Total Query Cost: 37513.8**
<hr>
<p>
  <h3>
  3. Top-Selling Product in New York
  </h3>
  Business Problem:
  Merchandising teams need to identify the best-selling product(s) in a specific region (New York) for targeted restocking or promotions.
</p>
Fields to Retrieve:
- PRODUCT_ID
- INTERNAL_NAME
- TOTAL_QUANTITY_SOLD
- CITY / STATE (within New York region)
- REVENUE (optionally, total sales amount)

```sql
select 
	oi.PRODUCT_ID, 
	p.INTERNAL_NAME,
	sum(oi.QUANTITY) as TOTAL_QUANTITY_SOLD,
	max(pa.CITY) as CITY,
	sum(oh.GRAND_TOTAL) as REVENUE
from order_item oi 
join order_header oh on (oi.ORDER_ID= oh.ORDER_ID and oi.STATUS_ID="ITEM_COMPLETED" and oh.ORDER_TYPE_ID="SALES_ORDER")
join order_contact_mech ocm on (oh.ORDER_ID=ocm.ORDER_ID  and ocm.CONTACT_MECH_PURPOSE_TYPE_ID ="SHIPPING_LOCATION")
join postal_address pa on (ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID and pa.STATE_PROVINCE_GEO_ID="NY")
join product p on p.PRODUCT_ID = oi.PRODUCT_ID
group by oi.PRODUCT_ID
order by TOTAL_QUANTITY_SOLD desc limit 10;
```
**Explanation:** 
<p> 
Queried orderItem to get SALES_ORDER's  items with COMPLETED status and then connected postalAddress via OCM to get ShippingLocation. At last joined product entity to get the internal name. Product entity may have a large volume of data so I joined it at the last, cosidering only the filtered ones. And the aggregate functions are used to calulate the same after grouping with productId
</p>

**Total Query Cost: 32,968**
<p> These are the products sold above average and can be considered as best selling</p>

```sql
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
order by TOTAL_QUANTITY_SOLD desc
LIMIT 10;
```
**Explanation:** 
<p> 
	Here used CTE to first calculate the Averege quantity per product sold and then listed all the products which have total sold quantity greater than average, so we 
</p>

**Total Query Cost: 775.37**
<hr>

<p><h3>4. Store-Specific (Facility-Wise) Revenue</h3>
Business Problem:
Different physical or online stores (facilities) may have varying levels of performance. The business wants to compare revenue across facilities for sales planning and budgeting.
</p>
Fields to Retrieve:
- FACILITY_ID
- FACILITY_NAME
- TOTAL_ORDERS
- TOTAL_REVENUE
- DATE_RANGE

```sql
select 
	oisg.facility_id,
	f2.FACILITY_NAME,
	count(oisg.ORDER_ID ) total_orders,
	sum(oh.GRAND_TOTAL) as REVENUE,
	concat(min(date(oh.ORDER_DATE))," - ",max(date(oh.ORDER_DATE))) as DATE_RANGE
from order_item_ship_group oisg
join order_header oh on (oh.ORDER_ID = oisg.ORDER_ID and oh.STATUS_ID = "ORDER_COMPLETED" and oh.ORDER_TYPE_ID="SALES_ORDER")
join facility f2  on f2.FACILITY_ID = oisg.FACILITY_ID
group by oisg.FACILITY_ID
order by total_orders desc ;
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>

<p><h3>5. Lost and Damaged Inventory</h3>
Business Problem:
Warehouse managers need to track “shrinkage” such as lost or damaged inventory to reconcile physical vs. system counts.
</p>
Fields to Retrieve:
- INVENTORY_ITEM_ID
- PRODUCT_ID
- FACILITY_ID
- QUANTITY_LOST_OR_DAMAGED
- REASON_CODE (Lost, Damaged, Expired, etc.)
- TRANSACTION_DATE

```sql
select 
	ii.INVENTORY_ITEM_ID,
	ii.PRODUCT_ID,
	ii.FACILITY_ID,
	sum(iid.AVAILABLE_TO_PROMISE_DIFF),
	iid.REASON_ENUM_ID,
	date(iid.CREATED_STAMP) as DATE
from inventory_item_detail iid 
join inventory_item ii on(ii.INVENTORY_ITEM_ID = iid.INVENTORY_ITEM_ID)
where iid.REASON_ENUM_ID is not null;
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>

<p><h3>6. Low Stock or Out of Stock Items Report</h3>
Business Problem:
Avoiding out-of-stock situations is critical. This report flags items that have fallen below a certain reorder threshold or have zero available stock.
</p>
Fields to Retrieve:
- PRODUCT_ID
- PRODUCT_NAME
- FACILITY_ID
- QOH (Quantity on Hand)
- ATP (Available to Promise)
- REORDER_THRESHOLD
- DATE_CHECKED

**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>

<p><h3>7. Retrieve the Current Facility (Physical or Virtual) of Open Orders</h3>
Business Problem:
The business wants to know where open orders are currently assigned, whether in a physical store or a virtual facility (e.g., a distribution center or online fulfillment location).
</p>
Fields to Retrieve:
- ORDER_ID
- ORDER_STATUS
- FACILITY_ID
- FACILITY_NAME
- FACILITY_TYPE_ID

```sql
select
	oh.ORDER_ID,
	oh.STATUS_ID,
	f.FACILITY_ID,
	f.FACILITY_NAME,
	f.FACILITY_TYPE_ID
from order_header oh 
join order_item_ship_group oisg on(oh.ORDER_ID = oisg.ORDER_ID)
join facility f on(oisg.FACILITY_ID = f.FACILITY_ID)
where oh.STATUS_ID="ORDER_APPROVED";
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>

<p><h3>8. Items Where QOH and ATP Differ</h3>
Business Problem:
Sometimes the Quantity on Hand (QOH) doesn’t match the Available to Promise (ATP) due to pending orders, reservations, or data discrepancies. This needs review for accurate fulfillment planning.
</p>
Fields to Retrieve:
- PRODUCT_ID
- FACILITY_ID
- QOH (Quantity on Hand)
- ATP (Available to Promise)
- DIFFERENCE (QOH - ATP)

```sql
select 
	ii.PRODUCT_ID,
	ii.FACILITY_ID,
	ii.QUANTITY_ON_HAND_TOTAL ,
	ii.AVAILABLE_TO_PROMISE_TOTAL,
	(ii.QUANTITY_ON_HAND_TOTAL-ii.AVAILABLE_TO_PROMISE_TOTAL) as DIFFERENCE
from inventory_item ii
where ii.QUANTITY_ON_HAND_TOTAL != ii.AVAILABLE_TO_PROMISE_TOTAL
order by DIFFERENCE desc;
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>

<p><h3>9. Order Item Current Status Changed Date-Time</h3>
Business Problem:
Operations teams need to audit when an order item’s status (e.g., from “Pending” to “Shipped”) was last changed, for shipment tracking or dispute resolution.
</p>
Fields to Retrieve:
- ORDER_ID
- ORDER_ITEM_SEQ_ID
- CURRENT_STATUS_ID
- STATUS_CHANGE_DATETIME
- CHANGED_BY

```sql
select
	os.ORDER_ID,
	os.ORDER_ITEM_SEQ_ID,
	ss.STATUS_ID,
	ss.STATUS_DATE,
	ss.CHANGE_BY_USER_LOGIN_ID 
from order_shipment os 
join shipment_status ss on(ss.SHIPMENT_ID = os.SHIPMENT_ID)
where ss.STATUS_ID ="SHIPMENT_SHIPPED";
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>


<p><h3>10. Total Orders by Sales Channel</h3>
Business Problem:
Marketing and sales teams want to see how many orders come from each channel (e.g., web, mobile app, in-store POS, marketplace) to allocate resources effectively.
</p>
- Fields to Retrieve:
- SALES_CHANNEL
- TOTAL_ORDERS
- TOTAL_REVENUE
- REPORTING_PERIOD

```sql
select 
	oh.SALES_CHANNEL_ENUM_ID as SALES_CHANNEL,
	count(oh.ORDER_ID) as TOTAL_ORDERS,
	sum(oh.GRAND_TOTAL) as TOTAL_REVENUE,
	concat(min(date(oh.ORDER_DATE)), " - ", max(date(oh.ORDER_DATE))) as REPORTING_PERIOD
from order_header oh 
where oh.ORDER_TYPE_ID="SALES_ORDER"
group by oh.SALES_CHANNEL_ENUM_ID;
```
**Explanation:** 
<p> 
</p>

**Total Query Cost: **
<hr>
