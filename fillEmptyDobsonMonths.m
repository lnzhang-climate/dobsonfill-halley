function out = fillEmptyDobsonMonths(sat_data, dob_data, total_years)
    month_names = ["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"];
    f = 1;
    yrs = length(total_years);
    out.daily = NaN(31,12,yrs,3);
    for year = total_years
        y = year-total_years(1)+1;
        for m = 1:12
            %check if month empty
            if ( nnz(~isnan(dob_data.daily(:,m,y,3))) > 1 || m == 5 || m == 6 || m == 7) && year ~= 2019 && year ~= 2020
                for d = 1:31    
                    out.daily(d,m,y,:) = dob_data.daily(d,m,y,:);
                end
            else
                out.empty_months(f) = strcat(month_names(m)," ",num2str(year));
                f = f+1;
                if m == 4
                    for d = 1:16
                        out.daily(d,m,y,:) = sat_data.daily(d,m,y,:);
                    end
                elseif m == 8
                    for d = 27:31
                        out.daily(d,m,y,:) = sat_data.daily(d,m,y,:);
                    end 
                else
                    for d = 1:31
                        out.daily(d,m,y,:) = sat_data.daily(d,m,y,:);
                    end 
                end
            end
        end
    end
end