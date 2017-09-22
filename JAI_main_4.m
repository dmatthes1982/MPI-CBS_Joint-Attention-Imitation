%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04_seg1/';
  cfg.filename  = 'JAI_p01_04_seg1';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '04_seg1/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_p%d_04_seg1_', sessionStr, '.mat'));
  end
end

%% auto artifact detection (threshold +-75 uV)
% verify automatic detected artifacts / manual artifact detection
% export the automatic selected artifacts into a *.mat file
% export the verified and the additional artifacts into a *.mat file

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04_seg1/');
  cfg.filename    = sprintf('JAI_p%02d_04_seg1', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load segmented data...\n');
  JAI_loadData( cfg );
  
  cfg           = [];
  cfg.chan      = {'Cz', 'O1', 'O2'};
  cfg.minVal    = -75;
  cfg.maxVal    = 75;

  cfg_autoArt   = JAI_autoArtifact(cfg, data_seg1);                         % auto artifact detection
  
  cfg           = [];
  cfg.artifact  = cfg_autoArt;
  
  cfg_allArt    = JAI_manArtifact(cfg, data_seg1);                          % manual artifact detection                           
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05_autoArt/');
  cfg.filename    = sprintf('JAI_p%02d_05_autoArt', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('\nThe automatic selected artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'cfg_autoArt', cfg_autoArt);
  fprintf('Data stored!\n');
  clear cfg_autoArt data_seg1
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06_allArt/');
  cfg.filename    = sprintf('JAI_p%02d_06_allArt', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The visual verified artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'cfg_allArt', cfg_allArt);
  fprintf('Data stored!\n\n');
  clear cfg_allArt
  
  if(i < max(numOfPart))
    selection = false;
    while selection == false
      fprintf('Proceed with the next dyad?\n');
      x = input('\nSelect [y/n]: ','s');
      if strcmp('y', x)
        selection = true;
      elseif strcmp('n', x)
        clear file_path numOfSources sourceList cfg i x selection
        return;
      else
        selection = false;
      end
    end
    fprintf('\n');
  end
end

%% clear workspace
clear file_path numOfSources sourceList cfg i x selection
