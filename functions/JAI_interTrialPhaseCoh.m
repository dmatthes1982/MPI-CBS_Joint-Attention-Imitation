function [ data ] = JAI_interTrialPhaseCoh(cfg, data)
% JAI_INTERTRIALPHASECOH estimates the inter-trial phase coherence (ITPC)
% of single participants for all different trials in the JAI_DATASTRUCTURE
%
% Use as
%   [ data ] = JAI_interTrialPhaseCoh( cfg, data )
%
% where the input data should be the result from JAI_SEGMENTATION
%
% The configuration options are
%   cfg.toi       = time of interest (default: 0:0.02:10)
%   cfg.foi       = frequency of interest (default: 1:0.5:48)
%
% Theoretical Background:
% ITC is a frequency-domain measure of the partial or exact synchronization  
% of activity at a particular latency and frequency to a set of 
% experimental events to which EEG data trials are time locked. The measure
% was  introduced by Tallon-Baudry et al. (1996) and  termed a "phase 
% locking factor". The term "inter-trial coherence" refers to its inter-
% pretation as the event-related phase coherence (ITPC) or event-related 
% linear coherence (ITLC) between recorded EEG activity and an event-phase 
% indicator function.  The  most  common (and  default) version is inter-
% trial phase coherence.
%                                         n
% Equation:         ITPC(f,t) = 1/n * | Sigma( F_k(f,t) / |F_k(f,t)| ) | 
%                                        k=1
%
% References:
%   [Delorme2004]   "EEGLAB: an open source toolbox for analysis of 
%                    single-trial EEG dynamics including independent 
%                    component analysis."
%   http://www.fieldtriptoolbox.org/faq/itc
%
% This function requires the fieldtrip toolbox
%
% See also JAI_DATASTRUCTURE, JAI_SEGMENTATION

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cfgSub.toi  = ft_getopt(cfg, 'toi', 0:0.2:9.8);
cfgSub.foi  = ft_getopt(cfg, 'foi', 1:0.5:48);

% -------------------------------------------------------------------------
% Estimate inter-trial phase coherence (ITPC)
% -------------------------------------------------------------------------
fprintf('<strong>Estimate ITPC for participant 1...</strong>\n');
data.part1 = interTrialPhaseCoh(cfgSub, data.part1);
  
fprintf('<strong>Estimate ITPC for participant 2...</strong>\n');
data.part2 = interTrialPhaseCoh(cfgSub, data.part2);

end

function [data_out] = interTrialPhaseCoh(cfgITPC, data_in)

if max(cfgITPC.toi) > max(data_in.time{1})                                  % check if trial length is long enough
  error('toi is larger than the trial length. - Use another toi or resegment the trials.');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');    
trialinfo     = unique(data_in.trialinfo, 'stable');                        % extract trialinfo
tf            = ismember(generalDefinitions.condNumITPC, trialinfo);        % bring trials into a correct order
trialinfo     = generalDefinitions.condNumITPC(tf)';

% -------------------------------------------------------------------------
% Calculate spectrum
% -------------------------------------------------------------------------
cfgFrq              = [];
cfgFrq.method       = 'wavelet';
cfgFrq.toi          = cfgITPC.toi;
cfgFrq.output       = 'fourier';
cfgFrq.foi          = cfgITPC.foi;
cfgFrq.showcallinfo = 'no';
cfgFrq.feedback     = 'no';

ft_notice off;
data_in.time(:) = { 0:(1/data_in.fsample): ...
                    ((length(data_in.time{1})-1)/data_in.fsample) };
data_freq       = ft_freqanalysis(cfgFrq, data_in);
ft_notice on;

% -------------------------------------------------------------------------
% Generate and add the meta conditions:
% MetaNo (201), Meta2Hz (202), Meta10Hz (203), Meta20Hz (204)
% -------------------------------------------------------------------------
cfg               = [];
cfg.channel       = 'all';
cfg.showcallinfo  = 'no';

cfg.trials  = [100,101,102];                                                % generate MetaNo condition
val = ismember(data_freq.trialinfo, cfg.trials);                            % estimate trial indices
cfg.trials = find(val);
if ~isempty(cfg.trials)
  trialinfo = [trialinfo; 201];
  data_metaNo = ft_selectdata(cfg, data_freq);
  data_metaNo = removefields(data_metaNo, {'cumtapcnt'});                   % to avoid a fieldtrip bug, which occurs if this meta dataset has only one good trial
  data_metaNo.trialinfo(:) = 201;
