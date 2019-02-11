%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01_raw/';
  cfg.filename  = 'JAI_d01_01_raw';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in repaired data folder
  sourceList    = dir([strcat(desPath, '01_raw/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_01_raw_', sessionStr, '.mat'));
  end
end

%% part 2
% 1. select bad/noisy channels
% 2. filter the good channels (basic bandpass filtering)

cprintf([0,0.6,0], '<strong>[2] - Preproc I: bad channel detection, filtering</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select your favoured bandpass for preprocessing:\n');
  fprintf('[1] - Regular bandpass 1...48 Hz \n');
  fprintf('[2] - Extended bandpass 0.3...48 Hz \n');
  fprintf('[3] - Extended bandpass 1...98 Hz with dft filter for line noise removal\n');
  fprintf('[4] - Manual selection\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      bpRange = [1 48];
      bandpass = {'[1 48]'};
      lnRemoval = 'no';
      lineNoiseFilt = {'n'};
    case 2
      selection = true;
      bpRange = [0.3 48];
      bandpass = {'[0.3 48]'};
      lnRemoval = 'no';
      lineNoiseFilt = {'n'};
    case 3
      selection = true;
      bpRange = [1 98];
      bandpass = {'[1 98]'};
      lnRemoval = 'yes';
      lineNoiseFilt = {'y'};
    case 4
      selection = true;
       bpRange = [];
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

if isempty(bpRange)                                                         % manual bandpass selection
  fig = uifigure( 'Position',[0 0 400 175],...
                  'Name','Select Bandpass');
  movegui(fig, 'center');

  txt = uilabel(fig,...
                'Position',[50 125 300 25],...
                'Text','Click the save button when you''re done.',...
                'HorizontalAlignment','center');                            %#ok<NASGU>

  hp = uieditfield( fig,'numeric',...
                    'Value', 0.1,...
                    'ValueDisplayFormat','%.2f',...
                    'Limits', [0.1 48],...
                    'Position',[75 95 100 25]);

  lp = uieditfield( fig,'numeric',...
                    'Value', 48,...
                    'Limits', [0.1 48],...
                    'ValueDisplayFormat','%.2f',...
                    'Position',[225 95 100 25]);

  hp.ValueChangedFcn = @(hp,event)hpChanged(hp,lp);
  lp.ValueChangedFcn = @(lp,event)lpChanged(hp,lp);

  notch = uicheckbox( fig,...
                      'Position',[148 60 110 25],...
                      'Text', '50 Hz notch filter');

  save = uibutton(fig,...
                   'Position',[150 25 100 25],...
                   'Text','Save');

  save.ButtonPushedFcn = @(save,event)SaveButtonPushed(fig);

  uiwait(fig);

  if ishandle(fig)
    bpRange = [hp.Value lp.Value];
    bandpass = { sprintf('[%g %g]', bpRange)};
    if notch.Value == true
      lnRemoval = 'yes';
      lineNoiseFilt = {'y'};
    else
      lnRemoval = 'no';
      lineNoiseFilt = {'n'};
    end
    close(fig);
  else
    bpRange = [0.1 48];
    bandpass = {'[0.1 48]'};
    lnRemoval = 'no';
    lineNoiseFilt = {'n'};
  end
clear fig txt hp lp save notch
end

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
T.bandpass(numOfPart) = bandpass;
T.lineNoiseFilt(numOfPart) = lineNoiseFilt;
warning on;

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);

  %% selection of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Selection of corrupted channels</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_raw/');
  cfg.filename    = sprintf('JAI_d%02d_01_raw', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load raw data...\n');
  JAI_loadData( cfg );

  % concatenated raw trials to a continuous stream
  data_continuous = JAI_concatData( data_raw );

  fprintf('\n');

  % detect noisy channels automatically
  data_noisy = JAI_estNoisyChan( data_continuous );

  fprintf('\n');

  % select corrupted channels
  data_badchan = JAI_selectBadChan( data_continuous, data_noisy );
  clear data_noisy

  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('JAI_d%02d_02a_badchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Bad channels of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_badchan', data_badchan);
  fprintf('Data stored!\n\n');
  clear data_continuous

  % add bad labels of bad channels to the settings file
  if isempty(data_badchan.part1.badChan)
    badChanPart1 = {'---'};
  else
    badChanPart1 = {strjoin(data_badchan.part1.badChan,',')};
  end
  if isempty(data_badchan.part2.badChan)
    badChanPart2 = {'---'};
  else
    badChanPart2 = {strjoin(data_badchan.part2.badChan,',')};
  end
  warning off;
  T.badChanPart1(i) = badChanPart1;
  T.badChanPart2(i) = badChanPart2;
  warning on;

  % store settings table
  delete(settings_file);
  writetable(T, settings_file);

  %% basic bandpass filtering of good channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Basic preprocessing of good channels</strong>\n');
  
  cfg                   = [];
  cfg.bpfreq            = bpRange;                                          % passband from 1 to 48 Hz or other selection
  cfg.bpfilttype        = 'but';
  cfg.bpinstabilityfix  = 'split';
  cfg.dftfilter         = lnRemoval;                                        % dft filter for additional line noise removal
  cfg.dftfreq           = [50 100 150];
  cfg.part1BadChan      = data_badchan.part1.badChan';
  cfg.part2BadChan      = data_badchan.part2.badChan';
  
  ft_info off;
  data_preproc1 = JAI_preprocessing( cfg, data_raw);
  ft_info on;
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('JAI_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_preproc1', data_preproc1);
  fprintf('Data stored!\n\n');
  clear data_preproc1 data_raw data_badchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i selection x T  bandpass ...
      bpRange lineNoiseFilt lnRemoval badChanPart1 badChanPart2 ...
      settings_file

%% callback functions
function hpChanged(hp,lp)
  lp.Limits = [hp.Value 48];
end

function lpChanged(hp,lp)
  hp.Limits = [0.1 lp.Value];
end

function SaveButtonPushed(fig)
  uiresume(fig);
end
