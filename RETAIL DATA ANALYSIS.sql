

-- Data Preperation and Understanding

-- 1.What is the total number of rows in each of 3 tables in the database?

	SELECT 'TBL_CUSTOMER' AS TBL_NAME, COUNT(*) AS NO_OF_RECORDS FROM [dbo].[CUSTOMER]
	UNION ALL
	SELECT 'TBL_PROD_CAT_INFO', COUNT(*) FROM [dbo].[prod_cat_info]
	UNION ALL
	SELECT 'TBL_TRANSACTIONS', COUNT(*) FROM [dbo].[Transactions]

--2. What is the total number of transaction that  have return
	
	SELECT COUNT(QTY) [TRANSACTIONS THAT HAVE RETURN] FROM TRANSACTIONS
	WHERE cast(QTY as float) < 0 AND cast(total_amt as float) < 0
--3
	UPDATE CUSTOMER
	SET DOB = CONVERT (DATE , DOB ,103)

	UPDATE Transactions
	SET tran_date = CONVERT (DATE , tran_date ,103)

--4
	SELECT 
    MIN(TRAN_DATE) AS Start_tran_Date,
    MAX(TRAN_DATE) AS End_tran_Date,
    DATEDIFF(DAY,  Min(TRAN_DATE), Max(TRAN_DATE) ) AS Difference_Days,
    DATEDIFF(MONTH,Min(TRAN_DATE), Max(TRAN_DATE) ) AS Difference_Months,
    DATEDIFF(YEAR, Min(TRAN_DATE), Max(TRAN_DATE) ) AS Difference_Years
	FROM Transactions

	
--5	
	SELECT prod_cat FROM PROD_CAT_INFO
	WHERE prod_subcat = 'DIY'

	
	--DATA ANALYSIS
	
--1
	Select Top 1 Store_type , Count(Store_type) as [COUNT OF STORE] from Transactions
	Group by Store_type
	Order by Count(Store_Type) Desc
--2
	SELECT GENDER , COUNT(GENDER) AS COUNTOFGENDER FROM Customer
	GROUP BY Gender

--3
	Select top 1 City_code , Count(City_code) as [Number of customers] from Customer
	Group by city_code
	Order by Count(City_code) desc

--4
SELECT  prod_cat Category,COUNT(prod_subcat) [Count Of SUbcategories]   FROM prod_cat_info
WHERE prod_cat = 'BOOKS'
GROUP BY prod_cat

--5
SELECT prod_subcat_code ,MAX(QTY) FROM Transactions
GROUP BY prod_subcat_code
ORDER BY prod_subcat_code 

Select Store_type , Count(Store_type) as [COUNT OF STORE] from Transactions
Group by Store_type

SELECT city_code , COUNT(city_code) FROM Customer
GROUP BY city_code
ORDER BY  city_code

--6
SELECT T1.prod_cat AS CATEGORIES , SUM(CAST(total_amt AS numeric)) [TOTAL REVENUE GENERATED] FROM prod_cat_info T1 INNER JOIN Transactions T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE T1.prod_cat IN ('BOOKS','ELECTRONICS') 
GROUP BY T1.prod_cat

--7 HOW MANY CUSTOMERS HAVE GREATER THAN 10 TRANSACTIONS WITH US , EXCLUDING RETURNS?

SELECT CUST_ID , COUNT(CUST_ID) [COUNT OF TRANSACTIONS] FROM Transactions 
WHERE CAST(QTY AS numeric) < 0 AND CAST(total_amt AS numeric) < 0
GROUP BY cust_id
HAVING COUNT(CUST_ID) >10

--8 
SELECT T1.prod_cat AS CATEGORIES , SUM(CAST(total_amt AS numeric)) [TOTAL REVENUE GENERATED] FROM prod_cat_info T1 INNER JOIN Transactions T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE T1.prod_cat IN ('clothing','ELECTRONICS') and T2.Store_type='Flagship store' 
GROUP BY T1.prod_cat

