select * 
from portfolioproject..NasvilleHousing
-------------------------------------------------------------------------------------------
-- 1. standardize Date format


SELECT saledate,CONVERT(date,saledate)
from portfolioproject..NasvilleHousing

--try to update date in table
update portfolioproject..NasvilleHousing
SET saledate=convert(date,saledate)

--check again
SELECT saledate,CONVERT(date,saledate)
from portfolioproject..NasvilleHousing -- It seems that date not update in table

-- looking alter in table
ALTER TABLE portfolioproject..NasvilleHousing
Add SaleDateConverted Date -- set new column name SaleDateConverted

-- insert data in new column
update portfolioproject..NasvilleHousing
SET SaleDateConverted=CONVERT(date,SaleDate)

-- check again that new column have right date format in table or not
SELECT SaleDateConverted
from portfolioproject..NasvilleHousing

select * 
from portfolioproject..NasvilleHousing -- new column created

----------------------------------------------------------------------------------------------

-- 2. proper property address

select * 
from portfolioproject..NasvilleHousing
--where PropertyAddress is null
order by ParcelID -- we found duplicate parceId along with same property address is present

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NasvilleHousing a
join portfolioproject..NasvilleHousing b -- self join
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ] -- <> is indicate not equal to. Here uniqueId will not repeat.
WHERE a.PropertyAddress is null


update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NasvilleHousing a
join portfolioproject..NasvilleHousing b -- self join
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ] 
WHERE a.PropertyAddress is null


---------------------------------------------------------------------------------------------
--3. Breaking out address into PropertyAddress columns(Address,City,State)

select PropertyAddress
from portfolioproject..NasvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
--CHARINDEX(',',PropertyAddress) - it give us no. of position. we are doing this because we want to remove comma in output
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

from portfolioproject..NasvilleHousing

-- UPDATE table and create 2 new columns for addess and city

ALTER TABLE portfolioproject..NasvilleHousing
Add PropertySplitAddress NVARCHAR(255) -- set new column name PropertySplitAddress

-- insert data in new column
update portfolioproject..NasvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE portfolioproject..NasvilleHousing
Add PropertySplitCity NVARCHAR(255) -- set new column name PropertySplitCity

-- insert data in new column
update portfolioproject..NasvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- check again that new column created and details
select *
from portfolioproject..NasvilleHousing


---------------------------------------------------------------------------------------------
--4. Breaking out Owneraddress column into (Address,City,State)
Select OwnerAddress
from portfolioproject..NasvilleHousing

select
PARSENAME(OwnerAddress,1) -- we can use substring method too
from portfolioproject..NasvilleHousing --it seems like no change because parse name is only useful with periods

-- Now we replace the comma(,) with periods (.)
select OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3) as address,
PARSENAME(replace(OwnerAddress,',','.'),2) as city, 
PARSENAME(replace(OwnerAddress,',','.'),1) as state 
from portfolioproject..NasvilleHousing

-- Now update in table 

ALTER TABLE portfolioproject..NasvilleHousing
Add OwnerSplitAddress NVARCHAR(255) -- set new column name OwnerSplitAddress

-- insert data in new column
update portfolioproject..NasvilleHousing
SET OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE portfolioproject..NasvilleHousing
Add OwnerSplitCity NVARCHAR(255) -- set new column name OwnerSplitCity

-- insert data in new column
update portfolioproject..NasvilleHousing
SET OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE portfolioproject..NasvilleHousing
Add OwnerSplitState NVARCHAR(255) -- set new column name OwnerSplitState

-- insert data in new column
update portfolioproject..NasvilleHousing
SET OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)


-- check again that new column created and details
select *
from portfolioproject..NasvilleHousing

----------------------------------------------------------------------------------------------------------
--5. change Y and N into Yes and No in "SolidAsVacant" column.

-- check unique value present in SolidAs Vacant column
select distinct(SoldAsVacant)
from portfolioproject..NasvilleHousing


--check how much time present all distinct value present in SolidAsVacant column
select distinct(SoldAsVacant),count(SoldAsVacant) as count
from portfolioproject..NasvilleHousing
group by SoldAsVacant
order by count -- we can use 2 instead of count

--Replace now
select SoldAsVacant,
CASE when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
     Else SoldAsVacant
     END
from portfolioproject..NasvilleHousing

-- update in table now
update portfolioproject..NasvilleHousing
SET SoldAsVacant=CASE when SoldAsVacant='Y' then 'Yes'
                      when SoldAsVacant='N' then 'No'
                      Else SoldAsVacant
                      END

-- check again
select distinct(SoldAsVacant),count(SoldAsVacant) as count
from portfolioproject..NasvilleHousing
group by SoldAsVacant
order by count  -- update successfully

-------------------------------------------------------------------------------------------------------------

--6. REMOVE DUPLICATES

select * ,
ROW_NUMBER() OVER(            --ROW_NUMBER(): This is the window function that assigns a unique sequential integer to each
                              --row within the defined partitions.
PARTITION BY ParcelID, -- PARTITION BY: This clause is used to partition the result set into groups based on the specified columns
             PropertyAddress,
             SaleDate,
             SalePrice,
             LegalReference
             ORDER BY UniqueID) row_num

from portfolioproject..NasvilleHousing
order by ParcelID -- row_num restarts from 1 for each unique combination of ParcelID
--where row_num>1 it will not work. So we will use WITH statement

-- select all duplicate row 

WITH RowNumCTE AS(
select * ,
ROW_NUMBER() OVER(           
PARTITION BY ParcelID,
             PropertyAddress,
             SaleDate,
             SalePrice,
             LegalReference
             ORDER BY UniqueID) row_num

from portfolioproject..NasvilleHousing
--order by ParcelID
)
SELECT * 
from RowNumCTE
where row_num>1
order by PropertyAddress

-- Delete selected duplicate Row
WITH RowNumCTE AS(
select * ,
ROW_NUMBER() OVER(           
PARTITION BY ParcelID,
             PropertyAddress,
             SaleDate,
             SalePrice,
             LegalReference
             ORDER BY UniqueID) row_num

from portfolioproject..NasvilleHousing
--order by ParcelID
)
delete 
from RowNumCTE
where row_num>1
--order by PropertyAddress

--check again for duplicate row remove or not
WITH RowNumCTE AS(
select * ,
ROW_NUMBER() OVER(           
PARTITION BY ParcelID,
             PropertyAddress,
             SaleDate,
             SalePrice,
             LegalReference
             ORDER BY UniqueID) row_num

from portfolioproject..NasvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress  -- All duplicate Row removed now.

-------------------------------------------------------------------------------------------------------------------

--7. Delete unused column
select *
from portfolioproject..NasvilleHousing

ALTER TABLE portfolioproject..NasvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress

ALTER TABLE portfolioproject..NasvilleHousing
DROP COLUMN SaleDate