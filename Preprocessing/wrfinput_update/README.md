Here you can find a set of scripts and small programs to update soil information in a wrfinput file in order to avoid long run to spinup the soil. 

The idea is to extract soil data (moisture and temperature) from an already available WRF run, remap the data to the grid of our WRF simulations and replace the soil variables that are located in the wrfinput file with those extracted from the wrfout longterm run. 

To follow the procedure, it is necessary to download and place all the script from this folder together with the wrfiput file and the wrfout file in the same location. To update the wrfinoput file, it is simply necessary to run:

**./main_script.sh [wrfout] [wrfiput]**

Description of the scripts in the folder:

**to_cf.ncl** - a small ncl script that extracts a variable from wrfiput file and write it out in a format following the CF conventions, 
so that the script can read the projection data correctly.

**read_grid.py** - the script based on the script shared within the CORDEX comunity that calculates corners of each grid and write it in the destination.grid file, allowing for correct and easy remapping afterwards. 

Then, the extracted soil data from wrfout, after getting the projection info (with read_grid.py) are remapped to the wrfinput grid using the cdo commands given directly in the main_script.sh (1st order conservation remapping)

**soil2wrfinput.ncl** - a small script used at the end, that updates the soil data (SMOIS, TSLB, and SH20) in the wrfinput file fro the given wrfout file.
