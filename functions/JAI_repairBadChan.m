function [ data_repaired ] = JAI_repairBadChan( data_badchan, data_raw )
% JAI_REPAIRBADCHAN 

load('mpi_customized_acticap32_neighb.mat', 'neighbours');
load('mpi_customized_acticap32.mat', 'lay');

cfg               = [];
cfg.method        = 'weighted';
cfg.neighbours    = neighbours;
cfg.layout        = lay;
cfg.trials        = 'all';
cfg.showcallinfo  = 'no';
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
  commandwindow;
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
  commandwindow;
  input('Press enter to continue!:');
  close(gcf);
end

fprintf('\n');

end
