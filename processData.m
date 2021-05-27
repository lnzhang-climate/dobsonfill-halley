%% Variables
total_years = 1956:2020;
sat_names = ["GOME" "GOME2A" "GOME2B" "SCHIAMACHY" "OMI" "epTOMS" "OMPSnm" "NIMBUS7" "OMPSnp" "Meteor3" "SBUV"];
satfocus_names = ["GOME2A" "GOME2B" "OMI" "OMPSnm" "OMPSnp" "SBUV"];
%% readData 
% read in Halley Dob, Halley SOAZ, and Satellite data as (type).(data set).daily 
% and (type).(data set).doy arrays of (31,12,51,3) and (366,51,3)
    % 51 is the number of years (1970:2020)
    % 3 Variables: 1-Hr, 2-SZA, 3-Ozone
% saved as "DailyAverages.mat"
run("readData.m")
%% correctData
% correct bias using all years of available data, returns corrected.(data
% set).(correction type).daily array (31,12,year lngth,3)
    % by Month
    % by DOY 
% then take the mean of indiviudally corrected sets to get the corrected satellite average
run("correctData.m")
%% fillData
% fill the Halley Dobson record during the periods with no operations, returns halleydobfilled.(dataset)_(correction).daily (31,12,51,3)
halleyfilled.daily.sataverage_doycorrect = fillEmptyDobsonMonths(corrected.halley.sataverage.doycorrect, halley.dob, total_years);
halleyfilled.daily.sataverage_monthcorrect = fillEmptyDobsonMonths(corrected.halley.sataverage.monthcorrect, halley.dob, total_years);
% read in monthly means from BAS
halleyfilled.monthly.sataverage_doycorrect = fillDobsonMonthlyMeans(corrected.halley.sataverage.doycorrect, halley.dob.monthly, total_years);
halleyfilled.monthly.sataverage_monthcorrect = fillDobsonMonthlyMeans(corrected.halley.sataverage.monthcorrect, halley.dob.monthly, total_years);
save("HalleyFilled","halleyfilled")
