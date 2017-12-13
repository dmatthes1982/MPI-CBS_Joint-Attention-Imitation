%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
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

%% part 5
% segmentation, auto artifact detection (threshold +-75 uV) and manual 
% artifact detection (verification)

for i = numOfPart
  % segmentation of the preprocessed trials
  % split the data of every condition into subtrials with a length of 5 
  % seconds
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preproc data...\n');
  JAI_loadData( cfg );
  
  % automatic artifact detection (threshold +-75 uV)
  cfg             = [];
  cfg.length      = 5000;                                                   % window length: 5 sec       
  cfg.overlap     = 0;                                                      % no overlap
  trl             = JAI_genTrl(cfg, data_preproc);                          % define artifact detection intervals
  
  cfg             = [];
  cfg.chan        = {'Cz', 'O1', 'O2'};
  cfg.continuous  = 'no';                                                   % data is trial-based
  cfg.trl         = trl;
  cfg.method      = 0;                                                      % method: maxmin threshold
  cfg.minVal      = -75;                                                    % min: -75 uV
  cfg.maxVal      = 75;                                                     % max: 75 uV

  cfg_autoart     = JAI_autoArtifact(cfg, data_preproc);
  
  % verify automatic detected artifacts / manual artifact detection
  cfg           = [];
  cfg.artifact  = cfg_autoart;
  
  cfg_allart    = JAI_manArtifact(cfg, data_preproc);                           
  
  % export the automatic selected artifacts into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05a_autoart/');
  cfg.filename    = sprintf('JAI_d%02d_05a_autoart', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('\nThe automatic selected artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'cfg_autoart', cfg_autoart);
  fprintf('Data stored!\n');
  clear cfg_autoart data_preproc trl
  
  % export the verified and the additional artifacts into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05b_allart/');
  cfg.filename    = sprintf('JAI_d%02d_05b_allart', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The visual verified artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'cfg_allart', cfg_allart);
  fprintf('Data stored!\n\n');
  clear cfg_allart
  
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
