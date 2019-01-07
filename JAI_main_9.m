%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '04c_preproc2';
  cfg.filename  = 'JAI_d01_04c_preproc2';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
  sourceList    = dir([strcat(desPath, '04c_preproc2/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('JAI_d%d_04c_preproc2_', sessionStr, '.mat'));
  end
end

%% part 9
% Calculate TFRs of the processed data

cprintf([0,0.6,0], '<strong>[9] - Power analysis (TFR, pWelch)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of time-frequency response (TFR)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the time-frequency response calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    tfr = true;
  elseif strcmp('n', x)
    choise = true;
    tfr = false;
  else
    choise = false;
  end
end
fprintf('\n');

if tfr == true
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);

    cfg             = [];                                                     % load EOG-artifact corrected data
    cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('JAI_d%02d_04c_preproc2', i);

    fprintf('Load preprocessed data...\n\n');
    JAI_loadData( cfg );

    cfg         = [];
    cfg.foi     = 2:1:50;                                                     % frequency of interest
    cfg.toi     = 4:0.5:176;                                                  % time of interest

    data_tfr = JAI_timeFreqanalysis( cfg, data_preproc2 );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '09a_tfr/');
    cfg.filename    = sprintf('JAI_d%02d_09a_tfr', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    JAI_saveData(cfg, 'data_tfr', data_tfr);
    fprintf('Data stored!\n\n');
    clear data_tfr data_preproc2
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of power spectral density using Welch's method (pWelch)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the power spectral density by using Welch''s method be calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    pwelch = true;
  elseif strcmp('n', x)
    choise = true;
    pwelch = false;
  else
    choise = false;
  end
end
fprintf('\n');

if pwelch == true
  choise = false;
  while choise == false
    cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PSD estimation?\n');
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
  if ~(exist(file_path, 'file') == 2)                                       % check if settings file already exist
    cfg = [];
    cfg.desFolder   = [desPath '00_settings/'];
    cfg.type        = 'settings';
    cfg.sessionStr  = sessionStr;
  
    JAI_createTbl(cfg);                                                     % create settings file
  end

  T = readtable(file_path);                                                 % update settings table
  warning off;
  T.artRejectPSD(numOfPart) = { x };
  warning on;
  delete(file_path);
  writetable(T, file_path);
  
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);
    
    % Load preprocessed data
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
    cfg.filename    = sprintf('JAI_d%02d_04c_preproc2', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load preprocessed data...\n\n');
    JAI_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of preprocessed data.</strong>\n');
    data_preproc2 = JAI_segmentation( cfg, data_preproc2 );

    fprintf('\n');
    
    % Load artifact definitions 
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
    
    % Artifact rejection
    if artifactRejection == true
      if artifactAvailable == true
        cfg           = [];
        cfg.artifact  = cfg_allart;
        cfg.reject    = 'complete';
        cfg.target    = 'single';

        fprintf('<strong>Artifact Rejection with preprocessed data.</strong>\n');
        data_preproc2 = JAI_rejectArtifacts(cfg, data_preproc2);
        fprintf('\n');
      end
      
      clear cfg_allart
    end
    
    % Estimation of power spectral density
    cfg         = [];
    cfg.foi     = 1:1:50;                                                   % frequency of interest
      
    data_preproc2 = JAI_pWelch( cfg, data_preproc2 );                       % calculate power spectral density using Welch's method
    data_pwelch = data_preproc2;                                            % to save need of RAM
    clear data_preproc2
    
    % export PSD data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '09b_pwelch/');
    cfg.filename    = sprintf('JAI_d%02d_09b_pwelch', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Power spectral density data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    JAI_saveData(cfg, 'data_pwelch', data_pwelch);
    fprintf('Data stored!\n\n');
    clear data_pwelch
  end
end

%% clear workspace
clear file_path cfg sourceList numOfSources i choise tfr pwelch T ...
      artifactRejection artifactAvailable
