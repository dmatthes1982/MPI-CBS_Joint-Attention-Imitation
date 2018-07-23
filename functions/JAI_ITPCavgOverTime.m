function [ data ] = JAI_ITPCavgOverTime( cfg, data)
% JAI_ITPCAVGOVERTIME averages the itpc results over time for selected
% frequencies.
%
% Use as
%   [ data ] = JAI_ITPCavgOverTime( cfg, data)
%
% where inpute data has to be the result of JAI_INTERTRIALPHASECOH.
%
% The configuration options are:
%   cfg.foi = frequencies of interest (default: [2,10,20])
%
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRIALPHASECOH

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cfgF.foi  = ft_getopt(cfg, 'foi', [2,10,20]);

% -------------------------------------------------------------------------
% Select frequencies and calculate average
% -------------------------------------------------------------------------
fprintf('<strong>Average ITPC of participant 1 for 2,10 and 20 Hz over time...\n</strong>');
data.part1 = selFreq(cfgF, data.part1);
data.part1 = calcAvg(data.part1);

fprintf('<strong>Average ITPC of participant 2 for 2,10 and 20 Hz over time...\n</strong>');
data.part2 = selFreq(cfgF, data.part2);
data.part2 = calcAvg(data.part2);

end

% -------------------------------------------------------------------------
% SUBFUNCTION - prune data, select certain frequencies
% -------------------------------------------------------------------------
function [dataTmp] = selFreq (cfgF, dataTmp )

loc = ismember(dataTmp.freq, cfgF.foi);
dataTmp.freq = dataTmp.freq(loc);

dataTmp.itpc = cellfun(@(x) x(:,loc,:), dataTmp.itpc,'UniformOutput', false);

end

% -------------------------------------------------------------------------
% SUBFUNCTION - calculate average over time
% -------------------------------------------------------------------------
function [dataTmp] = calcAvg (dataTmp)

dataTmp.itpc = cellfun(@(x) nanmean(x,3), dataTmp.itpc,'UniformOutput', false);
dataTmp.itpc = cellfun(@(x) squeeze(x), dataTmp.itpc, 'UniformOutput', false);

dataTmp = removefields(dataTmp, {'time'});

end
