%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '02_preproc';
  cfg.filename  = 'JAI_p01_02_preproc';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01826/DualEEG_JAI_processedData/';              % destination path for processed data  
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
                    strcat('JAI_p%d_02_preproc_', sessionStr, '.mat'));
  end
end

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
  cfg.filename    = sprintf('JAI_p%02d_02_preproc', i);
  
  fprintf('Load preprocessed data...\n');
  JAI_loadData( cfg );
  
  % Segmentation of the preprocessed trials for ITPC estimation %%%%%%%%%%%
  % split the data of every condition into subtrials with a length of 10
  % seconds
  cfg           = [];
  cfg.length    = 10;

  data_iseg  = JAI_segmentation( cfg, data_preproc );
  clear data_preproc

  % export the segmented data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '12_iseg/');
  cfg.filename    = sprintf('JAI_p%02d_12_iseg', i);
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
    cfg.desFolder   = desPath;
    cfg.filename    = 'JAI_06_allArt';
    cfg.sessionStr  = sessionStr;

    file_path = strcat(desPath, cfg.filename, '_', sessionStr, '.mat');
    if ~isempty(dir(file_path))
      fprintf('Loading %s ...\n\n', file_path);
      JAI_loadData( cfg );                                                    
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactRejection = false;
    end
  end
  
  if artifactRejection == true                                              % reject artifacts
    cfg           = [];
    cfg.artifact  = cfg_allArt;
    cfg.type      = 'single';
  
    data_iseg = JAI_rejectArtifacts(cfg, data_iseg);
    fprintf('\n');
    
    clear cfg_allArt
  end

  % estimation of the inter-trial phase coherence (ITPC)
  cfg           = [];
  cfg.toi       = 0:0.2:9.8;
  cfg.foi       = 1:0.5:48;

  data_itpc = JAI_interTrialPhaseCoh(cfg, data_iseg);
  clear data_iseg

  % export the itpc data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '13_itpc/');
  cfg.filename    = sprintf('JAI_p%02d_13_itpc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The ITPC data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_itpc', data_itpc);
  fprintf('Data stored!\n\n');
  clear data_itpc
end

%% clear workspace
clear file_path file_num cfg dyads dyadsNew i cfg_allArt artifactRejection ...
      x choise
