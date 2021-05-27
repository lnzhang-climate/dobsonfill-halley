[halley.dob, halley.dob_direct, halley.dob_nondirect] = readHalleyDobson('Halley/Daily/individual/', 'Halley/Daily/mean/', total_years);

dob_monthly = readtable('Halley/FormattedMonthly');
halley.dob.monthly = table2array(dob_monthly)';

halley.saoz = readHalleySAOZ('Halley/SAOZ/',total_years);

halley.satellite = readHalleySatellite('Overpass/Halley/',total_years,sat_names);

save("DailyAverages.mat",'halley')
