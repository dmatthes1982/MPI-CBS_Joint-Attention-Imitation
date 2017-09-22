function [ data ] = JAI_rejectArtifacts( cfg, data )
% JAI_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns clean data.
%
% Use as
%   [ data ] = JAI_rejectartifacts( cfg, data )
%
% where data can be a result of JAI_SEGMENTATION, JAI_BPFILTERING or
% JAI_HILBERTPHASE
%
% The configuration options are
%   cfg.artifact  = output of JAI_manArtifact or JAI_manArtifact 
%                   (see file JAI_pxx_05_autoArt_yyy.mat, JAI_pxx_06_allArt_yyy.mat)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_SEGMENTATION, JAI_BPFILTERING, JAI_HILBERTPHASE, 
% JAI_MANARTIFACT and JAI_AUTOARTIFACT 

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\nCleaning data of part 1...\n');
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part1, data.part1);
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part2, data.part1);
  
fprintf('\nCleaning data of part 2...\n');
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part1, data.part2);
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part2, data.part2);

ft_warning on;

end
