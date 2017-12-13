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
%   cfg.reject    = 'none', 'partial','nan', or 'complete' (default = 'complete')
%   cfg.target    = type of rejection, options: 'single' or 'dual' (default: 'single');
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
reject    = ft_getopt(cfg, 'reject', 'complete');
target    = ft_getopt(cfg, 'target', 'single');

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

if ~strcmp(target, 'single') && ~strcmp(target, 'dual')
  error('Selected type is unknown. Choose single or dual');
end

if ~strcmp(reject, 'complete')
  artifact.part1.artfctdef.reject = reject;
  artifact.part2.artfctdef.reject = reject;
  artifact.part1.artfctdef.minaccepttim = 0.2;
  artifact.part2.artfctdef.minaccepttim = 0.2;
end


% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\nCleaning data of part 1...\n');
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part1, data.part1);
if strcmp(target, 'dual')
  ft_warning off;
  data.part1 = ft_rejectartifact(artifact.part2, data.part1);
end
  
fprintf('\nCleaning data of part 2...\n');
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part2, data.part2);
if strcmp(target, 'dual')
  ft_warning off;
  data.part2 = ft_rejectartifact(artifact.part1, data.part2);
end
  
ft_warning on;

end
