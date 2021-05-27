function [halleydob, halleydob_direct, halleydob_nondirect] = readHalleyDobson(directory1, directory2, total_years)
    % Create table and array with all individual measurements
    files = dir([directory1,'*.DAT']);
    
    halleydob_table = readtable([directory1,files(1).name]);
    if contains(files(1).name,"2011B")
        blnk = array2table(NaN(height(halleydob_table),1));
        halleydob_table = horzcat(table2array(halleydob_table(:,1:2)),blnk,table2array(halleydob_table(:,3:end)));
        halleydob_table = array2table(halleydob_table);
        halleydob_table.Properties.VariableNames = {'Var1' 'Var2' 'Var3' 'Var4' 'Var5' 'Var6' 'Var7' 'Var8' 'Var9' 'Var10'};
    end
    file_year = str2double(files(1).name(7:10));
    next_index = find(halleydob_table.Var1 == 1, 1); 
    year(1:next_index-1,1) = file_year;
    year(next_index:height(halleydob_table),1) = file_year +1;
    j = height(halleydob_table)+1;
    for i = 2:length(files)
        na=files(i).name;
        new_table = readtable([directory1,files(i).name]);
        if contains(files(i).name,"2011B")
            blnk = NaN(height(new_table),1);
            new_table = horzcat(table2array(new_table(:,1:2)),blnk,table2array(new_table(:,3:end)));
            new_table = array2table(new_table);
            new_table.Properties.VariableNames = halleydob_table.Properties.VariableNames;
        end
        halleydob_table = vertcat(halleydob_table,new_table);
        file_year = str2double(files(i).name(7:10));
        start_new = find(new_table.Var1 == 1, 1);
        next_index = start_new - 1 + j; 
        if start_new > 1
            year(j:next_index-1,1) = file_year;
            year(next_index:height(halleydob_table),1) = file_year +1;
        elseif isempty(start_new)
            year(j:height(halleydob_table),1) = file_year;
        elseif start_new == 1
            year(j:height(halleydob_table),1) = file_year+1;
        end
        j = height(halleydob_table)+1;
    end
    halleydob_table = horzcat(array2table(year),halleydob_table);
    halleydob_table.Properties.VariableNames = {'Year','Month','Day','Hour','Minute','Julian','mu','SZA','Code','LS','Ozone'};
    halleydob_table(halleydob_table.Ozone < 10,:)=[];
    
%     %remove moon measurements
%     moon_index = find(mod(halleydob_table.LS,10)==1);
%     halleydob_table(moon_index,:) = [];
    
    % Create table and array with all daily values pre-1972
    files2 = dir([directory2,'*.txt']);
    
    halleydobmean_table = readtable([directory2,files2(1).name]);
    halleydobmean_table.Properties.VariableNames = {'Year','Month','Day','Ozone'};
    bad_index = find(halleydobmean_table.Ozone == 999);
    halleydobmean_table(bad_index,:) = [];
    
    % read in 2020 data
    halley2020_table = readtable([directory2,'ZYDATA2020.DAT']);
    halley2020_table.Properties.VariableNames = {'Month' 'Day'  'JJJJJ'   'Ozone'    'SD'   'N'   'MU'   'HOUR'  'SPAN'};
    
    % Take averages -- Hour, SZA, Ozone 
    yrs = length(total_years);
    halleydob.daily = NaN(31,12,yrs,11);
    
    for year = total_years
        y = year-total_years(1)+1;
        if year < 1973  
            for m = 1:12
                for d = 1:31
                    ind = find(halleydobmean_table.Day==d & halleydobmean_table.Month==m & halleydobmean_table.Year==year);
                    if ~isempty(ind)
                        halleydob.daily(d,m,y,11) = table2array(halleydobmean_table(ind,4));
                        date_array(d,m,y) = datetime(year,m,d);
                    else
                        disp([m d year]);
                    end
                end
            end
        elseif year == 2020
            for m = 1:12
                for d = 1:31
                    ind = find(halley2020_table.Day==d & halley2020_table.Month==m);
                    if ~isempty(ind)
                        halleydob.daily(d,m,y,11) = table2array(halley2020_table(ind,4));
                        date_array(d,m,y) = datetime(year,m,d);
                    else
                        disp([m d year]);
                    end
                end
            end
        else 
            year_indices = find(halleydob_table.Year==year);
            year_temp = halleydob_table(year_indices,:);
            for m = 1:12
                month_indices = find(year_temp.Month==m);
                month_temp = year_temp(month_indices,:);
                for d = 1:31
                    day_indices = find(month_temp.Day==d);
                    day_temp = month_temp(day_indices,:);
                    if length(day_indices) == 1
                        halleydob.daily(d,m,y,:) = table2array(day_temp);
                    else
                        halleydob.daily(d,m,y,:) = nanmean(table2array(day_temp));
                    end
                    date_array(d,m,y) = datetime(year,m,d);
                end
            end
        end
    end
    
    %clean
    halleydob.daily = halleydob.daily(:,:,:,[4, 8, 11]);
    halleydob.daily(24,8,2015-total_years(1)+1,:) = NaN(1,3);
    
    % Direct Sun
    direct_index = find(mod(halleydob_table.LS,10)==0);
    halleydobdirect_table = halleydob_table(direct_index,:);
    halleydob_direct.daily = NaN(31,12,yrs,11);
    for m = 1:12
        month_indices = find(halleydobdirect_table.Month==m);
        month_temp = halleydobdirect_table(month_indices,:);
        for year = total_years
            y = year-total_years(1)+1;
            year_indices = find(month_temp.Year==year);
            year_temp = month_temp(year_indices,:);
            for d = 1:31
                day_indices = find(year_temp.Day==d);
                day_temp = year_temp(day_indices,:);
                if length(day_indices) == 1
                    halleydob_direct.daily(d,m,y,:) = table2array(day_temp);
                else
                    halleydob_direct.daily(d,m,y,:) = nanmean(table2array(day_temp));
                end
            end
        end
    end
    halleydob_direct.daily = halleydob_direct.daily(:,:,:,[4, 8, 11]);
    halleydob_direct.daily(24,8,2015-total_years(1)+1,:) = NaN(1,3);
    
    % NonDirect Sun
    nondirect_index = find(mod(halleydob_table.LS,10)~=0);
    halleydobnondirect_table = halleydob_table(nondirect_index,:);
    halleydob_nondirect.daily = NaN(31,12,yrs,11);
    for m = 1:12
        month_indices = find(halleydobnondirect_table.Month==m);
        month_temp = halleydobnondirect_table(month_indices,:);
        for year = total_years
            y = year-total_years(1)+1;
            year_indices = find(month_temp.Year==year);
            year_temp = month_temp(year_indices,:);
            for d = 1:31
                day_indices = find(year_temp.Day==d);
                day_temp = year_temp(day_indices,:);
                if length(day_indices) == 1
                    halleydob_nondirect.daily(d,m,y,:) = table2array(day_temp);
                else
                    halleydob_nondirect.daily(d,m,y,:) = nanmean(table2array(day_temp));
                end
            end
        end
    end
    halleydob_nondirect.daily = halleydob_nondirect.daily(:,:,:,[4, 8, 11]);
    halleydob_nondirect.daily(24,8,2015-total_years(1)+1,:) = NaN(1,3);
    
    halleydob.doy = NaN(366,yrs,3);
    halleydob_direct.doy = NaN(366,yrs,3);
    halleydob_nondirect.doy = NaN(366,yrs,3);
    doy_array = NaN(31,12,51);
    for year = total_years
        y = year-total_years(1)+1;
        doy = 0;
        for month = 1:12
            for day = 1:31
                if month == 2
                    if mod(year,4)==0
                        if day <=29
                            doy = doy + 1;
                            doy_array(day,month,y) = doy;
                            halleydob.doy(doy,y,:)=halleydob.daily(day,month,y,:);
                            halleydob_direct.doy(doy,y,:)=halleydob_direct.daily(day,month,y,:);
                            halleydob_nondirect.doy(doy,y,:)=halleydob_nondirect.daily(day,month,y,:);
                        end
                    elseif day <= 28
                        doy = doy + 1;
                        doy_array(day,month,y) = doy;
                        halleydob.doy(doy,y,:)=halleydob.daily(day,month,y,:);
                        halleydob_direct.doy(doy,y,:)=halleydob_direct.daily(day,month,y,:);
                        halleydob_nondirect.doy(doy,y,:)=halleydob_nondirect.daily(day,month,y,:);
                    end
                elseif month == 9 || month == 4 || month == 6 || month == 11
                    if day <= 30
                        doy = doy + 1;
                        doy_array(day,month,y) = doy;
                        halleydob.doy(doy,y,:)=halleydob.daily(day,month,y,:);
                        halleydob_direct.doy(doy,y,:)=halleydob_direct.daily(day,month,y,:);
                        halleydob_nondirect.doy(doy,y,:)=halleydob_nondirect.daily(day,month,y,:);
                    end
                else
                    doy = doy + 1;
                    doy_array(day,month,y) = doy;
                    halleydob.doy(doy,y,:)=halleydob.daily(day,month,y,:);
                    halleydob_direct.doy(doy,y,:)=halleydob_direct.daily(day,month,y,:);
                    halleydob_nondirect.doy(doy,y,:)=halleydob_nondirect.daily(day,month,y,:);
                end
            end
        end
    end
     
    save('Calendar.mat','date_array','doy_array')
    %save('HalleyDobsonDirect.mat','halleydobdirect_table','halleydobdirect_average')
    %save('HalleyDobsonNonDirect.mat','halleydobnondirect_table','halleydobnondirect_average')
    
end