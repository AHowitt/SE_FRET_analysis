%% BOOTSTRAPPING

% initialize
%close all
rng('shuffle')

rep         = 1000; % bootstrap repeteations
min_length  = 15; % requires at least min_length time points

if 1
    % everything
    %treated and control curves
    Gt =(reshape(permute(o_frt(idx_trt,:,:),[2 3 1]),tn,[])');
    Gc =(reshape(permute(o_frt(idx_ctr,:,:),[2 3 1]),tn,[])');
    %eliminate curves that are too short
    Gt = Gt(find(sum(Gt>0,2)>min_length),:);
    Gc = Gc(find(sum(Gc>0,2)>min_length),:);

else
    % non mitotic
    Gt = fret_t;
    Gc = fret_c;
    
end



% size of populations
Nt = size(Gt,1);
Nc = size(Gc,1);
Nm = min([Nt Nc]);

BBta = [];
BBca = [];
Bca = [];
Bta = [];

% bootstrapping cycle 
for ri=1:rep
    
    Gt_ = Gt;
    Gc_ = Gc;
    
    if Nt~=Nc % draw an unbiased population
        idx = rand(1,max([Nt Nc])); % dec
        [dmb idx] = sort(idx);      % int
        
        if Nt>Nc
           Gt_ = Gt(idx(1:Nc),:);
        else
           Gc_ = Gc(idx(1:Nc),:);
        end
    end
    
    % aggregated population
    GG = [Gt_; Gc_];
    
    % control and treated boostrap populations from the aggregate one
    idx = randi(2*Nm,1,2*Nm); 
    BBt = GG(idx(1:Nm),    :);
    BBc = GG(idx(Nm+1:end),:);
    
    % control and treated boostrap populations
    idx = randi(Nm,1,Nm); 
    Bt = Gt_(idx(1:Nm),:);
    
    idx = randi(Nm,1,Nm); 
    Bc = Gc_(idx(1:Nm),:);
    
    % average populations (sum normalized by non zero time points)
    BBta(ri,:) = sum(BBt,1) ./ sum(BBt>0);
    BBca(ri,:) = sum(BBc,1) ./ sum(BBc>0);
    Bta(ri,:)  = sum(Bt, 1) ./ sum(Bt>0);
    Bca(ri,:)  = sum(Bc, 1) ./ sum(Bc>0);
end

%%
avg_Bc = mean(Bca);
std_Bc = std(Bca);
avg_Bt = mean(Bta);
std_Bt = std(Bta);

avg_BBc = mean(BBca);
std_BBc = std(BBca);
avg_BBt = mean(BBta);
std_BBt = std(BBta);

avg_Bratio = mean(Bta./Bca);
std_Bratio = std(Bta./Bca);

avg_BBratio = mean(BBta./BBca);
std_BBratio = std(BBta./BBca);


n_sig = 1;

xa = 1;
ya = 3;

boot = figure;



iax = 1;
subplot(xa,ya,iax)
hold all
plot(time(1:size(avg_Bc,2)),avg_Bc'+n_sig*std_Bc','b')
plot(time(1:size(avg_Bc,2)),avg_Bc','b')
plot(time(1:size(avg_Bc,2)),avg_Bc'-n_sig*std_Bc','b')
plot(time(1:size(avg_Bc,2)),avg_Bt'+n_sig*std_Bt','r')
plot(time(1:size(avg_Bc,2)),avg_Bt','r')
plot(time(1:size(avg_Bc,2)),avg_Bt'-n_sig*std_Bt','r')
title('bootstrap populations')

iax = iax + 1;
subplot(xa,ya,iax)
hold all
plot(time(1:size(avg_Bc,2)),avg_Bratio'+n_sig*std_Bratio','r')
plot(time(1:size(avg_Bc,2)),avg_Bratio','r')
plot(time(1:size(avg_Bc,2)),avg_Bratio'-n_sig*std_Bratio','r')

plot(time(1:size(avg_Bc,2)),avg_BBratio'+n_sig*std_BBratio','b')
plot(time(1:size(avg_Bc,2)),avg_BBratio','b')
plot(time(1:size(avg_Bc,2)),avg_BBratio'-n_sig*std_BBratio','b')

title('bootstrap ratio')

iax = iax + 1;
subplot(xa,ya,iax)
hold all

plot(time(1:size(avg_Bc,2)),avg_BBratio'+n_sig*std_BBratio','b')
plot(time(1:size(avg_Bc,2)),avg_BBratio','b')
plot(time(1:size(avg_Bc,2)),avg_BBratio'-n_sig*std_BBratio','b')

plot(time(1:size(avg_Bc,2)),(sum(Gt,1)./sum(Gt>0))./(sum(Gc,1)./sum(Gc>0)),'r')

title('bootstrap ratio (b) and experimental ratio')