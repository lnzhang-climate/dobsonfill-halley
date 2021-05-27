function halleysaoz = readHalleySAOZ(directory,total_years)
    % Create table and array with all measurements
    files = dir([directory,'*.txt']);
    opts = detectImportOptions([directory,files(1).name],'NumHeaderLines',1);
    halleysaoz_table = readtable([directory,files(1).name],opts);
    
    year(1:height(halleysaoz_table),1) = str2double(strcat("20",files(1).name(5:6)));
    j = height(halleysaoz_table)+1;
    for i = 2:length(files)
        opts = detectImportOptions([directory,files(i).name],'NumHeaderLines',1);
        new_table = readtable([directory,files(i).name],opts);
        halleysaoz_table = vertcat(halleysaoz_table,new_table);
        year(j:height(halleysaoz_table),1) = str2double(strcat("20",files(i).name(5:6)));
        j = height(halleysaoz_table)+1;
    end
    dt = caldays(halleysaoz_table.Var1)+datetime(year-1,12,31);
    mon = month(dt);
    dy = day(dt);
    
    halleysaoz_table = horzcat(array2table(year),array2table(mon),array2table(dy),halleysaoz_table);
    
    %disp(halleysaoz_table.Properties.VariableNames)
    
    halleysaoz_table.Properties.VariableNames = {'Year','Month','Day','doy','Ozone','o3sd','amNO2','amno2sd','amno2n','pmNO2','pmNO2sd','pmNO2n','Tdet','wshift'};
    
    % Take averages -- Hour, SZA, Ozone 
    yrs = length(total_years);
    halleysaoz.daily = NaN(31,12,yrs,14);
    for m = 1:12
        month_indices = find(halleysaoz_table.Month==m);
        month_temp = halleysaoz_table(month_indices,:);
        for year = total_years
            y = year-total_years(1)+1;
            year_indices = find(month_temp.Year==year);
            year_temp = month_temp(year_indices,:);
            for d = 1:31
                day_indices = find(year_temp.Day==d);
                day_temp = year_temp(day_indices,:);
                if length(day_indices) == 1
                    halleysaoz.daily(d,m,y,:) = table2array(day_temp);
                else
                    halleysaoz.daily(d,m,y,:) = nanmean(table2array(day_temp));
                end
            end
        end
    end
    
    emptydaily = NaN(31,12,yrs,1);
    
    halleysaoz.daily = cat(4,emptydaily,emptydaily,halleysaoz.daily(:,:,:,5));
    
    halleysaoz.doy = NaN(366,yrs,3);
    for year = total_years
        y = year-total_years(1)+1;
        doy = 0;
        for mon = 1:12
            for d = 1:31
                if mon == 2
                    if mod(year,4)==0
                        if d <=29
                            doy = doy + 1;
                            halleysaoz.doy(doy,y,:)=halleysaoz.daily(d,mon,y,:);
                        end
                    elseif d <= 28
                        doy = doy + 1;
                        halleysaoz.doy(doy,y,:)=halleysaoz.daily(d,mon,y,:);
                    end
                elseif mon == 9 || mon == 4 || mon == 6 || mon == 11
                    if d <= 30
                        doy = doy + 1;
                        halleysaoz.doy(doy,y,:)=halleysaoz.daily(d,mon,y,:);
                    end
                else
                    doy = doy + 1;
                    halleysaoz.doy(doy,y,:)=halleysaoz.daily(d,mon,y,:);
                end
            end
        end
    end
    %save('HalleySAOZ.mat','halleysaoz_table','halleysaoz_average')
end