%% GENERATE STATISTICS
% STATS(field_of_view , time_point, object)
%


max_on                                = size(STATS,3);
[o_frt o_cfp o_yfp o_frb o_are o_ecc] = deal(zeros([pn tn max_on]));
qc_flag                               = ones([pn max_on]);

for pi=1:pn % field of view / position
    pi
    for ti=1:tn               % frame
        for oi=1:max_on         % cell identifier?
            data = [STATS{pi,ti,oi}];
            if isempty(data)
                if (ti<=qc_ti) & bQC
                    qc_flag(pi,oi) = 0;
                end
            else             
                o_frt(pi,ti,oi) = squeeze([data.fret]);                     % object FRET values
                o_cfp(pi,ti,oi) = squeeze([data.cfp]);                      % object CFP value
                o_yfp(pi,ti,oi) = squeeze([data.yfp]);                      % object YFP value
                o_cfb(pi,ti,oi) = squeeze([data.cfp_bck]);                  % object CFP bck value
                o_yfb(pi,ti,oi) = squeeze([data.yfp_bck]);                  % object YFP bck value
                o_frb(pi,ti,oi) = squeeze(([data.yfp]-[data.yfp_bck])/...
                                          ([data.cfp]-[data.cfp_bck]));     % object FRET background corrected value
                o_are(pi,ti,oi) = squeeze(sum([data.stats.Area]));          % object AREA value
                o_ecc(pi,ti,oi) = squeeze(mean([data.stats.Eccentricity])); % object ECCENTRICITY value
            end
        end
   end 
end


%%
if bQC
    qc_msk = shiftdim(repmat(shiftdim(qc_flag,1),[1 1 size(o_frt,2)]),1);
    o_frt = o_frt .* qc_msk;
    o_frb = o_frb .* qc_msk;
    o_cfp = o_cfp .* qc_msk;
    o_yfp = o_yfp .* qc_msk;
    %o_cfb = o_cfb .* qc_msk;
    %o_yfb = o_yfb .* qc_msk;
    o_are = o_are .* qc_msk;
    o_ecc = o_ecc .* qc_msk;
end


%%

gap_l = 6;
gap_t = 2;
trend_l = 20;
min_trace_length = 15;

check = o_frt;
check(check==0) = NaN;
for pi=1:pn
    pi
    for oi=1:max_on
        % identify a gap of gap_t within a strecth of gap_l length
        tqc = min(find(filter(ones(1,gap_l),1,isnan(check(pi,:,oi)))>gap_t))-ceil(gap_l/2)+1;
        if ~isempty(tqc) & tqc>0
            check(pi,tqc:end,oi) = NaN;
        else
            tqc = tn;
        end
        
        % fill remaining gaps by interpolation
        if tqc>=min_trace_length
            [T Ti]  = deal(1:tqc);
            T(isnan(check(pi,1:tqc,oi)))=[];
            values=squeeze(check(pi,1:tqc,oi));
            values(isnan(check(pi,1:tqc,oi)))=[];
            check(pi,1:tqc,oi) = interp1(T,values,Ti);
        else
            check(pi,:,oi) = NaN;
        end
        
        % detrend and normalize
        trend_trace = imfilter(check(pi,1:tqc,oi),fspecial('average',[1 trend_l]),'symmetric');
        check(pi,1:tqc,oi) = (check(pi,1:tqc,oi)./trend_trace);
        
        
    end
end

% %%
% figure
% plot(nanmean((reshape(shiftdim(check(1:7,:,:),1),[size(check,2) size(check,3)*size(check,1)/2])),2))
% hold on
% plot(nanmean((reshape(shiftdim(check(8:14,:,:),1),[size(check,2) size(check,3)*size(check,1)/2])),2),'r')
% 


