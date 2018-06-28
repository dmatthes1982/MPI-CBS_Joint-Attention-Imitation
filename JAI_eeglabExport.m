% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
JAI_init;

cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export raw data to eeglab format</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.1</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';
desPath = '/data/pt_01826/eegData/DualEEG_JAI_eeglabExport/';

fprintf('\nThe default paths are:\n');
fprintf('Source: %s\n',srcPath);
fprintf('Destination: %s\n',desPath);

selection = false;
while selection == false
  fprintf('\nDo you want to select the default paths?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  srcPath = uigetdir(pwd, 'Select Source Folder...');
  desPath = uigetdir(strcat(srcPath,'/..'), ...
                      'Select Destination Folder...');
  srcPath = strcat(srcPath, '/');
  desPath = strcat(desPath, '/');
end

if ~exist(strcat(desPath, '01_fieldtrip'), 'dir')
  mkdir(strcat(desPath, '01_fieldtrip'));
end

if ~exist(strcat(desPath, '02_eeglab'), 'dir')
  mkdir(strcat(desPath, '02_eeglab'));
end

% -------------------------------------------------------------------------
% Specific selection of dyads
% -------------------------------------------------------------------------
sourceList    = dir([srcPath, '/*.vhdr']);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
fileNum       = zeros(1, numOfSources);

for i=1:1:numOfSources
  fileNum(i)     = sscanf(sourceList{i}, 'DualEEG_JAI_%d.vhdr');
end

y = sprintf('%d ', fileNum);

selection = false;
while selection == false
  fprintf('\nThe following participants are available: \n%s\n', y);
  fprintf(['Comma-seperate your selection and put it in squared ' ...
           'brackets!\n']);
  x = input('\nPlease make your choice! (i.e. [1,2,3]): ');

  if ~all(ismember(x, fileNum))
    cprintf([1,0.5,0], 'Wrong input!\n');
  else
    selection = true;
    numOfPart = x;
  end
end

fprintf('\n');

% -------------------------------------------------------------------------
% Import data from brain vision eeg files
% -------------------------------------------------------------------------
for dyad = numOfPart
  cfg               = [];
  cfg.path          = srcPath;
  cfg.dyad          = dyad;
  cfg.continuous    = 'no';
  cfg.prestim       = 15;
  cfg.rejectoverlap = 'no';
  
  fprintf('<strong>Import data of dyad %d</strong> from: %s ...\n', dyad, cfg.path);
  ft_info off;
  data_raw = JAI_importDataset( cfg );
  ft_info on;
  
  % Keep only necessary conditions in the dataset
  cfg         = [];
  cfg.channel = 'all';
  cfg.trials  = [111,2,3,4,5,6];
  
  data_raw = JAI_selectdata( cfg, data_raw );
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01_fieldtrip/');
  cfg.filename    = sprintf('JAI_d%02d_01_fieldtrip', dyad);
  cfg.sessionStr  = '001';

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', dyad); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw  
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Convert data from fieldtrip format to eeglab format
% Put every participant and every condition into a seperate file
% -------------------------------------------------------------------------
for dyad = numOfPart
  fprintf('<strong>Convert data into eeglab format\n</strong>');
  fprintf('<strong>Dyad %d</strong>\n\n', dyad);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_fieldtrip/');
  cfg.filename    = sprintf('JAI_d%02d_01_fieldtrip', dyad);
  cfg.sessionStr  = '001';
    
  fprintf('Load fieldtrip data...\n\n');
  JAI_loadData( cfg );
  
  numOfTrials = length(data_raw.part1.trialinfo);                           % Note: data of part 1 and part 2 were recorded synchronously 
  trialinfo = data_raw.part1.trialinfo;
  
  for part = 1:1:2
    fprintf('<strong>Participant %d</strong>\n', part);
    for trl = 1:1:numOfTrials
      condNum     = trialinfo(trl);
      pos         = ismember(generalDefinitions.condNum, condNum);
      condString  = generalDefinitions.condString{pos};
      fprintf('Convert trial of condition %s...\n', condString);
      
      % export selected trial into a separate dataset
      cfg         = [];
      cfg.channel = 'all';
      cfg.trials  = condNum;
  
      data = JAI_selectdata( cfg, data_raw );
      eval(sprintf('data = data.part%d;', part));
      
      % Generate eeglab EEG structure
      EEG               = [];
      EEG.setname       = sprintf('JAI dyad: %d - participant: %d - condition: %s', dyad, part, condString);
      EEG.filename      = sprintf('JAI_d%02d_p%02d_%s.set', dyad, part, condString);
      EEG.filepath      = [desPath '02_eeglab'];
      EEG.subject       = '';
      EEG.group         = '';
      EEG.condition     = sprintf('%s', condString);
      EEG.session       = [];
      EEG.comments      = 'preprocessed with fieldtrip';
      EEG.nbchan        = size(data.trial{1},1);
      EEG.trials        = size(data.trial,2);
      EEG.pnts          = size(data.trial{1},2);
      EEG.srate         = data.fsample;
      EEG.xmin          = data.time{1}(1);
      EEG.xmax          = data.time{1}(end);
      EEG.times         = data.time{1};
      EEG.ref           = 'unknown';
      EEG.event         = [];
      EEG.epoch         = [];
      EEG.icawinv       = [];
      EEG.icasphere     = [];
      EEG.icaweights    = [];
      EEG.icaact        = [];
      EEG.saved         = 'no';
      EEG.datfile       = sprintf('DualEEG_JAI_%02d.eeg', dyad);
      EEG.data(:,:,1)   = single(data.trial{1});       
      
      for i = 1:1:length(data.label)
        EEG.chanlocs(i).labels = data.label{i};
      end
      
      fprintf('The converted data of participant %d in dyad %d in condition %s will be saved in:\n', ...
              part, dyad, condString);
      fprintf('%s ...\n', [EEG.filepath '/' EEG.filename]);      
      save([EEG.filepath '/' EEG.filename], 'EEG');
      fprintf('Data stored!\n\n');
    end
  end
  
  clear data_raw
  
end

fprintf('<strong>Fieldtrip to eeglab dataset convertion successfully completed!\n</strong>');

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear desPath newPaths selection srcPath i x y sourceList numOfSources ...
      fileNum numOfPart cfg file_path condNum condString data dataCond ...
      dyad EEG filepath generalDefinitions numOfTrials part pos ...
      trialinfo trl
