function [ data_badchan ] = JAI_selectBadChan( data_raw )
% JAI_SELECTBADCHAN 

cfg           = [];
cfg.ylim      = [-200 200];
cfg.blocksize = 120;
cfg.part      = 1;
  
fprintf('Select bad channels of participant %d...\n', cfg.part);
JAI_databrowser( cfg, data_raw );
badLabel = JAI_channelCheckbox();
close(gcf);
fprintf('\n');
  
if ~isempty(badLabel)
  data_badchan.part1.badChan = data_raw.part1.label(ismember(...
                                          data_raw.part1.label, badLabel));
else
  data_badchan.part1.badChan = [];
end

cfg.part      = 2;
  
fprintf('Select bad channels of participant %d...\n', cfg.part);
JAI_databrowser( cfg, data_raw );
badLabel = JAI_channelCheckbox();
close(gcf);
fprintf('\n');
  
if ~isempty(badLabel)
  data_badchan.part2.badChan = data_raw.part2.label(ismember(...
                                          data_raw.part2.label, badLabel));
else
  data_badchan.part2.badChan = [];
end

end
