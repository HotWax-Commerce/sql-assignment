<h1>SQL Assignment-III</h1>

<p><h3>1. Completed Sales Orders (Physical Items)</h3>
Business Problem:
Merchants need to track only physical items (requiring shipping and fulfillment) for logistics and shipping-cost analysis.
</p>
Fields to Retrieve:
- ORDER_ID
- ORDER_ITEM_SEQ_ID
- PRODUCT_ID
- PRODUCT_TYPE_ID
- SALES_CHANNEL_ENUM_ID
- ORDER_DATE
- ENTRY_DATE
- STATUS_ID
- STATUS_DATETIME
- ORDER_TYPE_ID
- PRODUCT_STORE_ID

```sql
select 
	oh.ORDER_ID,
	oh.ORDER_TYPE_ID,
	oi.ORDER_ITEM_SEQ_ID,
	p.PRODUCT_ID,
	p.PRODUCT_TYPE_ID,
	oh.PRODUCT_STORE_ID,
	oh.SALES_CHANNEL_ENUM_ID,
	oh.ORDER_DATE,
	os.STATUS_ID,
	os.STATUS_DATETIME,
	oh.ORDER_DATE,
	oh.ENTRY_DATE
from order_header oh 
join order_item oi on (oh.ORDER_ID = oi.ORDER_ID)
join order_status os on (oi.ORDER_ID = os.ORDER_ID and os.ORDER_ITEM_SEQ_ID = oi.ORDER_ITEM_SEQ_ID)
join product p on(oi.PRODUCT_ID = p.PRODUCT_ID)
where p.PRODUCT_TYPE_ID not in ("DIGITAL_GOOD", "DONATION", "INSTALLATION_SERVICE", "SERVICE");
```

<hr>

<p><h3>2. Completed Return Items</h3>
Business Problem:
Customer service and finance often need insights into returned items to manage refunds, replacements, and inventory restocking.
</p>
Fields to Retrieve:
- RETURN_ID
- ORDER_ID
- PRODUCT_STORE_ID
- STATUS_DATETIME
- ORDER_NAME
- FROM_PARTY_ID
- RETURN_DATE
- ENTRY_DATE
- RETURN_CHANNEL_ENUM_ID

```sql
select
	rh.RETURN_ID,
	ri.ORDER_ID,
	oh.PRODUCT_STORE_ID,
	os.STATUS_DATETIME,
	oh.ORDER_NAME,
	rh.FROM_PARTY_ID,
	rh.RETURN_DATE,
	oh.ENTRY_DATE,
	rh.RETURN_CHANNEL_ENUM_ID
from return_header rh
join return_item ri on (rh.RETURN_ID = ri.RETURN_ID)
join order_header oh on (ri.ORDER_ID = oh.ORDER_ID)
join order_status os on (oh.ORDER_ID = os.ORDER_ID and os.STATUS_ID = "ORDER_COMPLETED");
```

<hr>
<p><h3>
  3. Single-Return Orders (Last Month)
  </h3>
  Business Problem:
The mechandising team needs a list of orders that only have one return.
</p>
Fields to Retrieve:
- PARTY_ID
- FIRST_NAME

```sql
select 
	rh.FROM_PARTY_ID as PARTY_ID,
	p.FIRST_NAME 
from return_header rh 
join return_item ri on (rh.RETURN_ID = ri.RETURN_ID and ri.RETURN_QUANTITY = 1 and date(rh.RETURN_DATE)>"2023-11-30" and date(rh.RETURN_DATE) <"2024-01-01")
join person p on (p.PARTY_ID = rh.FROM_PARTY_ID);
```

<hr>

<p><h3>4. Returns and Appeasements</h3>
Business Problem:
The retailer needs the total amount of items, were returned as well as how many appeasements were issued.
</p>
Fields to Retrieve:
- TOTAL RETURNS
- RETURN $ TOTAL
- TOTAL APPEASEMENTS
- APPEASEMENTS $ TOTAL

```sql

```


<hr>

<p><h3>5. Detailed Return Information</h3>
Business Problem:
Certain teams need granular return data (reason, date, refund amount) for analyzing return rates, identifying recurring issues, or updating policies.
</p>
Fields to Retrieve:
- RETURN_ID
- ENTRY_DATE
- RETURN_ADJUSTMENT_TYPE_ID (refund type, store credit, etc.)
- AMOUNT
- COMMENTS
- ORDER_ID
- ORDER_DATE
- RETURN_DATE
- PRODUCT_STORE_ID

```sql
select 
	rh.RETURN_ID,
	rh.ENTRY_DATE,
	ra.RETURN_ADJUSTMENT_TYPE_ID,
	ra.AMOUNT,
	ra.COMMENTS,
	oh.ORDER_ID,
	oh.ORDER_DATE,
	rh.RETURN_DATE,
	oh.PRODUCT_STORE_ID
from return_header rh 
join return_adjustment ra on rh.RETURN_ID = ra.RETURN_ID
join order_header oh on ra.ORDER_ID = oh.ORDER_ID;
```

<hr>

<p><h3>6. Orders with Multiple Returns</h3>
Business Problem:
Analyzing orders with multiple returns can identify potential fraud, chronic issues with certain items, or inconsistent shipping processes.
</p>
Fields to Retrieve:
- ORDER_ID
- RETURN_ID
- RETURN_DATE
- RETURN_REASON
- RETURN_QUANTITY

