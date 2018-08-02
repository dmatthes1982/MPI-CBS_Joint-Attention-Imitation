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

% Load general definitions
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

dataTmp.itpc = fixTrialOrder( dataTmp.itpc, dataTmp.trialinfo, ...
                      generalDefinitions.condNumITPC);
dataTmp.trialinfo = generalDefinitions.condNumITPC';

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for
% missing conditions.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg )

emptyMatrix = NaN * ones(size(dataTmp{1}, 1), size(dataTmp{1}, 2));    % empty matrix with NaNs


if ~isequal(trInf, trInfOrg')
  missingPhases = ~ismember(trInfOrg, trInf);
  missingPhases = trInfOrg(missingPhases);
  missingPhases = vec2str(missingPhases, [], [], 0);
  cprintf([0,0.6,0], ...
          sprintf('Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
          missingPhases));
  [~, loc] = ismember(trInfOrg, trInf);
  tmpBuffer = [];
  tmpBuffer{length(trInfOrg)} = [];
  for i = 1:1:length(trInfOrg)
    if loc(i) == 0
      tmpBuffer{i} = emptyMatrix;
    else
      tmpBuffer(i) = dataTmp(loc(i));
    end
  end
  dataTmp = tmpBuffer;
end

end
