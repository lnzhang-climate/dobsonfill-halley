# dobsonfill-halley
Run processData.m to read in Halley Dobson and overpass data, correct the satellite instruments, and fill in the record.

The "filled dataset" folder contains downloadable .csv files
- the "daily" dataset fills in each day the Dobson was not available
- the "monthly" dataset fills in months that contain no Dobson data (using https://legacy.bas.ac.uk/met/jds/ozone/data/ZOZ5699.DAT)
