/* Cleaning data in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------

--Standardize Date Format, the codes below doesn't update due to its originally a date type which all the time stays the same. You have to convert 
-- into string first if you want to update the date format. 

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

--Usng other method to udate the date. It worked but The problem with the code below was for me it ruined all the database readability. 
--I had to rerun new query to get everything back to normal. Maye its just a system error, dont know.


-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;


-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- 3. Run the Query
SELECT SaleDate, SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

--Populate Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

-- We can see ParcelID matches property address, so we can update NULL values in property address based on ParcelID.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- to UPDATE

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------
-- Breaking out address into individual columns

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT	
substring(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1 ) as Address 
, substring(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing


--Creating 2 new columns
-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1 )


-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress))

--check after the update
SELECT *
FROM PortfolioProject..NashvilleHousing


--split owner address using PARSNAME function instead of substracting as the code above. Only works when is '.' separated but not ','. 
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

select
PARSENAME (REPLACE(owneraddress,',','.'), 3)
,PARSENAME (REPLACE(owneraddress,',','.'), 2)
,PARSENAME (REPLACE(owneraddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing


-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(owneraddress,',','.'), 3)

-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(owneraddress,',','.'), 2)

-- 1 Add the table column below 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

-- 2 Update the dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(owneraddress,',','.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------
--Change Y and N in SoldAsVacant

SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		End
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					End


------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) rown_num
				
FROM PortfolioProject..NashvilleHousing
)

--SELECT *
DELETE
FROM RowNumCTE
where rown_num > 1
--order by PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------
--Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate


