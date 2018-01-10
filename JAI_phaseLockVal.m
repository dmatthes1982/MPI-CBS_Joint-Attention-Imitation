function [ data ] = JAI_phaseLockVal( cfg, data )
% JAI_PHASELOCKVAL estimates the phase locking value between the
% the participants of the dyads over all conditions and trials in the 
% JAI_DATASTRUCTURE
%
% Use as
%   [ data ] = JAI_phaseLockVal( cfg, data )
%
% where the input data have to be the result from JAI_HILBERTPHASE
%
% The configuration options are
%   cfg.winlen    = length of window over which the PLV will be calculated. (default: 5 sec)
%                   minimum = 1 sec
% 
% Theoretical Background:                                    T
% The phase locking value is originally defined by Lachaux as a summation
% over N trials. Since this definition is only applicable for comparing
% event-related data, this function provides a variant of the originally
% version. In this case the summation is done over a sliding time
% intervall. This version has been frequently used in EEG hyperscanning
% studies.
%
% Equation:         PLV(t) = 1/T | Sigma(e^j(phi(n,t) - psi(n,t)) |
%                                   n=1
%
% Reference:
%   [Lachaux1999]   "Measuring Phase Synchrony in Brain Signals"
%
% This function requires the fieldtrip toolbox
%
% See also JAI_DATASTRUCTURE, JAI_HILBERTPHASE

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get config options
% Get number of participants
% -------------------------------------------------------------------------
cfg.winlen = ft_getopt(cfg, 'winlen', 5);

% -------------------------------------------------------------------------
% Estimate Phase Locking Value (PLV)
% -------------------------------------------------------------------------
dataTmp = struct;
dataTmp.dyad = [];

fprintf('Calc PLVs with a center frequency of %g Hz...\n', ...           
         data.centerFreq);
dataTmp.dyad  = phaseLockingValue(cfg, data.part1, data.part2);
dataTmp.centerFreq = data.centerFreq;
dataTmp.bpFreq = data.bpFreq;

data = dataTmp;
end

function [data_out] = phaseLockingValue(cfgPLV, dataPart1, dataPart2)
%--------------------------------------------------------------------------
% Initialze variables
%--------------------------------------------------------------------------
markerTemplate          = [111, 2, 3, 31, 32, 41, 42, 51, 52, 105, 100, ... % template including all available markers in correct order
                           101, 102, 7, 8, 9, 10, 11, 12, 20, 21, 22, ...
                           4, 5, 6];                      
numOfElec               = length(dataPart1.label);                          % number of electrodes
connections             = numOfElec;                                        % number of connections
timeOrg                 = dataPart1.time;                                   % extract original time vector
trial_p1                = dataPart1.trial;                                  % extract trials of participant 1  
trial_p2                = dataPart2.trial;                                  % extract trials of participant 2 
N                       = cfgPLV.winlen * dataPart1.fsample;                % Number of samples in one PLV window

orgTrialLength          = cellfun(@(x) length(x), dataPart1.trial);
divider                 = orgTrialLength./N;

if ~all(divider == round(divider))
  hits = find(divider ~= round(divider));
  error(['The trial lengths have to be mutiples of plv window ' ...
        'length. Error in trial(s): %d'], hits);
end

%--------------------------------------------------------------------------
% concatenate all trials with equal condition numbers
%--------------------------------------------------------------------------
uniqueTrials            = unique(dataPart1.trialinfo, 'stable');            % estimate unique phases                                
tf                      = ismember(markerTemplate, uniqueTrials);           % bring unique phase into a correct order
idx                     = 1:length(markerTemplate);
idx                     = idx(tf);
uniqueTrials            = markerTemplate(idx);

diffPhases              = length(uniqueTrials);                             % estimate number of different phases 
trialinfo               = zeros(diffPhases, 1);                             % build new trialinfo
catTrial_p1{diffPhases} = [];                                               % new cell vector for concatenated trial matrices of participant 1
catTrial_p2{diffPhases} = [];                                               % new cell vector for concatenated trial matrices of participant 2
catTimeOrg{diffPhases}  = [];                                               % new cell vector for concatenated time vectors   

for i=1:1:diffPhases                                                        % for all phases
  marker          = uniqueTrials(i);                                        % estimate i-th phase marker
  trials          = find(dataPart1.trialinfo == marker);                    % extract all trials with this marker
  trialinfo(i)    = marker;                                                 % put phase marker into new trialinfo
  catTimeOrg{i}   = cat(2, timeOrg{trials});                                % concatenate time elements
  catTrial_p1{i}  = cat(2, trial_p1{trials});                               % concatenate trials of participant 1
  catTrial_p2{i}  = cat(2, trial_p2{trials});                               % concatenate trials of participant 2
end

numOfTrials             = length(catTrial_p1);                              % number of trials
PLV{numOfTrials}        = [];                                               % PLV matrix 
time{numOfTrials}       = [];                                               % time matrix

%--------------------------------------------------------------------------
% Calculate PLV values
%--------------------------------------------------------------------------
for i = 1:1:numOfTrials                                                     % for all trials
  VarA        = catTrial_p1{i};                                             % extract i-th trial of participant 1
  VarA        = permute(VarA, [1, 3, 2]);                                   % rearrange dimensions (electrodes to first, samples to third)
  VarB        = catTrial_p2{i};                                             % extract i-th trial of participant 2
  VarB        = permute(VarB, [3, 1, 2]);                                   % rearrange dimensions (electrodes to second, samples to third)
  Time        = catTimeOrg{i};
  numOfPLV    = fix(size(VarA, 3)/N);                                         % calculate number of PLV values within one trial
  PLV{i}      = zeros(numOfElec, connections, numOfPLV);
  
  phasediff = VarA - VarB;                                                  % calculate phase diff for all electrodes and over all connections
  for k = 1:1:numOfPLV                                                      % for all windows in one trial                                                   
    if mod(N, 2) == 0                                                       % if PLV window length is even 
      time{1,i}(1,k) = Time((k-1)*N + (N./2+1));                            % estimate time points for each PLV value
    else                                                                    % if PLV window length is odd
      time{1,i}(1,k) = (Time((k-1)*N + (fix(N./2)+1)) + ...
                        Time((k-1)*N + (fix(N./2)+2))) / 2;
    end
    window = phasediff(:,:, (k-1)*N + 1:k*N);
    PLV{i}(:,:,k) = abs(sum(exp(1i*window), 3)/N);
  end
  PLV{i} = mat2cell(PLV{i}, ones(1,30), ones(1,30), size(PLV{i},3));
  PLV{i} = cellfun(@(x) squeeze(x)', PLV{i}, 'uniform', 0);
end

%--------------------------------------------------------------------------
% concatenate all trials with equal condition numbers
%--------------------------------------------------------------------------
data_out                  = keepfields(dataPart1, {'hdr', 'fsample'});
data_out.trialinfo        = trialinfo;
data_out.dimord           = 'trl_chan1_chan2';
data_out.PLV              = PLV;
data_out.time             = time;
data_out.label            = dataPart1.label;
data_out.cfg              = cfgPLV;
data_out.cfg.previous{1}  = dataPart1.cfg;
data_out.cfg.previous{2}  = dataPart2.cfg;

end