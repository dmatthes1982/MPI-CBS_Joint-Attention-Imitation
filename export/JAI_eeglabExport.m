% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
run('../JAI_init.m');

cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export raw data to eeglab format</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.1</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01826/eegData/DualEEG_JAI_processedDataOld/';
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

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(srcPath, '04b_eyecor/');

sessionList     = dir([tmpPath, 'JAI_d*_04b_eyecor_*.mat']);
sessionList     = struct2cell(sessionList);
sessionList     = sessionList(1,:);
numOfSessions   = length(sessionList);

sessionNum      = zeros(1, numOfSessions);
sessionListCopy = sessionList;

for i=1:1:numOfSessions
  sessionListCopy{i} = strsplit(sessionList{i}, '04b_eyecor_');
  sessionListCopy{i} = sessionListCopy{i}{end};
  sessionNum(i) = sscanf(sessionListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(sessionListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, sessionList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i = sessionNum
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
  fprintf('Please select one session or create a new one:\n');
  fprintf('[0] - Create new session\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      sessionStr = sprintf('%03d', x);
    elseif x == 0  
      selection = true;
      if ~isempty(max(sessionNum))
        sessionStr = sprintf('%03d', max(sessionNum) + 1);
      else
        sessionStr = sprintf('%03d', 1);
      end
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

clear tmpPath sessionListCopy userList match filePath cmdout attrib ...
      sessionList sessionNum numOfSessions

% -------------------------------------------------------------------------
% Dyad list
% -------------------------------------------------------------------------
sourceList    = dir([strcat(srcPath, '04b_eyecor/'), ...
                     strcat('*_', sessionStr, '.mat')]);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
numOfPart     = zeros(1, numOfSources);

for i=1:1:numOfSources
  numOfPart(i)     = sscanf(sourceList{i}, ...
                   strcat('JAI_d%d_04b_eyecor_', sessionStr, '.mat'));
end

y = sprintf('%d ', numOfPart);
fprintf('\nThe following dyads will be exported:\n');
fprintf('%s\n\n', y);

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Convert data from fieldtrip format to eeglab format
% Put every participant and every condition into a seperate file
% -------------------------------------------------------------------------
for dyad = numOfPart
  fprintf('<strong>Convert data into eeglab format\n</strong>');
  fprintf('<strong>Dyad %d</strong>\n\n', dyad);
  
  cfg             = [];
  cfg.srcFolder   = strcat(srcPath, '04b_eyecor/');
  cfg.filename    = sprintf('JAI_d%02d_04b_eyecor', dyad);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load eye-artifact corrected data...\n\n');
  JAI_loadData( cfg );
  
  trialinfo = [111, 2, 3, 4, 5, 6];
  trialinfo = trialinfo(ismember(trialinfo, data_eyecor.part1.trialinfo));  % Note: data of part 1 and part 2 were recorded synchronously 
  numOfTrials = length(trialinfo);
  
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
  
      data = JAI_selectdata( cfg, data_eyecor );
      eval(sprintf('data = data.part%d;', part));
      
      % Generate eeglab EEG structure
      EEG               = [];
      EEG.setname       = sprintf('JAI dyad: %d - participant: %d - condition: %s', dyad, part, condString);
      EEG.filename      = sprintf('JAI_d%02d_p%02d_%d_%s.set', dyad, part, condNum, condString);
      EEG.filepath      = desPath;
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
      EEG.ref           = 'common';
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
      fprintf('%s ...\n', [EEG.filepath EEG.filename]);
      save([EEG.filepath EEG.filename], 'EEG');
      fprintf('Data stored!\n\n');
    end
  end
  
  clear data_eyecor
  
end

fprintf('<strong>Fieldtrip to eeglab dataset convertion successfully completed!\n</strong>');

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear desPath newPaths selection srcPath i x y sourceList numOfSources ...
      fileNum numOfPart cfg file_path condNum condString data dataCond ...
      dyad EEG filepath generalDefinitions numOfTrials part pos ...
      trialinfo trl sessionStr
