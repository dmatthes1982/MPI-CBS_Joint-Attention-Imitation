%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04c_preproc2/';
  cfg.filename  = 'JAI_d01_04c_preproc2';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data 
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
  sourceList    = dir([strcat(desPath, '04c_preproc2/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_04c_preproc2_', sessionStr, '.mat'));
  end
end

%% part 6

cprintf([0,0.6,0], '<strong>[6] - Narrow band filtering and Hilbert transform</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
  cfg.filename    = sprintf('JAI_d%02d_04c_preproc2', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n\n');
  JAI_loadData( cfg );
  
  filtCoeffDiv = 500 / data_preproc2.part1.fsample;                         % estimate sample frequency dependent divisor of filter length

  % bandpass filter data at 2Hz
  cfg           = [];
  cfg.bpfreq    = [1.9 2.1];
  cfg.filtorder = fix(500 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'}; 

  data_bpfilt_2Hz = JAI_bpFiltering(cfg, data_preproc2);
  
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
  
  % bandpass filter data at theta (4-7 Hz)
  cfg           = [];
  cfg.bpfreq    = [4 7];
  cfg.filtorder = fix(500 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};
  
  data_bpfilt_theta = JAI_bpFiltering(cfg, data_preproc2);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltTheta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (theta: 4-7Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_theta', data_bpfilt_theta);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_theta
  
  % bandpass filter data at alpha (8-12 Hz)
  cfg           = [];
  cfg.bpfreq    = [8 12];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};
  
  data_bpfilt_alpha = JAI_bpFiltering(cfg, data_preproc2);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_alpha', data_bpfilt_alpha);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_alpha

  % bandpass filter data at 20Hz
  cfg           = [];
  cfg.bpfreq    = [19 21];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};
  
  data_bpfilt_20Hz = JAI_bpFiltering(cfg, data_preproc2);

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
  clear data_bpfilt_20Hz
  
  % bandpass filter data at beta (13-30Hz)
  cfg           = [];
  cfg.bpfreq    = [13 30];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};
  
  data_bpfilt_beta = JAI_bpFiltering(cfg, data_preproc2);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_beta', data_bpfilt_beta);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_beta
  
  % bandpass filter data at gamma (31-48Hz)
  cfg           = [];
  cfg.bpfreq    = [31 48];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};
  
  data_bpfilt_gamma = JAI_bpFiltering(cfg, data_preproc2);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (beta: 31-48Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_bpfilt_gamma', data_bpfilt_gamma);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_gamma data_preproc2
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
    
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
  
  % calculate hilbert phase at theta (4-7Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltTheta', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at theta (4-7Hz) bandpass filtered data...\n');
  JAI_loadData( cfg );
  
  data_hilbert_theta = JAI_hilbertPhase(data_bpfilt_theta);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbertTheta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (theta: 4-7Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_theta', data_hilbert_theta);
  fprintf('Data stored!\n\n');
  clear data_hilbert_theta data_bpfilt_theta
  
  % calculate hilbert phase at alpha (8-12Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltAlpha', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at alpha (8-12Hz) bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  data_hilbert_alpha = JAI_hilbertPhase(data_bpfilt_alpha);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbertAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_alpha', data_hilbert_alpha);
  fprintf('Data stored!\n\n');
  clear data_hilbert_alpha data_bpfilt_alpha
  
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
  
  % calculate hilbert phase at beta (13-30Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltBeta', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at beta (13-30 Hz) bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  data_hilbert_beta = JAI_hilbertPhase(data_bpfilt_beta);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbertBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_beta', data_hilbert_beta);
  fprintf('Data stored!\n\n');
  clear data_hilbert_beta data_bpfilt_beta
  
  % calculate hilbert phase at gamma (31-48Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltGamma', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at gamma (31-48 Hz) bandpass filtered data ...\n');
  JAI_loadData( cfg );
  
  data_hilbert_gamma = JAI_hilbertPhase(data_bpfilt_gamma);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbertGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (gamma: 31-48Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hilbert_gamma', data_hilbert_gamma);
  fprintf('Data stored!\n\n');
  clear data_hilbert_gamma data_bpfilt_gamma
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv 
