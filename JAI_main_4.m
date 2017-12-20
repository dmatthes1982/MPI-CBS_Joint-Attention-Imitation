%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03b_eogcomp/';
  cfg.filename  = 'JAI_d01_03b_eogcomp';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/'; % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eogcomp data folder
  sourceList    = dir([strcat(desPath, '03b_eogcomp/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_03b_eogcomp_', sessionStr, '.mat'));
  end
end

%% part 4
% Correction of eye artifacts
% Calculate TFRs of the corrected data
% export both corrected data and TFR data into *.mat files

% Correction of eye artifacts
for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n');
  JAI_loadData( cfg );
  
  cfg.srcFolder   = strcat(desPath, '03b_eogcomp/');
  cfg.filename    = sprintf('JAI_d%02d_03b_eogcomp', i);
  
  fprintf('Load eye-artifact related components and the unmixing matrix...\n\n');
  JAI_loadData( cfg );
  
  % Remove eye artifacts
  data_eyecor = JAI_removeEOGArt(data_eogcomp, data_preproc);
  
  clear data_eogcomp data_preproc
  fprintf('\n');
  
  % export the reviced data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04a_eyecor/');
  cfg.filename    = sprintf('JAI_d%02d_04a_eyecor', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The reviced data (from EOG artifacts) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_eyecor', data_eyecor);
  fprintf('Data stored!\n\n');
  clear data_eyecor
end

% Calculate TFRs of the corrected data
for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04a_eyecor/');
  cfg.filename    = sprintf('JAI_d%02d_04a_eyecor', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load eyecor data...\n');
  JAI_loadData( cfg );

  cfg         = [];
  cfg.foi     = 2:1:50;                                                     % frequency of interest
  cfg.toi     = 4:0.5:176;                                                  % time of interest
  
  data_tfr = JAI_timeFreqanalysis( cfg, data_eyecor );
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04b_tfr/');
  cfg.filename    = sprintf('JAI_d%02d_04b_tfr', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_tfr', data_tfr);
  fprintf('Data stored!\n\n');
  clear data_tfr data_eyecor
end

%% clear workspace
clear file_path cfg sourceList numOfSources i