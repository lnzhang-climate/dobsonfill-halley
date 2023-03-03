# Scripts for filling gaps in the record of total ozone at Halley station using satellite observations
Run processData.m to: read in Halley Dobson and overpass data, correct the satellite instruments, and fill in the record.

The "filled dataset" folder contains downloadable .csv files
- the "daily" dataset (31 d x 12 m x 65 yr) fills in daily averages for months where no Dobson data is available
- the "monthly" dataset (12 m x 65 yr) fills in monthly averages for months that contain no Dobson data (using https://legacy.bas.ac.uk/met/jds/ozone/data/ZOZ5699.DAT)

Details can be found in Zhang et al. (2021): https://doi.org/10.5194/acp-21-9829-2021
