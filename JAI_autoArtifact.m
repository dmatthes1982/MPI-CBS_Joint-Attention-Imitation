function [ cfgAutoArt ] = JAI_autoArtifact( cfg, data )
% JAI_AUTOARTIFACT marks timeslots as an artifact in which the level of 
% 'Cz', 'O2' and 'O4' exceeds or fall below +/- 75 mV.
%
% Use as
%   [ cfgAutoArt ] = JAI_autoArtifact(cfg, data)
%
% where data has to be a result of JAI_SEGMENTATION
%
% The configuration options are
%   cfg.channel = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.min     = lower limit in uV (default: -75)
%   cfg.max     = upper limit in uV (default: 75)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_SEGMENTATION, FT_ARTIFACT_THRESHOLD

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------

chan      = ft_getopt(cfg, 'channel', {'Cz', 'O1', 'O2'});
minVal    = ft_getopt(cfg, 'min', -75);
maxVal    = ft_getopt(cfg, 'max', 75);

% -------------------------------------------------------------------------
% Artifact detection settings
% -------------------------------------------------------------------------
ft_info off;

cfg                               = [];
cfg.continuous                    = 'no';                                   % data are already trial based
cfg.artfctdef.threshold.channel   = chan;                                   % specify channels of interest
cfg.artfctdef.threshold.bpfilter  = 'no';                                   % use no additional bandpass
cfg.artfctdef.threshold.min       = minVal;                                 % minimum threshold
cfg.artfctdef.threshold.max       = maxVal;                                 % maximum threshold
cfg.showcallinfo                  = 'no';

% -------------------------------------------------------------------------
% Estimate artifacts
% -------------------------------------------------------------------------
cfgAutoArt.part1 = [];                                                      % build output structure
cfgAutoArt.part2 = [];
cfgAutoArt.bad1Num = []; 
cfgAutoArt.bad2Num = [];
cfgAutoArt.trialsNum = [];

cfgAutoArt.trialsNum = length(data.part1.trial);                    
  
cfg.trl = data.part1.cfg.previous.trl;
fprintf('Estimate artifacts in participant 1...\n');
cfgAutoArt.part1    = ft_artifact_threshold(cfg, data.part1);
cfgAutoArt.part1    = keepfields(cfgAutoArt.part1, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad1Num  = length(cfgAutoArt.part1.artfctdef.threshold.artifact);
fprintf('%d artifacts detected!\n', cfgAutoArt.bad1Num);
  
cfg.trl = data.part2.cfg.previous.trl;
fprintf('Estimate artifacts in participant 2...\n');
cfgAutoArt.part2    = ft_artifact_threshold(cfg, data.part2);
cfgAutoArt.part2    = keepfields(cfgAutoArt.part2, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad2Num  = length(cfgAutoArt.part2.artfctdef.threshold.artifact);
fprintf('%d artifacts detected!\n', cfgAutoArt.bad2Num);

ft_info on;

end