else
  data_metaNo = [];
end


cfg.trials  = [7,8,9];                                                      % generate Meta20Hz condition
val = ismember(data_freq.trialinfo, cfg.trials);                            % estimate trial indices
cfg.trials = find(val);
if ~isempty(cfg.trials)
  trialinfo = [trialinfo; 202];
  data_meta2Hz = ft_selectdata(cfg, data_freq);
  data_meta2Hz = removefields(data_meta2Hz, {'cumtapcnt'});                 % to avoid a fieldtrip bug, which occurs if this meta dataset has only one good trial
  data_meta2Hz.trialinfo(:) = 202;
else
  data_meta2Hz = [];
end


cfg.trials  = [10,11,12];                                                   % generate Meta10Hz condition
val = ismember(data_freq.trialinfo, cfg.trials);                            % estimate trial indices
cfg.trials = find(val);
if ~isempty(cfg.trials)
  trialinfo = [trialinfo; 203];
  data_meta10Hz = ft_selectdata(cfg, data_freq);
  data_meta10Hz = removefields(data_meta10Hz, {'cumtapcnt'});               % to avoid a fieldtrip bug, which occurs if this meta dataset has only one good trial
  data_meta10Hz.trialinfo(:) = 203;
else
  data_meta10Hz = [];
end


cfg.trials  = [20,21,22];                                                   % generate Meta20Hz condition
val = ismember(data_freq.trialinfo, cfg.trials);                            % estimate trial indices
cfg.trials = find(val);
if ~isempty(cfg.trials)
  trialinfo = [trialinfo; 204];
  data_meta20Hz = ft_selectdata(cfg, data_freq);
  data_meta20Hz = removefields(data_meta20Hz, {'cumtapcnt'});               % to avoid a fieldtrip bug, which occurs if this meta dataset has only one good trial
  data_meta20Hz.trialinfo(:) = 204;
else
  data_meta20Hz = [];
end

data_meta = {data_metaNo, data_meta2Hz, data_meta10Hz, data_meta20Hz};
val = cellfun(@(x) ~isempty(x), data_meta);
data_meta = data_meta(val);

cfg               = [];                                                     % add new conditions to the data struct
cfg.showcallinfo  = 'no';
ft_info off;
data_freq         = ft_appendfreq(cfg, data_freq, data_meta{:});
ft_info on;

% -------------------------------------------------------------------------
% Exclude all trials from ITPC calculation which have only one good trial
% -------------------------------------------------------------------------
for i = length(trialinfo):-1:1
  trials = find(data_freq.trialinfo == trialinfo(i));
  N = size(trials, 1);
  if N == 1
    warning backtrace off;
    warning(['Condition %d has only one good trial. Condition will be '...
             'removed for this dyad.'], trialinfo(i));
    warning backtrace on;
    trialinfo(i) = [];
  end
end

% -------------------------------------------------------------------------
% Calculate Inter-Trial-Coherence
% -------------------------------------------------------------------------
% make a new FieldTrip-style data structure containing the ITC
% copy the descriptive fields over from the frequency decomposition
data_out = [];
data_out.label      = data_freq.label;
data_out.freq       = data_freq.freq;
data_out.dimord     = 'rpt_chan_freq_time';
data_out.trialinfo  = trialinfo;
data_out.goodtrials = zeros(length(trialinfo), 1);

F = data_freq.fourierspctrm;                                                % copy the Fourier spectrum
F = F./abs(F);                                                              % divide by amplitude

data_out.itpc{1, length(trialinfo)} = [];
data_out.time{1, length(trialinfo)} = [];

for i = 1:1:length(trialinfo)
  trials = find(data_freq.trialinfo == trialinfo(i));
  N = size(trials, 1);
  data_out.goodtrials(i) = N;                                               % save the number of good trials for each condition 
  data_out.itpc{i} = sum(F(trials,:,:,:), 1);                               % sum angles
  data_out.itpc{i} = abs(data_out.itpc{i})/N;                               % take the absolute value and normalize
  data_out.itpc{i} = squeeze(data_out.itpc{i});                             % remove the first singleton dimension
  data_out.time{i} = data_freq.time;
end

end