```sql
select 
	ri.ORDER_ID, 
	ri.ORDER_ITEM_SEQ_ID,
	ri.RETURN_ID,
	rh.RETURN_DATE,
	ri.RETURN_REASON_ID,
	ri.RETURN_TYPE_ID,
	ri.RETURN_QUANTITY
from return_item ri
join return_header rh on ri.RETURN_ID = rh.RETURN_ID
where ri.RETURN_QUANTITY >1 and ri.STATUS_ID ="RETURN_COMPLETED"
order by ri.RETURN_QUANTITY desc;
```

<hr>


<p><h3>7. Store with Most One-Day Shipped Orders (Last Month)</h3>
Business Problem:
Identify which facility (store) handled the highest volume of “one-day shipping” orders in the previous month, useful for operational benchmarking.
</p>
Fields to Retrieve:
- FACILITY_ID
- FACILITY_NAME
- TOTAL_ONE_DAY_SHIP_ORDERS
- REPORTING_PERIOD

```sql
select 
	s.ORIGIN_FACILITY_ID as FACILITY_ID,
	f.FACILITY_NAME,
	count(s.SHIPMENT_ID) as TOTAL_ONE_DAY_SHIP_ORDERS,
	concat( min(date(s.CREATED_DATE)), " - ", max(date(s.CREATED_DATE))) as REPORTING_PERIOD
from shipment s
join facility f on(s.ORIGIN_FACILITY_ID = f.FACILITY_ID and s.SHIPMENT_TYPE_ID = "SALES_SHIPMENT")
where s.SHIPMENT_METHOD_TYPE_ID like "NEXT%" and (s.CREATED_DATE > "2024-12-31" and s.CREATED_DATE <"2025-02-01")
group by s.ORIGIN_FACILITY_ID
order by TOTAL_ONE_DAY_SHIP_ORDERS desc limit 1;
```

<hr>

<p><h3>8. List of Warehouse Pickers</h3>
Business Problem:
Warehouse managers need a list of employees responsible for picking and packing orders to manage shifts, productivity, and training needs.
</p>
Fields to Retrieve:
- PARTY_ID (or Employee ID)
- NAME (First/Last)
- ROLE_TYPE_ID (e.g., “WAREHOUSE_PICKER”)
- FACILITY_ID (assigned warehouse)
- STATUS (active or inactive employee)

```sql
select
	p.PARTY_ID,
	p.FIRST_NAME,
	pr.ROLE_TYPE_ID,
	p2.FACILITY_ID,
	case  when pr.THRU_DATE < current_date() then 'INACTIVE' else 'ACTIVE'end as STATUS
from picklist_role pr 
join person p on pr.PARTY_ID = p.PARTY_ID
join picklist p2 on p2.PICKLIST_ID = pr.PICKLIST_ID;
```

<hr>

<p><h3>9. Total Facilities That Sell the Product</h3>
Business Problem:
Retailers want to see how many (and which) facilities (stores, warehouses, virtual sites) currently offer a product for sale.
</p>
Fields to Retrieve:
- PRODUCT_ID
- PRODUCT_NAME (or INTERNAL_NAME)
- FACILITY_COUNT (number of facilities selling the product)
- (Optionally) a list of FACILITY_IDs if more detail is needed

```sql
select
	pf.PRODUCT_ID,
	p.PRODUCT_NAME,
	count(pf.FACILITY_ID) as FACILITY_COUNT,
	group_concat(pf.FACILITY_ID order by pf.FACILITY_ID separator ', ') as FACILITY_LIST 
from product_facility pf 
join product p on p.PRODUCT_ID = pf.PRODUCT_ID
group by pf.PRODUCT_ID
order by FACILITY_COUNT desc;
```

<hr>


<p><h3>10. Total Items in Various Virtual Facilities</h3>
Business Problem:
Retailers need to study the relation of inventory levels of products to the type of facility it's stored at.<br>
Retrieve all inventory levels for products at locations and include the facility type Id. Do not retrieve facilities that are of type Virtual.
</p>
- PRODUCT_ID
- FACILITY_ID
- FACILITY_TYPE_ID
- QOH (Quantity on Hand)
- ATP (Available to Promise)

```sql
select ii.PRODUCT_ID, ii.FACILITY_ID, f.FACILITY_TYPE_ID, sum(ii.QUANTITY_ON_HAND_TOTAL) as QUANTITY_ON_HAND, sum(ii.AVAILABLE_TO_PROMISE_TOTAL) as AVAILABLE_TO_PROMISE
from inventory_item ii join facility f on ii.FACILITY_ID = f.FACILITY_ID and f.FACILITY_TYPE_ID != "VIRTUAL_FACILITY"
group by ii.PRODUCT_ID, f.FACILITY_ID, f.FACILITY_TYPE_ID;
```

<hr>

<p><h3>12 Orders Without Picklist</h3>
Business Problem:
A picklist is necessary for warehouse staff to gather items. Orders missing a picklist might be delayed and need attention.
</p>
Fields to Retrieve: 
- `ORDER_ID`  
- `ORDER_DATE`  
- `ORDER_STATUS`  
- `FACILITY_ID`
- `DURATION` (How long has the order been assigned at the facility)


```sql
SELECT 
	oh.ORDER_ID, oh.STATUS_ID, oh.ORDER_DATE, 
	oisg.FACILITY_ID, datediff( now(), oisg.CREATED_STAMP) as DURATION
FROM order_header oh
LEFT JOIN order_item_ship_grp_inv_res oisgir 
on oh.ORDER_ID=oisgir.ORDER_ID
JOIN order_item_ship_group oisg ON oh.ORDER_ID = oisg.ORDER_ID
WHERE oisgir.RESERVED_DATETIME IS NULL AND oh.STATUS_ID="ORDER_APPROVED";
```
