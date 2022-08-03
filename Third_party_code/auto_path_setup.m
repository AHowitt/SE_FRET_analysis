path = mfilename('fullpath');
path = path(1:end-length(mfilename));

addpath(genpath(path),'-begin');

display(['Path updated with "' path ' "folder and all its subfolders'])

clear path