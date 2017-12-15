function [ data ] = JAI_selectdata( cfg, data )
% JAI_SELECTDATA extracts specified channels from a dataset
%
% Use as
%   [ data  ] = JAI_selectdata( cfg, data )
%
% where input data can be nearly every sensor space data
%
% The configuration options are
%   cfg.channel = Nx1 cell-array with selection of channels (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_PREPROCESSING, JAI_SEGMENTATION, JAI_CONCATDATA,
% JAI_BPFILTERING

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
channel = ft_getopt(cfg, 'channel', 'all');

% -------------------------------------------------------------------------
% Channel extraction
% -------------------------------------------------------------------------
cfg              = [];
cfg.channel      = channel;
cfg.showcallinfo = 'no';

data.part1 = ft_selectdata(cfg, data.part1);
data.part2 = ft_selectdata(cfg, data.part2);

end

