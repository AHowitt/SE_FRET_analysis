%% DISPLAY - SINGLE CELL

o_frt_ctr = o_frt(idx_ctr,:,:);

o_frt_trt = o_frt(idx_trt,:,:);

temp_ctr = reshape(shiftdim(o_frt_ctr,1),[tn max_on*n_ctr])';

temp_trt = reshape(shiftdim(o_frt_trt,1),[tn max_on*n_trt])';

sel = 1;

for c_num = 1:size(temp_ctr,1)
    
    if nnz(temp_ctr(c_num,1:tn-1)) >= qc_ti
    
        timefrt_ctr(sel,1:tn) = temp_ctr(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

sel = 1;
c_num = 0;

for c_num = 1:size(temp_trt,1)
    
    if nnz(temp_trt(c_num,1:tn-1)) >= qc_ti
    
        timefrt_trt(sel,1:tn) = temp_trt(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

clear sel c_num temp_ctr temp_trt

hf = figure; % FRET
hf.OuterPosition = [600 100 1000 800];
% title(['FRET (sat.lev. ' num2str(round(sat_lev*100)) '%)'])

    subplot(2,1,1)
%     imagesc(reshape(shiftdim(o_frt,1),[tn max_on*pn])')
    imagesc([time(1) time(end)], [1 size(timefrt_ctr,1)], timefrt_ctr)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_frt_ctr)) (1-sat_lev)*max(nonzeros(o_frt_ctr))])
    title(['FRET (sat.lev. ' num2str(round(sat_lev*100)) '%) - Control'])
    
    subplot(2,1,2)
    imagesc([time(1) time(end)], [1 size(timefrt_trt,1)], timefrt_trt)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_frt_trt)) (1-sat_lev)*max(nonzeros(o_frt_trt))])
    title(['FRET (sat.lev. ' num2str(round(sat_lev*100)) '%) - Treated'])
    
    saveas(hf,[path_save 'Singlecell_FRET.tif'],'tiff');
    
% hf = figure; % FRET background corrected
%     imagesc(reshape(shiftdim(o_frb,1),[tn max_on*pn])')
%     colormap(hot)
%     set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_frb)) (1-sat_lev)*max(nonzeros(o_frb))])
%     title(['FRET (back. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%)'])
%     saveas(hf,[path_save file_name '_singlecell_fretbck.tif'],'tif');

tmpcfp = (o_cfp)./repmat(o_cfp(:,1,:),[1 tn 1]);    

o_cfp_ctr = tmpcfp(idx_ctr,:,:);

o_cfp_trt = tmpcfp(idx_trt,:,:);

temp_ctr = reshape(shiftdim(o_cfp_ctr,1),[tn max_on*n_ctr])';

temp_trt = reshape(shiftdim(o_cfp_trt,1),[tn max_on*n_trt])';

sel = 1;

for c_num = 1:size(temp_ctr,1)
    
    if ~isnan(temp_ctr(c_num,1))
    
        timecfp_ctr(sel,1:tn) = temp_ctr(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

sel = 1;
c_num = 0;

for c_num = 1:size(temp_trt,1)
    
    if ~isnan(temp_trt(c_num,1))
    
        timecfp_trt(sel,1:tn) = temp_trt(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

clear sel c_num temp_ctr temp_trt

hf = figure; % CFP deltaF/F0
hf.OuterPosition = [600 100 1000 800];

% title(['CFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%)'])

    subplot(2,1,1)
%     imagesc(reshape(shiftdim(tmp,1),[tn max_on*pn])')
    imagesc([time(1) time(end)], [1 size(timecfp_ctr,1)], timecfp_ctr)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(timecfp_ctr)) (1-sat_lev)*max(nonzeros(timecfp_ctr))])
    title(['CFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%) - Control'])
    
    subplot(2,1,2)
    imagesc([time(1) time(end)], [1 size(timecfp_trt,1)], timecfp_trt)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(timecfp_trt)) (1-sat_lev)*max(nonzeros(timecfp_trt))])
    title(['CFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%) - Treated'])
    
    saveas(hf,[path_save 'Singlecell_cfp.tif']);    
    
tmpyfp = (o_yfp)./repmat(o_yfp(:,1,:),[1 tn 1]);    

o_yfp_ctr = tmpyfp(idx_ctr,:,:);

o_yfp_trt = tmpyfp(idx_trt,:,:);

temp_ctr = reshape(shiftdim(o_yfp_ctr,1),[tn max_on*n_ctr])';

temp_trt = reshape(shiftdim(o_yfp_trt,1),[tn max_on*n_trt])';

sel = 1;

for c_num = 1:size(temp_ctr,1)
    
    if ~isnan(temp_ctr(c_num,1))
    
        timeyfp_ctr(sel,1:tn) = temp_ctr(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

sel = 1;
c_num = 0;

for c_num = 1:size(temp_trt,1)
    
    if ~isnan(temp_trt(c_num,1))
    
        timeyfp_trt(sel,1:tn) = temp_trt(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

clear sel c_num temp_ctr temp_trt
    
hf = figure; % YFP deltaF/F0
hf.OuterPosition = [600 100 1000 800];

% title(['YFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%)'])

    subplot(2,1,1)
%     imagesc(reshape(shiftdim(tmpyfp,1),[tn max_on*pn])')
    imagesc([time(1) time(end)], [1 size(timeyfp_ctr,1)], timeyfp_ctr)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(timeyfp_ctr)) (1-sat_lev)*max(nonzeros(timeyfp_ctr))])
    title(['YFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%) - Control'])
    
    subplot(2,1,2)
    imagesc([time(1) time(end)], [1 size(timeyfp_trt,1)], timeyfp_trt)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(timeyfp_trt)) (1-sat_lev)*max(nonzeros(timeyfp_trt))])
    title(['YFP (deltaF/F0; bck. corrected; sat.lev. ' num2str(round(sat_lev*100)) '%) - Treated'])   
    saveas(hf,[path_save 'Singlecell_yfp.tif']);
    
% hf = figure; % CFP BCK deltaF/F0
%     tmp = (o_cfb)./repmat(o_cfb(:,1,:),[1 tn 1]);    
%     imagesc(reshape(shiftdim(tmp,1),[tn max_on*pn])')
%     colormap(hot)
%     set(gca,'clim',[(1+sat_lev)*min(nonzeros(tmp)) (1-sat_lev)*max(nonzeros(tmp))])
%     title(['CFP (deltaF/F0 bck.; sat.lev. ' num2str(round(sat_lev*100)) '%)'])    
%     saveas(hf,[path_save file_name '_singlecell_cfpbck.tif'],'tif');
%     
% hf = figure; % YFP BCK deltaF/F0
%     tmp = (o_yfb)./repmat(o_yfb(:,1,:),[1 tn 1]);    
%     imagesc(reshape(shiftdim(tmp,1),[tn max_on*pn])')
%     colormap(hot)
%     set(gca,'clim',[(1+sat_lev)*min(nonzeros(tmp)) (1-sat_lev)*max(nonzeros(tmp))])
%     title(['YFP (deltaF/F0 bck.; sat.lev. ' num2str(round(sat_lev*100)) '%)'])    
%     saveas(hf,[path_save file_name '_singlecell_yfpbck.tif'],'tif');

o_are_ctr = o_are(idx_ctr,:,:);

o_are_trt = o_are(idx_trt,:,:);

temp_ctr = reshape(shiftdim(o_are_ctr,1),[tn max_on*n_ctr])';

temp_trt = reshape(shiftdim(o_are_trt,1),[tn max_on*n_trt])';

sel = 1;

for c_num = 1:size(temp_ctr,1)
    
    if nnz(temp_ctr(c_num,1:tn-1)) >= qc_ti
    
        timeare_ctr(sel,1:tn) = temp_ctr(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

sel = 1;
c_num = 0;

for c_num = 1:size(temp_trt,1)
    
    if nnz(temp_trt(c_num,1:tn-1)) >= qc_ti
    
        timeare_trt(sel,1:tn) = temp_trt(c_num,:);
        
        sel = sel + 1;
    else
        continue
    end
end

clear sel c_num temp_ctr temp_trt

hf = figure; % AREA
hf.OuterPosition = [600 100 1000 800];
% title(['FRET (sat.lev. ' num2str(round(sat_lev*100)) '%)'])

    subplot(2,1,1)
%     imagesc(reshape(shiftdim(o_are,1),[tn max_on*pn])')
    imagesc([time(1) time(end)], [1 size(timeare_ctr,1)], timeare_ctr)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_are_ctr)) (1-sat_lev)*max(nonzeros(o_are_ctr))])
    title(['Area (sat.lev. ' num2str(round(sat_lev*100)) '%) - Control'])
    
    subplot(2,1,2)
    imagesc([time(1) time(end)], [1 size(timeare_trt,1)], timeare_trt)
    colormap(jet)
    colorbar
    set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_are_trt)) (1-sat_lev)*max(nonzeros(o_are_trt))])
    title(['Area (sat.lev. ' num2str(round(sat_lev*100)) '%) - Treated'])
 
    saveas(hf,[path_save 'Singlecell_area.tif']);
    
% hf = figure; % Eccentricity
%     imagesc(reshape(shiftdim(o_ecc,1),[tn max_on*pn])')
%     colormap(hot)
%     set(gca,'clim',[(1+sat_lev)*min(nonzeros(o_ecc)) (1-sat_lev)*max(nonzeros(o_ecc))])
%     title(['Ecc. (sat.lev. ' num2str(round(sat_lev*100)) '%)'])    
%     saveas(hf,[path_save 'Singlecell_ecc.tif']);
    
clear tmp