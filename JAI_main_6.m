%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'JAI_d01_02_preproc';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/'; % destination path for processed data 
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% part 6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n\n');
  JAI_loadData( cfg );
  
  filtCoeffDiv = 500 / data_preproc.part1.fsample;                          % estimate sample frequency dependent divisor of filter length

  % bandpass filter data at 2Hz
  cfg           = [];
  cfg.bpfreq    = [1.9 2.1];
  cfg.filtorder = fix(500 / filtCoeffDiv);

  data_bpfilt_2Hz = JAI_bpFiltering(cfg, data_preproc);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_2Hz', data_bpfilt_2Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_2Hz
  
  % bandpass filter data at 10Hz
  cfg           = [];
  cfg.bpfreq    = [9 11];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_10Hz = JAI_bpFiltering(cfg, data_preproc);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_10Hz', data_bpfilt_10Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_10Hz

  % bandpass filter data at 20Hz
  cfg           = [];
  cfg.bpfreq    = [19 21];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_20Hz = JAI_bpFiltering(cfg, data_preproc);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_20Hz', data_bpfilt_20Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_20Hz data_preproc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  fprintf('Dyad %d\n', i);
    
  % calculate hilbert phase at 2Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt2Hz', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at 2Hz bandpass filtered data...\n');
  JAI_loadData( cfg );
  
  data_hilbert_2Hz = JAI_hilbertPhase(data_bpfilt_2Hz);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_2Hz', data_hilbert_2Hz);
  fprintf('Data stored!\n\n');
  clear data_hilbert_2Hz data_bpfilt_2Hz
  
  % calculate hilbert phase at 10Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt10Hz', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at 10 Hz bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  data_hilbert_10Hz = JAI_hilbertPhase(data_bpfilt_10Hz);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_10Hz', data_hilbert_10Hz);
  fprintf('Data stored!\n\n');
  clear data_hilbert_10Hz data_bpfilt_10Hz
  
  % calculate hilbert phase at 20Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt20Hz', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at 20 Hz bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  data_hilbert_20Hz = JAI_hilbertPhase(data_bpfilt_20Hz);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_20Hz', data_hilbert_20Hz);
  fprintf('Data stored!\n\n');
  clear data_hilbert_20Hz data_bpfilt_20Hz
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv 
