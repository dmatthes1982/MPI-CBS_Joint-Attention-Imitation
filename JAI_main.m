% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
JAI_init;

cprintf([0,0.6,0], '<strong>---------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project - data processing</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.3</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>---------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';
desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';

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

if ~exist(strcat(desPath, '00_settings'), 'dir')
  mkdir(strcat(desPath, '00_settings'));
end
if ~exist(strcat(desPath, '01a_raw'), 'dir')
  mkdir(strcat(desPath, '01a_raw'));
end
if ~exist(strcat(desPath, '01b_badchan'), 'dir')
  mkdir(strcat(desPath, '01b_badchan'));
end
if ~exist(strcat(desPath, '01c_repaired'), 'dir')
  mkdir(strcat(desPath, '01c_repaired'));
end
if ~exist(strcat(desPath, '02_preproc'), 'dir')
  mkdir(strcat(desPath, '02_preproc'));
end
if ~exist(strcat(desPath, '03a_icacomp'), 'dir')
  mkdir(strcat(desPath, '03a_icacomp'));
end
if ~exist(strcat(desPath, '03b_eogchan'), 'dir')
  mkdir(strcat(desPath, '03b_eogchan'));
end
if ~exist(strcat(desPath, '04a_eogcomp'), 'dir')
  mkdir(strcat(desPath, '04a_eogcomp'));
end
if ~exist(strcat(desPath, '04b_eyecor'), 'dir')
  mkdir(strcat(desPath, '04b_eyecor'));
end
if ~exist(strcat(desPath, '05a_autoart'), 'dir')
  mkdir(strcat(desPath, '05a_autoart'));
end
if ~exist(strcat(desPath, '05b_allart'), 'dir')
  mkdir(strcat(desPath, '05b_allart'));
end
if ~exist(strcat(desPath, '06a_bpfilt'), 'dir')
  mkdir(strcat(desPath, '06a_bpfilt'));
end
if ~exist(strcat(desPath, '06b_hilbert'), 'dir')
  mkdir(strcat(desPath, '06b_hilbert'));
end
if ~exist(strcat(desPath, '07a_plv'), 'dir')
  mkdir(strcat(desPath, '07a_plv'));
end
if ~exist(strcat(desPath, '07b_mplv'), 'dir')
  mkdir(strcat(desPath, '07b_mplv'));
end
if ~exist(strcat(desPath, '08_itpc'), 'dir')
  mkdir(strcat(desPath, '08_itpc'));
end
if ~exist(strcat(desPath, '09a_tfr'), 'dir')
  mkdir(strcat(desPath, '09a_tfr'));
end
if ~exist(strcat(desPath, '09b_pwelch'), 'dir')
  mkdir(strcat(desPath, '09b_pwelch'));
end
if ~exist(strcat(desPath, '10a_mplvod'), 'dir')
  mkdir(strcat(desPath, '10a_mplvod'));
end
if ~exist(strcat(desPath, '10b_itpcod'), 'dir')
  mkdir(strcat(desPath, '10b_itpcod'));
end
if ~exist(strcat(desPath, '10c_pwelchod'), 'dir')
  mkdir(strcat(desPath, '10c_pwelchod'));
end

clear sessionStr numOfPart part newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '01a_raw/');

sessionList     = dir([tmpPath, 'JAI_d*_01a_raw_*.mat']);
sessionList     = struct2cell(sessionList);
sessionList     = sessionList(1,:);
numOfSessions   = length(sessionList);

sessionNum      = zeros(1, numOfSessions);
sessionListCopy = sessionList;

for i=1:1:numOfSessions
  sessionListCopy{i} = strsplit(sessionList{i}, '01a_raw_');
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
  for i=1:1:length(userList)
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
      session = x;
      sessionStr = sprintf('%03d', session);
    elseif x == 0  
      selection = true;
      session = x;
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

clear tmpPath sessionListCopy userList match filePath cmdout attrib 

% -------------------------------------------------------------------------
% General selection of dyads
% -------------------------------------------------------------------------
selection = false;

while selection == false
  fprintf('\nPlease select one option:\n');
  fprintf('[1] - Process all available dyads\n');
  fprintf('[2] - Process all new dyads\n');
  fprintf('[3] - Process specific dyad\n');
  fprintf('[4] - Quit data processing\n\n');
  x = input('Option: ');
  
  switch x
    case 1
      selection = true;
      dyadsSpec = 'all';
    case 2
      selection = true;
      dyadsSpec = 'new';
    case 3
      selection = true;
      dyadsSpec = 'specific';
    case 4
      fprintf('\nData processing aborted.\n');
      clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions sessionStr
      return;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

