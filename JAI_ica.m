function [ data ] = JAI_ica( cfg, data )
% JAI_ICA conducts an independent component analysis on both participants
%
% Use as
%   [ data ] = JAI_ica( cfg, data )
%
% where the input data have to be the result from JAI_CONCATDATA
%
% The configuration options are
%   cfg.channel       = cell-array with channel selection (default = {'all', '-EOGV', '-EOGH'})
%   cfg.numcomponent  = 'all' or number (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_CONCATDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
channel         = ft_getopt(cfg, 'channel', {'all', '-EOGV', '-EOGH', '-REF'});
numOfComponent  = ft_getopt(cfg, 'numcomponent', 'all');

% -------------------------------------------------------------------------
% ICA decomposition
% -------------------------------------------------------------------------
cfg               = [];
cfg.method        = 'runica';
cfg.channel       = channel;
cfg.trials        = 'all';
cfg.numcomponent  = numOfComponent;
cfg.demean        = 'no';
cfg.updatesens    = 'no';
cfg.showcallinfo  = 'no';

fprintf('\nICA decomposition for participant 1...\n\n');
data.part1 = ft_componentanalysis(cfg, data.part1);
fprintf('\nICA decomposition for participant 2...\n\n');
data.part2 = ft_componentanalysis(cfg, data.part2);

end
