function [ data_badchan ] = JAI_selectBadChan( data_raw )
% JAI_SELECTBADCHAN can be used for selecting bad channels visually. The
% data will be presented in the fieldtrip databrowser view and the bad
% channels will be marked in the JAI_CHANNELCHECKBOX gui. The function
% returns a fieldtrip-like datastructure which includes only a cell array 
% for each participant with the selected bad channels.
%
% Use as
%   [ data_badchan ] = JAI_selectBadChan( data_raw )
%
% where the input has to be raw data
%
% The function requires the fieldtrip toolbox
%
% SEE also JAI_DATABROWSER and JAI_CHANNELCHECKBOX

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Databrowser settings
% -------------------------------------------------------------------------
cfg           = [];
cfg.ylim      = [-200 200];
cfg.blocksize = 120;
cfg.part      = 1;

% -------------------------------------------------------------------------
% Selection of bad channels
% -------------------------------------------------------------------------
fprintf('Select bad channels of participant %d...\n', cfg.part);
JAI_databrowser( cfg, data_raw );
badLabel = JAI_channelCheckbox();
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
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
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
fprintf('\n');
  
if ~isempty(badLabel)
  data_badchan.part2.badChan = data_raw.part2.label(ismember(...
                                          data_raw.part2.label, badLabel));
else
  data_badchan.part2.badChan = [];
end

end
