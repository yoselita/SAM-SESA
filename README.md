# SAM-SESA
WRF UCAN setting for SAM-SESA simulations

This repository contains files, programs and scripts needed to set and run the WRF atmospheric model for simulating 3-years period over sub-South-American CORDEX domain on the convection permitting (CP) and 12km scale.
The repository is organized in folders:

1. Settings folder contains 2 subfolders for 3km and 12 km domain, with namelists for running WPS and WRF, as well as domain info and geo_em.d01 file.

2. Scripts folder contains scripts and the complete procedure on updating soil state in the wrfinput file from a WRF output to avoid long spinup. Also preparation precedure used for aerosol data is included here as well.

NOTE: WRF UCAN simuations at 3km is initialized on 25.5.2018, and uses soil data from WRF convection permitting run over South America conducted in NCAR by [SAAG](https://ral.ucar.edu/projects/south-america-affinity-group-saag) to avoid long spinup. 
