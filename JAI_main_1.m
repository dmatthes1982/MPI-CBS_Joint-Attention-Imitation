%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '011_raw/';
  cfg.filename  = 'JAI_d01_011_raw';
  sessionNum    = JAI_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';                  % source path to raw data
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'DualEEG_JAI_%d.vhdr');
  end
end

%% part 1
% 1. import data from brain vision eeg files and bring it into an order

cprintf([0,0.6,0], '<strong>[1] - Data import</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to import the data without a pre-stimulus offset? (DEFAULT)\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    prestim = 0;
  elseif strcmp('n', x)
    selection = true;
    prestim = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(prestim)
  selection = false;                                                        % specify a pre-stimulus offset
  while selection == false
    cprintf([0,0.6,0], 'Specify a pre-stimulus offset between 0 and 30 seconds!\n', i);
    x = input('Value: ');
    if isnumeric(x)
      if (x < 0 || x > 30)
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      else
        prestim = x;
        selection = true;
      end
    else
      cprintf([1,0.5,0], 'Wrong input!\n');
      selection = false;
    end
  end
fprintf('\n');
end

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Select channels, which are NOT of interest?\n');
  fprintf('[1] - import all channels\n');
  fprintf('[2] - reject T7, T8, PO9, PO10, P7, P8, TP10\n');
  fprintf('[3] - reject specific selection\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      noichan = [];
      noichanStr = {'---'};
    case 2
      selection = true;
      noichan = {'T7', 'T8', 'PO9', 'PO10', 'P7', 'P8', 'TP10'};
      noichanStr = {'-T7,-T8,-PO9,-PO10,-P7,-P8,-TP10'};
    case 3
      selection = true;
      cprintf([0,0.6,0], '\nAvailable channels will be determined. Please wait...\n');

      load('layouts/mpi_customized_acticap32.mat', 'lay')
      label = lay.label(1:end-2);
      loc   = ~ismember(label, {'V1', 'V2', 'F9', 'F10'});                  % remove EOG-related electrodes from options to avoid errors
      label = label(loc);

      sel = listdlg('PromptString', ...                                     % open the dialog window --> the user can select the channels wich are not of interest
              'Which channels are NOT of interest...', ...
              'ListString', label, ...
              'ListSize', [220, 300] );

      noichan = label(sel)';
      channels = {strjoin(noichan,',')};

      fprintf('You have unselected the following channels:\n');
      fprintf('%s\n', channels{1});

      noichanStr = cellfun(@(x) strcat('-', x), noichan, ...
                          'UniformOutput', false);
      noichanStr = {strjoin(noichanStr,',')};
      clear channels label loc sel
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;

  JAI_createTbl(cfg);                                                       % create settings file
end

% Load settings file
T = readtable(settings_file);
warning off;
T.dyad(numOfPart)     = numOfPart;
T.noiChan(numOfPart)  = noichanStr;
T.prestim(numOfPart)  = prestim;
warning on;

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  cfg               = [];
  cfg.path          = srcPath;
  cfg.dyad          = i;
  cfg.noichan       = noichan;
  cfg.continuous    = 'no';
  cfg.prestim       = prestim;
  cfg.rejectoverlap = 'yes';
  
  fprintf('<strong>Import data of dyad %d</strong> from: %s ...\n', i, cfg.path);
  ft_info off;
  data_raw = JAI_importDataset( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01_raw/');
  cfg.filename    = sprintf('JAI_d%02d_01_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
end

% store settings table
delete(settings_file);
writetable(T, settings_file);

%% clear workspace
clear file_path cfg sourceList numOfSources i T settings_file prestim ...
      lay noichan noichanStr
