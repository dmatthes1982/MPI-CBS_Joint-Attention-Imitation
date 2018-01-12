%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '07c_mplv/';
  cfg.filename  = 'JAI_d01_07c_mplvGamma';
  sessionStr    = sprintf('%03d', JAI_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01826/eegData/DualEEG_JAI_processedData_branch_ica/'; % destination path for processed data  
end

%% part 10
% Averaging over dyads

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
  cfg               = [];
  cfg.path          = strcat(desPath, '07c_mplv/');
  cfg.session       = str2num(sessionStr);                                  %#ok<ST2NM>
  cfg.passband      = '2Hz';

  data_mplvod_2Hz   = JAI_mPLVoverDyads( cfg );

  cfg.passband      = 'theta';

  data_mplvod_theta = JAI_mPLVoverDyads( cfg );
  
  cfg.passband      = 'alpha';

  data_mplvod_alpha = JAI_mPLVoverDyads( cfg );
  
  cfg.passband      = '20Hz';

  data_mplvod_20Hz  = JAI_mPLVoverDyads( cfg );
  
  cfg.passband      = 'beta';

  data_mplvod_beta  = JAI_mPLVoverDyads( cfg );
  
  cfg.passband      = 'gamma';

  data_mplvod_gamma = JAI_mPLVoverDyads( cfg );

  % export the averaged PLVs into a *.mat file
  % 2Hz
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvod2Hz';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at 2Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_2Hz', data_mplvod_2Hz);
  fprintf('Data stored!\n');
  clear data_mplvod_2Hz

  % theta
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvodTheta';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at theta (4-7Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_theta', data_mplvod_theta);
  fprintf('Data stored!\n');
  clear data_mplvod_theta
  
  % alpha
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvodAlpha';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at alpha (8-12Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_alpha', data_mplvod_alpha);
  fprintf('Data stored!\n');
  clear data_mplvod_alpha
  
  % 20Hz
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvod20Hz';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at 20Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_20Hz', data_mplvod_20Hz);
  fprintf('Data stored!\n');
  clear data_mplvod_20Hz
  
  % beta
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvodBeta';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at beta (13-30Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_beta', data_mplvod_beta);
  fprintf('Data stored!\n');
  clear data_mplvod_beta
  
  % gamma
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '10a_mplvod/');
  cfg.filename    = 'JAI_10a_mplvodGamma';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at gamma (31.48Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_mplvod_gamma', data_mplvod_gamma);
  fprintf('Data stored!\n\n');
  clear data_mplvod_gamma
end

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
  cfg.path        = strcat(desPath, '08b_itpc/');
  cfg.session     = str2num(sessionStr);                                    %#ok<ST2NM>
  
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
  fprintf('Data stored!\n');
  clear data_itpcod
end

%% clear workspace
clear cfg file_path avgOverDyads x choise