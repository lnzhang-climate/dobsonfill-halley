function out = fillDobsonMonthlyMeans(sat_data, dob_data, total_years)
    out = dob_data;
    sat_yearmean = squeeze(nanmean(sat_data.daily,1));
    for year = total_years
        y = year-total_years(1)+1;
        for month = 1:12 
            if isnan(out(month,y)) || year == 2019 || year == 2020
                out(month,y)=sat_yearmean(month,y,3);
            end
        end
    end
end