use AdventureWorksDW2022;
go

--#################################################################################################

-- overview on date table
SELECT * FROM dbo.DimDate;

-- the working period of the company
SELECT 
MAX(fulldatealternatekey) AS last_date,
MIN(fulldatealternatekey) AS first_date,
DATEDIFF(day,MIN(fulldatealternatekey),MAX(fulldatealternatekey))/365 AS 'Operational Period (Years)'
FROM dbo.dimdate;



--#################################################################################################

-- overview on customer table
SELECT * FROM dbo.DimCustomer;

-- count of customers
select 
format(count(customerkey),'N0') as "no of customers"
from dbo.DimCustomer;



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
count(productkey) as "no of products"
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
format(sum(salesamount),'N0') as "total internet sales",format(sum(salesamount)-sum(totalproductcost),'N0') as profit,
format(count(distinct(CustomerKey)),'N0') as "no of customers",format(sum(orderquantity),'N0') as "total quantities"
from dbo.factinternetsales;


-- sales trends
select 
CalendarYear as year,format(sum(salesamount),'N0') as "internet sales" 
from FactInternetSales as fis inner join DimDate as dd
on fis.OrderDateKey=dd.DateKey
group by CalendarYear
order by CalendarYear;


-- sales by country
select 
salesterritorycountry as country,format(sum(salesamount),'N0') as "internet sales"
from FactInternetSales fis inner join DimSalesTerritory dst
on fis.SalesTerritoryKey=dst.SalesTerritoryKey
group by SalesTerritoryCountry
order by sum(salesamount) desc;


-- sales by product category
select 
englishproductcategoryname as "product category", format(sum(salesamount),'N0') as "internet sales"
from FactInternetSales as fis inner join dimproduct as dp
on fis.productkey=dp.productkey
inner join DimProductSubcategory as dps
on dp.ProductSubcategoryKey=dps.ProductSubcategoryKey 
right join DimProductCategory as dpc 
on dps.ProductCategoryKey=dpc.ProductCategoryKey
group by EnglishProductCategoryName
order by sum(salesamount) desc;


-- top 100 customers who spend more than the average spending
select top 100
firstname +' '+LastName as "full name" , gender , 
YearlyIncome,TotalChildren,format(sum(salesamount),'N0') as "Total Expenditure"
from DimCustomer as dc inner join FactInternetSales as fis
on dc.CustomerKey=fis.CustomerKey
group by FirstName,LastName,Gender,YearlyIncome,TotalChildren
having sum(salesamount)>(select AVG(salesamount) from FactInternetSales)
order by sum(salesamount) desc;



--#################################################################################################

-- other measures

-- total reseller sales
select format(sum(salesamount),'N0') as "total reseller sales" from FactResellerSales

-- total sales
select 
format
((select sum(salesamount) from FactResellerSales)
+(select sum(salesamount) from factinternetsales),'N0')
as "total sales"