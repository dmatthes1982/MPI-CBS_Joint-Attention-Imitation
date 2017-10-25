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
%   cfg.type      = type of rejection, options: 'single' or 'dual' (default: 'single');
%                   'single' = trials of a certain participant will be 
%                              rejected, if they are marked as bad 
%                              for that particpant (useable for ITPC calc)
%                   'dual' = trials of a certain participant will be
%                            rejected, if they are marked as bad for
%                            that particpant or for the other participant
%                            of the dyad (useable for PLV calculation)
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
type      = ft_getopt(cfg, 'type', 'single');

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

if ~strcmp(type, 'single') && ~strcmp(type, 'dual')
  error('Selected type is unknown. Choose single or dual');
end

% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\nCleaning data of part 1...\n');
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part1, data.part1);
if strcmp(type, 'dual')
  ft_warning off;
  data.part1 = ft_rejectartifact(artifact.part2, data.part1);
end
  
fprintf('\nCleaning data of part 2...\n');
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part2, data.part2);
if strcmp(type, 'dual')
  ft_warning off;
  data.part2 = ft_rejectartifact(artifact.part1, data.part2);
end
  
ft_warning on;

end
