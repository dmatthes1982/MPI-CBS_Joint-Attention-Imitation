function [ data ] = JAI_segmentation(cfg, data )
% JAI_SEGMENTATION segments the data of each condition into segments with a
% certain length
%
% Use as
%   [ data ] = JAI_segmentation( cfg, data )
%
% where the input data can be the result from JAI_IMPORTDATASET, 
% JAI_PREPROCESSING, JAI_BPFILTERING or JAI_HILBERTPHASE
%
% The configuration options are
%   cfg.length    = length of segments (excepted values: 0.2, 1, 5, 10 seconds, default: 1)
%   cfg.overlap   = percentage of overlapping (range: 0 ... 1, default: 0)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_IMPORTDATASET, JAI_PREPROCESSING, FT_REDEFINETRIAL,
% JAI_DATASTRUCTURE, JAI_BPFILTERING, JAI_HILBERTPHASE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
segLength = ft_getopt(cfg, 'length', 1);
overlap   = ft_getopt(cfg, 'overlap', 0);

possibleLengths = [0.2, 1, 5, 10];

if ~any(ismember(possibleLengths, segLength))
  error('Excepted cfg.length values are only 0.2, 1, 5 and 10 seconds');
end

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = segLength;
cfg.overlap         = overlap;

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('Segment data of participant 1...\n');
ft_info off;
ft_warning off;
data.part1 = ft_redefinetrial(cfg, data.part1);
    
fprintf('Segment data of participant 2...\n');
ft_info off;
ft_warning off;
data.part2 = ft_redefinetrial(cfg, data.part2);
    
ft_info on;
ft_warning on;