% -------------------------------------------------------------------------
% General selection of preprocessing option
% -------------------------------------------------------------------------
selection = false;

if session == 0
  fprintf('\nA new session always will start with part:\n');
  fprintf('[1] - Import raw data\n');
  part = 1;
else
  while selection == false
    fprintf('\nPlease select what you want to do with the selected dyads:\n');
    fprintf('[1]  - Data import and repairing of bad channels\n');
    fprintf('[2]  - Preprocessing, filtering, re-referencing\n');
    fprintf('[3]  - ICA decomposition\n');
    fprintf('[4]  - Estimation and correction of eye artifacts\n');
    fprintf('[5]  - Automatic and manual artifact detection\n');
    fprintf('[6]  - Narrow band filtering and Hilbert transform\n'); 
    fprintf('[7]  - Estimation of Phase Locking Values (PLV)\n');
    fprintf('[8]  - Estimation of Inter Trial Phase Coherences (ITPC)\n');
    fprintf('[9]  - Power analysis (TFR, pWelch)\n');
    fprintf('[10] - Averaging over dyads\n');
    fprintf('[11] - Quit data processing\n\n');
    x = input('Option: ');
  
    switch x
      case 1
        part = 1;
        selection = true;
      case 2
        part = 2;
        selection = true;
      case 3
        part = 3;
        selection = true;
      case 4
        part = 4;
        selection = true;
      case 5
        part = 5;
        selection = true;
      case 6
        part = 6;
        selection = true;
      case 7
        part = 7;
        selection = true;
      case 8
        part = 8;
        selection = true;
      case 9
        part = 9;
        selection = true;
      case 10
        part = 10;
        selection = true;
      case 11
        fprintf('\nData processing aborted.\n');
        clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions dyadsSpec sessionStr
        return;
      otherwise
        selection = false;
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
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

