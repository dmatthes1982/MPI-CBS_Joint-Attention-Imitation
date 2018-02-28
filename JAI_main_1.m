%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw/';
  cfg.filename  = 'JAI_d01_01a_raw';
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
% 1. import data from brain vision eeg files and bring it into an order
% 2. select corrupted channels 
% 3. repair corrupted channels

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  cfg.desFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('JAI_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
end

fprintf('Repairing of corrupted channels\n\n');

%% repairing of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('Dyad %d\n\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('JAI_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load raw data...\n');
  JAI_loadData( cfg );
  
  % Concatenated raw trials to a continuous stream
  data_continuous = JAI_concatData( data_raw );
  
  fprintf('\n');
  
  % select corrupted channels
  data_badchan = JAI_selectBadChan( data_continuous );
  
  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_badchan/');
  cfg.filename    = sprintf('JAI_d%02d_01b_badchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Bad channels of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_badchan', data_badchan);
  fprintf('Data stored!\n\n');
  clear data_continuous
  
  % repair corrupted channels
  data_repaired = JAI_repairBadChan( data_badchan, data_raw );
  
  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01c_repaired/');
  cfg.filename    = sprintf('JAI_d%02d_01c_repaired', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Repaired raw data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_repaired', data_repaired);
  fprintf('Data stored!\n\n');
  clear data_repaired data_raw data_badchan 
end

%% clear workspace
clear file_path cfg sourceList numOfSources i
