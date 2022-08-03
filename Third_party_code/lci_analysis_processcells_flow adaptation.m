%% DISPLAY - POPULATION from single cells

[A_frt A_frt_e B_frt B_frt_e C_frt C_frt_e D_frt D_frt_e,...
 A_cfp A_cfp_e B_cfp B_cfp_e C_cfp C_cfp_e D_cfp D_cfp_e,...
 A_yfp A_yfp_e B_yfp B_yfp_e C_yfp C_yfp_e D_yfp D_yfp_e,...
 A_num B_num C_num D_num] = deal(zeros([tn 1]));

msr_pnt = {'o_frt','o_frb','o_cfp','o_yfp','o_are','o_ecc'};

for mi=1:length(msr_pnt) % scan measurement
    for si=1:4 % scan samples (A vs B vs C vs D)
        if si==1
            % sample A
            eval(['tmp = reshape(shiftdim(' msr_pnt{mi} '(idx_A,:,:),1),[tn max_on*length(idx_A)]);']);
        elseif si==2
            % sample B
            eval(['tmp = reshape(shiftdim(' msr_pnt{mi} '(idx_B,:,:),1),[tn max_on*length(idx_B)]);']);
        elseif si==3
            % sample C
            eval(['tmp = reshape(shiftdim(' msr_pnt{mi} '(idx_C,:,:),1),[tn max_on*length(idx_C)]);']);
        elseif si==4
            % sample D
            eval(['tmp = reshape(shiftdim(' msr_pnt{mi} '(idx_D,:,:),1),[tn max_on*length(idx_D)]);']);
        end
        
        for ti=1:tn
           tmp_v(ti) = mean(nonzeros(tmp(ti,:)));
           
           % measure
           if nnz(tmp(ti,:))>1
                tmp_e(ti) =  std(nonzeros(tmp(ti,:)))/sqrt(nnz(tmp(ti,:))-1);
           else
                tmp_e(ti) = NaN;
           end
           
           % compute number of cells per time point
           if si==1            
                if mi==1
                    A_num(ti) = nnz(tmp(ti,:));                            
                end
           elseif si==2
               if mi==1
                    B_num(ti) = nnz(tmp(ti,:));
               end
           elseif si==3
               if mi==1
                    C_num(ti) = nnz(tmp(ti,:));
               end
           elseif si==4
               if mi==1
                    D_num(ti) = nnz(tmp(ti,:));
               end
           end  
           
        end

        if si==1                      
            % sample A
            eval(['A' msr_pnt{mi}(2:end) '   = tmp_v;']);
            eval(['A' msr_pnt{mi}(2:end) '_e = tmp_e;']);            
        elseif si==2 
            % sample B          
            eval(['B' msr_pnt{mi}(2:end) '   = tmp_v;']);
            eval(['B' msr_pnt{mi}(2:end) '_e = tmp_e;']);
        elseif si==3                      
            % sample C
            eval(['C' msr_pnt{mi}(2:end) '   = tmp_v;']);
            eval(['C' msr_pnt{mi}(2:end) '_e = tmp_e;']);            
        elseif si==4
            % sample D          
            eval(['D' msr_pnt{mi}(2:end) '   = tmp_v;']);
            eval(['D' msr_pnt{mi}(2:end) '_e = tmp_e;']);  
        end    
        
    end % si
end % mi

% Normalisation to t0

for s = 1:tn
    A_frt_n(s) = [A_frt(s)-A_frt(1)];
    
    B_frt_n(s) = [B_frt(s)-B_frt(1)];
    
    C_frt_n(s) = [C_frt(s)-C_frt(1)];
    
    D_frt_n(s) = [D_frt(s)-D_frt(1)];
    
end

% Normalisation to lowest value induced by ERK inhibitor
% Finding minimum values first, post ERKi inhibitor treatment

A_min = min(A_frt(30:end));
    
B_min = min(B_frt(30:end));
    
C_min = min(C_frt(30:end));
    
D_min = min(D_frt(30:end));

% Computing values normalised to lowest respective value

for s = 1:tn
    A_frt_i(s) = [A_frt(s)- A_min];
    
    B_frt_i(s) = [B_frt(s)- B_min];
    
    C_frt_i(s) = [C_frt(s)- C_min];
    
    D_frt_i(s) = [D_frt(s)- D_min];
    
end

fig_leg1 = 'WT - dox';
fig_leg2 = 'R - dox)';
fig_leg3 = 'WT + dox';
fig_leg4 = 'R+ dox';

