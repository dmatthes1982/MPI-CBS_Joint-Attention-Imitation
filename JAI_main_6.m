%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '08_hilbert/';
  cfg.filename  = 'JAI_p01_08d_hilbert40Hz';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '08_hilbert/'), ...
                       strcat('*40Hz_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_p%d_08d_hilbert40Hz_', sessionStr, '.mat'));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    selection = true;
    artifactRejection = false;
  else
    selection = false;
  end
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLV and mPLV calculation

for i = numOfPart
  fprintf('Dyad %d\n', i);
  
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '06_allArt/');
    cfg.filename    = sprintf('JAI_p%02d_06_allArt', i);
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
  
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '08_hilbert/');
  cfg.sessionStr  = sessionStr;
  
  cfg.filename    = sprintf('JAI_p%02d_08a_hilbert2Hz', i);
  fprintf('Load hilbert phase data at 2 Hz...\n');
  JAI_loadData( cfg );

  cfg.filename    = sprintf('JAI_p%02d_08b_hilbert10Hz', i);
  fprintf('Load hilbert phase data at 10 Hz...\n');
  JAI_loadData( cfg );
  
  cfg.filename    = sprintf('JAI_p%02d_08c_hilbert20Hz', i);
  fprintf('Load hilbert phase data at 20 Hz...\n');
  JAI_loadData( cfg );
  
  cfg.filename    = sprintf('JAI_p%02d_08d_hilbert40Hz', i);
  fprintf('Load hilbert phase data at 40 Hz...\n\n');
  JAI_loadData( cfg );
  
  if artifactRejection == true                                              % artifact rejection
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allArt;
  
      fprintf('Artifact Rejection of Hilbert phase data at 2 Hz.\n');
      data_hilbert_2Hz = JAI_rejectArtifacts(cfg, data_hilbert_2Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 10 Hz.\n');
      data_hilbert_10Hz = JAI_rejectArtifacts(cfg, data_hilbert_10Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 20 Hz.\n');
      data_hilbert_20Hz = JAI_rejectArtifacts(cfg, data_hilbert_20Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 40 Hz.\n');
      data_hilbert_40Hz = JAI_rejectArtifacts(cfg, data_hilbert_40Hz);
      fprintf('\n');
      
      clear cfg_allArt
    end
  end
  
  % calculate PLV and meanPLV at 2Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 5;                                                        % window length for one PLV value in seconds
  
  data_plv_2Hz  = JAI_phaseLockVal(cfg, data_hilbert_2Hz);
  data_mplv_2Hz = JAI_calcMeanPLV(data_plv_2Hz);
  clear data_hilbert_2Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('JAI_p%02d_09a_plv2Hz', i);
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
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('JAI_p%02d_10a_mplv2Hz', i);
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
  
  data_plv_10Hz  = JAI_phaseLockVal(cfg, data_hilbert_10Hz);
  data_mplv_10Hz = JAI_calcMeanPLV(data_plv_10Hz);
  clear data_hilbert_10Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('JAI_p%02d_09b_plv10Hz', i);
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
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('JAI_p%02d_10b_mplv10Hz', i);
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
  
  data_plv_20Hz  = JAI_phaseLockVal(cfg, data_hilbert_20Hz);
  data_mplv_20Hz = JAI_calcMeanPLV(data_plv_20Hz);
  clear data_hilbert_20Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('JAI_p%02d_09c_plv20Hz', i);
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
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('JAI_p%02d_10c_mplv20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplv_20Hz', data_mplv_20Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_20Hz
  
  % calculate PLV and meanPLV at 40Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_40Hz  = JAI_phaseLockVal(cfg, data_hilbert_40Hz);
  data_mplv_40Hz = JAI_calcMeanPLV(data_plv_40Hz);
  clear data_hilbert_40Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('JAI_p%02d_09d_plv40Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (40Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_plv_40Hz', data_plv_40Hz);
  fprintf('Data stored!\n');
  clear data_plv_40Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('JAI_p%02d_10d_mplv40Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (40Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplv_40Hz', data_mplv_40Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_40Hz
end

%% clear workspace
clear cfg file_path sourceList numOfSources i artifactRejection ...
      artifactAvailable x selection
