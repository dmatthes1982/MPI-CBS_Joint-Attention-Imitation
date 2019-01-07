% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
run('../JAI_init.m');

cprintf([0,0.6,0], '<strong>-------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of phase locking value results of joint attention part</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-------------------------------------------------------------</strong>\n');

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
srcPath = [path 'DualEEG_JAI_processedDataOld/'];
srcPath = [srcPath  '07b_mplv/'];

fileList     = dir([srcPath, 'JAI_d*_07b_mplvGamma_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '07b_mplvGamma_');
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
  fprintf('\nThe following sessions are available: %s\n', y);
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
      fileList numOfFiles

% -------------------------------------------------------------------------
% Select passband
% -------------------------------------------------------------------------
selection = false;
while selection == false
  fprintf(['Please select your desired passband! Selectable options'...
           ' are: Theta, Alpha, Beta, Gamma, 2Hz or 20Hz.\n']);
  x = input('Selection: ','s');
  switch x
    case 'Theta'
      file_postfix = x;
      data_postfix = 'theta';
      selection = true;
    case 'Alpha'
      file_postfix = x;
      data_postfix = 'alpha';
      selection = true;
    case 'Beta'
      file_postfix = x;
      data_postfix = 'beta';
      selection = true;
    case 'Gamma'
      file_postfix = x;
      data_postfix = 'gamma';
      selection = true;
    case '2Hz'
      file_postfix = x;
      data_postfix = '2Hz';
      selection = true;
    case '20Hz'
      file_postfix = x;
      data_postfix = '20Hz';
      selection = true;
    otherwise
      cprintf([1,0.5,0], 'Wrong input, passband does not exist!\n');
      selection = false;
  end
end
  
% -------------------------------------------------------------------------
% build structure field including xls file names, condition strings and
% condition numbers
% -------------------------------------------------------------------------
desPath = [path 'DualEEG_JAI_results/' 'PLV_export/' 'JAP/'];
xls(1).address    = [desPath 'PLV_' 'SameObjectB_' '111_' file_postfix ...
                        '_' sessionStr '.xls'];
xls(1).condition  = 'SameObjectB';
xls(1).condNum    = 111;
xls(2).address    = [desPath 'PLV_' 'ViewMotionB_' '2_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(2).condition  = 'ViewMotionB';
xls(2).condNum    = 2;
xls(3).address    = [desPath 'PLV_' 'SameMotionB_' '3_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(3).condition  = 'SameMotionB';
xls(3).condNum    = 3;
xls(4).address    = [desPath 'PLV_' 'Single_No_' '100_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(4).condition  = 'Single_No';
xls(4).condNum    = 100;
xls(5).address    = [desPath 'PLV_' 'Dual12_No_' '101_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(5).condition  = 'Dual12_No';
xls(5).condNum    = 101;
xls(6).address    = [desPath 'PLV_' 'Dual21_No_' '102_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(6).condition  = 'Dual21_No';
xls(6).condNum    = 102;
xls(7).address    = [desPath 'PLV_' 'Single_2Hz_' '7_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(7).condition  = 'Single_2Hz';
xls(7).condNum    = 7;
xls(8).address    = [desPath 'PLV_' 'Dual12_2Hz_' '8_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(8).condition  = 'Dual12_2Hz';
xls(8).condNum    = 8;
xls(9).address    = [desPath 'PLV_' 'Dual21_2Hz_' '9_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(9).condition  = 'Dual21_2Hz';
xls(9).condNum    = 9;
xls(10).address   = [desPath 'PLV_' 'Single_10Hz_' '10_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(10).condition = 'Single_10Hz';
xls(10).condNum   = 10;
xls(11).address   = [desPath 'PLV_' 'Dual12_10Hz_' '11_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(11).condition = 'Dual12_10Hz';
xls(11).condNum   = 11;
xls(12).address   = [desPath 'PLV_' 'Dual21_10Hz_' '12_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(12).condition = 'Dual21_10Hz';
xls(12).condNum   = 12;
xls(13).address   = [desPath 'PLV_' 'Single_20Hz_' '20_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(13).condition = 'Single_20Hz';
xls(13).condNum   = 20;
xls(14).address   = [desPath 'PLV_' 'Dual12_20Hz_' '21_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(14).condition = 'Dual12_20Hz';
xls(14).condNum   = 21;
xls(15).address   = [desPath 'PLV_' 'Dual21_20Hz_' '22_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(15).condition = 'Dual21_20Hz';
xls(15).condNum   = 22;
xls(16).address   = [desPath 'PLV_' 'SameObjectE_' '4_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(16).condition = 'SameObjectE';
xls(16).condNum   = 4;
xls(17).address   = [desPath 'PLV_' 'ViewMotionE_' '5_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(17).condition = 'ViewMotionE';
xls(17).condNum   = 5;
xls(18).address   = [desPath 'PLV_' 'SameMotionE_' '6_' file_postfix ...
                      '_' sessionStr '.xls'];
xls(18).condition = 'SameMotionE';
xls(18).condNum   = 6;

% -------------------------------------------------------------------------
% generate files (existing files will always be overwritten to avoid
% results with conflicts!)
% -------------------------------------------------------------------------
template_file = [path 'DualEEG_JAI_templates/' 'PLV_export_template.xls'];

for i = 1:1:length(xls)
  [~] = copyfile(template_file, xls(i).address);                            % create xls file
end

% -------------------------------------------------------------------------
% generate table template
% -------------------------------------------------------------------------
fileList     = dir([srcPath 'JAI_d*_07b_mplv' file_postfix '_' ...
                    sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

load([srcPath fileList{1}]);                                                % load data of first dyad
eval(['data = ' sprintf('data_mplv_%s', data_postfix) ';']);                % remove passband dependent postfix
eval(['clear ' sprintf('data_mplv_%s', data_postfix) ';']);

label     = data.dyad.label;                                                % extract channel names
numOfChan = length(label);

T = cell2table(num2cell(NaN(numOfChan,numOfChan + 1)));                     % create template table
T.Properties.VariableNames = ['channel' label'];
T.channel = label;

clear data label numOfChan

% -------------------------------------------------------------------------
% export plv maps into spreadsheets
% -------------------------------------------------------------------------
fprintf('\nExport of PLV tables into xls files...\n');
f = waitbar(0,'Please wait...');                                            % visualize progress
for dyad=1:1:numOfFiles
  load([srcPath fileList{dyad}]);
  eval(['data = ' sprintf('data_mplv_%s', data_postfix) ';']);
  eval(['clear ' sprintf('data_mplv_%s', data_postfix) ';']);
  
  dyadNum = sscanf(fileList{dyad}, 'JAI_d%d');                              % estimate dyad original number
  numOfTrials = length([xls(:).condNum]);
  
  for trl = 1:1:numOfTrials
    waitbar(((dyad-1)*numOfTrials + trl)/(numOfFiles * numOfTrials), ...
               f, 'Please wait...');
    loc = ismember(data.dyad.trialinfo(:), [xls(trl).condNum]);
    if any(loc)
      T(1:end, 2:end) = num2cell(data.dyad.mPLV{loc});                      % put imported PLV matrix into table
    else
      T(1:end, 2:end) = {NaN};
    end
    writetable(T, xls(trl).address, ...                                     % write table into corresponding spreadsheet/tab
                'Sheet', sprintf('Dyad%d', dyadNum));
  end
end

close(f);
clear loc numOfTrials trl data dyadNum

% -------------------------------------------------------------------------
% clear workspace
% -------------------------------------------------------------------------
clear path srcPath desPath x selection file_postfix sessionStr xls i ...
      template_file data_postfix numOfFiles fileList dyad f T
