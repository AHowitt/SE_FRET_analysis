
%% XLS EXPORT

sheet_name = {'FRET',...
              'FRET (background corrected',...
              'CFP',...
              'CFP background',...
              'YFP',...
              'YFP background',...
              'Cell area',...
              'Cell eccentricity'};
          
var_pnt     = {'o_frt','o_frb','o_cfp','o_cfb','o_yfp','o_yfb','o_are','o_ecc'};
var_swt     = [1      , 1     , 1     , 1     , 1     , 1     , 1     , 1     ]; % toggle ON/OFF export of individual variables

% excel file name
xls_name = [path_name file_name '_analysis.xls'];

for ei=1:length(var_swt)   
ei
    if var_swt(ei)
        % label: time
        xlswrite(xls_name,{'time (hrs)'},sheet_name{ei},['a2']); 
        % time
        xRange = ['a3:a' num2str(tn+2)];
        %xlswrite(xls_name,squeeze(o_frt(pi,:,idx)),sheet_name{ei},xRange);


        counter = 0;
        for pi=1:pn
            %if pi==1
            %    loc = 2;
            %else
            %    loc = counter + loc;
            %end

            %xlswrite(xls_name,'FoV:','FRET (bck corrected)',['b2']);

            counter = counter +  nnz(qc_flag(pi,:));

            idx = find(qc_flag(pi,:));

            
            loc = counter + 2;
            
            % label: FoV
            xRange = [ind2xls(loc) '1'];
            xlswrite(xls_name,{['FoV: ' num2str(pi)]},sheet_name{ei},xRange);

            % label: obj
            xRange = [ind2xls(loc) '2:'  ind2xls(loc+length(idx)-1) '2'];
            xlswrite(xls_name,idx,sheet_name{ei},xRange);

            % data
            xRange = [ind2xls(loc) '3:'  ind2xls(loc+length(idx)-1) num2str(tn+2)];
            eval(['xlswrite(xls_name,squeeze(' var_pnt{ei} '(pi,:,idx)),sheet_name{ei},xRange)']);

        end %for pi
    end % if var_swt
end % for ei