% JAI_PERMTEST_MPLV - Using this script one can test if the difference of
% one connection (e.g. Cz-Cz) or one cluster of connections is significant
% between two conditions. First, a paired-sample t-test is conducted. If
% this test shows a significant result, a permutation test follows. Here,
% the permutation is done on the level of averaged PLV values. Since our
% null hypothesis says that we expect no difference between conditions but
% a difference between dyads, the permutation is done only by randomly
% interchanging the values of the two conditions within the dyads. It is
% highly recommended to only use this script, if the number of PLV segments
% is nearly the same in both conditions for single dyads. Otherwise one
% should use JAI_PERMTEST_PLV
%
% See also JAI_PERMTEST_PLV

% -------------------------------------------------------------------------
% Add directory and subfolders to path, clear workspace, clear command
% windwow
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
run([filepath '/../JAI_init.m']);

cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Joint attention imitation project</strong>\n');
cprintf([0,0.6,0], '<strong>Permutation test on mplv level</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2019, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
datastorepath = '/data/pt_01826/eegData/';                                  % root path to eeg data

fprintf('\nThe default path is: %s\n', datastorepath);

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
  datastorepath = uigetdir(pwd, 'Select folder...');
  datastorepath = strcat(datastorepath, '/');
end

clear newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
fprintf('\n<strong>Session selection...</strong>\n');
srcPath = [datastorepath 'DualEEG_JAI_processedData/'];
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

part = listdlg('PromptString',' Select passband...', ...                    % open the dialog window --> the user can select the passband of interest
                'SelectionMode', 'single', ...
                'ListString', passband, ...
                'ListSize', [220, 300] );
              
passband  = passband{part};
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
                'ListString', listOfPartStr, ...
                'ListSize', [220, 300] );

listOfPartBool = ismember(1:1:numOfFiles, part);                            % transform the user's choise into a binary representation for further use

dyads = listOfPartStr(listOfPartBool);                                      % generate a cell vector with identifiers of all selected dyads

fprintf('You have selected the following dyads:\n');
cellfun(@(x) fprintf('%s, ', x), dyads, 'UniformOutput', false);            % show the identifiers of the selected dyads in the command window
fprintf('\b\b.\n\n');

dyads       = listOfPart(listOfPartBool);                                   % generate dyad vector for further use
fileList    = fileList(listOfPartBool);
numOfFiles  = length(fileList);

clear listOfPart listOfPartStr listOfPartBool i

% -------------------------------------------------------------------------
% Conditions selection
% -------------------------------------------------------------------------
fprintf('<strong>Conditions selection...</strong>\n');
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...     % load general definitions
     'generalDefinitions');

condMark  = generalDefinitions.condMark(1, :);                              % extract condition identifiers
condNum   = generalDefinitions.condNum;

part = listdlg('PromptString',' Select condition 1...', ...                 % open the dialog window --> the user can select the first condition of interest
                'ListString', condMark, ...
                'ListSize', [220, 300], ...
                'SelectionMode', 'single');
condMark1 = condMark(part);
condNum1  = condNum(part);             

part = listdlg('PromptString',' Select condition 2...', ...                 % open the dialog window --> the user can select the second condition of interest
                'ListString', condMark, ...
                'ListSize', [220, 300], ...
                'SelectionMode', 'single');
condMark2 = condMark(part);
condNum2  = condNum(part); 

condMark  = [condMark1, condMark2];
condNum   = [condNum1, condNum2];

fprintf('You have selected the following conditions:\n');
cellfun(@(x) fprintf('%s, ', x), condMark, 'UniformOutput', false);         % show the identifiers of the selected conditions in the command window
fprintf('\b\b.\n\n');

clear generalDefinitions part filepath condNum1 condNum2 condMark1 ...
      condMark2 condMark

% -------------------------------------------------------------------------
% Cluster specification
% -------------------------------------------------------------------------
fprintf('<strong>Connection selection...</strong>\n');
fprintf(['If you are selecting multiple connections, the selection '...
          'will be considered as cluster\n']);

load([srcPath fileList{1}]);                                                % load data of first dyad

label     = data_mplv.dyad.label;                                           % extract channel names
numOfChan = length(label);

