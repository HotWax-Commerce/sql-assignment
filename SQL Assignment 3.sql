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





