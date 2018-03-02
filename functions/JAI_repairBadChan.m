function [ data_repaired ] = JAI_repairBadChan( data_badchan, data_raw )
% JAI_REPAIRBADCHAN can be used for repairing previously selected bad
% channels. For repairing this function uses the weighted neighbour
% approach. After the repairing operation, the result will be displayed in
% the fieldtrip databrowser for verification purpose.
%
% Use as
%   [ data_repaired ] = JAI_repairBadChan( data_badchan, data_raw )
%
% where data_raw has to be raw data and data_badchan the result of
% JAI_SELECTBADCHAN.
%
% Used layout and neighbour definitions:
%   mpi_customized_acticap32.mat
%   mpi_customized_acticap32_neighb.mat
%
% The function requires the fieldtrip toolbox
%
% SEE also JAI_DATABROWSER and FT_CHANNELREPAIR

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load layout and neighbour definitions
% -------------------------------------------------------------------------
load('mpi_customized_acticap32_neighb.mat', 'neighbours');
load('mpi_customized_acticap32.mat', 'lay');

% -------------------------------------------------------------------------
% Configure Repairing
% -------------------------------------------------------------------------
cfg               = [];
cfg.method        = 'weighted';
cfg.neighbours    = neighbours;
cfg.layout        = lay;
cfg.trials        = 'all';
cfg.showcallinfo  = 'no';

% -------------------------------------------------------------------------
% Repairing bad channels
% -------------------------------------------------------------------------
cfg.badchannel    = data_badchan.part1.badChan;

fprintf('Repairing bad channels of participant 1...\n');
if isempty(cfg.badchannel)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.part1 = data_raw.part1;
else
  data_repaired.part1 = ft_channelrepair(cfg, data_raw.part1);
  data_repaired.part1 = removefields(data_repaired.part1, {'elec'});
  
  cfgView           = [];
  cfgView.ylim      = [-200 200];
  cfgView.blocksize = 120;
  cfgView.part      = 1;
  
  fprintf('\nVerification view for participant %d...\n', cfgView.part);
  JAI_databrowser( cfgView, data_repaired );
  commandwindow;                                                            % set focus to commandwindow
  input('Press enter to continue!:');
  close(gcf);
end

cfg.badchannel    = data_badchan.part2.badChan;

fprintf('Repairing bad channels of participant 2...\n');
if isempty(cfg.badchannel)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.part2 = data_raw.part2;
else
  data_repaired.part2 = ft_channelrepair(cfg, data_raw.part2);
  data_repaired.part2 = removefields(data_repaired.part2, {'elec'});
  
  cfgView           = [];
  cfgView.ylim      = [-200 200];
  cfgView.blocksize = 120;
  cfgView.part      = 2;
  
  fprintf('\nVerification view for participant %d...\n', cfgView.part);
  JAI_databrowser( cfgView, data_repaired );
  commandwindow;                                                            % set focus to commandwindow
  input('Press enter to continue!:');
  close(gcf);
end

fprintf('\n');

end
