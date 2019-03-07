function [ data ] = JAI_flipData( cfg, data )
% JAI_FLIPDATA - This function is flipping the data. The flipping operation
% can be done either only for one specific participant or for both.
% Furthermore, flipping of the whole dataset as well as condition-wise
% flipping is supported.
%
% Use as
%   [ data ] = JAI_flipData( cfg, data )
%
% where the input can be any data.
%
% The configuration options are
%   cfg.part = participants which shall be processed: 'part1', 'part2' or 'both' (default: 'part2')
%   cfg.mode = flipping mode, options 'complete' or 'condwise' (default: 'condwise')
%
% This function requires the fieldtrip toolbox.
%
% See also FLIPLR

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 'part2');                                     % participant selection
mode = ft_getopt(cfg, 'mode', 'condwise');                                  % mode selection

if ~ismember(part, {'part1', 'part2', 'both'})                              % check cfg.part definition
  error('cfg.part has to either ''part1'', ''part2'' or ''both''.');
end

if ~ismember(mode, {'complete', 'condwise'})                                % check cfg.mode definition
  error('cfg.mode has to either ''complete'', or ''condwise''.');
end

% -------------------------------------------------------------------------
% Flip the data
% -------------------------------------------------------------------------
if ismember(part, {'part1', 'both'})
  fprintf('Flip data of participant 1...\n');
  data.part1 = flipping(mode, data.part1);
end

if ismember(part, {'part2', 'both'})
  fprintf('Flip data of participant 2...\n');
  data.part2 = flipping(mode, data.part2);
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION for flipping
% -------------------------------------------------------------------------
function [dataflip] = flipping( mode, dataflip )

dataflip.trial = cellfun(@(x) fliplr(x), dataflip.trial, 'UniformOutput', false);

switch mode
  case 'complete'
    dataflip.trial = fliplr(dataflip.trial);
  case 'condwise'
    trialinfo = unique(dataflip.trialinfo, 'stable');
    for i = 1:1:size(trialinfo, 1)
      tf = ismember(dataflip.trialinfo, trialinfo(i));
      dataflip.trial(tf) = fliplr(dataflip.trial(tf));
    end
end

end
