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
% 1. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 2. Verify the estimated components by using the ft_databrowser function
% 3. Remove eye artifacts
% 4. Recovery of bad channels
% 5. Re-referencing

cprintf([0,0.6,0], '<strong>[4] - Preproc II: eye artifacts correction, bad channel recovery, re-referencing</strong>\n');
fprintf('\n');

% favoured reference
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select favoured reference:\n');
% fprintf('[1] - Linked mastoid (''TP9'', ''TP10'')\n');
  fprintf('[1] - Common average reference\n');
  x = input('Option: ');

  switch x
%   case 1
%     selection = true;
%     refchannel = 'TP10';
%     reference = {'LM'};
    case 1
      selection = true;
      refchannel = {'all', '-V1', '-V2'};
      reference = {'CAR'};
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

% correlation threshold
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

% Create settings if not existing
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
T.reference(numOfPart)    = reference;
T.ICAcorrVal1(numOfPart)  = threshold(1);
T.ICAcorrVal2(numOfPart)  = threshold(2);
warning on;

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);

  %% Eye artifact correction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Eye artifact correction</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('JAI_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;

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

  % store settings table
  delete(settings_file);
  writetable(T, settings_file);

  % load basic bandpass filtered data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('JAI_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load bandpass filtered data...\n');
  JAI_loadData( cfg );
  
  % remove eye artifacts
  data_eyecor = JAI_removeEOGArt(data_eogcomp, data_preproc1);
  
  clear data_eogcomp data_preproc1
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

  %% Recovery of bad channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Bad channel recovery</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('JAI_d%02d_02a_badchan', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load bad channels specification...\n');
  JAI_loadData( cfg );

  data_eyecor = JAI_repairBadChan( data_badchan, data_eyecor );
  clear data_badchan

  %% re-referencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Rereferencing</strong>\n');

  cfg                   = [];
  cfg.refchannel        = refchannel;

  ft_info off;
  data_preproc2 = JAI_reref( cfg, data_eyecor);
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04c_preproc2/');
  cfg.filename    = sprintf('JAI_d%02d_04c_preproc2', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The clean and re-referenced data of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_preproc2', data_preproc2);
  fprintf('Data stored!\n\n');
  clear data_preproc2 data_eyecor data_badchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i threshold selection x T ...
      settings_file EOGcompPart1 EOGcompPart2 reference refchannel
