--1. Liệt kê danh sách products
SELECT *
FROM products

--2. Liệt kê danh sách products với thông tin là product_name, model_year và list_price
SELECT product_name,
       model_year,
	   list_price
FROM products
SELECT *
FROM products
WHERE model_year > 2017

--3. Liệt kê danh sách products có có model_year lớn hơn năm 2017
SELECT *
FROM products
WHERE list_price > 250 AND list_price < 375
SELECT product_name
FROM products
WHERE product_name LIKE 'S%'

--4. Liệt kê danh sách products có list_price trong khoảng 250 đến 375
SELECT
(first_name + ' ' + last_name) AS full_name,
(street + ' ' + city + ' ' + zip_code) AS address  
FROM customers

--5.	Liệt kê brand với tên bắt đầu bằng chữ S
SELECT product_name
FROM products
WHERE product_name LIKE 'S%'

--6. Liệt kê customers, bộ sung cột full_name = first_name+last_name, address = street+city+zipcode   
SELECT
(first_name + ' ' + last_name) AS full_name,
(street + ' ' + city + ' ' + zip_code) AS address  
FROM customers

--7.Liệt kê customer ở bang CA và các thành phố Longview, Forney, Canandaigua, Orchard Park
SELECT
    *
FROM
    Customers
WHERE
    state = 'CA'
    AND (city = 'Longview' 
         OR city = 'Forney' 
         OR city = 'Canandaigua' 
         OR city = 'Orchard Park');
--8. Liệt kê customer ở bang CA và ở bang NY
SELECT 
(first_name + ' ' + last_name) AS full_name,
phone,
state, 
(street + ' ' + city + ' ' + zip_code) AS address  
FROM customers
WHERE
    state IN ('CA','NY')

--9. Liệt kê orders, bổ sung column order_status_description: 1-mới đặt, 2-đang giao, 3-đã giao, 4-hoàn thành
SELECT *,
CASE 
    WHEN order_status = 1 THEN 'mới đặt'
	WHEN order_status = 2 THEN 'đang giao'
	WHEN order_status = 3 THEN 'đã giao'
    WHEN order_status = 4 THEN 'hoàn thành'
	ELSE 'không xác định'
	END AS order_status_description
FROM orders

--10. Liệt kê staff làm việc tại bang CA     
 with table_total as (SELECT * ,
CASE 
When store_id = 1 THEN 'CA'
WHEN store_id = 2 THEN 'NY'
WHEN store_id = 3 THEN 'TX'
ELSE 'không xác định'
END AS state
FROM staffs)
SELECT *
FROM table_total
WHERE state = 'CA'

--11. Liệt kệ product cùng brand và category tương ứng nhưng phải còn hàng
SELECT product_name,
       brand_id,
	   category_id,
	   quantity
FROM products
JOIN stocks ON stocks.product_id = products.product_id
where quantity > 0

--12. Liệt kê product cùng brand và caterogy tương ứng với điều kiện còn hang và có giá > 200.
SELECT product_name,
       brand_id,
	   category_id,
	   quantity,
	   list_price
FROM products
JOIN stocks ON stocks.product_id = products.product_id
where quantity > 0 AND list_price > 200

--15. Đếm số orders theo từng customer_id – kết  hợp liệt kê thông tin custome chi tiết
   

SELECT 
    customers.customer_id,
    customers.first_name,
    customers.last_name,
   COUNT(DISTINCT orders.order_id) AS order_count
FROM 
    orders
JOIN 
    customers
ON 
    orders.customer_id = customers.customer_id
GROUP BY 
    customers.customer_id,
	customers.first_name,
    customers.last_name

--16. Cho biết cửa hàng có số đơn hang bán được nhiều nhất
SELECT stores.store_id,
       stores.store_name,
	   stores.city,
SUM(stocks.quantity) as total_quantity
FROM stores
JOIN  
    stocks
ON 
    stocks.store_id = stores.store_id
GROUP BY 
         stores.store_id,
         stores.store_name,
	     stores.city
ORDER BY 
TOTAL_QUANTITY DESC

