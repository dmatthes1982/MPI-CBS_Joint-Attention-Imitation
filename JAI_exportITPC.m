% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
JAI_init;

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of ITPC results (only meta conditions)</strong>\n');
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
srcPath = [path 'DualEEG_JAI_processedDataCCA/'];
srcPath = [srcPath  '08b_itpcavg/'];

fileList     = dir([srcPath, 'JAI_d*_08b_itpcavg_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '08b_itpcavg_');
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
desPath = [path 'DualEEG_JAI_results/' 'ITPC_export/'];                     % destination path
xlsFile = [desPath 'ITPC_meta_conditions_export_' sessionStr '.xls'];       % build file name

template_file = [path 'DualEEG_JAI_templates/' 'ITPC_export_template.xls']; % template file

[~] = copyfile(template_file, xlsFile);                                     % copy template to destination

clear desPath template_file path

% -------------------------------------------------------------------------
% generate table templates
% -------------------------------------------------------------------------
fileList     = dir([srcPath 'JAI_d*_08b_itpcavg_' sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

numOfPart = 2 * numOfFiles;                                                 % each file has data of two participants

load([srcPath fileList{1}]);                                                % load data of first dyad

label       = data_itpc.part1.label;                                        % extract channel names
loc         = ~ismember(label, {'V1', 'V2', 'EOGH', 'EOGV', 'REF'});        % remove channels which are not of interest.
label       = label(loc);
label_No    = cellfun(@(x) [x '_0M'], label, 'UniformOutput', false);       % generate column titles for each kind of entrainment
label_2Hz   = cellfun(@(x) [x '_2M'], label, 'UniformOutput', false);
label_10Hz  = cellfun(@(x) [x '_10M'], label, 'UniformOutput', false);
label_20Hz  = cellfun(@(x) [x '_20M'], label, 'UniformOutput', false);

numOfChan = 4 * length(label);
col{1}    = 2:length(label)+1;                                              % estimate column identifier for each kind of entrainment
col{2}    = col{1} + length(label);
col{3}    = col{2} + length(label);
col{4}    = col{3} + length(label);

cell_array      = num2cell(NaN(numOfPart, numOfChan + 1));
cell_array(:,1) = {'unknown'};
T               = cell2table(cell_array);                                   % create template table
T.Properties.VariableNames = ['participant' label_No' label_2Hz' ...
                                label_10Hz' label_20Hz'];
T_NB2   = T;                                                                % create table for each narrow band
T_NB10  = T;
T_NB20  = T;

clear T label_No label_2Hz label_10Hz label_20Hz numOfPart numOfChan ...
      cell_array sessionStr loc

% -------------------------------------------------------------------------
% import itpc values into tables
% -------------------------------------------------------------------------
condition  = 201:204;                                                       % conditions: MetaNo, Meta2Hz, Meta10Hz, Meta20Hz 
numOfTrials = length(condition);

fprintf('Import of ITPC values...\n');
f = waitbar(0,'Please wait...');  
for dyad=1:1:numOfFiles
  load([srcPath fileList{dyad}]);
  dyadNum     = sscanf(fileList{dyad}, 'JAI_d%d');                          % estimate dyad original number

  T_NB2.participant(2*dyad - 1)   = {sprintf('%d_1', dyadNum)};             % set participants identifier in all tables
  T_NB2.participant(2*dyad)       = {sprintf('%d_2', dyadNum)};
  T_NB10.participant(2*dyad - 1)  = {sprintf('%d_1', dyadNum)};
  T_NB10.participant(2*dyad)      = {sprintf('%d_2', dyadNum)};
  T_NB20.participant(2*dyad - 1)  = {sprintf('%d_1', dyadNum)};
  T_NB20.participant(2*dyad)      = {sprintf('%d_2', dyadNum)};
  
  for trl = 1:1:numOfTrials                                                 % spread the itpc results into the three different tables
    waitbar(((dyad-1)*numOfTrials + trl)/(numOfFiles * numOfTrials), ...
               f, 'Please wait...');
    % participant 1 -------------------------------------------------------
    loc_trl = ismember(data_itpc.part1.trialinfo, condition(trl));
    % 2Hz narrow band
    loc_freq = ismember(data_itpc.part1.freq, 2);
    T_NB2(2*dyad - 1, col{trl}) = ... 
      num2cell(data_itpc.part1.itpc{loc_trl}(1:length(label), loc_freq))';
    % 10Hz narrow band
    loc_freq = ismember(data_itpc.part1.freq, 10);
    T_NB10(2*dyad - 1, col{trl}) = ... 
      num2cell(data_itpc.part1.itpc{loc_trl}(1:length(label), loc_freq))';
    % 20Hz narrow band
    loc_freq = ismember(data_itpc.part1.freq, 20);
    T_NB20(2*dyad - 1, col{trl}) = ... 
      num2cell(data_itpc.part1.itpc{loc_trl}(1:length(label), loc_freq))';

    % participant 2 -------------------------------------------------------
    loc_trl = ismember(data_itpc.part2.trialinfo(:), condition(trl));
    % 2Hz narrow band
    loc_freq = ismember(data_itpc.part2.freq, 2);
    T_NB2(2*dyad, col{trl}) = ...
      num2cell(data_itpc.part2.itpc{loc_trl}(1:length(label), loc_freq))';
    % 10Hz narrow band
    loc_freq = ismember(data_itpc.part2.freq, 10);
    T_NB10(2*dyad, col{trl}) = ...
      num2cell(data_itpc.part2.itpc{loc_trl}(1:length(label), loc_freq))';
    % 20Hz narrow band
    loc_freq = ismember(data_itpc.part2.freq, 20);
    T_NB20(2*dyad, col{trl}) = ...
      num2cell(data_itpc.part2.itpc{loc_trl}(1:length(label), loc_freq))';
  end
end

close(f);
clear dyadNum condition loc_trl loc_freq col f dyad trl numOfFiles ...
      fileList srcPath data_itpc numOfTrials label

% -------------------------------------------------------------------------
% export itpc table into spreadsheet
% -------------------------------------------------------------------------
fprintf('Export of ITPC tables into a xls spreadsheet...\n');

writetable(T_NB2, xlsFile, 'Sheet', '2Hz_narrow_band');
writetable(T_NB10, xlsFile, 'Sheet', '10Hz_narrow_band');
writetable(T_NB20, xlsFile, 'Sheet', '20Hz_narrow_band');

% -------------------------------------------------------------------------
% clear workspace
% -------------------------------------------------------------------------
clear xlsFile T_NB2 T_NB10 T_NB20
