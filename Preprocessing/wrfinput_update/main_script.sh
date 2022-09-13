#!/bin/bash

# Load conda enviroment with cdo and nco
source activate <conda_enviroment>

#-----------------------------------------------------------------------------------------------------------------
# Define source and destination files
source_file=$1                        	# File from which data are to be extracted (e.g. wrfout file, or obs file)
destination_file=$2			# File in which variable will be changed (e.g. wrfinput, or wrflowinput)
domain_boundaries="-80,-30,-40,-10"

#-----------------------------------------------------------------------------------------------------------------
# Define destination.grid
#-----------------------------------------------------------------------------------------------------------------
# Create cf-conform file to extract correct information on grids:
ncl 'file_in="'$destination_file'"' 'file_out="destination.nc"' to_cf.ncl

# Define source.grid and destination.grid:
python3 fix_grid.py destination.nc
mv source.grid destination.grid; rm destination.nc 

#-----------------------------------------------------------------------------------------------------------------
# Prepare and interpolate soil data from the source file
#-----------------------------------------------------------------------------------------------------------------
# Extract soil variables fro the source file
cdo selname,SMOIS,SH2O,TSLB,SMCWTD,LANDMASK $source_file source.nc

# Shriniking the source file to save memory and make interpolation faster:
cdo sellonlatbox,${domain_boundaries} source.nc source_cut.nc
mv source_cut.nc source.nc

# Create cf-conform file to extract correct information on grids:
ncl 'file_in="source.nc"' 'file_out="int_file.nc"' to_cf.ncl

# Define source.grid:
python3 read_grid.py int_file.nc; rm int_file.nc

# Setgrid on the working files:
cdo setgrid,source.grid source.nc source_setgrid.nc
mv source_setgrid.nc source.nc

# Creating weights
cdo gencon,destination.grid source.nc weights.nc

# Remapping
cdo remap,destination.grid,weights.nc source.nc remapped_soil.nc
rm weights.nc source.nc destination.grid source.grid
ncrename -d x,west_east   remapped_soil.nc
ncrename -d y,south_north remapped_soil.nc

#-----------------------------------------------------------------------------------------------------------------
# Changing soil data in the wrfinput file
#-----------------------------------------------------------------------------------------------------------------
ncl 'file_in="'$destination_file'"' 'file_out="remapped_soil.nc"' soil2wrfinput.ncl
rm remapped_soil.nc



