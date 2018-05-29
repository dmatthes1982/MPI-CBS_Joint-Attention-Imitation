%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04b_eyecor/';
  cfg.filename  = 'JAI_d01_04b_eyecor';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
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

%% part 5
% 1. auto artifact detection (threshold and method is selectable - default: 'minmax', +-75 uV)
% 2. manual artifact detection (verification)

cprintf([0,0.6,0], '<strong>[5] - Automatic and manual artifact detection</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default threshold (+-75uV) for automatic artifact detection?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    threshold = 75;
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
    cprintf([0,0.6,0], 'Specify the absolut value (in uV) of the threshold limits in a range between 50 and 200!\n');
    cprintf([0,0.6,0], 'i.e.: value 100 means threshold limits are +-100uV\n');
    x = input('Value: ');
    if isnumeric(x)
      if (x < 50 || x > 200)
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
warning off;
T.artThreshold(numOfPart) = threshold;
warning on;
delete(file_path);
writetable(T, file_path);

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('JAI_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('<strong>Dyad %d</strong>\n', i);
  fprintf('Load eye-artifact corrected data...\n');
  JAI_loadData( cfg );
  
  % automatic artifact detection (threshold +-75 uV)
  cfg             = [];
  cfg.channel     = {'all', '-V1', '-V2', '-REF', ...
                     '-EOGV', '-EOGH'};
  cfg.method      = 'minmax';
  cfg.sliding     = 'no';
  cfg.winsize     = 1000;
  cfg.continuous  = 'no';                                                   % data is trial-based
  cfg.trllength   = 1000;                                                   % minimal subtrial length: 1 sec
  cfg.overlap     = 0;                                                      % no overlap
  cfg.min         = -threshold;                                             % min: -threshold uV
  cfg.max         = threshold;                                              % max: threshold uV
  cfg.range       = threshold;                                              % range: threshold uV
  cfg.stddev      = threshold;                                              % stddev: threshold uV
  cfg.mad         = threshold;                                              % mad: multiples of median absolute deviation

  cfg_autoart     = JAI_autoArtifact(cfg, data_eyecor);
  
  % verify automatic detected artifacts / manual artifact detection
  cfg           = [];
  cfg.artifact  = cfg_autoart;
  cfg.dyad      = i;
  
  cfg_allart    = JAI_manArtifact(cfg, data_eyecor);                           
  
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
  clear cfg_autoart data_eyecor trl
  
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
clear file_path numOfSources sourceList cfg i x selection T threshold
