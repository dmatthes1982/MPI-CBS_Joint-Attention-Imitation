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
% 2. Detect and reject transient artifacts (200uV delta within 200 ms. 
%    The window is shifted with 100 ms, what means 50 % overlapping.)
% 3. Concatenated cleaned data to a continuous stream
% 4. ICA decomposition
% 5. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 6. Verify the estimated components by using the ft_topoplotIC function
% 7. Reject verified components and save the resulting mixing and unmixing
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
  fprintf('\n');
  
  % Detect and reject transient artifacts (200uV delta within 200 ms. 
  % The window is shifted with 100 ms, what means 50 % overlapping.)
  cfg         = [];
  cfg.length  = 200;                                                        % window length: 200 msec        
  cfg.overlap = 50;                                                         % 50 % overlapping
  trl         = JAI_genTrl(cfg, data_continuous);                           % define artifact detection intervals
  
  cfg             = [];
  cfg.chan        = 'all';                                                  % use all channels
  cfg.continuous  = 'yes';
  cfg.trl         = trl; 
  cfg.method      = 1;                                                      % method: range
  cfg.range       = 200;                                                    % 200 uV
   
  cfg_autoart     = JAI_autoArtifact(cfg, data_continuous);
  
  clear trl
   
  cfg           = [];
  cfg.artifact  = cfg_autoart;
  cfg.reject    = 'partial';                                                % partial rejection
  cfg.target    = 'single';                                                 % target of rejection
  
  data_cleaned  = JAI_rejectArtifacts(cfg, data_continuous);
  
  clear data_continuous cfg_autoart
  fprintf('\n');
  
  % Concatenated cleaned data to a continuous stream
  data_cleaned = JAI_concatData( data_cleaned );
  
  % ICA decomposition
  cfg               = [];
  cfg.channel       = {'all', '-EOGV', '-EOGH', '-REF'};
  cfg.numcomponent  = 'all';
  
  tic;
  data_icacomp = JAI_ica(cfg, data_cleaned);
  toc;
  
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
clear file_path cfg sourceList numOfSources i j


