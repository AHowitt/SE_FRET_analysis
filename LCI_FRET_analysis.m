%% identify indexing of groups
idx_A = find(g_sel2==1);
idx_B = find(g_sel2==2);
idx_C = find(g_sel2==3);
idx_D = find(g_sel2==4);
n_A = length(idx_A);
n_B = length(idx_B);
n_C = length(idx_C);
n_D = length(idx_D);

%% compute and visualize population based measurements
lci_analysis_average

%%    EXECUTE EVERYTHIGN ELSE ONLY IF TRACKING ENABLED
if ~bTrack
        return
end
    
%% generate statistics
lci_analysis_stats

%% export to excel
% lci_analysis_xls

%% display/export/analyse single cell traces
% lci_analysis_displaycells
lci_analysis_processcells

%% bootstrapping
% lci_analysis_boot

% saveas(boot,[path_save 'Bootstrapped.tif'], 'tiff');


