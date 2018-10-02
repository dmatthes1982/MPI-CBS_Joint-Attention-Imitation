% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
filepath = fileparts(mfilename('fullpath'));
run([filepath '/../JAI_init.m']);

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of PLV results (general script)</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01826/eegData/';                                           % root path to eeg data

fprintf('\nThe default path is: %s\n', path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default path?\n');
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
  path = uigetdir(pwd, 'Select folder...');
  path = strcat(path, '/');
end

clear newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
fprintf('\n<strong>Session selection...</strong>\n');
srcPath = [path 'DualEEG_JAI_processedData/'];
srcPath = [srcPath  '07b_mplv/'];

fileList     = dir([srcPath, 'JAI_d*_07b_mplv2Hz_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '07b_mplv2Hz_');
  fileListCopy{dyad} = fileListCopy{dyad}{end};
  sessionNum(dyad) = sscanf(fileListCopy{dyad}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for dyad = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', dyad)), 1, 'first');
  filePath = [srcPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{dyad} = attrib{3};
end

selection = false;
while selection == false
  fprintf('The following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for dyad = sessionNum
    fprintf('%d - %s\n', dyad, userList{dyad});
  end
  fprintf('\n');
  fprintf('Please select one session:\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear sessionNum fileListCopy y userList match filePath cmdout attrib ...
      fileList numOfFiles x selection dyad

% -------------------------------------------------------------------------
% Passband selection
% -------------------------------------------------------------------------
fprintf('<strong>Passband selection...</strong>\n');
passband  = {'2Hz', 'Theta', 'Alpha', '20Hz', 'Beta', 'Gamma'};             % all available passbands
suffix    = {'2Hz', 'theta', 'alpha', '20Hz', 'beta', 'gamma'};

part = listdlg('PromptString',' Select passband...', ...                    % open the dialog window --> the user can select the passband of interest
                'SelectionMode', 'single', ...
                'ListString', passband);
              
passband  = passband{part};
suffix    = suffix{part};
fprintf('You have selected the following passband: %s\n\n', passband);

% -------------------------------------------------------------------------
% Dyad selection
% -------------------------------------------------------------------------
fprintf('<strong>Dyad selection...</strong>\n');
fileList     = dir([srcPath 'JAI_d*_07b_mplv' passband '_' sessionStr ...
                    '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

listOfPart = zeros(numOfFiles, 1);

for i = 1:1:numOfFiles
  listOfPart(i) = sscanf(fileList{i}, ['JAI_d%d_07b_mplv' passband '_' ...  % generate a list of all available numbers of dyads
                                        sessionStr '.mat']);
end

listOfPartStr = cellfun(@(x) sprintf('%d', x), ...                          % prepare a cell array with all possible options for the following list dialog
                        num2cell(listOfPart), 'UniformOutput', false);

part = listdlg('PromptString',' Select dyads...', ...                       % open the dialog window --> the user can select the participants of interest
                'ListString', listOfPartStr);

listOfPartBool = ismember(1:1:numOfFiles, part);                            % transform the user's choise into a binary representation for further use

dyads = listOfPartStr(listOfPartBool);                                      % generate a cell vector with identifiers of all selected dyads

fprintf('You have selected the following dyads:\n');
cellfun(@(x) fprintf('%s, ', x), dyads, 'UniformOutput', false);            % show the identifiers of the selected dyads in the command window
fprintf('\b\b.\n\n');

dyads       = listOfPart(listOfPartBool);                                   % generate dyad vector for further use
fileList    = fileList(listOfPartBool);
numOfFiles  = length(fileList);

clear sessionStr listOfPart listOfPartStr listOfPartBool i

% -------------------------------------------------------------------------
% Conditions selection
% -------------------------------------------------------------------------
fprintf('<strong>Conditions selection...</strong>\n');
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...     % load general definitions
     'generalDefinitions');

condMark  = generalDefinitions.condMark(1, :);                              % extract condition identifiers
condNum     = generalDefinitions.condNum;

part = listdlg('PromptString',' Select conditions...', ...                  % open the dialog window --> the user can select the conditions of interest
                'ListString', condMark);

condMark  = condMark(part);
condNum   = condNum(part);

fprintf('You have selected the following conditions:\n');
cellfun(@(x) fprintf('%s, ', x), condMark, 'UniformOutput', false);         % show the identifiers of the selected conditions in the command window
fprintf('\b\b.\n\n');

clear generalDefinitions condMark part filepath

% -------------------------------------------------------------------------
% Cluster specification
% -------------------------------------------------------------------------
fprintf('<strong>Cluster specification...</strong>\n');
load([srcPath fileList{1}]);                                                % load data of first dyad

eval(['data_mplv=' sprintf('data_mplv_%s', suffix) ';']);                   % transfrom passband specific variable name into the common term data_mplv
eval(['clear ' sprintf('data_mplv_%s', suffix)]);

label     = data_mplv.dyad.label;                                           % extract channel names
numOfChan = length(label);

label_x = repmat(label, 1, numOfChan);                                      % prepare a cell array with all possible connections for cluster specification
label_y = repmat(label', numOfChan, 1);
connMatrix = cellfun(@(x,y) [x '_' y], label_x, label_y, ...
                'UniformOutput', false);

part = listdlg('PromptString',' Select connections...', ...                 % open the dialog window --> the user can select the connections of interest
                'ListString', connMatrix);

row = mod(part, numOfChan);
col = ceil(part/numOfChan);

connMatrixBool = false(numOfChan, numOfChan);
for i=1:1:length(row)
  connMatrixBool(row(i), col(i)) = true;
end

connections = connMatrix(connMatrixBool);

fprintf('You have selected the following connections:\n');
cellfun(@(x) fprintf('%s, ', x), connections, 'UniformOutput', false);      % show the identifiers of the selected connections in the command window
fprintf('\b\b.\n\n');
              
clear data_mplv label numOfChan connMatrix row col part

% -------------------------------------------------------------------------
% Identifier selection
% -------------------------------------------------------------------------
