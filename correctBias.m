%Inputs: sat_set (the satellite dataset that's being bias corrected
%Outputs: out (the bias corrected satellite dataset for the years)

function out = correctBias(sat_data, halleydob_data, total_years)
    
    correction_y = (total_years(1):2018)-total_years(1)+1;
    
    overpass_dlyO3 = sat_data.daily(:,:,correction_y,3);
    halley_dlyO3 = halleydob_data.daily(:,:,correction_y,3);

    no_overlap = find(isnan(halley_dlyO3) | isnan(overpass_dlyO3));
    halley_dlyO3(no_overlap)=NaN;
    overpass_dlyO3(no_overlap)=NaN;

    % Find absolute differences (biases) between monthly averages for sataverage and dobson
    overpass_monO3 = nanmean(overpass_dlyO3,[1 3]);
    halley_monO3 = nanmean(halley_dlyO3,[1 3]);

    out.biases.monthly = overpass_monO3-halley_monO3;
    out.monthcorrect.daily = sat_data.daily;
    for i = 1:12
        if ~isnan(out.biases.monthly(i))
            out.monthcorrect.daily(:,i,:,3) = out.monthcorrect.daily(:,i,:,3)-out.biases.monthly(i);
        end
    end
 
    % Find biases by doy
    halley_doyO3 = halleydob_data.doy(:,:,3);
    overpass_doyO3 = sat_data.doy(:,:,3);
    no_overlap = find(isnan(halley_doyO3) | isnan(overpass_doyO3));
    halley_doyO3(no_overlap)=NaN;
    overpass_doyO3(no_overlap)=NaN;
    
    overpass_doyO3 = nanmean(overpass_doyO3,2);
    halley_doyO3 = nanmean(halley_doyO3,2);
    
    out.biases.doy = overpass_doyO3-halley_doyO3;
    out.doycorrect.doy = sat_data.doy;
    for i = 1:366
        if ~isnan(out.biases.doy(i))
            out.doycorrect.doy(i,:,3) = out.doycorrect.doy(i,:,3)-out.biases.doy(i);
        end
    end
    
    out.doycorrect.daily = convertfromDOY(out.doycorrect.doy,total_years);
end