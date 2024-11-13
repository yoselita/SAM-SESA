# SAM-SESA
WRF UCAN setting for SAM-SESA simulations

This repository contains files, programs and scripts needed to set and run the WRF atmospheric model for simulating 3-years period over sub-South-American CORDEX domain on the convection permitting (CP) scale.
The repository is organized in folders:


1. Settings folder contains namelists for running WPS and WRF, as well as domain info and geo_em.d01 file.


2. Preprocessing folder contains scripts and the complete procedure on updating soil state in the wrfinput file from a WRF output to avoid long spinup. Also preparation precedure used for aerosol data is included here as well.

3. Running folder contains running scripts used to run wrf.exe on a monthly frequency.

NOTE: WRF UCAN simuation is initialized on 25.5.2018, and uses soil data from WRF convection permitting run over South America conducted in NCAR by [SAAG](https://ral.ucar.edu/projects/south-america-affinity-group-saag) to avoid long spinup. 
