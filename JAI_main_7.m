%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '06a_bpfilt';
  cfg.filename  = 'JAI_d01_06a_bpfiltGamma';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedDataCCA/';         % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
  sourceList    = dir([strcat(desPath, '06a_bpfilt/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_06a_bpfiltGamma_', sessionStr, '.mat'));
  end
end

%% part 7

cprintf([0,0.6,0], '<strong>[7] - Canonical correlation analysis (CCA)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% canonical correlation analysis

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
  
  %% 2 Hz branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at 2 Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt2Hz', i);
  fprintf('Load bandpass filtered data at 2 Hz...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at 2 Hz
  data_cca_2Hz    = JAI_cca(data_bpfilt_2Hz); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_cca2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at 2 Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_2Hz', data_cca_2Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_2Hz data_cca_2Hz
  
  %% theta branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at theta
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltTheta', i);
  fprintf('Load bandpass filtered data at theta...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at theta
  data_cca_theta    = JAI_cca(data_bpfilt_theta); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_ccaTheta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at theta in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_theta', data_cca_theta);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_theta data_cca_theta
  
  %% alpha branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at alpha
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltAlpha', i);
  fprintf('Load bandpass filtered data at alpha...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at alpha
  data_cca_alpha    = JAI_cca(data_bpfilt_alpha); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_ccaAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at alpha in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_alpha', data_cca_alpha);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_alpha data_cca_alpha
  
  %% beta branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at beta
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltBeta', i);
  fprintf('Load bandpass filtered data at beta...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at beta
  data_cca_beta    = JAI_cca(data_bpfilt_beta); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_ccaBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at beta in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_beta', data_cca_beta);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_beta data_cca_beta
  
   %% 20 Hz branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at 20 Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfilt20Hz', i);
  fprintf('Load bandpass filtered data at 20 Hz...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at 20 Hz
  data_cca_20Hz    = JAI_cca(data_bpfilt_20Hz); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_cca20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at 20 Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_20Hz', data_cca_20Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_20Hz data_cca_20Hz
  
  %% gamma branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load bandpass filtered data at gamma
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_06a_bpfiltGamma', i);
  fprintf('Load bandpass filtered data at gamma...\n');
  JAI_loadData( cfg );
  
  % conduct CCA at gamma
  data_cca_gamma    = JAI_cca(data_bpfilt_gamma); 
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07_cca/');
  cfg.filename    = sprintf('JAI_d%02d_07_ccaGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving CCA results at gamma in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_cca_gamma', data_cca_gamma);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_gamma data_cca_gamma
  
end

%% clear workspace
clear cfg file_path sourceList numOfSources i
