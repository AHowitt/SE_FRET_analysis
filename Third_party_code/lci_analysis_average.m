
[A_avg_frt B_avg_frt C_avg_frt D_avg_frt A_avg_cfp B_avg_cfp C_avg_cfp D_avg_cfp A_avg_yfp B_avg_yfp C_avg_yfp D_avg_yfp ] = deal(zeros([tn 1]));
for pi=1:n_A
    A_avg_frt = A_avg_frt + STATS_FOV{idx_A(pi)}.fret;
    A_avg_cfp = A_avg_cfp + STATS_FOV{idx_A(pi)}.cfp;
    A_avg_yfp = A_avg_yfp + STATS_FOV{idx_A(pi)}.yfp;
end
A_avg_frt = A_avg_frt / n_A;
A_avg_cfp = A_avg_cfp / n_A;
A_avg_yfp = A_avg_yfp / n_A;

for pi=1:n_B
    B_avg_frt = B_avg_frt + STATS_FOV{idx_B(pi)}.fret;
    B_avg_cfp = B_avg_cfp + STATS_FOV{idx_B(pi)}.cfp;
    B_avg_yfp = B_avg_yfp + STATS_FOV{idx_B(pi)}.yfp;
end
B_avg_frt = B_avg_frt / n_B;
B_avg_cfp = B_avg_cfp / n_B;
B_avg_yfp = B_avg_yfp / n_B;

for pi=1:n_C
    C_avg_frt = C_avg_frt + STATS_FOV{idx_C(pi)}.fret;
    C_avg_cfp = C_avg_cfp + STATS_FOV{idx_C(pi)}.cfp;
    C_avg_yfp = C_avg_yfp + STATS_FOV{idx_C(pi)}.yfp;
end
C_avg_frt = C_avg_frt / n_C;
C_avg_cfp = C_avg_cfp / n_C;
C_avg_yfp = C_avg_yfp / n_C;

for pi=1:n_D
    D_avg_frt = D_avg_frt + STATS_FOV{idx_D(pi)}.fret;
    D_avg_cfp = D_avg_cfp + STATS_FOV{idx_D(pi)}.cfp;
    D_avg_yfp = D_avg_yfp + STATS_FOV{idx_D(pi)}.yfp;
end
D_avg_frt = D_avg_frt / n_D;
D_avg_cfp = D_avg_cfp / n_D;
D_avg_yfp = D_avg_yfp / n_D;

hf = figure;
hf.OuterPosition = [600 100 600 800];
    subplot(3,1,1)
    plot(time,A_avg_frt,'b','LineWidth',4)
    hold on
    plot(time,B_avg_frt,'r','LineWidth',4)
    plot(time,C_avg_frt,'g','LineWidth',4)
    plot(time,D_avg_frt,'k','LineWidth',4)
    title('FRET - average across FoVs')
    
    subplot(3,1,2)
    plot(time,A_avg_cfp,'b','LineWidth',4)
    hold on
    plot(time,B_avg_cfp,'r','LineWidth',4)
    plot(time,C_avg_cfp,'g','LineWidth',4)
    plot(time,D_avg_cfp,'k','LineWidth',4)

    title('CFP - average across FoVs')
    
    subplot(3,1,3)
    plot(time,A_avg_yfp,'b','LineWidth',4)
    hold on
    plot(time,B_avg_yfp,'r','LineWidth',4)
    plot(time,C_avg_yfp,'g','LineWidth',4)
    plot(time,D_avg_yfp,'k','LineWidth',4)
    title('YFP - average across FoVs')
    
    saveas(hf,[path_save file_name '_averageoverFOVs.tif'],'tif');