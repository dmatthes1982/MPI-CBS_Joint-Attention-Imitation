function [ cfgAutoArt ] = JAI_autoArtifact( cfg, data )
% JAI_AUTOARTIFACT marks timeslots as an artifact in which the values of
% specified channels exeeds either a min-max level, a defined range, a
% standard deviation threshold or a defined mutiple of the median absolute
% deviation.
%
% Use as
%   [ cfgAutoArt ] = JAI_autoArtifact(cfg, data)
%
% where data have to be a result of JAI_PREPROCESSING or JAI_CONCATDATA
%
% The configuration options are
%   cfg.channel     = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.method      = 'minmax', 'range' or 'stddev' (default: 'minmax'
%   cfg.sliding     = use a sliding window, 'yes' or 'no', (default: 'no')
%   cfg.winsize     = size of sliding window (default: 200 ms)
%                     only required if cfg.sliding = 'yes'
%   cfg.continuous  = data is continuous ('yes' or 'no', default: 'no')
%                     only required, if cfg.sliding = 'no'
%
% Specify the trial specification, which will later be used with artifact rejection
%   cfg.trllength   = trial length (default: 1000 ms = minimal subtrial length with plv estimation)
%   cfg.overlap     = amount of window overlapping in percentage (default: 0, permitted values: 0 or 50)
%
% Specify at least one of theses thresholds
%   cfg.min         = lower limit in uV for cfg.method = 0 (default: -75) 
%   cfg.max         = upper limit in uV for cfg.method = 0 (default: 75)
%   cfg.range       = range in uV (default: 200)
%   cfg.stddev      = standard deviation threshold in uV (default: 50)
%                     only usable, cfg.sliding = 'yes'
%   cfg.mad         = multiple of median absolute deviation (default: 3)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_GENTRL, JAI_PREPROCESSING, JAI_SEGMENTATION, 
% JAI_CONCATDATA, FT_ARTIFACT_THRESHOLD

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
chan        = ft_getopt(cfg, 'channel', {'Cz', 'O1', 'O2'});                % channels to test
method      = ft_getopt(cfg, 'method', 'minmax');                           % artifact detection method
sliding     = ft_getopt(cfg, 'sliding', 'no');                              % use a sliding window

if ~(strcmp(sliding, 'no') || strcmp(sliding, 'yes'))                       % validate cfg.sliding
  error('Sliding has to be either ''yes'' or ''no''!');
end

trllength   = ft_getopt(cfg, 'trllength',1000);                             % subtrial length to which the detected artifacts will be extended
overlap     = ft_getopt(cfg, 'overlap', 0);                                 % overlapping between the subtrials

if ~(overlap ==0 || overlap == 50)                                          % only non overlapping or 50% is allowed to simplify this function
  error('Currently there is only overlapping of 0 or 50% permitted');
end

cfgTrl          = [];
cfgTrl.length   = trllength;
cfgTrl.overlap  = overlap;
trl = JAI_genTrl(cfgTrl, data);                                             % generate subtrial specification

trllength = trllength * data.part1.fsample/1000;                            % convert subtrial length from milliseconds into number of samples

switch method                                                               % get and check method dependent config input
  case 'minmax'
    minVal    = ft_getopt(cfg, 'min', -75);
    maxVal    = ft_getopt(cfg, 'max', 75);
    if strcmp(sliding, 'no')
      continuous  = ft_getopt(cfg, 'continuous', 'no');
    else
      error('Method ''minmax'' is not supported with option sliding=''yes''');
    end
  case 'range'
    range     = ft_getopt(cfg, 'range', 200);
    if strcmp(sliding, 'no')
      continuous  = ft_getopt(cfg, 'continuous', 0);
    else
      winsize     = ft_getopt(cfg, 'winsize', 200);
    end
  case 'stddev'
    stddev     = ft_getopt(cfg, 'stddev', 50);
    if strcmp(sliding, 'no')
      error('Method ''stddev'' is not supported with option sliding=''no''');
    else
      winsize     = ft_getopt(cfg, 'winsize', 200);
    end
  case 'mad'
    mad     = ft_getopt(cfg, 'mad', 3);
    if strcmp(sliding, 'no')
      error('Method ''mad'' is not supported with option sliding=''no''');
    else
      winsize     = ft_getopt(cfg, 'winsize', 200);
    end
  otherwise
    error('Only ''minmax'', ''range'' and ''stdev'' are supported methods');
end

% -------------------------------------------------------------------------
% Artifact detection settings
% -------------------------------------------------------------------------
cfg = [];
cfg.artfctdef.threshold.channel   = chan;                                   % specify channels of interest
cfg.artfctdef.threshold.bpfilter  = 'no';                                   % use no additional bandpass
cfg.artfctdef.threshold.bpfreq    = [];                                     % use no additional bandpass
cfg.artfctdef.threshold.onset     = [];                                     % just defined to get a similar output from ft_artifact_threshold and artifact_threshold
cfg.artfctdef.threshold.offset    = [];                                     % just defined to get a similar output from ft_artifact_threshold and artifact_threshold
cfg.showcallinfo                  = 'no';

switch method                                                               % set method dependent config parameters
  case 'minmax'
    cfg.artfctdef.threshold.min     = minVal;                               % minimum threshold
    cfg.artfctdef.threshold.max     = maxVal;                               % maximum threshold
    if strcmp(sliding, 'no')
      cfg.continuous = continuous;
      cfg.trl        = trl;
    end
  case 'range'
    cfg.artfctdef.threshold.range   = range;                                % range
    if strcmp(sliding, 'yes')
      cfg.artfctdef.threshold.winsize = winsize;
      cfg.artfctdef.threshold.trl = trl;
    else
      cfg.continuous = continuous;
      cfg.trl        = trl;
    end
  case 'stddev'
    cfg.artfctdef.threshold.stddev  = stddev;                               % stddev
    if strcmp(sliding, 'yes')
      cfg.artfctdef.threshold.winsize = winsize;
      cfg.artfctdef.threshold.trl = trl;
    end
  case 'mad'
    cfg.artfctdef.threshold.mad  = mad;                                     % mad
    if strcmp(sliding, 'yes')
      cfg.artfctdef.threshold.winsize = winsize;
      cfg.artfctdef.threshold.trl = trl;
    end
end

% -------------------------------------------------------------------------
% Estimate artifacts
% -------------------------------------------------------------------------
cfgAutoArt.part1 = [];                                                      % build output structure
cfgAutoArt.part2 = [];
cfgAutoArt.bad1Num = []; 
cfgAutoArt.bad2Num = [];
cfgAutoArt.trialsNum = size(trl, 1);

if strcmp(sliding, 'no')                                                    % no sliding window --> use ft_artifacts_threshold function
  ft_info off;

  fprintf('<strong>Estimate artifacts in participant 1...</strong>\n');     % participant one
  cfgAutoArt.part1 = ft_artifact_threshold(cfg, data.part1);
  cfgAutoArt.part1 = keepfields(cfgAutoArt.part1, {'artfctdef', 'showcallinfo'});
  [cfgAutoArt.part1.artfctdef.threshold, cfgAutoArt.bad1Num] = ...          % extend artifacts to subtrial definition
                  combineArtifacts( overlap, trllength, cfgAutoArt.part1.artfctdef.threshold );
  fprintf('%d segments with artifacts detected!\n', cfgAutoArt.bad1Num);

  if cfgAutoArt.bad1Num == sum(generalDefinitions.trialNum1sec)
    warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
  end

  fprintf('<strong>Estimate artifacts in participant 2...</strong>\n');     % participant two
  cfgAutoArt.part2 = ft_artifact_threshold(cfg, data.part2);
  cfgAutoArt.part2 = keepfields(cfgAutoArt.part2, {'artfctdef', 'showcallinfo'});
  [cfgAutoArt.part2.artfctdef.threshold, cfgAutoArt.bad2Num] = ...          % extend artifacts to subtrial definition
                  combineArtifacts( overlap, trllength, cfgAutoArt.part2.artfctdef.threshold );
  fprintf('%d segments with artifacts detected!\n', cfgAutoArt.bad2Num);

  if cfgAutoArt.bad2Num == sum(generalDefinitions.trialNum1sec)
    warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
  end

  ft_info on;
else                                                                        % sliding window --> use own artifacts_threshold function
  fprintf('<strong>Estimate artifacts in participant 1...</strong>\n');     % participant one
  cfgAutoArt.part1 = artifact_threshold(cfg, data.part1);
  [cfgAutoArt.part1.artfctdef.threshold, cfgAutoArt.bad1Num] = ...          % extend artifacts to subtrial definition
                  combineArtifacts( overlap, trllength, cfgAutoArt.part1.artfctdef.threshold );
  fprintf('%d segments with artifacts detected!\n', cfgAutoArt.bad1Num);

  if cfgAutoArt.bad1Num == sum(generalDefinitions.trialNum1sec)
    warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
  end

  fprintf('<strong>Estimate artifacts in participant 2...</strong>\n');     % participant two
  cfgAutoArt.part2 = artifact_threshold(cfg, data.part2);
  [cfgAutoArt.part2.artfctdef.threshold, cfgAutoArt.bad2Num] = ...          % extend artifacts to subtrial definition
                  combineArtifacts( overlap, trllength, cfgAutoArt.part2.artfctdef.threshold );
  fprintf('%d segments with artifacts detected!\n', cfgAutoArt.bad2Num);

  if cfgAutoArt.bad2Num == sum(generalDefinitions.trialNum1sec)
    warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
  end
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION which extends and combines artifacts according to the
% subtrial definition
% -------------------------------------------------------------------------
function [ threshold, bNum ] = combineArtifacts( overl, trll, threshold )

if isempty(threshold.artifact)                                              % do nothing, if nothing was detected
  bNum = 0;
  return;
end

trlMask   = zeros(size(threshold.trl,1), 1);

for i = 1:size(threshold.trl,1)
  if overl == 0                                                             % if no overlapping was selected
    if any(~(threshold.artifact(:,2) < threshold.trl(i,1)) & ...            % mark artifacts which final points are not less than the trials zero point
            ~(threshold.artifact(:,1) > threshold.trl(i,2)))                % mark artifacts which zero points are not greater than the trials final point
      trlMask(i) = 1;                                                       % mark trial as bad, if both previous conditions are true at least for one artifact
    end
  else                                                                      % if overlapping of 50% was selected
    if any(~(threshold.artifact(:,2) < (threshold.trl(i,1) + trll/2)) & ... % mark artifacts which final points are not less than the trials zero point - trllength/2
            ~(threshold.artifact(:,1) > (threshold.trl(i,2) - trll/2)))     % mark artifacts which zero points are not greater than the trials final point + trllength/2
      trlMask(i) = 1;                                                       % mark trial as bad, if both previous conditions are true at least for one artifact
    end
  end
end

bNum = sum(trlMask);                                                        % calc number of bad segments
threshold.artifact = threshold.trl(logical(trlMask),1:2);                   % if trial contains artifacts, mark whole trial as artifact

if isfield(threshold, 'artfctmap')
  map = [];

  for i=1:1:size(threshold.artfctmap, 2)
    for j = 1:trll:(size(threshold.artfctmap{i},2) - trll + 1)
      map = [map sum(threshold.artfctmap{i}(:,j:j+trll-1) == 1, 2) > 0];    %#ok<AGROW>
    end
    threshold.artfctmap{i} = map;
    map = [];
  end

end

end

% -------------------------------------------------------------------------
% SUBFUNCTION which detects artifacts by using a sliding window
% -------------------------------------------------------------------------
function [ autoart ] = artifact_threshold(cfgT, data_in)

  numOfTrl  = length(data_in.trialinfo);                                    % get number of trials in the data
  winsize   = cfgT.artfctdef.threshold.winsize * data_in.fsample / 1000;    % convert window size from milliseconds to number of samples
  artifact  = zeros(0,2);                                                   % initialize artifact variable
  artfctmap{1,numOfTrl} = [];

  channel = ft_channelselection(cfgT.artfctdef.threshold.channel, ...
              data_in.label);

  for i = 1:1:numOfTrl
    data_in.trial{i} = data_in.trial{i}(ismember(data_in.label, ...         % prune the available data to the channels of interest
                        channel) ,:);
  end

  if isfield(cfgT.artfctdef.threshold, 'range')                             % check for range violations
    for i=1:1:numOfTrl
      tmpmin = movmin(data_in.trial{i}, winsize, 2);                        % get all minimum values
      if mod(winsize, 2)                                                    % remove useless results from the edges
        tmpmin = tmpmin(:, (winsize/2 + 1):(end-winsize/2));
      else
        tmpmin = tmpmin(:, (winsize/2 + 1):(end-winsize/2 + 1));
      end

      tmpmax = movmax(data_in.trial{i}, winsize, 2);                        % get all maximum values
      if mod(winsize, 2)                                                    % remove useless results from the edges
        tmpmax = tmpmax(:, (winsize/2 + 1):(end-winsize/2));
      else
        tmpmax = tmpmax(:, (winsize/2 + 1):(end-winsize/2 + 1));
      end
      tmp = abs(tmpmin - tmpmax);                                           % estimate a moving maximum difference

      artfctmap{i} = tmp > cfgT.artfctdef.threshold.range;                  % find all violations
      [channum, begnum] = find(artfctmap{i});                               % estimate pairs of channel numbers and begin numbers for each violation
      artfctmap{i} = [artfctmap{i} false(length(channel), winsize - 1)];    % extend artfctmap to trial size
      endnum = begnum + winsize - 1;                                        % estimate end numbers for each violation
      for j=1:1:length(channum)
        artfctmap{i}(channum(j), begnum(j):endnum(j)) = true;               % extend the violations in the map to the window size
      end
      if ~isempty(begnum)
        begnum = unique(begnum);                                            % select all unique violations
        begnum = begnum + data_in.sampleinfo(i,1) - 1;                      % convert relative sample number into an absolute one
        begnum(:,2) = begnum(:,1) + winsize - 1;
        artifact = [artifact; begnum];                                      %#ok<AGROW> add results to the artifacts matrix
      end
    end
  elseif isfield(cfgT.artfctdef.threshold, 'stddev')                        % check for standard deviation violations
    for i=1:1:numOfTrl
      tmp = movstd(data_in.trial{i}, winsize, 0, 2);                        % estimate a moving standard deviation
      if mod(winsize, 2)                                                    % remove useless results from the edges
        tmp = tmp(:, (winsize/2 + 1):(end-winsize/2));
      else
        tmp = tmp(:, (winsize/2 + 1):(end-winsize/2 + 1));
      end

      artfctmap{i} = tmp > cfgT.artfctdef.threshold.stddev;                 % find all violations
      [channum, begnum] = find(artfctmap{i});                               % estimate pairs of channel numbers and begin numbers for each violation
      artfctmap{i} = [artfctmap{i} false(length(channel), winsize - 1)];    % extend artfctmap to trial size
      endnum = begnum + winsize - 1;                                        % estimate end numbers for each violation
      for j=1:1:length(channum)
        artfctmap{i}(channum(j), begnum(j):endnum(j)) = true;               % extend the violations in the map to the window size
      end
      if ~isempty(begnum)
        begnum = unique(begnum);                                            % select all unique violations
        begnum = begnum + data_in.sampleinfo(i,1) - 1;                      % convert relative sample number into an absolute one
        begnum(:,2) = begnum(:,1) + winsize - 1;
        artifact = [artifact; begnum];                                      %#ok<AGROW> add results to the artifacts matrix
      end
    end
  elseif isfield(cfgT.artfctdef.threshold, 'mad')                           % check for median absolute deviation violations
    data_continuous = cat(2, data_in.trial{:});                             % concatenate all trials
    tmpmad = mad(data_continuous, 1, 2);                                    % estimate the median absolute deviation of the whole data
    tmpmedian = median(data_continuous, 2);                                 % estimate the median of the data

    for i=1:1:numOfTrl
      tmpmin = movmin(data_in.trial{i}, winsize, 2);                        % get all minimum values
      if mod(winsize, 2)                                                    % remove useless results from the edges
        tmpmin = tmpmin(:, (winsize/2 + 1):(end-winsize/2));
      else
        tmpmin = tmpmin(:, (winsize/2 + 1):(end-winsize/2 + 1));
      end

      tmpmax = movmax(data_in.trial{i}, winsize, 2);                        % get all maximum values
      if mod(winsize, 2)                                                    % remove useless results from the edges
        tmpmax = tmpmax(:, (winsize/2 + 1):(end-winsize/2));
      else
        tmpmax = tmpmax(:, (winsize/2 + 1):(end-winsize/2 + 1));
      end

      tmpdiffmax = abs(tmpmax - tmpmedian);                                 % estimate the differences between the maximum values and the median
      tmpdiffmin = abs(tmpmin - tmpmedian);                                 % estimate the differences between the minimum values and the median
      tmp = cat(3, tmpdiffmax, tmpdiffmin);                                 % select always the maximum absolute difference
      tmp = max(tmp, [], 3);

      artfctmap{i} = tmp > cfgT.artfctdef.threshold.mad*tmpmad;             % find all violations
      [channum, begnum] = find(artfctmap{i});                               % estimate pairs of channel numbers and begin numbers for each violation
      artfctmap{i} = [artfctmap{i} false(length(channel), winsize - 1)];    % extend artfctmap to trial size
      endnum = begnum + winsize - 1;                                        % estimate end numbers for each violation
      for j=1:1:length(channum)
        artfctmap{i}(channum(j), begnum(j):endnum(j)) = true;               % extend the violations in the map to the window size
      end
      if ~isempty(begnum)
        begnum = unique(begnum);                                            % select all unique violations
        begnum = begnum + data_in.sampleinfo(i,1) - 1;                      % convert relative sample number into an absolute one
        begnum(:,2) = begnum(:,1) + winsize - 1;
        artifact = [artifact; begnum];                                      %#ok<AGROW>  add results to the artifacts matrix
      end
    end
  end

  autoart.artfctdef     = cfgT.artfctdef;                                   % generate output data structure
  autoart.showcallinfo  = cfgT.showcallinfo;
  autoart.artfctdef.threshold.artifact  = artifact;
  autoart.artfctdef.threshold.artfctmap = artfctmap;
  autoart.artfctdef.threshold.sliding   = 'yes';

end