switch part
  case 1
    fileNamePre = [];
    tmpPath = strcat(desPath, '01a_raw/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_01a_raw_', sessionStr, '.mat');
  case 2
    tmpPath = strcat(desPath, '01c_repaired/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_01c_repaired_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_02_preproc_', sessionStr, '.mat');
  case 3
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_02_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '03b_eogchan/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_03b_eogchan_', sessionStr, '.mat');
  case 4
    tmpPath = strcat(desPath, '03b_eogchan/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_03b_eogchan_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '04b_eyecor/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_04b_eyecor_', sessionStr, '.mat');
  case 5
    tmpPath = strcat(desPath, '04b_eyecor/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_04b_eyecor_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '05b_allart/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_05b_allart_', sessionStr, '.mat');
  case 6
    tmpPath = strcat(desPath, '04b_eyecor/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_04b_eyecor_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '06b_hilbert/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_06b_hilbertGamma_', sessionStr, '.mat');
  case 7
    tmpPath = strcat(desPath, '06b_hilbert/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_06b_hilbertGamma_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '07b_mplv/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_07b_mplvGamma_', sessionStr, '.mat');
  case 8
    tmpPath = strcat(desPath, '04b_eyecor/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_04b_eyecor_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '08_itpc/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_08_itpc_', sessionStr, '.mat');
  case 9
    tmpPath = strcat(desPath, '04b_eyecor/');
    fileNamePre = strcat(tmpPath, 'JAI_d*_04b_eyecor_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '09b_pwelch/');
    fileNamePost = strcat(tmpPath, 'JAI_d*_09b_pwelch_', sessionStr, '.mat');
  case 10
    fileNamePre = 0;
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if ~isequal(fileNamePre, 0)
  if isempty(fileNamePre)
    numOfPrePart = fileNum;
  else
    fileListPre = dir(fileNamePre);
    if isempty(fileListPre)
      cprintf([1,0.5,0], ['Selected part [%d] can not be executed, no '...'
            'input data available\n Please choose a previous part.\n'], part);
      clear desPath fileNamePost fileNamePre fileNum i numOfSources ...
            selection sourceList srcPath x y dyadsSpec fileListPre ... 
            sessionList sessionNum numOfSessions session part sessionStr ...
            tmpPath
      return;
    else
      fileListPre = struct2cell(fileListPre);
      fileListPre = fileListPre(1,:);
      numOfFiles  = length(fileListPre);
      numOfPrePart = zeros(1, numOfFiles);
      for i=1:1:numOfFiles
        numOfPrePart(i) = sscanf(fileListPre{i}, strcat('JAI_d%d*', sessionStr, '.mat'));
      end
    end
  end

  if strcmp(dyadsSpec, 'all')                                               % process all participants
    numOfPart = numOfPrePart;
  elseif strcmp(dyadsSpec, 'specific')                                      % process specific participants
    y = sprintf('%d ', numOfPrePart);
    
    selection = false;
    
    while selection == false
      fprintf('\nThe following participants are available: %s\n', y);
      fprintf(['Comma-seperate your selection and put it in squared ' ...
               'brackets!\n']);
      x = input('\nPlease make your choice! (i.e. [1,2,3]): ');
      
      if ~all(ismember(x, numOfPrePart))
        cprintf([1,0.5,0], 'Wrong input!\n');
      else
        selection = true;
        numOfPart = x;
      end
    end
  elseif strcmp(dyadsSpec, 'new')                                           % process only new participants
    if session == 0
      numOfPart = numOfPrePart;
    else
      fileListPost = dir(fileNamePost);
      if isempty(fileListPost)
        numOfPostPart = [];
      else
        fileListPost = struct2cell(fileListPost);
        fileListPost = fileListPost(1,:);
        numOfFiles  = length(fileListPost);
        numOfPostPart = zeros(1, numOfFiles);
        for i=1:1:numOfFiles
          numOfPostPart(i) = sscanf(fileListPost{i}, strcat('JAI_d%d*', sessionStr, '.mat'));
        end
      end
  
      numOfPart = numOfPrePart(~ismember(numOfPrePart, numOfPostPart));
      if isempty(numOfPart)
        cprintf([1,0.5,0], 'No new dyads available!\n');
        fprintf('Data processing aborted.\n');
        clear desPath fileNamePost fileNamePre fileNum i numOfPrePart ...
              numOfSources selection sourceList srcPath x y dyadsSpec ...
              fileListPost fileListPre numOfPostPart sessionList ...
              numOfFiles sessionNum numOfSessions session numOfPart ...
              part sessionStr dyads tmpPath
        return;
      end
    end
  end

  y = sprintf('%d ', numOfPart);
  fprintf(['\nThe following participants will be processed ' ... 
         'in the selected part [%d]:\n'],  part);
  fprintf('%s\n\n', y);

  clear fileNamePost fileNamePre fileNum i numOfPrePart ...
        numOfSources selection sourceList x y dyads fileListPost ...
        fileListPre numOfPostPart sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
else
  fprintf('\n');
  clear fileNamePost fileNamePre fileNum i numOfSources selection ...
        sourceList x y dyads sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
end

% -------------------------------------------------------------------------
% Data processing main loop
% -------------------------------------------------------------------------
sessionStatus = true;
sessionPart = part;

clear part;

while sessionStatus == true
  switch sessionPart
    case 1
      JAI_main_1;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[2] - Preprocessing, filtering, re-referencing?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 2;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 2
      JAI_main_2;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[3] - ICA decomposition?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 3;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 3
      JAI_main_3;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[4] - Estimation and correction of eye artifacts?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 4;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 4
      JAI_main_4;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[5] - Automatic and manual detection of artifacts?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 5;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 5
      JAI_main_5;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[6]  - Narrow band filtering and Hilbert transform?</strong>\n');
        fprintf('<strong>[8]  - Estimation of Inter Trial Phase Coherences (ITPC)?</strong>\n');
        fprintf('<strong>[9]  - Power analysis (TFR, pWelch)?</strong>\n');
        fprintf('<strong>[11] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 8
            selection = true;
            sessionStatus = true;
            sessionPart = 8;
          case 9
            selection = true;
            sessionStatus = true;
            sessionPart = 9;
          case 11
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 6
      JAI_main_6;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[7] - Estimation of Phase Locking Values (PLV)?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 7;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end  
    case 7
      JAI_main_7;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[8]  - Estimation of Inter Trial Phase Coherences (ITPC)?</strong>\n');
        fprintf('<strong>[9]  - Power analysis (TFR, pWelch)?</strong>\n');
        fprintf('<strong>[10] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[11] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 8
            selection = true;
            sessionStatus = true;
            sessionPart = 8;
          case 9
            selection = true;
            sessionStatus = true;
            sessionPart = 9;
          case 10
            selection = true;
            sessionStatus = true;
            sessionPart = 10;
          case 11
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 8
      JAI_main_8;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[9]  - Power analysis (TFR, pWelch)?</strong>\n');
        fprintf('<strong>[10] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[11] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 9
            selection = true;
            sessionStatus = true;
            sessionPart = 9;
          case 10
            selection = true;
            sessionStatus = true;
            sessionPart = 10;
          case 11
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 9
      JAI_main_9;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[10] - Averaging over dyads?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 10;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 10
      JAI_main_10;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('<strong>Data processing finished.</strong>\n');
fprintf('<strong>Session will be closed.</strong>\n');

clear sessionStr numOfPart srcPath desPath sessionPart sessionStatus ...
      selection x
