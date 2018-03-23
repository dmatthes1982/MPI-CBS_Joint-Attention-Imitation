function [ data ] = JAI_selectdata( cfg, data )
% JAI_SELECTDATA extracts specified channels from a dataset
%
% Use as
%   [ data  ] = JAI_selectdata( cfg, data )
%
% where input data can be nearly every sensor space data
%
% The configuration options are
%   cfg.channel = 1xN cell-array with selection of channels (default = 'all')
%   cfg.trials  = 1xN vector of condition numbers or 'all' (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_PREPROCESSING, JAI_SEGMENTATION, JAI_CONCATDATA,
% JAI_BPFILTERING

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
channel = ft_getopt(cfg, 'channel', 'all');
trials  = ft_getopt(cfg, 'trials', 'all');

% -------------------------------------------------------------------------
% Estimate trial indices
% ------------------------------------------------------------------------
if ischar(trials)
  trialsPart1 = trials;
  trialsPart2 = trials;
else
  val = ismember(data.part1.trialinfo, trials);                             % estimate trial indices
  trialsPart1 = find(val);
  val = ismember(data.part2.trialinfo, trials);                             % estimate trial indices
  trialsPart2 = find(val);
end

% -------------------------------------------------------------------------
% Channel extraction
% -------------------------------------------------------------------------
cfg              = [];
cfg.channel      = channel;
cfg.showcallinfo = 'no';

cfg.trials = trialsPart1;
data.part1 = ft_selectdata(cfg, data.part1);

cfg.trials = trialsPart2;
data.part2 = ft_selectdata(cfg, data.part2);

end

