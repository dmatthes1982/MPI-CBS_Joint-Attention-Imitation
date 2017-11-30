%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.desFolder = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/';
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

%% part 3
% Estimation of eye artifacts (via ICA decomposition)
% Processing steps:
% 1. Concatenated preprocessed trials to a continuous stream
% 2. Detect and reject transient artifacts (200?V delta within 100 ms, 50% 
%    window overlapping)
% 3. ICA decomposition
% 4. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 5. Verify the estimated components by using the ft_topoplotIC function
% 6. Reject verified components and save the resulting mixing and unmixing
%    matrices for the following eye artifact correction in part 4

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n');
  JAI_loadData( cfg );
  
  % Concatenated preprocessed trials to a continuous stream
  data_continuous = JAI_concatData( data_preproc );
  
  clear data_preproc
  
  % Detect and reject transient artifacts (200?V delta within 100 ms, 50% 
  % window overlapping)
  %cfg = [];
  
  %cfg_autoart  = JAI_autoArtifact(cfg, data_continuous);
  
  %cfg = [];
  
  %data_cleaned = JAI_rejectArtifacts(cfg, data_continuous);
  
  % ICA decomposition
  %cfg = [];
  
  %data_icacomp = JAI_ica(cfg, data_cleaned);
  
  % Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
  % confirmity)
  %cfg = [];
  
  % Verify the estimated components
  %cfg = [];
  
  % Reject verified components and save the resulting mixing and unmixing
  % matrices
  %cfg = [];
  
end


%% clear workspace
clear file_path cfg sourceList numOfSources i


