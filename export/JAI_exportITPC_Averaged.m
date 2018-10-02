% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
run('../JAI_init.m');

cprintf([0,0.6,0], '<strong>-----------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of ITPC results (averaged over participants for meta conditions)</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-----------------------------------------------------------------------</strong>\n');

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
srcPath = [srcPath  '08a_itpc/'];

fileList     = dir([srcPath, 'JAI_d*_08a_itpc_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '08a_itpc_');
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
xlsFile = [desPath 'ITPC_meta_cond_avg_export_' sessionStr '.xls'];         % build file name

template_file = [path 'DualEEG_JAI_templates/' ...                          % template file
                  'ITPCavg_export_template.xls'];

[~] = copyfile(template_file, xlsFile);                                     % copy template to destination

clear desPath template_file path

% -------------------------------------------------------------------------
% select participants
% -------------------------------------------------------------------------
fprintf('Select Participants...\n\n');
fileList     = dir([srcPath 'JAI_d*_08a_itpc_' sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

listOfPart = zeros(numOfFiles, 1);

for i = 1:1:numOfFiles
  listOfPart(i) = sscanf(fileList{i}, ['JAI_d%d_08a_itpc_' sessionStr ...   % generate a list of all available numbers of dyads
                                        '.mat']);
end

listOfPartStr = cell(numOfFiles, 2);                                        % prepare a cell array with all possible options for the following list dialog
listOfPartStr(:,1) = cellfun(@(x) sprintf('%d_1', x), ...
                            num2cell(listOfPart), 'UniformOutput', false);
listOfPartStr(:,2) = cellfun(@(x) sprintf('%d_2', x), ...
                            num2cell(listOfPart), 'UniformOutput', false);

part = listdlg('ListString', listOfPartStr);                                % open the dialog window --> the user can select the participants of interest

listOfPartBool(:,1) = ismember(1:1:numOfFiles, part);                       % transform the user's choise into a binary representation for further use
listOfPartBool(:,2) = ismember((1:1:numOfFiles) + numOfFiles, part);

selected = [listOfPartStr(listOfPartBool(:,1), 1); ...                      % generate a cell vector with identifiers of all selected participants
            listOfPartStr(listOfPartBool(:,2), 2)];

fprintf('You have selected the following participants:\n');
cellfun(@(x) fprintf('%s, ', x), selected, 'UniformOutput', false);         % show the identifiers of the selected participants in the command window
fprintf('\b\b.\n\n');

Tpart = cell2table(selected);                                               % transform the vector of identifiers into a table. This table will be also attached to the spreadsheet 

clear sessionStr listOfPart listOfPartStr i

% -------------------------------------------------------------------------
% generate table templates
% -------------------------------------------------------------------------
load([srcPath fileList{1}]);                                                % load data of first dyad

label = data_itpc.part1.label;                                              % extract channel names
loc   = ~ismember(label, {'V1', 'V2', 'EOGH', 'EOGV', 'REF'});              % remove channels which are not of interest.
label = label(loc);

freq  = data_itpc.part1.freq;

cell_array      = num2cell(NaN(length(freq), length(label) + 1));
cell_array(:,1) = num2cell(freq');
T               = cell2table(cell_array);                                   % create template table
T.Properties.VariableNames = ['participant' label'];

T_201 = T;                                                                  % create table for each condition
T_202 = T;
T_203 = T;
T_204 = T;

clear cell_array T

% -------------------------------------------------------------------------
% import itpc values into tables
% -------------------------------------------------------------------------
condition   = {201, 202, 203, 204};                                         % conditions 
numOfTrials = length(condition);

fprintf('Import of ITPC values...\n');
f = waitbar(0,'Please wait...');

part    = 1;
itpc = cell(4, length(selected));

for dyad=1:1:numOfFiles
  if any(listOfPartBool(dyad,:))                                            % check if dyad was selected
    load([srcPath fileList{dyad}]);
    if listOfPartBool(dyad, 1)                                              % check if participant 1 was selected
      for trl = 1:1:numOfTrials
        waitbar(((part-1)*numOfTrials + trl)/(length(selected) * ...
                  numOfTrials), f, 'Please wait...');
        loc_trl = ismember(data_itpc.part1.trialinfo, condition{trl});
        if any(loc_trl)
          itpc{trl, part} = nanmean(data_itpc.part1.itpc{loc_trl}(loc,:,:), 3)';
        else
          itpc{trl, part} = NaN(length(freq), length(label));               % if condition is missing, use matrix with NaNs
        end
      end
      part = part + 1;
    end
    if listOfPartBool(dyad, 2)                                              % check if participant 2 was selected
      for trl = 1:1:numOfTrials
        waitbar(((part-1)*numOfTrials + trl)/(length(selected) * ...
                  numOfTrials), f, 'Please wait...');
        loc_trl = ismember(data_itpc.part2.trialinfo, condition{trl});
        if any(loc_trl)
          itpc{trl, part} = nanmean(data_itpc.part2.itpc{loc_trl}(loc,:,:), 3)';
        else
          itpc{trl, part} = NaN(length(freq), length(label));               % if condition is missing, use matrix with NaNs
        end
      end
      part = part + 1;
    end
  end
end

close(f);
clear dyad data_itpc label freq loc listOfPartBool fileList part srcPath ...
      numOfFiles selected f condition loc_trl numOfTrials trl

% -------------------------------------------------------------------------
% average itpc values over participants
% -------------------------------------------------------------------------    
fprintf('Average of ITPC values over participants...\n');
T_201(:,2:end) = num2cell(nanmean(cat(3,itpc{1,:}),3));
T_202(:,2:end) = num2cell(nanmean(cat(3,itpc{2,:}),3));
T_203(:,2:end) = num2cell(nanmean(cat(3,itpc{3,:}),3));
T_204(:,2:end) = num2cell(nanmean(cat(3,itpc{4,:}),3));

% -------------------------------------------------------------------------
% export itpc table into spreadsheet
% -------------------------------------------------------------------------
fprintf('Export of ITPC tables into a xls spreadsheet...\n');

writetable(T_201, xlsFile, 'Sheet', '201');
writetable(T_202, xlsFile, 'Sheet', '202');
writetable(T_203, xlsFile, 'Sheet', '203');
writetable(T_204, xlsFile, 'Sheet', '204');
writetable(Tpart, xlsFile, 'Sheet', 'selected participants');

% -------------------------------------------------------------------------
% clear workspace
% -------------------------------------------------------------------------
clear xlsFile T_201 T_202 T_203 T_204 Tpart itpc