% FRET
hf = figure;
    plot(time,A_frt,'b','LineWidth',4)
    hold on
    plot(time,A_frt+A_frt_e,'b')
    plot(time,A_frt-A_frt_e,'b')
    
    plot(time,B_frt,'r','LineWidth',4)    
    plot(time,B_frt+B_frt_e,'r')
    plot(time,B_frt-B_frt_e,'r')
    
    plot(time,C_frt,'g','LineWidth',4)    
    plot(time,C_frt+C_frt_e,'g')
    plot(time,C_frt-C_frt_e,'g')
    
    plot(time,D_frt,'k','LineWidth',4)    
    plot(time,D_frt+D_frt_e,'k')
    plot(time,D_frt-D_frt_e,'k')
    
    title('FRET index')
%     legend(fig_leg1, fig_leg2, fig_leg3, fig_leg4,  'Location', 'southeast')
    
    saveas(hf,[path_save '_avg_fret.tif'],'tif');
    
    % FRET with no SD
hf = figure;
    plot(time,A_frt,'b','LineWidth',3)
    hold on
    plot(time,B_frt,'r','LineWidth',3)    
    plot(time,C_frt,'g','LineWidth',3)    
    plot(time,D_frt,'k','LineWidth',3)    
    
    title('FRET index')
    legend(fig_leg1, fig_leg2, fig_leg3, fig_leg4,  'Location', 'southeast')
    
    saveas(hf,[path_save '_avg_fret_labels.tif'],'tif');
    
%     Normalised to t0
    
    hf = figure;
    plot(time(1:end),A_frt_n(1:end),'b','LineWidth',3)
    hold on
    plot(time(1:end),B_frt_n(1:end),'r','LineWidth',3)    
    plot(time(1:end),C_frt_n(1:end),'g','LineWidth',3)    
    plot(time(1:end),D_frt_n(1:end),'k','LineWidth',3)    
    
    title('FRET index - normalised to t0')
    legend(fig_leg1, fig_leg2, fig_leg3, fig_leg4,  'Location', 'southeast')
    
    saveas(hf,[path_save '_avg_fret_normT0.tif'],'tif');
        
%     Normalised to lowest value induced by 2-DG/antimycin
    
    hf = figure;
    plot(time,A_frt_i,'b','LineWidth',3)
    hold on
    plot(time,B_frt_i,'r','LineWidth',3)    
    plot(time,C_frt_i,'g','LineWidth',3)    
    plot(time,D_frt_i,'k','LineWidth',3)    
    
    title('FRET index - normalised to lowest antimycin-induced activity')
    legend(fig_leg1, fig_leg2, fig_leg3, fig_leg4,  'Location', 'southeast')
    
    saveas(hf,[path_save '_avg_fret_norm-to-Antimycin.tif'],'tif');
    
    
% CFP bck corrected
hf = figure;
    plot(time,A_cfp,'b','LineWidth',4)
    hold on
    plot(time,A_cfp+A_cfp_e,'b')
    plot(time,A_cfp-A_cfp_e,'b')
    
    plot(time,B_cfp,'r','LineWidth',4)    
    plot(time,B_cfp+B_cfp_e,'r')
    plot(time,B_cfp-B_cfp_e,'r')
    
    plot(time,C_cfp,'g','LineWidth',4)    
    plot(time,C_cfp+C_cfp_e,'g')
    plot(time,C_cfp-C_cfp_e,'g')
    
    plot(time,D_cfp,'k','LineWidth',4)    
    plot(time,D_cfp+D_cfp_e,'k')
    plot(time,D_cfp-D_cfp_e,'k')
    
    title('CFP (bck corrected)')

    saveas(hf,[path_save '_avg_cfp.tif'],'tif');
    
% YFP bck corrected
hf = figure;
    plot(time,A_yfp,'b','LineWidth',4)
    hold on
    plot(time,A_yfp+A_yfp_e,'b')
    plot(time,A_yfp-A_yfp_e,'b')
    
    plot(time,B_yfp,'r','LineWidth',4)    
    plot(time,B_yfp+B_yfp_e,'r')
    plot(time,B_yfp-B_yfp_e,'r')
    
    plot(time,C_yfp,'g','LineWidth',4)    
    plot(time,C_yfp+C_yfp_e,'g')
    plot(time,C_yfp-C_yfp_e,'g')
    
    plot(time,D_yfp,'k','LineWidth',4)    
    plot(time,D_yfp+D_yfp_e,'k')
    plot(time,D_yfp-D_yfp_e,'k')
    
    title('YFP (bck corrected)')   

    saveas(hf,[path_save '_avg_yfp.tif'],'tif');  
    
% total cell number
hf = figure;
    plot(time,A_num,'b','LineWidth',4)
    hold on
    plot(time,B_num,'r','LineWidth',4)
    plot(time,C_num,'g','LineWidth',4)  
    plot(time,D_num,'k','LineWidth',4)  
    set(gca,'ylim',[0 max([max(A_num) max(B_num) max(C_num) max(D_num)])])
    title('Counted&segmented&tracked cells')   
    
    saveas(hf,[path_save '_cellnumber.tif'],'tif');