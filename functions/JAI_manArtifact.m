function [ cfgAllArt ] = JAI_manArtifact( cfg, data )
% JAI_MANARTIFACT - this function could be use to is verify the automatic 
% detected artifacts remove some of them or add additional ones if
% required.
%
% Use as
%   [ cfgAllArt ] = JAI_manArtifact(cfg, data)
%
% where data has to be a result of JAI_SEGMENTATION
%
% The configuration options are
%   cfg.artifact  = output of JAI_autoArtifact (see file JAI_dxx_05a_autoart_yyy.mat)
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_SEGMENTATION, JAI_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);
dyad      = ft_getopt(cfg, 'dyad', []);

% -------------------------------------------------------------------------
% Initialize settings, build output structure
% -------------------------------------------------------------------------
cfg             = [];
cfg.dyad        = dyad;
cfg.channel     = {'all', '-V1', '-V2'};
cfg.ylim        = [-100 100];
cfgAllArt.part1 = [];                                       
cfgAllArt.part2 = [];

% -------------------------------------------------------------------------
% Check Data
% -------------------------------------------------------------------------

fprintf('\n<strong>Search for artifacts with participant 1...</strong>\n');
cfg.part = 1;
cfg.artifact = artifact.part1.artfctdef.threshold.artifact;
ft_warning off;
cfgAllArt.part1 = JAI_databrowser(cfg, data);
cfgAllArt.part1 = keepfields(cfgAllArt.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('\n<strong>Search for artifacts with participant 2...</strong>\n');
cfg.part = 2;
cfg.artifact = artifact.part2.artfctdef.threshold.artifact;
ft_warning off;
cfgAllArt.part2 = JAI_databrowser(cfg, data);
cfgAllArt.part2 = keepfields(cfgAllArt.part2, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end