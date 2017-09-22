%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04_seg1/';
  cfg.filename  = 'JAI_p01_04_seg1';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '04_seg1/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_p%d_04_seg1_', sessionStr, '.mat'));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04_seg1/');
  cfg.filename    = sprintf('JAI_p%02d_04_seg1', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load segmented data...\n');
  JAI_loadData( cfg );
  
  filtCoeffDiv = 500 / data_seg1.part1.fsample;                             % estimate sample frequency dependent divisor of filter length

  % bandpass filter data at 2Hz
  cfg           = [];
  cfg.bpfreq    = [1.9 2.1];
  cfg.filtorder = fix(500 / filtCoeffDiv);

  data_bpfilt_2Hz = JAI_bpFiltering(cfg, data_seg1);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_bpFilt/');
  cfg.filename    = sprintf('JAI_p%02d_07a_bpfilt2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_2Hz', data_bpfilt_2Hz);
  fprintf('Data stored!\n');
  clear data_bpfilt_2Hz
  
  % bandpass filter data at 10Hz
  cfg           = [];
  cfg.bpfreq    = [9 11];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_10Hz = JAI_bpFiltering(cfg, data_seg1);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_bpFilt/');
  cfg.filename    = sprintf('JAI_p%02d_07b_bpfilt10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_10Hz', data_bpfilt_10Hz);
  fprintf('Data stored!\n');
  clear data_bpfilt_10Hz

  % bandpass filter data at 20Hz
  cfg           = [];
  cfg.bpfreq    = [19 21];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_20Hz = JAI_bpFiltering(cfg, data_seg1);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_bpFilt/');
  cfg.filename    = sprintf('JAI_p%02d_07c_bpfilt20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_20Hz', data_bpfilt_20Hz);
  fprintf('Data stored!\n');
  clear data_bpfilt_20Hz

  % bandpass filter data at 40Hz
  cfg           = [];
  cfg.bpfreq    = [39 41];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_40Hz = JAI_bpFiltering(cfg, data_seg1);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_bpFilt/');
  cfg.filename    = sprintf('JAI_p%02d_07d_bpfilt40Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (40Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_40Hz', data_bpfilt_40Hz);
  fprintf('Data stored!\n');
  clear data_bpfilt_40Hz data_seg1
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07_bpFilt/');
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  
  cfg.filename    = sprintf('JAI_p%02d_07a_bpfilt2Hz', i);
  fprintf('Load the at 2Hz bandpass filtered data...\n');
  JAI_loadData( cfg );

  cfg.filename    = sprintf('JAI_p%02d_07b_bpfilt10Hz', i);
  fprintf('Load the at 10 Hz bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  cfg.filename    = sprintf('JAI_p%02d_07c_bpfilt20Hz', i);
  fprintf('Load the at 20 Hz bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  cfg.filename    = sprintf('JAI_p%02d_07d_bpfilt40Hz', i);
  fprintf('Load the at 30 Hz bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  % calculate hilbert phase at 2Hz
  data_hilbert_2Hz = JAI_hilbertPhase(data_bpfilt_2Hz);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08_hilbert/');
  cfg.filename    = sprintf('JAI_p%02d_08a_hilbert2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_2Hz', data_hilbert_2Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_2Hz data_bpfilt_2Hz
  
  % calculate hilbert phase at 10Hz
  data_hilbert_10Hz = JAI_hilbertPhase(data_bpfilt_10Hz);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08_hilbert/');
  cfg.filename    = sprintf('JAI_p%02d_08b_hilbert10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_10Hz', data_hilbert_10Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_10Hz data_bpfilt_10Hz
  
  % calculate hilbert phase at 20Hz
  data_hilbert_20Hz = JAI_hilbertPhase(data_bpfilt_20Hz);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08_hilbert/');
  cfg.filename    = sprintf('JAI_p%02d_08c_hilbert20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_20Hz', data_hilbert_20Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_20Hz data_bpfilt_20Hz
  
  % calculate hilbert phase at 40Hz
  data_hilbert_40Hz = JAI_hilbertPhase(data_bpfilt_40Hz);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08_hilbert/');
  cfg.filename    = sprintf('JAI_p%02d_08d_hilbert40Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (40Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_40Hz', data_hilbert_40Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_40Hz data_bpfilt_40Hz
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv 
