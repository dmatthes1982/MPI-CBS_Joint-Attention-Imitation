%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '04b_eyecor';
  cfg.filename  = 'JAI_d01_04b_eyecor';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedDataCCA/';         % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
  sourceList    = dir([strcat(desPath, '04b_eyecor/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_04b_eyecor_', sessionStr, '.mat'));
  end
end

%% part 8

cprintf([0,0.6,0], '<strong>[8] - Estimation of Inter Trial Phase Coherences (ITPC)</strong>\n');
fprintf('\n');

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

% Write selected settings to settings file
file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(file_path, 'file') == 2)                                         % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  JAI_createTbl(cfg);                                                       % create settings file
end

T = readtable(file_path);                                                   % update settings table
warning off;
T.artRejectITPC(numOfPart) = { x };
warning on;
delete(file_path);
writetable(T, file_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation, Artifact rejection and ITPC estimation

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);

  cfg             = [];                                                     % load preprocessed data
  cfg.srcFolder   = strcat(desPath, '04b_eyecor/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('JAI_d%02d_04b_eyecor', i);
  
  fprintf('Load eye-artifact corrected data...\n\n');
  JAI_loadData( cfg );
  
  % Keep only necessary conditions in the dataset
  cfg         = [];
  cfg.channel = 'all';
  cfg.trials  = [7,8,9,10,11,12,20,21,22,100,101,102];
  
  data_eyecor = JAI_selectdata( cfg, data_eyecor );
  
  % Segmentation of the preprocessed trials for ITPC estimation %%%%%%%%%%%
  % split the data of every condition into subtrials with a length of 10
  % seconds
  cfg           = [];
  cfg.length    = 10;
  cfg.overlap   = 0;

  data_eyecor  = JAI_segmentation( cfg, data_eyecor );
  
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
    cfg.reject    = 'complete';
    cfg.target    = 'single';
  
    data_eyecor = JAI_rejectArtifacts(cfg, data_eyecor);
    fprintf('\n');
    
    clear cfg_allart
  end

  % estimation of the inter-trial phase coherence (ITPC)
  cfg           = [];
  cfg.toi       = 0:0.2:9.8;
  cfg.foi       = 1:0.5:48;

  data_itpc = JAI_interTrialPhaseCoh(cfg, data_eyecor);
  clear data_eyecor
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'itpc';
  cfg.sessionStr = sessionStr;
  JAI_writeTbl(cfg, data_itpc);
  
  % export the itpc data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08a_itpc/');
  cfg.filename    = sprintf('JAI_d%02d_08a_itpc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The ITPC data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_itpc', data_itpc);
  fprintf('Data stored!\n\n');

  % average itpc values over time for certain frequencies
  cfg     = [];
  cfg.foi = [2,10,20];

  data_itpc = JAI_ITPCavgOverTime(cfg, data_itpc);

  % export the averaged itpc data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08b_itpcavg/');
  cfg.filename    = sprintf('JAI_d%02d_08b_itpcavg', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The over time averaged ITPC data (for 2,10 and 20 Hz) of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_itpc', data_itpc);
  fprintf('Data stored!\n\n');
  clear data_itpc
end

%% clear workspace
clear file_path file_num cfg dyads dyadsNew i cfg_allArt artifactRejection ...
      x choise T
