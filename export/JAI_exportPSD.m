% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
run('../JAI_init.m');

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of PSD results (only first baseline conditions)</strong>\n');
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
xlsFile = [desPath 'PSD_begBaseline_conditions_export_' sessionStr '.xls']; % build file name

template_file = [path 'DualEEG_JAI_templates/' 'PSD_export_template.xls'];  % template file

[~] = copyfile(template_file, xlsFile);                                     % copy template to destination

clear desPath template_file path

% -------------------------------------------------------------------------
% generate table templates
% -------------------------------------------------------------------------
fileList    = dir([srcPath 'JAI_d*_09b_pwelch_' sessionStr '.mat']);
fileList    = struct2cell(fileList);
fileList    = fileList(1,:);                                                % generate list with filenames of all existing dyads
numOfFiles  = length(fileList);
numOfPart   = 2 * numOfFiles;                                               % each file has data of two participants

freq        = {8,9,10,11,12,13};                                            % frequencies of interest
label_111   = cellfun(@(x) sprintf('C111_%dHz', x), freq, ...                  % generate column titles for each condition
                      'UniformOutput', false);
label_2     = cellfun(@(x) sprintf('C2_%dHz', x), freq, ...
                      'UniformOutput', false);
label_3     = cellfun(@(x) sprintf('C3_%dHz', x), freq, ...
                      'UniformOutput', false);

numOfChan   = 3 * length(freq);
col{1}      = 2:length(freq)+1;                                             % estimate column identifier for each condition
col{2}      = col{1} + length(freq);
col{3}      = col{2} + length(freq);

cell_array      = num2cell(NaN(numOfPart, numOfChan + 1));
cell_array(:,1) = {'unknown'};
T               = cell2table(cell_array);                                   % create template table
T.Properties.VariableNames = ['participant' label_111 label_2 label_3];

clear label_111 label_2 label_3 numOfPart numOfChan cell_array ...
      sessionStr loc freq

% -------------------------------------------------------------------------
% import psd values into tables
% -------------------------------------------------------------------------
condition   = [111,2,3];                                                     % conditions: SameObjectB, ViewMotionB, SameMotionB
numOfTrials = length(condition);
label       = {'C3','Cz','C4'};
freq        = 8:13;

fprintf('Import of PSD values...\n');
f = waitbar(0,'Please wait...');
for dyad=1:1:numOfFiles
  load([srcPath fileList{dyad}]);
  dyadNum     = sscanf(fileList{dyad}, 'JAI_d%d');                          % estimate dyad original number
  
  T.participant(2*dyad - 1) = {sprintf('%d_1', dyadNum)};                   % set participants identifier
  T.participant(2*dyad)     = {sprintf('%d_2', dyadNum)};
  
  for trl = 1:1:numOfTrials                                                 % copy the psd results into the tables
    waitbar(((dyad-1)*numOfTrials + trl)/(numOfFiles * numOfTrials), ...
               f, 'Please wait...');
    % participant 1 -------------------------------------------------------
    loc_trl   = ismember(data_pwelch.part1.trialinfo, condition(trl));
    loc_freq  = ismember(data_pwelch.part1.freq, freq);
    loc_label = ismember(data_pwelch.part1.label, label);
    
    psd = squeeze(data_pwelch.part1.powspctrm(loc_trl,loc_label, ...        % extract values of desired channels and frequencies
                  loc_freq));
    psd = mean(psd, 1);                                                     % average over channels
    T(2*dyad - 1, col{trl}) = num2cell(psd);
    
    % participant 2 -------------------------------------------------------
    loc_trl   = ismember(data_pwelch.part2.trialinfo, condition(trl));
    loc_freq  = ismember(data_pwelch.part2.freq, freq);
    loc_label = ismember(data_pwelch.part2.label, label);
    
    psd = squeeze(data_pwelch.part2.powspctrm(loc_trl,loc_label, ...        % extract values of desired channels and frequencies
                  loc_freq));
    psd = mean(psd, 1);                                                     % average over channels
    T(2*dyad, col{trl}) = num2cell(psd);
  end
end

close(f);
clear dyadNum condition loc_trl loc_freq loc_label col f dyad trl ...
      numOfFiles fileList srcPath data_pwelch numOfTrials label freq psd

% -------------------------------------------------------------------------
% export itpc table into spreadsheet
% -------------------------------------------------------------------------
fprintf('Export of PSD table into a xls spreadsheet...\n');

writetable(T, xlsFile, 'Sheet', 'C3-Cz-C4');

% -------------------------------------------------------------------------
% clear workspace
% -------------------------------------------------------------------------
clear xlsFile T
