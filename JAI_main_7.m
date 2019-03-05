%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '06b_hilbert/';
  cfg.filename  = 'JAI_d01_06b_hilbertGamma';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '06b_hilbert/'), ...
                       strcat('*Gamma_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_06b_hilbertGamma_', sessionStr, '.mat'));
  end
end

%% part 7
% 1. Segmentation of the hilbert phase data trials for PLV estimation.
%    Split the data of every condition into subtrials with a length of 5
%    seconds
% 2. Artifact rejection
% 3. PLV estimation
% 4. mPLV estimation

cprintf([0,0.6,0], '<strong>[7] - Estimation of Phase Locking Values (PLV)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    choise = true;
    artifactRejection = false;
  else
    choise = false;
  end
end
fprintf('\n');

% Write selected settings to settings file
file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(file_path, 'file') == 2)                                         % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  JAI_createTbl(cfg);                                                       % create settings file
end

T = readtable(file_path);                                                   % update settings table
warning off;
T.artRejectPLV(numOfPart) = { x };
warning on;
delete(file_path);
writetable(T, file_path);

%% passband specifications
[pbSpec(1:6).fileSuffix]    = deal('2Hz','Theta','Alpha','20Hz','Beta','Gamma');
[pbSpec(1:6).name]          = deal('2Hz','theta','alpha','20Hz','beta','gamma');
[pbSpec(1:6).winLength]     = deal(5, 5, 1, 1, 1, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation, artifact rejection, PLV and mPLV estimation

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
  
  %% Load Artifact definitions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '05b_allart/');
    cfg.filename    = sprintf('JAI_d%02d_05b_allart', i);
    cfg.sessionStr  = sessionStr;
  
    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
    if ~isempty(dir(file_path))
      fprintf('Loading %s ...\n', file_path);
      JAI_loadData( cfg );                                                  
      artifactAvailable = true;     
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactAvailable = false;
    end
  fprintf('\n');  
  end
  
  for j = 1:1:numel(pbSpec)
    % load hilbert phase % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('JAI_d%02d_06b_hilbert%s', i, ...
                                pbSpec(j).fileSuffix);
    fprintf('Load hilbert phase data at %s...\n', pbSpec(j).name);
    JAI_loadData( cfg );

    % segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cfg           = [];
    cfg.length    = pbSpec(j).winLength;
    cfg.overlap   = 0;

    fprintf(['<strong>Segmentation of Hilbert phase data at '...
              '%s (%g-%gHz).</strong>\n'], pbSpec(j).name, ...
              data_hilbert.bpFreq);
    data_hilbert  = JAI_segmentation( cfg, data_hilbert );

    % artifact rejection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if artifactRejection == true
      if artifactAvailable == true
        cfg           = [];
        cfg.artifact  = cfg_allart;
        cfg.reject    = 'complete';
        cfg.target    = 'dual';

        fprintf(['<strong>Artifact Rejection of Hilbert phase data at '...
                  '%s (%g-%gHz).</strong>\n'], pbSpec(j).name, ...
                  data_hilbert.bpFreq);
        data_hilbert = JAI_rejectArtifacts(cfg, data_hilbert);
        fprintf('\n');
      end
    end
  
    % calculate PLV and meanPLV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cfg           = [];
    cfg.winlen    = pbSpec(j).winLength;                                    % window length for one PLV value in seconds

    data_plv  = JAI_phaseLockVal(cfg, data_hilbert);
    data_mplv = JAI_calcMeanPLV(data_plv);
    clear data_hilbert

    % export number of good trials into a spreadsheet
    cfg           = [];
    cfg.desFolder = [desPath '00_settings/'];
    cfg.dyad = i;
    cfg.type = 'plv';
    cfg.param = pbSpec(j).name;
    cfg.sessionStr = sessionStr;
    JAI_writeTbl(cfg, data_plv);

    % export the PLVs into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '07a_plv/');
    cfg.filename    = sprintf('JAI_d%02d_07a_plv%s', i, ...
                                pbSpec(j).fileSuffix);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Saving PLVs (%s: %g-%gHz) of dyad %d in:\n', ...
             pbSpec(j).name, data_plv.bpFreq, i);
    fprintf('%s ...\n', file_path);
    JAI_saveData(cfg, 'data_plv', data_plv);
    fprintf('Data stored!\n');
    clear data_plv

    % export the mean PLVs into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '07b_mplv/');
    cfg.filename    = sprintf('JAI_d%02d_07b_mplv%s', i, ...
                                pbSpec(j).fileSuffix);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Saving mean PLVs (%s: %g-%gHz) of dyad %d in:\n', ...
             pbSpec(j).name, data_mplv.bpFreq, i);
    fprintf('%s ...\n', file_path);
    JAI_saveData(cfg, 'data_mplv', data_mplv);
    fprintf('Data stored!\n\n');
    clear data_mplv
  end
  clear cfg_allart
end

%% clear workspace
clear cfg file_path sourceList numOfSources i artifactRejection ...
      artifactAvailable x choise T pbSpec j
