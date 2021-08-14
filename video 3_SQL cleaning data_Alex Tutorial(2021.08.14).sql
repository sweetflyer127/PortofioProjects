-- 1. Cleaning Data in SQL queries

SELECT * 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 2. Standardize data format 

--- 2.1 Alternative 1 
SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

--- 2.1 Alternative 2 

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 3. Populate Property Address data 

-- 3.1 check if NULL in PropertyAddress, result is YES. 

SELECT *
FROM Nini_PortofolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

-- 3.2 check if same ParcellID but there is property addess 

SELECT ParcelID, PropertyAddress
FROM Nini_PortofolioProject.dbo.NashvilleHousing
ORDER BY ParcelID ASC;

-- 3.3. Join table NashvilleHousing itself to find PropertyAddress where is NULL 

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
       FROM Nini_PortofolioProject.dbo.NashvilleHousing AS a
            JOIN Nini_PortofolioProject.dbo.NashvilleHousing AS b
	        ON a.ParcelID = b.ParcelID
	        AND a.[UniqueID ] <> b.[UniqueID ]
         WHERE a.PropertyAddress IS NULL; 

-- 3.4. Use ISNULL to fill propertyAddress where is NULL

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
       FROM Nini_PortofolioProject.dbo.NashvilleHousing AS a
            JOIN Nini_PortofolioProject.dbo.NashvilleHousing AS b
	        ON a.ParcelID = b.ParcelID
	        AND a.[UniqueID ] <> b.[UniqueID ]
         WHERE a.PropertyAddress IS NULL; 

-- 3.5. Cover PropertyAddress where is NULL in the table NashvilleHousing 

UPDATE a  
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nini_PortofolioProject.dbo.NashvilleHousing AS a
            JOIN Nini_PortofolioProject.dbo.NashvilleHousing AS b
	        ON a.ParcelID = b.ParcelID
	        AND a.[UniqueID ] <> b.[UniqueID ]
         WHERE a.PropertyAddress IS NULL; 

-- 3.6 Double check the result (above 3.4.) if table has null in column PropertyAddress

-- 4. Breaking out address into Individual columns (address, city, state) by SUBSTRING & CHARINDEX 

-- 4.1 Breaking out address into Addresss and City 

SELECT PropertyAddress
FROM Nini_PortofolioProject.dbo.NashvilleHousing

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
	    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 4.2 Add splited Address and City into Table 

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
ADD PropersplitAddress NVARCHAR (255) 

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing
SET PropersplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing 
ADD PropersplitCity NVARCHAR (255)

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing
SET PropersplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- 5. Breaking out OwnerAddresss into individual columns by PARSENAME 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 5.1 Add splited OwnerAddress into table 

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
ADD OwnersplitAddress VARCHAR(255) 

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing 
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
ADD OwnersplitCity VARCHAR(255) 

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing 
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
ADD OwnerSplitState VARCHAR(255) 

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing 
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 6. Change Y and N to Yes and No in SoldAsVacant

-- 6.1 Check how many different type in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nini_PortofolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 ASC

-- 6.2 Change Y and N to Yes and No in SoldAsVacant

SELECT SoldAsVacant, 
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
       WHEN SoldAsVacant = 'N' THEN 'No' 
	   Else SoldAsVacant  
	   END 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

UPDATE Nini_PortofolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
       WHEN SoldAsVacant = 'N' THEN 'No' 
	   Else SoldAsVacant  
	   END

-- 6.3 Back to 6.1 to double check & confirm no Y and N but Yes and No

-- 7. Remove duplicates

-- 7.1 Check status
SELECT * 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

-- 7.2 USE CTE to filter Row_num > 1 (duplicates)
WITH ROWNUM_CTE AS ( 
SELECT *, 
       ROW_NUMBER () OVER (
	   PARTITION BY ParcelID, 
	                PropertyAddress, 
					SaleDate, 
					SalePrice,
					Legalreference
					ORDER BY UniqueID) AS Row_num
FROM Nini_PortofolioProject.dbo.NashvilleHousing
)

--- 7.3. USE SELECT * to check if there are duplicates

--SELECT *
--FROM ROWNUM_CTE
--WHERE Row_num > 1

--- 7.4 if above (select *) find duplicates, then use DELETE (below) to remove all duplicates
DELETE 
FROM ROWNUM_CTE
WHERE Row_num > 1

--- 7.5. Excute 7.2 + 7.4 to check if there are Row_num > 1, result turns out no. All duplicates are removed. 

--- 8. Delete unused columns 

SELECT * 
FROM Nini_PortofolioProject.dbo.NashvilleHousing

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict 

ALTER TABLE Nini_PortofolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate










