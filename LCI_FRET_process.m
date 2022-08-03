close(LCI_FRET_channels);

bExtMsk = 0;

ch_tra = 0;

bMitCheck = 0;

bBck = 0;

%% PROCESSING

% v3: support external masks (from main v7)

    STATS = {};
    STATS_FOV = {};

%% further initializations (no GUI)

seg_opt.nuc_disk       = 2;
seg_opt.bck_disk       = 150;
seg_opt.area_min       = 350;
seg_opt.ring_spacer    = 1;
seg_opt.ring_thickness = 1;

mit_trk   = [];
min_t     = 100; % minimum length of the trace (in number of frames)
        
bOld      = 0;   % scell segmentation version

% init smart waitbar
% global scan ti
% 
% [scan ti] = deal(0);
% hw99    = ae_waitbar('varlist','scan ti',...
%                     'limits',[1 pn; 1 tn],...
%                     'captions',{'FIELD OF VIEW','TIME POINT'},...
%                     'handler_name','hw99');
            
% check consistency of background type estimation seletcions            
if ~bBck
    bBckType = 0 * bBckType;
else
    if nnz(bBckType)==0
        error('Background estimation set to 1, but no bck estimation type was set.')
    end
end

% query information about masks
if bExtMsk
    [file_msk path_msk] = uigetfile('*.lif;*.nd2;*.tif;*.tiff','Select a msk file...'); 
    
    fname = @(p,t) [file_msk(1:strfind(file_msk,'Pos')+2) ...
                    num2str(p,'%03.0f')...
                    file_msk(strfind(file_msk,'Pos')+6:strfind(file_msk,'_t')+1)...
                    num2str(t-1,'%03.0f')...
                    file_msk(strfind(file_msk,'_t')+5:end)];

    bSmooth = 0; % this is optional, but it speeds up computation
end

%% query for save path
path_save = uigetdir(path_name,'Save to...');
path_save = [path_save '/MATLAB-ANALYSIS-' date '/']; % change direction of backslash if on \Windows(/Mac)

mkdir(path_save)
%%
 for fov=1:pn % scan field of view / position
    
    %% read data / matrix assigments
    
    if fov>1 % read data, except first field of view that is already in memory because of initializations
        data = ae_bfopen([path_name file_name file_ext],fov);   
    end
        
    display(['Field of view ' num2str(fov) ' of ' num2str(pn)])
    
    temp = data{fov,1}(:,1);
    temp = permute(reshape(cell2mat(temp),[res(1) cn tn res(2)]),[2 3 1 4]); % [detectors time_frames image(NxN)]
    %temp=temp(:,1:end-1,:,:); % TOCHECK "-1"    

    cfp = double(squeeze(temp(ch_don,:,:,:)));
    yfp = double(squeeze(temp(ch_acc,:,:,:)));
    
    if ch_nuc==0
        nuc = double(squeeze(temp(ch_acc,:,:,:)));
    end
    
    if ch_tra>0
        tra = double(squeeze(temp(ch_tra,:,:,:)));
    else
        tra = zeros(512);
    end
    
    clear temp
    
    %% image enhancement
    if bSmooth
        display('Filtering...');          
        for ti=1:tn
 

            if bBckType(2) % Background suppression on full field image (SLOW)
                BCKKER = sqrt(prod(res))/4;

                bck_sup     = imfilter(squeeze(cfp(ti,:,:)),fspecial('disk',BCKKER),'replicate');
                tmp         = squeeze(cfp(ti,:,:)) - bck_sup;
                cfp(ti,:,:) = tmp - min(min(tmp));

                bck_sup     = imfilter(squeeze(yfp(ti,:,:)),fspecial('disk',BCKKER),'replicate');
                tmp         = squeeze(yfp(ti,:,:)) - bck_sup;
                yfp(ti,:,:) = tmp - min(min(tmp));
            end
        
            cfp(ti,:,:) = medfilt2(squeeze(cfp(ti,:,:)),MEDKER,'symmetric');
            yfp(ti,:,:) = medfilt2(squeeze(yfp(ti,:,:)),MEDKER,'symmetric');
        end       
    end
    % end -image enhancement
    
    %% FIJI initialization (TrackMate + ROIs + thresholding)
    
% addpath('/Applications/Fiji.app/scripts') % Update for your ImageJ installation as appropriate
% javaaddpath '/Applications/MATLAB_R2017b.app/java/ij.jar'
% javaaddpath '/Applications/MATLAB_R2017b.app/java/mij.jar'
% 
% ImageJ;
%     

    
    %% segmentation & tracking
    
    [mnt lbl] = deal(zeros([tn res(1) res(2)]));
    
    display('Segmenting...');               

    for ti=1:tn

        if bOld 
            thr_c = thr_level*opthr(squeeze(cfp(ti,:,:)));
            thr_y = thr_level*opthr(squeeze(yfp(ti,:,:)));

            msk = (squeeze(cfp(ti,:,:))>=thr_c) & (squeeze(yfp(ti,:,:))>=thr_y);
            msk = bwareaopen(bwmorph(msk,'erode',2),100);

            mnt(ti,:,:) = msk; % this mask is used when no tracking is implemented

            lbl(ti,:,:) = bwlabel(msk);                
        else
           %%

           if ~bExtMsk
               % segment nuclei with background subtraction 
               % (open image to emphasize nuclei - open image to emphasize bck)
               seg_nuc = imopen(squeeze(double(nuc(ti,:,:))),strel('disk',seg_opt.bck_disk));
               seg_nuc = imopen(squeeze(double(nuc(ti,:,:))),strel('disk',seg_opt.nuc_disk)) - seg_nuc;           

               % split adjecent nuclei with watershed algorithm - elimiate
               % small objects
               if nnz(seg_nuc)>10
                tt=opthr(seg_nuc);
               else
                tt = 0;
               end
               msk = imfill(seg_nuc>0.6*tt,'holes');
%                imshow(msk);
           else
               ext_lbl = double(imread([path_msk fname(fov,ti)]));       
               msk     = ext_lbl>0;
           end
           
           wtr = double(watershed(bwdist(msk)))>0;
           seg_nuc = bwareaopen(msk.*wtr,seg_opt.area_min);
%            imshow(seg_nuc);

           % eliminate from watershed, those area that do not contain a
           % valid nucleus
           wtr = bwlabel(wtr);
           valid = unique(nonzeros(wtr.*seg_nuc));
           for i=1:max(wtr(:))
              if nnz(i==valid)==0
                wtr(wtr==i)=0;
              end
           end

           % identify cytoplasmic areas creating a ring measurement
%            ring_inner = imdilate(seg_nuc,strel('disk',seg_opt.ring_spacer));
           ring_outer = imdilate(seg_nuc,strel('disk',seg_opt.ring_spacer+seg_opt.ring_thickness));
%            seg_rng(ti,:,:) = ((ring_outer - ring_inner).*wtr)>0;
%            
           if ~bExtMsk
               % generate segmented image for tracking purposes
               lbl(ti,:,:) = bwlabel(ring_outer.*(wtr>0));                                            
           else
%                %%
%                new_lbl = 0*ring_outer;
%                for oi=1:max(ext_lbl(:))
%                    % select externally segmented object
%                    ext_msk = double(ext_lbl==oi);
%                    
%                    % is this object still exist
%                    if nnz(ext_msk)>0
%                         % select respective watershed area
%                         idx = round(median(nonzeros(wtr.*ext_msk)));
%                         wtr_msk = double(wtr==idx);
%                         wtr_msk(find(wtr_msk)) = oi;
%                         new_lbl = new_lbl + ring_outer.*wtr_msk;
%                    end
%                end
%                lbl(ti,:,:) = new_lbl;
% 
%            
%                new_lbl = 0*ring_outer;
%                for oi=1:max(nonzeros(wtr))
%                     wtr_msk = double(wtr==oi);
%                     idx = round(median(nonzeros(wtr_msk.*ext_lbl)));
%                     wtr_msk(find(wtr_msk)) = idx;
%                     new_lbl = new_lbl + ring_outer.*wtr_msk;
%                end
               lbl(ti,:,:) = seg_nuc;
           
           end
        end
        
        mnt(ti,:,:) = lbl(ti,:,:)>0;

        % tracking
        if ti~=1 & bTrack & ~bExtMsk
            % init 
            no  = max(nonzeros(lbl(ti,:,:))); % number of cells           
            tmp = zeros(res);

            % scan cells
            for ni=1:no
               %at which cellid at time ti-1 corresponded current object at
               %time ti?
               cell_id = (round(mean(nonzeros(squeeze(lbl(ti-1,:,:)).*(squeeze(lbl(ti,:,:))==ni)))));
               if ~isnan(cell_id) % if exist, assign id to cell
                    tmp = tmp + (squeeze(lbl(ti,:,:))==ni).*cell_id;               
               end
            end            
            lbl(ti,:,:) = tmp;
            clear tmp

%             if bMitCheck % check for tracked mitotic cells                
%                 no  = max(nonzeros(lbl(ti,:,:))); % number of cells                    
%                 for ni=1:no
%                     if max(nonzeros(bwlabel(squeeze(lbl(ti,:,:))==ni)))==2
%                         try 
%                             if mit_trk(scan,ni)==0
%                                 mit_trk(scan,ni) = ti;
%                             end
%                         catch
%                             mit_trk(scan,ni) = ti;
%                         end
%                     end
%                 end
%             end

            mnt(ti,:,:) = lbl(ti,:,:)>0; 
        end


    end
    
    seg_rng = seg_nuc;
    
% end - segmentation & tracking
    
    
    
    %%
    % measuring
    
    display('Measuring...');          
    for ti=1:tn
        
        ti
        [cfp_bck yfp_bck] = deal(zeros(size(msk)));  
        
        no  = max(nonzeros(lbl(ti,:,:)));        
        msk = imfill(squeeze(lbl(ti,:,:))>0,'holes');                
%         imshow(msk)
        
        if bBckType(1) % Background estimation and subtraction
            for ni=1:no
                ring_outer = bwmorph(squeeze(lbl(ti,:,:))==ni,'dilate',10);
                ring_inner = bwmorph(squeeze(lbl(ti,:,:))==ni,'dilate',5);
                permitted  = ~(msk.*(squeeze(lbl(ti,:,:))~=1));

                value = mean(reshape((ring_outer.*~ring_inner.*permitted.*squeeze(cfp(ti,:,:))),1,[]));
                cfp_bck = cfp_bck + (squeeze(lbl(ti,:,:))==ni)*value;  
                value = mean(reshape((ring_outer.*~ring_inner.*permitted.*squeeze(yfp(ti,:,:))),1,[]));
                yfp_bck = yfp_bck + (squeeze(lbl(ti,:,:))==ni)*value;                                
            end
        else
            cfp_bck = 0;
            yfp_bck = 0;
        end
        
        fret(ti,:,:) = squeeze(mnt(ti,:,:)).*(squeeze(yfp(ti,:,:))-yfp_bck)./(squeeze(cfp(ti,:,:))-cfp_bck);
        av(ti)       = mean(nonzeros(fret(ti,:,:)));
        er(ti)       = std(nonzeros(fret(ti,:,:)));
        cfp_av(ti)   = mean(nonzeros(squeeze(lbl(ti,:,:)>0).*(squeeze(cfp(ti,:,:))-cfp_bck)));
        yfp_av(ti)   = mean(nonzeros(squeeze(lbl(ti,:,:)>0).*(squeeze(yfp(ti,:,:))-yfp_bck)));
        
      
        
        idx = unique(nonzeros(lbl(ti,:,:)));
        no  = length(idx);
        for ni=1:no
            cell_mask = squeeze(lbl(ti,:,:)==idx(ni));
            
            STATS{fov,ti,idx(ni)}.stats   = regionprops(imfill(cell_mask,'holes'),{'Area','Perimeter','Eccentricity','Centroid'});
            STATS{fov,ti,idx(ni)}.fret    = mean(nonzeros(squeeze(fret(ti,:,:)).*cell_mask));
            STATS{fov,ti,idx(ni)}.cfp     = mean(nonzeros(squeeze(cfp(ti,:,:)).*cell_mask));
            STATS{fov,ti,idx(ni)}.yfp     = mean(nonzeros(squeeze(yfp(ti,:,:)).*cell_mask));
            STATS{fov,ti,idx(ni)}.cfp_bck = mean(nonzeros(squeeze(cfp_bck).*cell_mask));
            STATS{fov,ti,idx(ni)}.yfp_bck = mean(nonzeros(squeeze(yfp_bck).*cell_mask));
        end
        
    end
    
    
    
    STATS_FOV{fov}.fret = av;
    STATS_FOV{fov}.err  = er;
    STATS_FOV{fov}.cfp  = cfp_av;
    STATS_FOV{fov}.yfp  = yfp_av;
    
   
%     end - measuring
    
    %%

    % vis
    fmin = min(av);
    fmax = max(av);
    fmed = median(av);
    tend = tn;
              
    hf_intensity = figure;
    
    plot(time,cfp_av,'cyan')
    hold on
    plot(time,yfp_av,'yellow')
%     set(gca,'color','white','ylim',[0 1.1*max(nonzeros([cfp_av yfp_av]))]); %,'xgrid','on','xcolor','white','ygrid','on','ycolor','white'
    set(gcf, 'Color', 'w');
    set(gca,'color','black');
    set(gca,'ylim',[0 1.1*max(nonzeros([cfp_av yfp_av]))])
    xlabel(['time (' time_string ')'])
    ylabel('intensity (a.u.)')

    export_fig([path_save file_name '_' num2str(fov) '_cfpyfp'], '-png');


%     hp2 = patch(time([1 tn tn 1]),[0 0 1.1*max(nonzeros([cfp_av yfp_av])) 1.1*max(nonzeros([cfp_av yfp_av])) ],'black');
%     set(hp2,'edgealpha',.9,'facecolor','black')

%     hp = patch(time([tend tn tn tend]),[0 0  1.1*max(nonzeros([cfp_av yfp_av]))  1.1*max(nonzeros([cfp_av yfp_av])) ],'white');
%     set(hp,'edgealpha',.9,'facecolor',[.3 .3 .3])


    %%
    hf = figure;
    hf.OuterPosition = [600 400 1000 600];
    LUT = jet;
    LUT(1,:)=[1 1 1];

    subplot(1,3,1)
    h1=imagesc(squeeze(fret(1,:,:)));
       set(gca,'clim',[0.5*fmin 1.5*fmax])
    axis image
    axis off
    colormap(LUT)
    colorbar('northoutside')
    title('fret index')

    subplot(1,3,2) 
    h3=imagesc(squeeze(lbl(1,:,:)));
    axis image
    axis off
    colorbar('northoutside')
    title('segmentation')


    subplot(1,3,3)
    plot(time(1:tend),av(1:tend),'k')
    hold on
    %plot(time(1:t_end),av2(1:t_end)-er(1:t_end),'r')
    %plot(time(1:t_end),av2(1:t_end)+er(1:t_end),'r')
    h2=plot(time(1),av(1),'O');
    axis square
    set(gca,'ylim',[fmin fmax])
    xlabel(['time (' time_string ')'])
    ylabel('fret index (a.u.)')
    
    saveas(hf,[path_save file_name '_' num2str(fov) '_fret.tif'], 'tiff');
    
    %%
    if exist('F','var'), clear F, end

    F(tend).cdata=[];
    F(tend).colormap=[];

    for fi=1:tend
        %subplot(1,3,1)    
        set(h1,'cdata',squeeze(fret(fi,:,:)))
        set(h3,'cdata',squeeze(lbl(fi,:,:)))
        %subplot(1,2,2)
        delete(h2)
        h2=plot(time(fi),av(fi),'O');
        drawnow
        F(fi) = getframe(hf);        
    end
    
    %%
    saveas(hf_intensity,[path_save file_name '_' num2str(fov) '_cfpyfp.tif'],'tif')
    v = VideoWriter([path_save file_name '_' num2str(fov) '_fret.avi']);
    v.FrameRate=5;
    open(v)
%     movie2avi(F,[path_save file_name '_' num2str(scan) '_fret.avi'],'compression','none')   
    writeVideo(v,F);

close(v)
    save([path_save file_name '_' num2str(fov) '_backup.mat'],'-v7.3')        
    
    close(hf_intensity)
    close(hf)
end

%%
save([path_save file_name '_STATS.mat'],'STATS','-v7.3')
save([path_save file_name '_STATS_FOV.mat'],'STATS_FOV','-v7.3')
    %%
     LCI_FRET_analysis
