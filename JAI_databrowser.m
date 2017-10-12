function cfgArtifacts = JAI_databrowser( cfg, data )
% JAI_DATABROWSER displays a certain joint attention imitation project 
% dataset using a appropriate scaling.
%
% Use as
%   JAI_databrowser( data )
%
% where the input can be the result of JAI_IMPORTDATASET,
% JAI_PREPROCESSING or JAI_SEGMENTATION
%
% The configuration options are
%   cfg.part      = number of participant (default: 1)
%   cfg.artifact  = Nx2 matrix with artifact segments (default: [])
%
% This function requires the fieldtrip toolbox
%
% See also JAI_IMPORTALLDATASETS, JAI_PREPROCESSING, JAI_SEGMENTATION, 
% JAI_DATASTRUCTURE, FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 1);
artifact  = ft_getopt(cfg, 'artifact', []);

if part < 1 || part > 2                                                     % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

% -------------------------------------------------------------------------
% Configure and start databrowser
% -------------------------------------------------------------------------
cfg                               = [];
cfg.ylim                          = [-80 80];
cfg.viewmode                      = 'vertical';
cfg.artfctdef.threshold.artifact  = artifact;
cfg.continuous                    = 'no';
cfg.channel                       = 'all';
cfg.showcallinfo                  = 'no';

fprintf('Databrowser - Participant: %d\n', part);

switch part
  case 1
    cfgArtifacts = ft_databrowser(cfg, data.part1);
  case 2
    cfgArtifacts = ft_databrowser(cfg, data.part2);
end

end
