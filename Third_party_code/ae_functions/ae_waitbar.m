% 'varlist': list of variables to be monitored
% 'limits': lower and upper bound of the variables to be monitored [0 1]
% 'position' [x y width height]
% 'title'
% 'handler_name' hw=ae_waitbar('handler_name','hw') needed for the timer
% option
% 'timer' [on]/off
% 'timer_lag' [2s]
% 'memory' [on]/off



function varargout = ae_waitbar(varargin)

    % initialize
    values = []; % values to be monitored
    vnames = {}; % variable names to be monitored
    limits = []; % lower and upper bound of the variables to be monitored
    captions = {}; % waitbars captions
    colours = []; % waitbar colours
    
    str_title = 'ae waitbar';
    
    handler_name = 'hw'; % needed to use the timer option
    bTimer = 1;
    timer_lag = 2;
    
    bMemory = 1;
    
    % default GUI parameters
    gui.x0            = 0.05; % left margin
    gui.y0            = 0.15; % bottom margin
    gui.x             = 0.9;  % bar width
    gui.y             = 0.05; % bar height
    gui.spacing       = 0.3; % spacinf between bars
    gui.font          = 6;   % font size
    gui.text_posy     = 2.6; % captions relative position
    gui.size          = [10 423 410 75]; % size and position of window

    if ischar(varargin{1}) % creating the waitbar     
        bCreate = 1;
        
        % parse input
        for i=1:2:nargin
            switch lower(varargin{i}) 

                case {'var','varlist'} % parse variables

                    % init
                    eval(['global ' varargin{i+1}]);
                    remain = varargin{i+1};
                    var_name = ' ';
                    iv = 0;
                    
                    % identify and assign
                    while 1
                        iv = iv + 1;
                        [var_name, remain] = strtok(remain,' ');
                        if isempty(var_name)
                            break
                        end
                        vnames{iv} = var_name;
                    end

                    % number of varibles and clear
                    nv = iv - 1;                                                   
                    values=zeros(1,nv);
                    for iv=1:nv
                        eval(['values(1,' num2str(iv) ') = ' vnames{iv} ';'])
                    end
                    clear iv var_name remain
                    

                case {'lim','limits'}

                    limits = varargin{i+1}; 

                case {'pos','position'}

                    gui.size  = varargin{i+1};

                case 'title'

                    str_title = varargin{i+1};

                case 'captions'

                    captions = varargin{i+1};

                case {'col','color','colours'}

                    colours = varargin{i+1};
                    
                case {'handler_name','handler'}
                    
                    handler_name = varargin{i+1};
                    
                case {'timer'}
                    if strcmp(lower(varargin{i+1}),'off')
                        bTimer = 0;                    
                    else
                        bTimer = 1;
                    end
                    
                case {'timer_lag'}
                    timer_lag = varargin{i+1};
                    
                case {'memory'}
                    if strcmp(lower(varargin{i+1}),'off')
                        bMemory = 0;                    
                    else
                        bMemory = 1;
                    end                    
                    
                otherwise
                    error([mfilename '> input argument not supported (' varargin{i} ')'])
            end
        end

        % check input values
        if isempty(values)
            error([mfilename '>no variable to be monitored'])
        end

        if isempty(limits)
            warning([mfilename '> no declared limits, imposing default values (0,1)']);
            limits = repmat([0 1],[nv 1]);
        end

        if isempty(captions)
            captions = vnames;
        end

        if isempty(colours)
            colours = repmat([1 0 0],[nv 1]);
        end                
        
        
        h.varlist = vnames;
        h.nvar    = nv;
        
        
        if bMemory
           if bCreate
            nv = nv + 1;
           else
            nv = h.nvar + 1;
           end

           
           [m1 m2] = memory;
           cur_mem = 1-m2.PhysicalMemory.Available/m2.PhysicalMemory.Total;       

           vnames{nv} = 'cur_mem';
           vnames = {vnames{[nv (1:nv-1)]}};
           captions{nv} = 'MEMORY USAGE';
           captions = {captions{[nv (1:nv-1)]}}   ;    
           colours(2:nv,:) = colours(1:nv-1,:);
           colours(1,:) = [0 0 1];
           limits(2:nv,:) = limits(1:nv-1,:);
           limits(1,:) = [0 1];
           values(2:nv) = values(1:nv-1);
           values(1) = cur_mem;
        end        
        
    else % updating waitbar        
        
        bCreate = 0;
        
        if nargin==1
            h = varargin{1};                 
        end
                
        
        if nargin==2 % update also captions
            h = varargin{1};
            captions = varargin{2};
        end

   
        bMemory = h.memory_on;
        bTimer  = h.timer_on;
        
     
    end
        
    
    if bCreate
        % draw GUI
        str_close_callback = ['eval([''stop(' handler_name '.timer);delete(' handler_name '.timer);delete(' handler_name '.figure);''])'];
        
        gui.spacing       = 0.9/nv; % spacinf between bars
        
        % set position (function)               
        posw = @(x)[gui.x0
                    1-(gui.y0+gui.spacing*(x-0.5))
                    gui.x
                    gui.y];   

        h.figure = figure('Position',gui.size,...
                           'Name',str_title,...
                           'CloseRequestFcn',str_close_callback,...
                           'toolbar','none',...
                           'menubar','none',...
                           'numbertitle','off');
        for iv=1:nv

            axes('position',posw(iv),...
                'box','on',...
                'xlim',limits(iv,:),...
                'ylim',[0 1],...
                'XTickLabel','',...
                'XTick',[],...
                'YTick',[],...
                'YTickLabel','');

            h.captions(iv) = text(limits(iv,1),gui.text_posy,captions{iv},'fontsize',gui.font);                           
            h.waitbar(iv) = patch([0 0 values(iv) values(iv)], [0 1 1 0],colours(iv,:));        

        end
        
        % create timer
        
        
        if timer_lag<2
            timer_lag = 2;
            warning([mfilename '> timer lag reset to 2s; requested value was too short'])
        end
        
        wbTimer                 = timer;
        wbTimer.TimerFcn        = ['ae_waitbar(' handler_name ');'];
        wbTimer.Period          = timer_lag;
        wbTimer.StartDelay      = timer_lag;
        wbTimer.TasksToExecute  = Inf;
        wbTimer.ExecutionMode   = 'fixedSpacing';
        
        h.timer = wbTimer;        
        
        if bTimer
            start(wbTimer)
        end
        
    else
        % monitor values
        
        for iv=1:h.nvar
        
            eval(['global ' h.varlist{iv} ';'])
            eval(['values(iv) = ' h.varlist{iv} ';'])
            
            set(h.waitbar(iv+bMemory),'xdata',[0 0 values(iv) values(iv)]);
            
            
            if ~isempty(captions)
                set(h.captions(iv+bMemory),'string',captions{iv});   
            end
        end
 
        if bMemory
            [m1 m2] = memory;
            cur_mem = 1-m2.PhysicalMemory.Available/m2.PhysicalMemory.Total;    
            set(h.waitbar(1),'xdata',[0 0 cur_mem cur_mem]);
        end
        


    end
    
    
    
   
    h.memory_on = bMemory;
    h.timer_on  = bTimer;
    if nargout==1
        varargout{1} = h;
    end
    
    drawnow
    
    %%
    return
     % STATUS CONSTANT DEFINITIONS (MOVE TO INIT@)
    ELIS_CS_STATUS_OK      = 1;
    ELIS_CS_STATUS_WARNING = 2;
    ELIS_CS_STATUS_ERROR   = 3;
    
    
    %% defaults




    % DRAW FIGURE


    % create handler for status icon
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');               
    path_graphics = 'G:\SHARED_PROJECTS\TDCs\ELIS_alpha_build5\support_files\';
    graphics_dot  = {'greenbut.png','yellowbut.png','redbut.png'};
    guiw_jframe   = get(hgui.w_main,'javaframe');

    

    % status message (function)        
    cs_status      = @(s)set(hgui.w_main,'Name',['status: ' s]);                         
    % waitbar value (function)
    cs_waitbar     = @(h,v)set(h,'xdata',[0 0 v v]);
    % waitbar title (function)        
    cs_waitbar_msg = @(h,s)set(h,'string',s);    
    % waitbar title (function)        
    cs_waitbar_col = @(h,c)set(h,'facecolor',c);    
    % status icon (function)        
    cs_status_icon = @(s)guiw_jframe.setFigureIcon(javax.swing.ImageIcon([path_graphics graphics_dot{s}]));







