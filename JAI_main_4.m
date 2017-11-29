%% calculate TFRs of the preprocessed data
% export the preprocessed data into a *.mat file

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('JAI_p%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preproc data...\n');
  JAI_loadData( cfg );

  cfg         = [];
  cfg.foi     = 2:1:50;                                                     % frequency of interest
  cfg.toi     = 4:0.5:176;                                                  % time of interest
  
  data_tfr1 = JAI_timeFreqanalysis( cfg, data_preproc );

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03_tfr1/');
  cfg.filename    = sprintf('JAI_p%02d_03_tfr1', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  JAI_saveData(cfg, 'data_tfr1', data_tfr1);
  fprintf('Data stored!\n\n');
  clear data_tfr1 data_preproc
end

%% clear workspace
clear file_path cfg sourceList numOfSources i