--17. Cho biết nhân viên có nhiều đơn hang hoàn thành nhất
SELECT staffs.first_name,
       staffs.last_name,
	   staffs.staff_id,
SUM(fact_sale.quantity) as total_quantity
FROM staffs
JOIN
    fact_sale
ON 
  staffs.staff_id = fact_sale. staff_id
  GROUP BY 
          staffs.first_name,
          staffs.last_name,
	      staffs.staff_id
ORDER BY total_quantity DESC
          
--18. Cho biết thành phố nào có nhiều cửa hàng nhất
SELECT *
FROM dimension_store
JOIN
    cities
ON 
 cities.city = dimension_store.city

--19. Bổ sung table order_item, add column gross_amt = quantity * list_price
ALTER TABLE order_items
ADD gross_amt DECIMAL(10, 2)

UPDATE order_items
SET gross_amt = quantity * list_price;

--20. Bổ sung table order_item, add column discount_amt = gross_amt * discount 
ALTER TABLE order_items
ADD discount_amt DECIMAL(10, 2)

UPDATE order_items
SET discount_amt = gross_amt  * discount;

--21. Bổ sung table order_item, add column net_amt = (quantity * list_price) * (1-discount_amt)
ALTER TABLE order_items
ADD net_amt DECIMAL(10, 2)

UPDATE order_items
SET net_amt = (quantity * list_price) * (1-discount_amt);

--24. Tạo mới 1 bảng customer1, staff1, product1 và store1 lần lượt copy dữ liệu từ customer, staff, product và store 
SELECT *
INTO customer1
FROM customers

SELECT *
INTO staff1
FROM staffs;

SELECT *
INTO product1
FROM products;

SELECT *
INTO store1
FROM stores;

--25. Thêm mới data trong customer1 từ staff1 từ bang CA và TX
SELECT *
FROM customer1

--27. Xóa dữ liễu trong product1 không tồn tại trong order_iterms
DELETE FROM product1
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items
    WHERE order_items.product_id = product1.product_id
);
SELECT *
FROM order_items

--28.Xóa dữ liệu lần lượt trong product1, store1 nếu có quantity tương ứng trong stock = 0
DELETE FROM product1
WHERE product_id IN (SELECT product_id
                     FROM stocks
					 WHERE quantity = 0 )

DELETE FROM store1
WHERE store_id IN (SELECT store_id
                     FROM stocks
					 WHERE quantity = 0 )

--29. Tìm danh sách đơn hàng có tổng số tiền vượt qua 200
with table_total as (SELECT orders.order_id,
       orders.customer_id,
SUM(fact_sale.list_price) as total_price
FROM orders
JOIN 
    fact_sale
ON orders.order_id = fact_sale.order_id
GROUP BY
orders.order_id,
orders.customer_id)
SELECT *
FROM table_total
WHERE total_price > 200 
ORDER BY total_price DESC

--30. Tìm các nhân viên bán được hơn 30 đơn hàng
with table_total as (SELECT staffs.staff_id,
       staffs.last_name,
SUM(fact_sale.quantity) as total_quantity
FROM staffs
JOIN 
    fact_sale
ON staffs.staff_id = fact_sale.staff_id
GROUP BY
staffs.staff_id,
staffs.last_name)
SELECT *
FROM table_total
WHERE total_quantity > 30 
ORDER BY total_quantity DESC

--31.Tìm các sản phẩm có số lượng bán được hơn 100 cái  
with table_total as (SELECT products.product_id,
       products.product_name,
SUM(order_items.quantity) as total_quantity
FROM products
JOIN 
    order_items
ON products.product_id = order_items.product_id
GROUP BY
products.product_id,
products.product_name)
SELECT *
FROM table_total
WHERE total_quantity > 100 
ORDER BY total_quantity DESC

--32.Liệt kê product và số tồn kho theo từng store, và theo con số tổng, them cột status ghi nhận hết hang, “sắp hết” nếu tổng số tồn <=20, ngược lại là OK, them cột khoảng thời gian giữa order_date và required_date 
SELECT 
    products.product_id,
    products.product_name,
    stores.store_id,
    SUM(stocks.quantity) AS total_stock,
    CASE 
        WHEN SUM(stocks.quantity) <= 0 THEN 'Hết hàng'
        WHEN SUM(stocks.quantity) <= 20 THEN 'Sắp hết'
        ELSE 'OK'
    END AS status,
    DATEDIFF(day, orders.order_date, orders.required_date) AS days_between_order_and_required
