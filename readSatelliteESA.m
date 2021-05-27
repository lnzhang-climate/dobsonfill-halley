function out = readSatelliteESA(directory,total_years)
    % Create table and array with all measurements
    files = dir([directory,'*.dat']);
    
    data_table = readtable([directory,files(1).name]);
    new_date = num2str(data_table.Var1);
    year = str2num(new_date(:,1:4));
    month = str2num(new_date(:,5:6));
    day = str2num(new_date(:,7:8));
    
    hour = (mod(data_table.Var2,10000)-mod(data_table.Var2,10000))/10000;
    minute = (mod(data_table.Var2,10000)-mod(data_table.Var2,100))/100;
    second = mod(data_table.Var2,100);
    
    dt = datetime(year,month,day,hour,minute,second);
    jd = juliandate(dt);
    
    data_table = horzcat(array2table(year),array2table(month),array2table(day),array2table(hour),array2table(minute),array2table(second),data_table,array2table(jd));
    data_table.Properties.VariableNames = {'Year','Month','Day','Hour','Minute','Second','Date','UTC','Lat','Lon','SZA','Distance','Height','Ozone','Pixels','Julian'};
    data_table.Ozone = data_table.Ozone/1.025; %Bass Paur adjustment
    
    % Take averages -- Hour, SZA, Ozone 
    yrs = length(total_years);
    data_average.daily = NaN(31,12,yrs,width(data_table));
    for m = 1:12
        month_indices = find(data_table.Month==m);
        month_temp = data_table(month_indices,:);
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
    data_average.daily = data_average.daily(:,:,:,[4, 11, 14]);
    
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