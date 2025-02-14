-- Question-1
-- Merchants need to track only physical items (requiring shipping and fulfillment) for logistics and shipping-cost analysis.
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


-- Question -2
-- Completed Return Items
-- Customer service and finance often need insights into returned items to manage refunds, replacements, and inventory restocking.
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


-- Question -3
-- Single-Return Orders (Last Month)
-- The mechandising team needs a list of orders that only have one return.
select 
	rh.FROM_PARTY_ID as PARTY_ID,
	p.FIRST_NAME 
from return_header rh 
join return_item ri on (rh.RETURN_ID = ri.RETURN_ID and ri.RETURN_QUANTITY = 1 and date(rh.RETURN_DATE)>"2023-11-30" and date(rh.RETURN_DATE) <"2024-01-01")
join person p on (p.PARTY_ID = rh.FROM_PARTY_ID);


-- Question-4
-- Returns and Appeasements
-- The retailer needs the total amount of items, were returned as well as how many appeasements were issued.
-- TOTAL RETURNS
-- RETURN $ TOTAL
-- TOTAL APPEASEMENTS
-- APPEASEMENTS $ TOTAL


-- 5 Detailed Return Information
-- Certain teams need granular return data (reason, date, refund amount) for analyzing return rates, identifying recurring issues, or updating policies.
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


-- Question-6 Orders with Multiple Returns
-- Analyzing orders with multiple returns can identify potential fraud, chronic issues with certain items, or inconsistent shipping processes.
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

-- Question-7 Store with Most One-Day Shipped Orders (Last Month)
-- Identify which facility (store) handled the highest volume of “one-day shipping” orders in the previous month, useful for operational benchmarking.
-- FACILITY_ID
-- FACILITY_NAME
-- TOTAL_ONE_DAY_SHIP_ORDERS
-- REPORTING_PERIOD
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





