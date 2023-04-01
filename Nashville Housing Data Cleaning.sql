/****** Cleaning data SQL  ******/
SELECT * FROM [Portfolio_project].[dbo].[Nashvillehousing]

---standarzise date
SELECT saledate,CONVERT(Date,SaleDate)
FROM [Portfolio_project].[dbo].[Nashvillehousing]

ALTER table Nashvillehousing
add convertedsaledsate date;


UPDATE Nashvillehousing
SET convertedsaledsate=CONVERT(Date,SaleDate)

SELECT convertedsaledsate,saledate
FROM Portfolio_project.[dbo].Nashvillehousing

/***Populating property address**/

SELECT a.Parcelid,a.PropertyAddress,b.Parcelid,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_project.dbo.Nashvillehousing  a
JOIN Portfolio_project.dbo.Nashvillehousing b
on a.Parcelid=b.Parcelid
and a.UniqueId <>b.UniqueId
where a.PropertyAddress is NULL

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_project.dbo.Nashvillehousing  a
JOIN Portfolio_project.dbo.Nashvillehousing b
on a.Parcelid=b.Parcelid
and a.UniqueId <>b.UniqueId
where a.PropertyAddress is NULL


/***Addresss format***/

--SUBSTRING

select PropertyAddress from Nashvillehousing

select  PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Nashvillehousing

ALTER table Nashvillehousing
add propertysplitaddress nvarchar(255);


UPDATE Nashvillehousing
SET propertysplitaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER table Nashvillehousing
add propertysplitcity nvarchar(255);


UPDATE Nashvillehousing
SET propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from Nashvillehousing

---PARSENAME   


Select PARSENAME(OwnerAddress,1),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio_project].[dbo].[Nashvillehousing]



---CASE

select distinct SoldAsVacant ,count (SoldAsVacant)
from Nashvillehousing
group by SoldAsVacant
order by 2;

select
      CASE WHEN SoldAsVacant='Y' THEN 'YES'
	       WHEN SoldAsVacant='N' THEN 'No'
		   ELSE SoldAsVacant
		   END
from Nashvillehousing

UPDATE Nashvillehousing 
SET SoldAsVacant=     CASE WHEN SoldAsVacant='Y' THEN 'YES'
	       WHEN SoldAsVacant='N' THEN 'No'
		   ELSE SoldAsVacant
		   END
from Nashvillehousing

/****REMOVING DUPLICATES**/

WITH ROWNUMCTE AS(
Select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate
order by UniqueID)  rown_num
from [Portfolio_project].[dbo].[Nashvillehousing]
)
select * from  ROWNUMCTE
where rown_num>1;

--DELETING duplicates

WITH ROWNUMCTE AS(
Select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate
order by UniqueID)  rown_num
from [Portfolio_project].[dbo].[Nashvillehousing]

)
DELETE from  ROWNUMCTE
where rown_num>1;

/***DELETING unused columne***/

--SELECT * FROM  Nashvillehousing

ALTER Table Nashvillehousing
DROP COLUMN OwnerAddress
