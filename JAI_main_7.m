%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '06b_hilbert/';
  cfg.filename  = 'JAI_d01_06b_hilbert20Hz';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/'; % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '06b_hilbert/'), ...
                       strcat('*20Hz_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_06b_hilbert20Hz_', sessionStr, '.mat'));
  end
end

%% part 7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
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
%% Segmentation and Artifact rejection

for i = numOfPart
  fprintf('Dyad %d\n', i);
  
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert2Hz', i);
  fprintf('Load hilbert phase data at 2 Hz...\n');
  JAI_loadData( cfg );

  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert10Hz', i);
  fprintf('Load hilbert phase data at 10 Hz...\n');
  JAI_loadData( cfg );
  
  cfg.filename    = sprintf('JAI_d%02d_06b_hilbert20Hz', i);
  fprintf('Load hilbert phase data at 20 Hz...\n\n');
  JAI_loadData( cfg );
  
  % Segmentation of the hilbert phase data trials for PLV estimation %%%%%%
  % split the data of every condition into subtrials with a length of 5
  % seconds
  cfg           = [];
  cfg.length    = 5;
  
  fprintf('Segmentation of Hilbert phase data at 2 Hz.\n');
  data_hseg_2Hz  = JAI_segmentation( cfg, data_hilbert_2Hz );
  fprintf('\n');
  
  fprintf('Segmentation of Hilbert phase data at 10 Hz.\n');
  data_hseg_10Hz  = JAI_segmentation( cfg, data_hilbert_10Hz );
  fprintf('\n');
  
  fprintf('Segmentation of Hilbert phase data at 20 Hz.\n');
  data_hseg_20Hz  = JAI_segmentation( cfg, data_hilbert_20Hz );
  fprintf('\n');
  
  % export the segmented hilbert (2 Hz, 10 Hz, 20 Hz) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');
  cfg.filename    = sprintf('JAI_d%02d_07a_hseg2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (2Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hseg_2Hz', data_hseg_2Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_2Hz
  
  cfg.filename    = sprintf('JAI_d%02d_07a_hseg10Hz', i);
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (10Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hseg_10Hz', data_hseg_10Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_10Hz
  
  cfg.filename    = sprintf('JAI_d%02d_07a_hseg20Hz', i);
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (20Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_hseg_20Hz', data_hseg_20Hz);
  fprintf('Data stored!\n');
  clear data_hilbert_20Hz
    
  % Artifact rejection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '05c_allart/');
    cfg.filename    = sprintf('JAI_d%02d_05c_allart', i);
    cfg.sessionStr  = sessionStr;
  
    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
    if ~isempty(dir(file_path))
      fprintf('\nLoading %s ...\n', file_path);
      JAI_loadData( cfg );                                                  
      artifactAvailable = true;     
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactAvailable = false;
    end
  end
  
  if artifactRejection == true                                              % artifact rejection
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.type      = 'dual';
  
      fprintf('Artifact Rejection of Hilbert phase data at 2 Hz.\n');
      data_hseg_2Hz = JAI_rejectArtifacts(cfg, data_hseg_2Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 10 Hz.\n');
      data_hseg_10Hz = JAI_rejectArtifacts(cfg, data_hseg_10Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 20 Hz.\n');
      data_hseg_20Hz = JAI_rejectArtifacts(cfg, data_hseg_20Hz);
      fprintf('\n');
      
      clear cfg_allArt
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% PLV and mPLV calculation
  % calculate PLV and meanPLV at 2Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 5;                                                        % window length for one PLV value in seconds
  
  data_plv_2Hz  = JAI_phaseLockVal(cfg, data_hseg_2Hz);
  data_mplv_2Hz = JAI_calcMeanPLV(data_plv_2Hz);
  clear data_hseg_2Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('JAI_d%02d_07b_plv2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_plv_2Hz', data_plv_2Hz);
  fprintf('Data stored!\n');
  clear data_plv_2Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('JAI_d%02d_07c_mplv2Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (2Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplv_2Hz', data_mplv_2Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_2Hz

  % calculate PLV and meanPLV at 10Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_10Hz  = JAI_phaseLockVal(cfg, data_hseg_10Hz);
  data_mplv_10Hz = JAI_calcMeanPLV(data_plv_10Hz);
  clear data_hseg_10Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('JAI_d%02d_07b_plv10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_plv_10Hz', data_plv_10Hz);
  fprintf('Data stored!\n');
  clear data_plv_10Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('JAI_d%02d_07c_mplv10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplv_10Hz', data_mplv_10Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_10Hz
  
  % calculate PLV and meanPLV at 20Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_20Hz  = JAI_phaseLockVal(cfg, data_hseg_20Hz);
  data_mplv_20Hz = JAI_calcMeanPLV(data_plv_20Hz);
  clear data_hseg_20Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('JAI_d%02d_07b_plv20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_plv_20Hz', data_plv_20Hz);
  fprintf('Data stored!\n');
  clear data_plv_20Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('JAI_d%02d_07c_mplv20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplv_20Hz', data_mplv_20Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_20Hz
end

%% clear workspace
clear cfg file_path sourceList numOfSources i artifactRejection ...
      artifactAvailable x choise
