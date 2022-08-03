% v7: support input of masks from third party sw (e.g., Callum's segmentation and tracking)
% v6: reorganization of the code
% v5: support of extra channels
% v4: load only indivivual series... save RAM req.
% LCI

%% initialize
%close all
clear all

auto_path_setup %'end,',...

%% INPUT BLOCK - non GUI

% segmentation
bAutoThr  = 1;       % identify automatic threshold level
bTrack    = 1;       % track cells
thr       = 25;      % manual threshold level
thr_level = 0.8;    % threshold stringency THR = THR_AUTO * THR_LEVEL

% image enhancement 
bSmooth   = 1;       % image enhancement (median filtering)
MEDKER    = [2 2];   % median kernel

% background estimation
bBck      = 0;
bBckType  = [0 0];   % [bBacgroundEstimation-and-Subtraction bBackgrounSuppression (SLOW)]

% quality control
bQC   = 1;
qc_ti = 35;         % number of time points required per cell to be a valid object

% output
sat_lev = 0.05;     % 2d diagram - saturation level of LUT

%% CONSTANT DEFINITIONS
LCI_MIC_LEICA = 1;
LCI_MIC_NIKON = 2;

LCI_NAME = 'LCI v7';

%% INPUT BLOCK - GUI - FILE

[file_name path_name]    = uigetfile('*.lif;*.nd2','Select a folder with data...'); % GUI
[dmb file_name file_ext] = fileparts(file_name);                                    % parse name

% recognize format
switch lower(file_ext)
    case '.lif'
        mic_type = LCI_MIC_LEICA;        
    case '.nd2'
        mic_type = LCI_MIC_NIKON;
    otherwise
        error('FILE FORMAT NOT SUPPORTED')
end

% Load first series to initialize res values
data = ae_bfopen([path_name file_name file_ext],1);   

pn   = size(data, 1);            % number of field of views
res  = size(data{1,1}{1,1});     % image pixel resolution

% parse meta data (need improving @@@)
% time_base: can be found in metadata?g_sel
switch mic_type
    case LCI_MIC_LEICA
        meta_data = data{1,1}{1,2};
        cn = str2num(meta_data(strfind(meta_data,'C=')+4));        % number of channels
        tn = str2num(meta_data(strfind(meta_data,'T=')+4:end));    % number of frames
        
        
    case LCI_MIC_NIKON
        meta_data = data{1,1}{1,2};
        cn = str2num(meta_data(strfind(meta_data,'C=')+4)); % number of channels
        tn = str2num(meta_data(strfind(meta_data,'T=')+4:end));      % number of frames
        
end

% query for time base
time_base   = inputdlg('Time step (in mins):',LCI_NAME,1,{'3'});
time_base   = str2num(time_base{1});
time        = (0:tn-1)*time_base/60;
time_string = 'hrs';

% other initializations
bck      = [];
lbl      = [];
msk      = [];

fret                  = zeros(tn,res(1),res(2));
[av er cfp_av yfp_av] = deal(zeros(tn,1));
STATS                 = {};

%%

str_callback = ['for pi=1:pn,',...
                'g_sel(pi) = hb(pi).SelectedObject;',...
                'g_sel(pi) = [g_sel(pi)]'';',...
                'end,',...
                'for pi=1:pn,',...
                '[dmb g_sel2(pi)] = find(hr==g_sel(pi));',...
                'end,',...
                'close(hfgn),',...
                 'LCI_FRET_channels'];

% f = @groups;

% assign FoV to groups

gn = inputdlg('Number of groups (UT/treated/etc...). Set to 0 to neglect', LCI_NAME,1,{'2'});
gn = str2num(gn{1});        %number of conditions/groups



if gn>0
   hfgn = figure('position',[0 0 170*gn 40*pn],'units','pixels');
   movegui(hfgn, 'center')
   line_height = 1.05/(pn+1);
   column_width = pn*2/gn;
   
    %uicontrol('Style','text','Position',[10*pn*.05 530*gn*(1-line_height) 30*pn*.2 150*gn*line_height],'String','Number of FoVs')
    uicontrol('Style','pushbutton','Position',[5 5 10*pn*.55 200*gn*line_height*0.9],'String','NEXT >>>','Callback',str_callback)

    
%    hb (pn) = uibuttongroup('visible','on',...
%                                'Position',[30 100*gn*line 20 20],...
%                                'units','pixels');
% raws
   for pi=1:pn
       line = 1-(pi-1)*line_height;
       %uicontrol('Style','text',...
       %             'Position',[50 330*gn*line 20 20],...
       %             'String',num2str(pi))
       
        % Create the button group.
        hb(pi) = uibuttongroup('visible','on',...
                                'parent', hfgn,...
                                'units','normalized',...
                                'Position',[.2 1-.9*pi/pn .6 .03]);
                                %'Position',[.33 1.3-1.3*pi/pn .5 .05]);
                                %[120 510*gn*line 180 50]);
                                
        uicontrol('Style','text',...
                    'parent', hfgn,...
                    'units','normalized',...
                    'Position',[.1 .99-.9*pi/pn .1 .035],...
                    'String',num2str(pi));
                                
        %   'Position',[30 100*gn*line 20 20],...
                             
        % Create three radio buttons in the button group.
        for gi=1:gn
            hr(pi,gi) = uicontrol('Style',...
                                    'radiobutton',...
                                    'String',['Group' num2str(gi)],...
                                    'position',[120*gn*(gi-1)/gn 0 100 25],...
                                    'parent',hb(pi),...
                                    'HandleVisibility','off',...
                                    'units','normalized');
                        
        end
        
        % Make the uibuttongroup visible after creating child objects. 
        hb(pi).Visible = 'on';
            
        % assign default group
        hb(pi).SelectedObject = hr(pi,floor((pi-1)/(pn/gn))+1);  % Default selections
% 
%        uicontrol('Style','radio',...
%                     'Position',[30 100*gn*line 20 20],...
%                     'String',num2str(pi),...
%                     'units','normalized')
   end
end

%% INITIALIZE FIJI (make necessary installations)

% addpath('/Applications/Fiji.app/scripts') % Update for your ImageJ installation as appropriate
% javaaddpath '/Applications/MATLAB_R2017b.app/java/ij.jar'
% javaaddpath '/Applications/MATLAB_R2017b.app/java/mij.jar'
% ImageJ;