label_x = repmat(label, 1, numOfChan);                                      % prepare a cell array with all possible connections for cluster specification
label_y = repmat(label', numOfChan, 1);
connMatrix = cellfun(@(x,y) [x '_' y], label_x, label_y, ...
                'UniformOutput', false);

prompt_string = 'Select connections of interest...';

part = listdlg('PromptString', prompt_string, ...                           % open the dialog window --> the user can select the connections of interest
                'ListString', connMatrix, ...
                'ListSize', [220, 300] );

row = mod(part, numOfChan);
tf = (row == 0);
row(tf) = numOfChan;
col = ceil(part/numOfChan);

connMatrixBool = false(numOfChan, numOfChan);
for i=1:1:length(row)
  connMatrixBool(row(i), col(i)) = true;
end

connections = connMatrix(connMatrixBool);

fprintf('\nYou have selected the following connections:\n');
cellfun(@(x) fprintf('%s, ', x), connections, 'UniformOutput', false);      % show the identifiers of the selected connections in the command window
fprintf('\b\b.\n\n');
              
clear data_mplv numOfChan connMatrix row col part i label_x label_y ...
      selection x prompt_string tf

% -------------------------------------------------------------------------
% Import data
% -------------------------------------------------------------------------
fprintf('<strong>Import of PLV values...</strong>\n');
f = waitbar(0,'Please wait...');

cnt               = 0;
data_stat.goodDyadsNum = NaN(numOfFiles, 1);
data_stat.trialinfo    = NaN(numOfFiles * 2, 1);
data_stat.mPLV         = NaN(1, numOfFiles * 2);

for dyad = 1:1:numOfFiles
  waitbar(dyad/numOfFiles, f, sprintf('Please wait %d/%d...', dyad, ...
          numOfFiles));
  load([srcPath fileList{dyad}]);                                           % load data
  
  if any(~strcmp(data_mplv.dyad.label, label))
    error(['Error with dyad %d. The channels are not in the correct ' ...
            'order!\n'], dyads(dyad));
  end

  if dyad == 1                                                              % extract bandpass specification
    data_stat.passband    = passband;
    data_stat.range       = data_mplv.bpFreq;
    data_stat.connections = connections;
  end
  
  tf = ismember(data_mplv.dyad.trialinfo, condNum);                         % check if selected conditions are exisiting
  if(sum(tf) ~=2)
    cprintf([1,0.5,0], sprintf(['At least one condition is missing. ' ...
                      'Dyad %d will not be considered.\n'], dyads(dyad)));
  else                                                                      % extract PLV values
    cnt       = cnt + 1;
    mPLVtemp  = data_mplv.dyad.mPLV(tf);
    mPLVtemp  = cellfun(@(x) x(connMatrixBool), ...
                       mPLVtemp, 'UniformOutput', false);
    mPLVtemp  = cellfun(@(x) mean(x), ...                                   % average over connections
                       mPLVtemp, 'UniformOutput', false);
    
    data_stat.mPLV(2*cnt-1:2*cnt)      = cell2mat(mPLVtemp);
    data_stat.trialinfo(2*cnt-1:2*cnt) = data_mplv.dyad.trialinfo(tf);
    data_stat.goodDyadsNum(cnt)        = dyads(dyad);
  end
  clear data_mplv
end

close(f);

data_stat.goodDyadsNum = data_stat.goodDyadsNum(1:cnt);
data_stat.trialinfo    = data_stat.trialinfo(1:2*cnt);
data_stat.mPLV         = data_stat.mPLV(1:2*cnt);
numOfGoodDyads         = numel(data_stat.goodDyadsNum);

fprintf('\n');

clear f cnt mPLVtemp tf dyad connections connMatrixBool dyads fileList ...
      passband label numOfFiles

% -------------------------------------------------------------------------
% Run t-Test
% -------------------------------------------------------------------------
fprintf('<strong>Run paired-sample t-test...</strong>\n');

cond1 = ismember(data_stat.trialinfo, condNum(1));
cond2 = ismember(data_stat.trialinfo, condNum(2));
[h,p,ci,stats] = ttest(data_stat.mPLV(cond1),data_stat.mPLV(cond2));
data_stat.stat.h      = h;
data_stat.stat.p      = p;
data_stat.stat.ci     = ci;
data_stat.stat.tstat  = stats.tstat;
data_stat.stat.df     = stats.df;
data_stat.stat.sd     = stats.sd;


if data_stat.stat.p < 0.05                                                  % check if result is significant
  fprintf('The t-test result is significant: %s=%g\n\n', ...
          char(945), data_stat.stat.p);
else
  fprintf('The t-test result is NOT significant: %s=%g\n', ...
          char(945), data_stat.stat.p);
  fprintf('Skip permutation test...\n\n');
  clear cond1 cond2 h p ci stats condNum datastorepath numOfGoodDyads ...
        sessionStr srcPath
  return                                                                    % return if result is non-significant
end

clear cond1 cond2 h p ci stats

% -------------------------------------------------------------------------
% Run permutation Test
% -------------------------------------------------------------------------
fprintf('<strong>Run permutation test...</strong>\n');

design(:,1) = 1:2:2*numOfGoodDyads;                                         % specify permutation design
design(:,2) = 2:2:2*numOfGoodDyads;
design = mat2cell(design,ones(1,numOfGoodDyads), 2);
design = design';

numOfPerm = 2500;                                                           % specify number of permutations (500 more than required)
resample = zeros(numOfPerm, 2*numOfGoodDyads);
hasDuplicates    = true;

fprintf('Generate permutation matrix...\n');
while hasDuplicates
  for i=1:numOfPerm
    for j=1:numOfGoodDyads
      resample(i, design{j}) = design{j}(randperm(2));
    end
  end

  [u, loc] = unique(resample, 'rows', 'first');                             % test for duplicates
  hasDuplicates = size(u,1) < size(resample,1);
  if(hasDuplicates)
    loc = sort(loc);
    resample = resample(loc, :);
    if(size(resample,1) > numOfPerm - 500)
      numOfPerm = numOfPerm - 500;
      resample  = resample(1:numOfPerm,:);
      hasDuplicates = false;
    end
  else
    numOfPerm = numOfPerm - 500;
    resample  = resample(1:numOfPerm, :);
  end
end

fprintf('Run test...\n');
data_stat.tstatPerm = zeros(1, numOfPerm);

for i=1:1:numOfPerm
  tmptrialinfo = data_stat.trialinfo(resample(i,:));
  cond1 = ismember(tmptrialinfo, condNum(1));
  cond2 = ismember(tmptrialinfo, condNum(2));
  [~,~,~,stats] = ttest(data_stat.mPLV(cond1),data_stat.mPLV(cond2));
  data_stat.tstatPerm(i) = stats.tstat;
end

fprintf('Evaluate test...\n\n');

data_stat.pPerm = sum(abs(data_stat.tstatPerm) > ...
                      abs(data_stat.stat.tstat)) / numOfPerm;
data_stat.numOfPerm = numOfPerm;

clear design numOfPerm resample hasDuplicates i j u loc cond1 cond2 ...
      tmptrialinfo stats condNum numOfGoodDyads

% -------------------------------------------------------------------------
% Test result
% -------------------------------------------------------------------------    
fprintf('<strong>Test result:</strong>\n');
if data_stat.pPerm < 0.05
  fprintf('The permutation test result is also significant: %s=%g\n\n', ...
          char(945), data_stat.pPerm);
else
  fprintf('The permutation test result is NOT significant: %s=%g\n', ...
          char(945), data_stat.pPerm);
  fprintf('The result of the t-test might be spurious.\n\n');
  return
end

% -------------------------------------------------------------------------
% Save result
% -------------------------------------------------------------------------
fprintf('<strong>Save data...</strong>\n');

desPath = [datastorepath 'DualEEG_JAI_results/PLV_stats/' sessionStr '/'];  % destination path
if ~exist(desPath, 'dir')                                                   % generate session dir, if not exist
  mkdir(desPath);
end

selection = false;
while selection == false
  identifier = inputdlg(['Specify file identifier (use only letters '...
                         'and/or numbers):'], 'Identifier specification');
  if ~all(isstrprop(identifier{1}, 'alphanum'))                             % check if identifier is valid
    cprintf([1,0.5,0], ['Use only letters and or numbers for the file '...
                        'identifier\n']);
  else
    matFile = [desPath 'JAI_mplvStats_' identifier{1} '_' sessionStr ...    % build filename
                '.mat'];

    if exist(matFile, 'file')                                               % check if file already exists
      cprintf([1,0.5,0], 'A file with this identifier exists!');
      selection2 = false;
      while selection2 == false
        fprintf('\nDo you want to overwrite this existing file?\n');        % ask if existing file should be overwritten
        x = input('Select [y/n]: ','s');
        if strcmp('y', x)
          selection2 = true;
          selection = true;
          save(matFile, 'data_stat');                                       % store data structure
          fprintf('\n');
        elseif strcmp('n', x)
          selection2 = true;
          fprintf('\n');
        else
          cprintf([1,0.5,0], 'Wrong input!\n');
          selection2 = false;
        end
      end
    else
      selection = true;
      save(matFile, 'data_stat');                                           % store data structure
    end
  end
end

fprintf('Data stored!\n');

clear selection selection2 x identifier desPath matFile

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear srcPath sessionStr datastorepath
