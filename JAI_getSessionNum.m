function [ num ] = JAI_getSessionNum( cfg )
% JAI_GETSESSIONNUM determines the highest session number of a specific 
% data file 
%
% Use as
%   [ num ] = JAI_getSessionNum( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01826/eegData/DualEEG_JAI_processedData/')
%   cfg.subFolder   = name of subfolder (default: '01_raw/')
%   cfg.filename    = filename (default: 'JAI_p01_01_raw')
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2017, Daniel Matthes, MPI CBS

desFolder   = ft_getopt(cfg, 'srcFolder', '/data/pt_01826/eegData/DualEEG_JAI_processedData/');
subFolder   = ft_getopt(cfg, 'subFolder', '01_raw/');
filename    = ft_getopt(cfg, 'filename', 'JAI_p01_01_raw');

file_path = strcat(desFolder, subFolder, filename, '_*.mat');

sessionList    = dir(file_path);
if isempty(sessionList)
  num = 0;
else
  sessionList   = struct2cell(sessionList);
  sessionList   = sessionList(1,:);
  numOfSessions = length(sessionList);

  sessionNum    = zeros(1, numOfSessions);
  filenameStr   = strcat(filename, '_%d.mat');
  
  for i=1:1:numOfSessions
    sessionNum(i) = sscanf(sessionList{i}, filenameStr);
  end

  num = max(sessionNum);
end

end

