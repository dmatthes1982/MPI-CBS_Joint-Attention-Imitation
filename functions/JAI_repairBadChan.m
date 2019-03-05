function [ data ] = JAI_repairBadChan( data_badchan, data )
% JAI_REPAIRBADCHAN can be used for repairing previously selected bad
% channels. For repairing this function uses the weighted neighbour
% approach.
%
% Use as
%   [ data ] = JAI_repairBadChan( data_badchan, data )
%
% where data_badchan has to be the result of INFADI_SELECTBADCHAN.
%
% Used layout and neighbour definitions:
%   mpi_customized_acticap32.mat
%   mpi_customized_acticap32_neighb.mat
%
% The function requires the fieldtrip toolbox
%
% SEE also FT_CHANNELREPAIR

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

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
cfg.missingchannel    = data_badchan.part1.badChan;

fprintf('<strong>Repairing bad channels of participant 1...</strong>\n');
if isempty(cfg.missingchannel)
  fprintf('All channels are good, no repairing operation required!\n');
else
  ft_warning off;
  data.part1 = ft_channelrepair(cfg, data.part1);
  ft_warning on;
  data.part1 = removefields(data.part1, {'elec'});
  fprintf('\n');
end
label = [lay.label; {'EOGV'; 'EOGH'}];
data.part1 = correctChanOrder( data.part1, label);

cfg.missingchannel    = data_badchan.part2.badChan;

fprintf('<strong>Repairing bad channels of participant 2...</strong>\n');
if isempty(cfg.missingchannel)
  fprintf('All channels are good, no repairing operation required!\n');
else
  ft_warning off;
  data.part2 = ft_channelrepair(cfg, data.part2);
  ft_warning on;
  data.part2 = removefields(data.part2, {'elec'});
  fprintf('\n');
end
data.part2 = correctChanOrder( data.part2, label);

end

% -------------------------------------------------------------------------
% Local function - move corrected channel to original position
% -------------------------------------------------------------------------
function [ dataTmp ] = correctChanOrder( dataTmp, label )

[~, pos]  = ismember(label, dataTmp.label);
pos       = pos(~ismember(pos, 0));

dataTmp.label = dataTmp.label(pos);
dataTmp.trial = cellfun(@(x) x(pos, :), dataTmp.trial, 'UniformOutput', false);

end
