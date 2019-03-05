%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '07b_mplv/';
  cfg.filename  = 'JAI_d01_07b_mplvGamma';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData/';            % destination path for processed data  
end

%% part 10
% Averaging over dyads

cprintf([0,0.6,0], '<strong>[10] - Averaging over dyads</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging mPLVs over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging mPLVs over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  % passband specifications
  [pbSpec(1:6).fileSuffix]  = deal('2Hz','Theta','Alpha','20Hz','Beta','Gamma');
  [pbSpec(1:6).name]        = deal('2Hz','theta','alpha','20Hz','beta','gamma');

  for i = 1:1:numel(pbSpec)
    cfg               = [];
    cfg.path          = strcat(desPath, '07b_mplv/');
    cfg.session       = str2double(sessionStr);
    cfg.passband      = pbSpec(i).name;

    data_mplvod   = JAI_mPLVoverDyads( cfg );

    % export the averaged PLVs into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '10a_mplvod/');
    cfg.filename    = sprintf('JAI_10a_mplvod%s', pbSpec(i).fileSuffix);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                      '.mat');
                   
    fprintf('Saving mean PLVs over dyads at %s (%g-%gHz) in:\n', ...
              pbSpec(i).name, data_mplvod.bpFreq);
    fprintf('%s ...\n', file_path);
    JAI_saveData(cfg, 'data_mplvod', data_mplvod);
    fprintf('Data stored!\n\n');
    clear data_mplvod
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging iptc over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging IPTC over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  cfg             = [];
  cfg.path        = strcat(desPath, '08a_itpc/');
  cfg.session     = str2double(sessionStr);
  
  data_itpcod     = JAI_ITPCoverDyads( cfg );
  
  % export the averaged IPTCs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10b_itpcod/');
  cfg.filename    = 'JAI_10b_itpcod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving IPTCs over dyads in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_itpcod', data_itpcod);
  fprintf('Data stored!\n\n');
  clear data_itpcod
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging TFR over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging TFR over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  cfg             = [];
  cfg.path        = strcat(desPath, '09a_tfr/');
  cfg.session     = str2double(sessionStr);
  
  data_tfrod     = JAI_TFRoverDyads( cfg );
  
  % export the averaged TFR values into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10c_tfrod/');
  cfg.filename    = 'JAI_10c_tfrod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving TFR values over dyads in:\n');
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_tfrod', data_tfrod);
  fprintf('Data stored!\n\n');
  clear data_tfrod
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging power over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging power over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
    fprintf('\n');
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end

if avgOverDyads == true
  cfg             = [];
  cfg.path        = strcat(desPath, '09b_pwelch/');
  cfg.session     = str2double(sessionStr);
  
  data_pwelchod     = JAI_powOverDyads( cfg );
  
  % export the averaged power spectrum into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10d_pwelchod/');
  cfg.filename    = 'JAI_10d_pwelchod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving averaged power spectrum over dyads in:\n');
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_pwelchod', data_pwelchod);
  fprintf('Data stored!\n');
  clear data_pwelchod
end

%% clear workspace
clear cfg file_path avgOverDyads x choise i pbSpec
