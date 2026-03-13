use AdventureWorksDW2022;
go

--#################################################################################################

-- overview on date table
SELECT * FROM dbo.DimDate;

-- the working period of the company
SELECT FORMAT(DATEDIFF(day, first_date, last_date) / 365, 'N0') AS "Operational Period (Years)"
FROM
(SELECT 
 MAX(fulldatealternatekey) AS last_date,
 MIN(fulldatealternatekey) AS first_date
 FROM dbo.dimdate) AS date_range;



--#################################################################################################

-- overview on customer table
SELECT * FROM dbo.DimCustomer;

-- count of customers
select 
format(count(customerkey),'N0') as "no of customers"
from dbo.DimCustomer
go

-- customer sales summary view
create view vw_customersalessummary
AS
SELECT
FirstName + ' ' + LastName AS "Full Name",
COUNT(Distinct(fis.SalesOrderNumber)) AS "No Of Orders",
SUM(fis.SalesAmount) AS "Total Sales",
CAST(MIN(fis.OrderDate) AS date) AS "First Order",
CAST(MAX(fis.OrderDate) AS date) AS "Last Order"
FROM dbo.DimCustomer as dc
inner join FactInternetSales as fis 
ON dc.CustomerKey = fis.CustomerKey
GROUP BY FirstName,LastName;
go

select * from vw_customersalessummary;


--#################################################################################################

-- overview on reseller table
SELECT * FROM dbo.DimReseller;

-- count of resellers
select 
count(resellerkey) as "no of resellers"
from dbo.DimReseller ;



--#################################################################################################

-- overview on product tables
SELECT * FROM dbo.DimProduct;
SELECT * FROM dbo.DimProductCategory;

-- count of products
select
count(productkey) as "No Of Products"
from dbo.DimProduct;

-- count of products categories
select 
count(productcategorykey) as "no of products categoreis"
from dbo.DimProductCategory;



--#################################################################################################

-- overview on sales territory tables
select * from dbo.DimSalesTerritory;

-- count of countries
select 
count(distinct(salesterritorycountry)) as "no of countries"
from DimSalesTerritory;



--#################################################################################################

-- overview on fact internet sales
select * from dbo.FactInternetSales;

-- internet sales measures
select 
format(sum(salesamount),'N0') as "Total Internet Sales",
format(sum(salesamount)-sum(totalproductcost),'N0') as Profit,
format(count(distinct(CustomerKey)),'N0') as "No Of Customers",
format(sum(orderquantity),'N0') as "Total Quantity",
format(count(distinct(salesordernumber)),'N0') as "No Of Orders"
from dbo.factinternetsales;

-- sales trends
select 
CalendarYear as Year,
format(sum(salesamount),'N0') as "Internet Sales" 
from FactInternetSales as fis inner join DimDate as dd
on fis.OrderDateKey=dd.DateKey
group by CalendarYear
order by CalendarYear;

-- sales by country
select 
salesterritorycountry as Country,
format(sum(salesamount),'N0') as "Internet Sales"
from FactInternetSales fis inner join DimSalesTerritory dst
on fis.SalesTerritoryKey=dst.SalesTerritoryKey
group by SalesTerritoryCountry
order by sum(salesamount) desc;

-- sales by product category
select 
englishproductcategoryname as "Product Category",
format(sum(salesamount),'N0') as "Internet Sales"
from FactInternetSales as fis right join dimproduct as dp
on fis.productkey=dp.productkey
inner join DimProductSubcategory as dps
on dp.ProductSubcategoryKey=dps.ProductSubcategoryKey 
inner join DimProductCategory as dpc 
on dps.ProductCategoryKey=dpc.ProductCategoryKey
group by EnglishProductCategoryName
order by sum(salesamount) desc;
go

-- SP FOR Top 100 customers whose total expenditure exceeds the overall average customer spending
create procedure sp_gettopcustomers
as 
begin
select top 100
firstname +' '+LastName as "Full Name" , Gender , 
format(YearlyIncome,'N0') as "Yearly Income",TotalChildren,
format(sum(salesamount),'N0') as "Total Expenditure"
from DimCustomer as dc inner join FactInternetSales as fis
on dc.CustomerKey=fis.CustomerKey
group by FirstName,LastName,Gender,YearlyIncome,TotalChildren
having sum(salesamount)>(select AVG(salesamount) from FactInternetSales)
order by sum(salesamount) desc;
end;
go

exec sp_gettopcustomers;



--#################################################################################################
-- other measures

-- total reseller sales
select format(sum(salesamount),'N0') as "Total Reseller Sales" from FactResellerSales

-- total sales
select 
format
((select sum(salesamount) from FactResellerSales)
+(select sum(salesamount) from factinternetsales),'N0')
as "Total Sales"