FROM 
    products
JOIN 
    stocks ON products.product_id = stocks.product_id
JOIN 
    stores ON stocks.store_id = stores.store_id
LEFT JOIN 
    orders ON orders.store_id = stores.store_id
GROUP BY 
    products.product_id, products.product_name, stores.store_id, orders.order_date, orders.required_date
ORDER BY 
    products.product_id, stores.store_id;
	
--33. Tìm danh sách khách hang và nhân viên cùng ở bang CA (union)
SELECT 
    customer_id AS id,
    first_name,
    last_name,
    'Customer' AS type
FROM 
    customers
WHERE 
    state = 'CA'

UNION

SELECT 
    staff_id AS id,
    first_name,
    last_name,
    'Staff' AS type
FROM 
    staffs
JOIN 
    stores 
ON stores.store_id = staffs.store_id
WHERE 
    state = 'CA';


--34.	Dùng câu lệnh pivot, liệt kê số lượng customer theo từng city
SELECT *
FROM (
    SELECT 
        city,
        COUNT(customer_id) AS customer_count
    FROM 
        customers
    GROUP BY 
        city
) AS SourceTable
PIVOT (
    SUM(customer_count)
    FOR city IN ()
) AS PivotTable;

--35. Dùng câu lệnh pivot, liệt kê số lượng order theo từng customer_id (tùy ý chọn 5 customer_id) và lưu vào table pivot1
SELECT *

FROM (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM 
         orders
    GROUP BY 
        customer_id
) AS SourceTable
PIVOT (
    SUM(order_count)
    FOR customer_id IN ([250],[1212],[1324],[91],[450])
) AS PivotTable;

--36. Viết cậu lệnh unpivot, query unpivot data từ table pivot1
SELECT 
    customer_id,
    order_count
FROM 
    table_pivot3
UNPIVOT (
    order_count FOR customer_id IN ([250], [1212], [1324], [91], [450])
) AS UnpivotTable;

 SELECT *
FROM (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM 
         orders
    GROUP BY 
        customer_id
) AS SourceTable
PIVOT (
    SUM(order_count)
    FOR customer_id IN ([250], [1212], [1324], [91], [450])
) AS PivotTable;

-- Câu 37.	Cho biết top 3 ngày có doanh thu cao nhất và top 5 ngày có doanh thu thấp nhất
SELECT *
FROM 
      fact_sale
	  
ALTER TABLE 
      fact_sale
ADD revenue DECIMAL(10, 2)

UPDATE fact_sale
SET revenue = (quantity * list_price) 
SELECT *
FROM (
SELECT TOP 5
       order_date,
	   SUM(revenue) AS total_revenue
FROM 
       fact_sale
GROUP BY 
       order_date
ORDER BY
       total_revenue DESC) as top_3_highest_revenue
UNION ALL
SELECT TOP 5
    order_date,
    SUM(revenue) AS total_revenue
FROM 
    fact_sale
GROUP BY 
    order_date
ORDER BY 
    total_revenue ASC;


--38. Cho biết top 10 hóa đơn có khoảng cách từ order_date đến shipped_date là thấp nhất
SELECT TOP 10
    order_id,
    DATEDIFF(day, order_date, shipped_date) AS between_date
FROM 
    fact_sale
ORDER BY
    between_date ASC

--39. Liệt kê danh sách nhân viên từ manager đi xuống theo phân cấp
SELECT *
FROM staffs
ORDER BY manager_id DESC

--40.	Liệt kê danh sách nhân viên theo thứ tự từ dưới lên
SELECT *
FROM staffs
ORDER BY staff_id DESC


--41. Tạo hàm tính độ lệch giữa order_date đến shipped_date. Liệt kê orders và độ lệch này
SELECT
      *,
	  DATEDIFF(day,order_date,shipped_date) as between_date
FROM 
      orders

--41. 
