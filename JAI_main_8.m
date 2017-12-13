%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '02_preproc';
  cfg.filename  = 'JAI_d01_02_preproc';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/'; % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preprocessed data folder
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

%% part 8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before ITPC estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    choise = true;
    artifactRejection = false;
  else
    choise = false;
  end
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation, Artifact rejection and ITPC estimation

for i = numOfPart
  fprintf('Dyad %d\n', i);

  cfg             = [];                                                     % load preprocessed data
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  
  fprintf('Load preprocessed data...\n\n');
  JAI_loadData( cfg );
  
  % Segmentation of the preprocessed trials for ITPC estimation %%%%%%%%%%%
  % split the data of every condition into subtrials with a length of 10
  % seconds
  cfg           = [];
  cfg.length    = 10;
  cfg.overlap   = 0;

  data_iseg  = JAI_segmentation( cfg, data_preproc );
  clear data_preproc

  % export the segmented data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08a_iseg/');
  cfg.filename    = sprintf('JAI_d%02d_08a_iseg', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_iseg', data_iseg);
  fprintf('Data stored!\n\n');
  clear data_preproc

  % artifact rejection
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '05b_allart/');
    cfg.filename    = sprintf('JAI_d%02d_05b_allart', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');
                     
    if ~isempty(dir(file_path))
      fprintf('Loading %s ...\n', file_path);
      JAI_loadData( cfg );                                                    
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactRejection = false;
    end
  end
  
  if artifactRejection == true                                              % reject artifacts
    cfg           = [];
    cfg.artifact  = cfg_allart;
    cfg.type      = 'single';
  
    data_iseg = JAI_rejectArtifacts(cfg, data_iseg);
    fprintf('\n');
    
    clear cfg_allart
  end

  % estimation of the inter-trial phase coherence (ITPC)
  cfg           = [];
  cfg.toi       = 0:0.2:9.8;
  cfg.foi       = 1:0.5:48;

  data_itpc = JAI_interTrialPhaseCoh(cfg, data_iseg);
  clear data_iseg

  % export the itpc data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08b_itpc/');
  cfg.filename    = sprintf('JAI_d%02d_08b_itpc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The ITPC data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_itpc', data_itpc);
  fprintf('Data stored!\n');
  clear data_itpc
end

%% clear workspace
clear file_path file_num cfg dyads dyadsNew i cfg_allArt artifactRejection ...
      x choise
