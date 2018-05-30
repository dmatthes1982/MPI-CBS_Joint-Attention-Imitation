% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
JAI_init;

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export number of segments with artifacts</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';

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

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
tmpPath = strcat(path, '05a_autoart/');

fileList     = dir([tmpPath, 'JAI_d*_05a_autoart_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for i=1:1:numOfFiles
  fileListCopy{i} = strsplit(fileList{i}, '05a_autoart_');
  fileListCopy{i} = fileListCopy{i}{end};
  sessionNum(i) = sscanf(fileListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

selection = false;
while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
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

% -------------------------------------------------------------------------
% Extract and export number of artifacts
% -------------------------------------------------------------------------
tmpPath = strcat(path, '05a_autoart/');

T = table(0,0,0);
T.Properties.VariableNames = {'dyad', 'ArtifactsPart1', 'ArtifactsPart2'};

fileList     = dir([tmpPath, ['JAI_d*_05a_autoart_' sessionStr '.mat']]);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles  = length(fileList);
numOfPart   = zeros(1, numOfFiles);
for i = 1:1:numOfFiles
  numOfPart(i) = sscanf(fileList{i}, strcat('JAI_d%d*', sessionStr, '.mat'));
end

for i = 1:1:length(fileList)
  file_path = strcat(tmpPath, fileList{i});
  load(file_path, 'cfg_autoart');
  
  warning off;
  T.dyad(i) = numOfPart(i);
  T.ArtifactsPart1(i) = cfg_autoart.bad1Num;
  T.ArtifactsPart2(i) = cfg_autoart.bad2Num;
  warning on;
end

file_path = strcat(path, '00_settings/', 'numOfArtifacts_', sessionStr, '.xls');
fprintf('The default file path is: %s\n', file_path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default file path and possibly overwrite an existing file?\n');
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
  [filename, file_path] = uiputfile(file_path, 'Specify a destination file...');
  file_path = [file_path, filename];
end

if exist(file_path, 'file')
  delete(file_path);
end
writetable(T, file_path);

fprintf('\nNumber of segments with artifacts per dyad exported to:\n');
fprintf('%s\n', file_path);

%% clear workspace
clear tmpPath path sessionStr fileList numOfFiles numOfPart i ...
      file_path cfg_autoart T newPaths filename selection x
