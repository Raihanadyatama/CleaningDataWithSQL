-- CLEANING DATA
----------------------------------------------------------------------------------------
Select * from NashvilleHousing
-------------------------------------------------------------------------------------
--Standardize Date Format
Select SaleDate from NashvilleHousing

Select SaleDate, Convert(date, SaleDate)
from NashvilleHousing

Alter table NashvilleHousing
add SaleDateConv Date

Update NashvilleHousing
set SaleDateConv = CONVERT(date,SaleDate)
---------------------------------------------------------------------------
--Populated Property Address
Select * from NashvilleHousing 
where PropertyAddress is null

Select * from NashvilleHousing
order by ParcelID

Select *
from NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
-----------------------------------------------------------------------

-- Seperate PropertyAddress (Address, City)
Select PropertyAddress,
Substring(PropertyAddress, 1, Charindex(',',PropertyAddress) -1) as Address1,
Substring(PropertyAddress, Charindex(',',PropertyAddress) +1, Len(PropertyAddress)) as Address2
from NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255), 
	PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',',PropertyAddress) -1),
	PropertySplitCity = Substring(PropertyAddress, Charindex(',',PropertyAddress) +1, Len(PropertyAddress));


-- Seperate OwnerAddress (Address, City, State)

Select OwnerAddress from NashvilleHousing

Select
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255), 
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3), 
	OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1) ;

Select * from NashvilleHousing

--Change Y and N in 'Sold As Vacant' Column

Select distinct SoldAsVacant from NashvilleHousing

Select distinct SoldAsVacant, count(soldAsVacant) 
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldASVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldASVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldASVacant = 'N' then 'No'
	else SoldAsVacant
end

-- Remove Duplicates
Select *, ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from NashvilleHousing order by ParcelID

With RowNumCTE as(
Select *, ROW_NUMBER() Over (
	Partition by 
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num
from NashvilleHousing
)

Select * from RowNumCTE
where row_num > 1
order by PropertyAddress

Delete from RowNumCTE
where row_num > 1

-------------------------------------------------------------------------------------

-- Delete unused Columns
Select * from NashvilleHousing

Alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate