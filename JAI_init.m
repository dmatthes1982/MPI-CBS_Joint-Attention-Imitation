% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/:%s/easyplot:%s/elecorder:%s/functions:%s/general:%s/layouts:%s/utilities', ...
        filepath, filepath, filepath, filepath, filepath, filepath, filepath));

clear filepath