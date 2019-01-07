% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
run('../JAI_init.m');

cprintf([0,0.6,0], '<strong>--------------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of PSD results of single and dual conditions with 10 Hz entrainment</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>--------------------------------------------------------------------------</strong>\n');

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
srcPath = [path 'DualEEG_JAI_processedData/'];
srcPath = [srcPath  '09b_pwelch/'];

fileList     = dir([srcPath, 'JAI_d*_09b_pwelch_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '09b_pwelch_');
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
      fileList numOfFiles x selection

% -------------------------------------------------------------------------
% generate xls file (existing files will always be overwritten to avoid 
% results with conflicts!)
% -------------------------------------------------------------------------
desPath = [path 'DualEEG_JAI_results/' 'PSD_export/'];                      % destination path
xlsFile = [desPath 'PSD_10Hz_singledual_conditions_export_' ...             % build file name
            sessionStr '.xls'];

template_file = [path 'DualEEG_JAI_templates/' ...                          % template file
                  'PSD_10Hz_export_template.xls'];

[~] = copyfile(template_file, xlsFile);                                     % copy template to destination

clear desPath template_file path

% -------------------------------------------------------------------------
% generate table templates
% -------------------------------------------------------------------------
fileList     = dir([srcPath 'JAI_d*_09b_pwelch_' sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

numOfPart = 2 * numOfFiles;                                                 % each file has data of two participants

load([srcPath fileList{1}]);                                                % load data of first dyad

label     = data_pwelch.part1.label;                                        % extract channel names
loc_label = ~ismember(label, {'V1', 'V2', 'EOGH', 'EOGV', 'REF'});          % remove channels which are not of interest.
label     = label(loc_label);
numOfChan = length(label);

freq = data_pwelch.part1.freq;                                              % extract frequencies
loc_freq  = ismember(freq, 10);                                             % estimate column for 10 Hz

cell_array      = num2cell(NaN(numOfPart, numOfChan + 1));
cell_array(:,1) = {'unknown'};
T               = cell2table(cell_array);                                   % create template table
T.Properties.VariableNames = ['participant' label'];
T_single  = T;                                                              % create one table for the single 10 Hz condition and one for the dual 10 Hz condition
T_dual    = T;

clear T numOfPart numOfChan cell_array sessionStr freq label

% -------------------------------------------------------------------------
% import itpc values into tables
% -------------------------------------------------------------------------
condition  = {10, [11,12]};                                                 % conditions

fprintf('Import of PSD values...\n');
f = waitbar(0,'Please wait...');  
for dyad=1:1:numOfFiles
  load([srcPath fileList{dyad}]);
  dyadNum     = sscanf(fileList{dyad}, 'JAI_d%d');                          % estimate dyad original number

  T_single.participant(2*dyad - 1)   = {sprintf('%d_1', dyadNum)};          % set participants identifier in all tables
  T_single.participant(2*dyad)       = {sprintf('%d_2', dyadNum)};
  T_dual.participant(2*dyad - 1)  = {sprintf('%d_1', dyadNum)};
  T_dual.participant(2*dyad)      = {sprintf('%d_2', dyadNum)};

  waitbar(dyad/numOfFiles, f, 'Please wait...');                            % spread the psd results into the three different tables
  % participant 1 -------------------------------------------------------
  % condition 10
  loc_trl = ismember(data_pwelch.part1.trialinfo, condition{1});
  data    = data_pwelch.part1.powspctrm(loc_trl, loc_label, loc_freq);
  T_single(2*dyad - 1, 2:end) = num2cell(data);
  % condition [11, 12]
  loc_trl = ismember(data_pwelch.part1.trialinfo, condition{2});
  data    = data_pwelch.part1.powspctrm(loc_trl, loc_label, loc_freq);
  T_dual(2*dyad - 1, 2:end) = num2cell(nanmean(data, 1));

  % participant 2 -------------------------------------------------------
  % condition 10
  loc_trl = ismember(data_pwelch.part2.trialinfo, condition{1});
  data    = data_pwelch.part2.powspctrm(loc_trl, loc_label, loc_freq);
  T_single(2*dyad, 2:end) = num2cell(data);
  % condition [11, 12]
  loc_trl = ismember(data_pwelch.part2.trialinfo, condition{2});
  data    = data_pwelch.part2.powspctrm(loc_trl, loc_label, loc_freq);
  T_dual(2*dyad, 2:end) = num2cell(nanmean(data, 1));
end

close(f);
clear dyadNum condition loc_trl loc_freq f dyad numOfFiles fileList ...
      srcPath data_pwelch data loc_label

% -------------------------------------------------------------------------
% export itpc table into spreadsheet
% -------------------------------------------------------------------------
fprintf('Export of PSD tables into a xls spreadsheet...\n');

writetable(T_single, xlsFile, 'Sheet', 'Single');
writetable(T_dual, xlsFile, 'Sheet', 'Dual');

% -------------------------------------------------------------------------
% clear workspace
% -------------------------------------------------------------------------
clear xlsFile T_single T_dual
