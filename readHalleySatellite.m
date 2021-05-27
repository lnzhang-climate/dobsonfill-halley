function satellite = readHalleySatellite(directory,total_years,sat_names)
    % ESA
    GOME_out = readSatelliteESA([directory,'GOME/'],total_years);
    satellite.GOME = GOME_out.average;
    GOME2A_out = readSatelliteESA([directory,'GOME2A/'],total_years);
    satellite.GOME2A = GOME2A_out.average;
    GOME2B_out = readSatelliteESA([directory,'GOME2B/'],total_years);
    satellite.GOME2B = GOME2B_out.average;
    SCHIAMACHY_out = readSatelliteESA([directory,'SCHIAMACHY/'],total_years);
    satellite.SCHIAMACHY = SCHIAMACHY_out.average;
    % NASA 1
    OMI_out = readSatelliteNASA1([directory,'OMI/'],total_years);
    satellite.OMI = OMI_out.average;
    epTOMS_out = readSatelliteNASA1([directory,'epTOMS/'],total_years);
    satellite.epTOMS = epTOMS_out.average;
    OMPStc_out = readSatelliteNASA1([directory,'OMPStc/'],total_years);
    satellite.OMPSnm = OMPStc_out.average;
    NIMBUS7_out = readSatelliteNASA1([directory,'NIMBUS7/'],total_years);
    satellite.NIMBUS7 = NIMBUS7_out.average;
    % NASA 2
    OMPSnp_out = readSatelliteNASA2([directory,'OMPSnp/'],total_years);
    satellite.OMPSnp = OMPSnp_out.average;
    % Meteor 3
    Meteor3_out = readSatelliteMeteor([directory,'Meteor3/'],total_years);
    satellite.Meteor3 = Meteor3_out.average;
    
    % SBUV
    SBUV_out = readSatelliteSBUV([directory,'SBUV/'],total_years);
    satellite.SBUV = SBUV_out.average;
    
    yrs = length(total_years);
    
    % Average of all satellites
    allsats.daily = NaN(31,12,yrs,3,length(sat_names));
    i = 1;
    for sat = sat_names
        allsats.daily(:,:,:,:,i) = satellite.(sat).daily;
        i = i+1;
    end
    satellite.sataverage.daily = nanmean(allsats.daily,5);
    satellite.sataverage.std.daily = nanstd(allsats.daily,0,5);
    
    for year = total_years
        y = year-total_years(1)+1;
        doy = 0;
        for mon = 1:12
            for d = 1:31
                if mon == 2
                    if mod(year,4)==0
                        if d <=29
                            doy = doy + 1;
                            satellite.sataverage.doy(doy,y,:)=satellite.sataverage.daily(d,mon,y,:);
                            satellite.sataverage.std.doy(doy,y,:)=satellite.sataverage.std.daily(d,mon,y,:);
                        end
                    elseif d <= 28
                        doy = doy + 1;
                        satellite.sataverage.doy(doy,y,:)=satellite.sataverage.daily(d,mon,y,:);
                        satellite.sataverage.std.doy(doy,y,:)=satellite.sataverage.std.daily(d,mon,y,:);
                    end
                elseif mon == 9 || mon == 4 || mon == 6 || mon == 11
                    if d <= 30
                        doy = doy + 1;
                        satellite.sataverage.doy(doy,y,:)=satellite.sataverage.daily(d,mon,y,:);
                        satellite.sataverage.std.doy(doy,y,:)=satellite.sataverage.std.daily(d,mon,y,:);
                    end
                else
                    doy = doy + 1;
                    satellite.sataverage.doy(doy,y,:)=satellite.sataverage.daily(d,mon,y,:);
                    satellite.sataverage.std.doy(doy,y,:)=satellite.sataverage.std.daily(d,mon,y,:);
                end
            end
        end
    end
end