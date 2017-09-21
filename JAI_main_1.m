%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg         = [];                                                         
  sessionStr  = sprintf('%03d', JAI_getSessionNum( cfg ) + 1);              % calculate next session number
end

if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';              % source path to raw data
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';        % destination path for processed data  
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

%% import data from brain vision eeg files and bring it into an order
%  and export the imported and sorted data into an *.mat file

for i = numOfPart
  cfg       = [];
  cfg.path  = srcPath;
  cfg.part  = i;  

  fprintf('Import data of dyad %d from: %s ...\n', i, cfg.path);
  ft_info off;
  data_raw = JAI_importDataset( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01_raw/');
  cfg.filename    = sprintf('JAI_p%02d_01_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
end

%% preprocess the raw data
% export the preprocessed data into a *.mat file

selection = false;
  while selection == false
    cprintf([0,0.6,0], 'Please select sampling rate for preprocessing:\n');
    fprintf('[1] - 500 Hz (original sampling rate)\n');
    fprintf('[2] - 250 Hz (downsampling factor 2)\n');
    fprintf('[3] - 125 Hz (downsampling factor 4)\n');
    x = input('Option: ');
  
    switch x
      case 1
        selection = true;
        samplingRate = 500;
      case 2
        selection = true;
        samplingRate = 250;
      case 3
        selection = true;
        samplingRate = 125;
      otherwise
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
  fprintf('\n');

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_raw/');
  cfg.filename    = sprintf('JAI_p%02d_01_raw', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load raw data...\n');
  JAI_loadData( cfg );
  
  cfg                   = [];
  cfg.bpfreq            = [1 48];                                           % passband from 1 to 48 Hz
  cfg.bpfilttype        = 'but';
  cfg.bpinstabilityfix  = 'split';
  cfg.samplingRate      = samplingRate;
  
  ft_info off;
  data_preproc = JAI_preprocessing( cfg, data_raw);
  ft_info on;
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_p%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_preproc', data_preproc);
  fprintf('Data stored!\n\n');
  clear data_preproc data_raw 
end

%% calculate TFRs of the preprocessed data
% export the preprocessed data into a *.mat file

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_p%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preproc data...\n');
  JAI_loadData( cfg );

  cfg         = [];
  cfg.foi     = 2:1:50;                                                     % frequency of interest
  cfg.toi     = 4:0.5:176;                                                  % time of interest
  
  data_tfr1 = JAI_timeFreqanalysis( cfg, data_preproc );

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03_tfr1/');
  cfg.filename    = sprintf('JAI_p%02d_03_tfr1', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_tfr1', data_tfr1);
  fprintf('Data stored!\n\n');
  clear data_tfr1 data_preproc
end

%% clear workspace
clear file_path cfg sourceList numOfSources i selection samplingRate x
