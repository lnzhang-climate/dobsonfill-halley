%OMPSnp
function out = readSatelliteMeteor(directory,total_years)
    % Create table and array with all measurements
    files = dir([directory,'*.txt']);
    
    opts = detectImportOptions([directory,files(1).name],'NumHeaderLines',4);
    data_table = readtable([directory,files(1).name],opts);
    
    dt = caldays(data_table.Var3)+datetime(data_table.Var2-1,12,31);
    mon = month(dt);
    dy = day(dt);
    [hour, minute, second] = hms(seconds(data_table.Var4));
    
    data_table = horzcat(array2table(mon),array2table(dy),array2table(hour),array2table(minute),array2table(second),data_table);
    data_table.Properties.VariableNames = {'Month','Day','Hour','Minute','Second','Julian','Year','YearDay','sec-UT','SCN','Lat','Lon','DIS','PT','SZA','Ozone','REF','A.I','SOI'};
    
    average_data_table = data_table(:,[1, 2, 3, 7, 15, 16]);
    yrs = length(total_years);
    data_average.daily = NaN(31,12,yrs,width(average_data_table));
    for m = 1:12
        month_indices = find(average_data_table.Month==m);
        month_temp = average_data_table(month_indices,:);
        for year = total_years
            y = year-total_years(1)+1;
            year_indices = find(month_temp.Year==year);
            year_temp = month_temp(year_indices,:);
            for d = 1:31
                day_indices = find(year_temp.Day==d);
                day_temp = year_temp(day_indices,:);
                if length(day_indices) == 1
                    data_average.daily(d,m,y,:) = table2array(day_temp);
                elseif ~isempty(day_indices)
                    data_average.daily(d,m,y,:) = nanmean(table2array(day_temp));
                end
            end
        end
    end
    data_average.daily = data_average.daily(:,:,:,[3, 5, 6]);
    
    data_average.doy = NaN(366,yrs,3);
    for year = total_years
        y = year-total_years(1)+1;
        doy = 0;
        for mon = 1:12
            for d = 1:31
                if mon == 2
                    if mod(year,4)==0
                        if d <=29
                            doy = doy + 1;
                            data_average.doy(doy,y,:)=data_average.daily(d,mon,y,:);
                        end
                    elseif d <= 28
                        doy = doy + 1;
                        data_average.doy(doy,y,:)=data_average.daily(d,mon,y,:);
                    end
                elseif mon == 9 || mon == 4 || mon == 6 || mon == 11
                    if d <= 30
                        doy = doy + 1;
                        data_average.doy(doy,y,:)=data_average.daily(d,mon,y,:);
                    end
                else
                    doy = doy + 1;
                    data_average.doy(doy,y,:)=data_average.daily(d,mon,y,:);
                end
            end
        end
    end
    
    out.table = data_table;
    out.average = data_average;
end