--9
SELECT P.prod_subcat ,ROUND(SUM(CAST(T.total_amt AS FLOAT)),2) AS [TOTAL REVENUE] FROM Transactions T INNER JOIN CUSTOMER C ON T.cust_id = C.customer_Id INNER JOIN prod_cat_info P ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE Gender = 'M' AND P.PROD_CAT = 'ELECTRONICS'
GROUP BY P.PROD_SUBCAT
ORDER BY ROUND(SUM(CAST(T.total_amt AS FLOAT)),2) DESC


--10 

	select top 5
	P.prod_subcat [Subcategory] ,
	Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)[Sales]  , 
	Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2) [Returns] ,
	Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
			- Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)[total_qty],
	((Round(SUM(cast( case when T.Qty < 0 then T.Qty  else 0 end as float)),2))/
				(Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
				- Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_Returs],
	((Round(SUM(cast( case when T.Qty > 0 then T.Qty  else 0 end as float)),2))/
			(Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
			- Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_sales]
	from Transactions as T
		INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
		group by P.prod_subcat
		order by [%_sales] desc



--11

SELECT SUM(cast(t.total_amt as float)) as Net_Total_Revenue
FROM (SELECT t.*,
             MAX(t.tran_date) OVER () as max_tran_date
      FROM Transactions t
     ) t JOIN
     Customer c
     ON t.cust_id = c.customer_Id
WHERE t.tran_date >= DATEADD(day, -90, t.max_tran_date) AND 
      t.tran_date >= DATEADD(YEAR, 25, c.DOB) AND
      t.tran_date <= DATEADD(YEAR, 35, c.DOB);


--12 
	
SELECT TOP 1 P.prod_cat , SUM(CAST(total_amt AS float)) [MAX VALUE OF RETURNS] FROM Transactions T INNER JOIN prod_cat_info P ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE CAST(total_amt AS float) < 0 AND t.tran_date >= DATEADD(DAY,-90,'24-02-2014')
GROUP BY P.prod_cat
ORDER BY SUM(CAST(total_amt AS float))


--13
select store_type, MAX(total_amt), MAX(Qty)
from Transactions
group by Store_type
ORDER BY  MAX(total_amt) DESC,  MAX(Qty) DESC 


--14
SELECT p.prod_cat, AVG(Cast(t.total_amt as float)) AS average 
FROM (SELECT t.*, AVG(Cast(t.total_amt as float)) OVER () as overall_average
      FROM Transactions T
     ) t JOIN
     prod_cat_info P 
     ON T.prod_cat_code = P.prod_cat_code
GROUP BY p.prod_cat, overall_average
HAVING AVG(Cast(t.total_amt as float)) > overall_average;

--15

select P.prod_subcat as Product_SubCategory, 
AVG(cast(total_amt as float)) as Average_Revenue,
SUM(cast(total_amt as float)) as Total_Revenue
from Transactions as T
INNER JOIN prod_Cat_info as P
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = 
P.prod_sub_cat_code
WHERE P.prod_cat_code IN (
select top 5 P.prod_cat_code
from prod_cat_info as P
inner join Transactions as T
ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = 
T.prod_subcat_code
group by P.prod_cat_code
order by sum(Cast(Qty as numeric)) desc
)
group by P.prod_subcat





















SELECT PROD_SUBCAT , AVG(CAST(TOTAL_AMT AS FLOAT)) , SUM(CAST(TOTAL_AMT AS FLOAT)) FROM Transactions T INNER JOIN prod_cat_info P ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat_code IN (
SELECT TOP 5 P.prod_cat_code  FROM
prod_cat_info P INNER JOIN Transactions T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY P.prod_cat_code
ORDER BY SUM(CAST(T.Qty AS NUMERIC)) DESC
)
GROUP BY P.prod_subcat
