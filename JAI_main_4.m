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

selection = false;
while selection == false
  fprintf('Do you want to use the default threshold (0.8) for EOG-artifact estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    threshold = 0.8;
  elseif strcmp('n', x)
    selection = true;
    threshold = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(threshold)
  selection = false;
  while selection == false
    fprintf('\nSpecify a threshold value in a range between 0 and 1!\n');
    x = input('Value: ');
    if isnumeric(x)
      if (x < 0 || x > 1)
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      else
        threshold = x;
        selection = true;
      end
    else
      cprintf([1,0.5,0], 'Wrong input!\n');
      selection = false;
    end
  end
fprintf('\n');  
end

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
delete(file_path);
warning off;
T.ICAcorrVal(numOfPart) = threshold;
warning on;
writetable(T, file_path);

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('JAI_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load ICA result...\n');
  JAI_loadData( cfg );
  
  cfg.srcFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('JAI_d%02d_03b_eogchan', i);
  
  fprintf('Load EOG data...\n\n');
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
    
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n');
  JAI_loadData( cfg );
  
  % Remove eye artifacts
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

%% clear workspace
clear file_path cfg sourceList numOfSources i threshold selection x T
