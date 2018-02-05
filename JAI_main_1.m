%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01_raw/';
  cfg.filename  = 'JAI_d01_01_raw';
  sessionNum    = JAI_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';                  % source path to raw data
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'DualEEG_JAI_%d.vhdr');
  end
end

%% part 1
% import data from brain vision eeg files and bring it into an order
% and export the imported and sorted data into an *.mat file

for i = numOfPart
  cfg       = [];
  cfg.path  = srcPath;
  cfg.dyad  = i;
  cfg.continuous  = 'no';
  
  fprintf('Import data of dyad %d from: %s ...\n', i, cfg.path);
  ft_info off;
  data_raw = JAI_importDataset( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01_raw/');
  cfg.filename    = sprintf('JAI_d%02d_01_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
end

%% clear workspace
clear file_path cfg sourceList numOfSources i
