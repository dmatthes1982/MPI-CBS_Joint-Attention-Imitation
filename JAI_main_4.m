%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03b_eogchan/';
  cfg.filename  = 'JAI_d01_03b_eogchan';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eogcomp data folder
  sourceList    = dir([strcat(desPath, '03b_eogchan/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_03b_eogchan_', sessionStr, '.mat'));
  end
end

%% part 4
% Estimation and correction of eye artifacts
% Processing steps:
% 1. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 2. Verify the estimated components by using the ft_databrowser function
% 3. Remove eye artifacts

cprintf([0,0.6,0], '<strong>[4] - Estimation and correction of eye artifacts</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default threshold (0.8) for EOG-artifact estimation for both participants?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    threshold = [0.8 0.8];
  elseif strcmp('n', x)
    selection = true;
    threshold = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(threshold)
  for i = 1:1:2                                                             % specify a independent threshold for each participant
    selection = false;
    while selection == false
      cprintf([0,0.6,0], 'Specify a threshold value for participant %d in a range between 0 and 1!\n', i);
      x = input('Value: ');
      if isnumeric(x)
        if (x < 0 || x > 1)
          cprintf([1,0.5,0], 'Wrong input!\n');
          selection = false;
        else
          threshold(i) = x;
          selection = true;
        end
      else
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      end
    end
  end
fprintf('\n');  
end

% Write selected settings to settings file
settings_file = [desPath '00_settings/' ...
                          sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  JAI_createTbl(cfg);                                                       % create settings file
end

T = readtable(settings_file);                                               % update settings table
warning off;
T.ICAcorrVal1(numOfPart) = threshold(1);
T.ICAcorrVal2(numOfPart) = threshold(2);
warning on;

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('JAI_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('<strong>Dyad %d</strong>\n', i);
  fprintf('Load ICA result...\n');
  JAI_loadData( cfg );
  
  cfg.srcFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('JAI_d%02d_03b_eogchan', i);
  
  fprintf('Load original EOG channels...\n\n');
  JAI_loadData( cfg );
  
  % Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
  % confirmity)
  cfg         = [];
  cfg.threshold = threshold;
  
  data_eogcomp      = JAI_corrComp(cfg, data_icacomp, data_eogchan);
  
  clear data_eogchan
  fprintf('\n');
  
  % Verify the estimated components
  data_eogcomp      = JAI_verifyComp(data_eogcomp, data_icacomp);
  
  clear data_icacomp
  fprintf('\n');

  % export the determined eog components and the unmixing matrix into 
  % a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04a_eogcomp/');
  cfg.filename    = sprintf('JAI_d%02d_04a_eogcomp', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The eye-artifact related components and the unmixing matrix of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_eogcomp', data_eogcomp);
  fprintf('Data stored!\n\n');

  % add eye-artifact related components to the settings file
  if isempty(data_eogcomp.part1.elements)
    EOGcompPart1 = {'---'};
  else
    EOGcompPart1 = {strjoin(data_eogcomp.part1.elements,',')};
  end
  if isempty(data_eogcomp.part2.elements)
    EOGcompPart2 = {'---'};
  else
    EOGcompPart2 = {strjoin(data_eogcomp.part2.elements,',')};
  end
  warning off;
  T.EOGcompPart1(i) = EOGcompPart1;
  T.EOGcompPart2(i) = EOGcompPart2;
  warning on;

  % load preprocessed data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n');
  JAI_loadData( cfg );
  
  % remove eye artifacts
  data_eyecor = JAI_removeEOGArt(data_eogcomp, data_preproc);
  
  clear data_eogcomp data_preproc
  fprintf('\n');
  
  % export the reviced data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('JAI_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The reviced data (from eye artifacts) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_eyecor', data_eyecor);
  fprintf('Data stored!\n\n');
  clear data_eyecor
end

% store settings table
delete(settings_file);
writetable(T, settings_file);

%% clear workspace
clear file_path cfg sourceList numOfSources i threshold selection x T ...
      settings_file EOGcompPart1 EOGcompPart2
