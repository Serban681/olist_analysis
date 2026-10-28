# Data Dictionary

## Customers

**Grain:** One row represents one order-specific customer record.

**Primary key:** `customer_id`

**Important columns:**
- `customer_id`
- `customer_unique_id`
- `customer_state`
- `customer_city`

**Notes:**
- `customer_id` should not automatically be interpreted as a unique real-world customer.
- `customer_unique_id` is used to identify repeat customers across different orders.

---

## Geolocation

**Grain:**  One row represents one recorded geolocation observation for a zip-code prefix.

**Important columns:**
- `geolocation_zip_code`
- `geolocation_lat`
- `geolocation_lng`

**Notes:**
- A zip-code prefix can appear multiple times with different latitude/longitude observations.
- `geolocation_zip_code_prefix` is therefore not unique.

---

## Order item

**Grain:** One row represents one line item within an order.

**Candidate key:** (`order_id`, `order_item_id`)

**Important columns:**
- `order_id`
- `order_item_id`
- `product_id`
- `price`
- `freight_value`

**Notes:**
- One order can have registered the same product multiple times. Individual products are distinguished by their order_item_id.
- Freight value is splitted between multiple items if an order has more than one item.

---

## Order payments

**Grain:** One row represents one individual payment

**Candidate key:** (`order_id`, `payment_sequential`)

**Important columns:**
- `order_id`
- `payment_sequential`
- `payment_value`

**Notes:**
- An order can be paid through multiple payment types. This demands a payment sequence. This is why the same order_id may appear multiple times with a different payment_sequential
- The total value of an order is the sum of individual payments from the entire sequence

---

## Order reviews

**Grain:** One row represents one order review

**Important columns:** 
- `review_id`
- `order_id`
- `review_score`
- `review_creation_date`
- `review_answer_timestamp`

**Notes:**
- The user gets sent a review survey on `review_creation_date`. They will have answered it at time `review_answer_timestamp`
- An order can potentially have more than one review-related record, so verify uniqueness before assuming a strict one-to-one relationship with orders.

---

## Orders

**Grain:** One row represents one order

**Primary key:** `order_id`

**Important columns:** 
- `order_id`
- `customer_id`
- `order_status`
- `order_purchase_timestamp`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

---

## Products

**Grain:** One row represents one product.

**Primary key:** `product_id`

**Important columns:** 
- `product_id`
- `product_category_name`

**Notes:**
- Additional columns suggest information about name length or description as well as number of photos
- There is also additional information regarding weight and size

---

## Sellers

**Grain:** One row represents one seller

**Primary key:** `seller_id`

**Important columns:** 
- `seller_id`
- `seller_zip_code_prefix`

---

## Product Category Namme Translations

**Grain:** One row represents one category and its translated category name.

**Primary key:** `product_category_name`

**Important columns:**
- `product_category_name`
- `product_category_name_english`