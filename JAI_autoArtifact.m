function [ cfgAutoArt ] = JAI_autoArtifact( cfg, data )
% JAI_AUTOARTIFACT marks timeslots as an artifact in which the values of
% specified channels exeeds a min-max levels or a defined range.
%
% Use as
%   [ cfgAutoArt ] = JAI_autoArtifact(cfg, data)
%
% where data has to be a result of JAI_SEGMENTATION
%
% The configuration options are
%   cfg.channel     = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.continuous  = data is continuous ('yes' or 'no', default: 'no')
%   cfg.trl         = trial definition (only necessary, if called with continuous data, default: []) 
%   cfg.method      = type of artifact detection (0: lower/upper limit, 1: range)
%   cfg.min         = lower limit in uV for cfg.method = 0 (default: -75) 
%   cfg.max         = upper limit in uV for cfg.method = 0 (default: 75)
%   cfg.range       = range in uV for cfg.method = 1 (default: 200)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_SEGMENTATION, FT_ARTIFACT_THRESHOLD

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
chan        = ft_getopt(cfg, 'channel', {'Cz', 'O1', 'O2'});
continuous  = ft_getopt(cfg, 'continuous', 'no');
trl         = ft_getopt(cfg, 'trl', []);
method      = ft_getopt(cfg, 'method', 0);

switch method
  case 0
    minVal    = ft_getopt(cfg, 'min', -75);
    maxVal    = ft_getopt(cfg, 'max', 75);
  case 1
    range     = ft_getopt(cfg, 'range', 200);
  otherwise
    error('Only 0: lower/upper limit or 1: range are supported methods.');
end

% -------------------------------------------------------------------------
% Artifact detection settings
% -------------------------------------------------------------------------
ft_info off;

cfg                               = [];
cfg.continuous                    = continuous;
cfg.trl                           = trl;
cfg.artfctdef.threshold.channel   = chan;                                   % specify channels of interest
cfg.artfctdef.threshold.bpfilter  = 'no';                                   % use no additional bandpass
if method == 0
  cfg.artfctdef.threshold.min       = minVal;                               % minimum threshold
  cfg.artfctdef.threshold.max       = maxVal;                               % maximum threshold
elseif method == 1
  cfg.artfctdef.threshold.range     = range;                                % range
end
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

if isempty(cfg.trl)
  cfg.trl = data.part1.cfg.trl;
end
fprintf('Estimate artifacts in participant 1...\n');
cfgAutoArt.part1    = ft_artifact_threshold(cfg, data.part1);
cfgAutoArt.part1    = keepfields(cfgAutoArt.part1, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad1Num  = length(cfgAutoArt.part1.artfctdef.threshold.artifact);
fprintf('%d artifacts detected!\n', cfgAutoArt.bad1Num);

if isempty(cfg.trl)
  cfg.trl = data.part2.cfg.trl;
end
fprintf('Estimate artifacts in participant 2...\n');
cfgAutoArt.part2    = ft_artifact_threshold(cfg, data.part2);
cfgAutoArt.part2    = keepfields(cfgAutoArt.part2, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad2Num  = length(cfgAutoArt.part2.artfctdef.threshold.artifact);
fprintf('%d artifacts detected!\n', cfgAutoArt.bad2Num);

ft_info on;

end
