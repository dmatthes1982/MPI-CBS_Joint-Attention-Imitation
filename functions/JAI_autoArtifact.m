function [ cfgAutoArt ] = JAI_autoArtifact( cfg, data )
% JAI_AUTOARTIFACT marks timeslots as an artifact in which the values of
% specified channels exeeds a min-max level or a defined range.
%
% Use as
%   [ cfgAutoArt ] = JAI_autoArtifact(cfg, data)
%
% where data have to be a result of JAI_PREPROCESSING, JAI_SEGMENTATION or 
% JAI_CONCATDATA
%
% The configuration options are
%   cfg.channel     = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.continuous  = data is continuous ('yes' or 'no', default: 'no')
%   cfg.trl         = trial definition (always necessary, generate with JAI_GENTRL) 
%   cfg.method      = type of artifact detection (0: lower/upper limit, 1: range)
%   cfg.min         = lower limit in uV for cfg.method = 0 (default: -75) 
%   cfg.max         = upper limit in uV for cfg.method = 0 (default: 75)
%   cfg.range       = range in uV for cfg.method = 1 (default: 200)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_GENTRL, JAI_PREPROCESSING, JAI_SEGMENTATION, 
% JAI_CONCATDATA, FT_ARTIFACT_THRESHOLD

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

if isempty(cfg.trl)
  error('cfg.trl is missing. You can use JAI_genTrl to generate the trl matrix');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

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
  cfg.artfctdef.threshold.min     = minVal;                                 % minimum threshold
  cfg.artfctdef.threshold.max     = maxVal;                                 % maximum threshold
elseif method == 1
  cfg.artfctdef.threshold.range   = range;                                  % range
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

cfgAutoArt.trialsNum = size(trl, 1);                    

fprintf('Estimate artifacts in participant 1...\n');
cfgAutoArt.part1    = ft_artifact_threshold(cfg, data.part1);
cfgAutoArt.part1    = keepfields(cfgAutoArt.part1, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad1Num  = calcBadNum( cfgAutoArt.part1.artfctdef.threshold );
fprintf('%d segments of 1 second with artifacts detected!\n', cfgAutoArt.bad1Num);

if cfgAutoArt.bad1Num == sum(generalDefinitions.trialNum1sec)
  warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
end

fprintf('Estimate artifacts in participant 2...\n');
cfgAutoArt.part2    = ft_artifact_threshold(cfg, data.part2);
cfgAutoArt.part2    = keepfields(cfgAutoArt.part2, ...
                                      {'artfctdef', 'showcallinfo'});
cfgAutoArt.bad2Num  = calcBadNum( cfgAutoArt.part2.artfctdef.threshold );
fprintf('%d segments of 1 second with artifacts detected!\n', cfgAutoArt.bad2Num);

if cfgAutoArt.bad2Num == sum(generalDefinitions.trialNum1sec)
  warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
end

ft_info on;

end

% -------------------------------------------------------------------------
% SUBFUNCTION which estimates segments of one second with artifacts
% -------------------------------------------------------------------------
function [ bNum ] = calcBadNum( threshold )

if isempty(threshold.artifact)
  bNum = 0;
  return;
end

begtrl = find(threshold.trl(:,1) <= threshold.artifact(1,1), 1, 'last');    % find first segment with artifacts
endtrl = find(threshold.trl(:,2) >= threshold.artifact(end,2), 1, 'first'); % find last segment with artifacts

trlMask = zeros(900,1);

for i = begtrl:endtrl
  if any(threshold.trl(i,1) <= threshold.artifact(:,1) & ...
         threshold.trl(i,2) >= threshold.artifact(:,2))
    trlMask(i) = 1;
  end
end

bNum = sum(trlMask);                                                        % calc number of bad segments

end
