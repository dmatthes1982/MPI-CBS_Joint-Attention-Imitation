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
numOfTrials             = length(dataPart1.trial);                          % number of trials
numOfElec               = length(dataPart1.label);                          % number of electrodes
connections             = numOfElec;                                        % number of connections
timeOrg                 = dataPart1.time;                                   % extract original time vector
trial_p1                = dataPart1.trial;                                  % extract trials of participant 1  
trial_p2                = dataPart2.trial;                                  % extract trials of participant 2 

N                               = cfgPLV.winlen * dataPart1.fsample;        % Number of samples in one PLV window
PLV{connections, numOfTrials}   = [];                                       % PLV matrix 
time{1, numOfTrials}  = [];                                                 % time matrix

%--------------------------------------------------------------------------
% Calculate PLV values
%--------------------------------------------------------------------------
for i = 1:1:numOfTrials                                                     % for all trials
  VarA = trial_p1{i};                                                       % extract i-th trial of participant 1
  VarB = trial_p2{i};                                                       % extract i-th trial of participant 2
  lenOfTrial = length(VarA(1,:));                                           % estimate trial length
  if N > lenOfTrial                                                         % error if PLV window length exceeds the trial length
    error('PLV window length is larger than the trial length, choose another size!');
  else
    numOfPLV = fix(lenOfTrial/N);                                           % calculate number of PLV values within one trial
    for k = 1:1:numOfPLV                                                    % estimate time points for each PLV value
      if mod(N, 2) == 0                                                     % if PLV window length is even 
        time{1,i}(1,k) = timeOrg{i}((k-1)*N + (N./2+1));
      else                                                                  % if PLV window length is odd
        time{1,i}(1,k) = (timeOrg{i}((k-1)*N + (fix(N./2)+1)) + ...
                        timeOrg{i}((k-1)*N + (fix(N./2)+2))) / 2;
      end
    end
  end
  for j = 1:1:connections                                                   % for all connections
    VarB_shifted = circshift(VarB, -(j-1));                                 % rotate trial matrix of participant 2
    phasediff = VarA - VarB_shifted;                                        % calculate phase difference
    for l=1:1:numOfElec                                                     % for all electrodes
      for m=1:1:numOfPLV                                                    % for all windows in one trial
        window = phasediff(l,(m-1)*N + 1:m*N);
        PLV{j,i}(l,m) = abs(sum(exp(1i*window))/N);
      end
    end
  end  
end

%--------------------------------------------------------------------------
% concatenate all trials with equal condition numbers
%--------------------------------------------------------------------------
uniqueTrials = unique(dataPart1.trialinfo, 'stable');                       % estimate unique phases                                
diffPhases = length(uniqueTrials);                                          % estimate number of different phases 
trialinfo = zeros(diffPhases, 1);                                           % build new trialinfo
catPLV{connections, diffPhases} = [];                                       % concatenated PLV matrix                                 
catTime{1, diffPhases} = [];                                                % concatenated Time matrix   

for i=1:1:diffPhases                                                        % for all phases
  marker = uniqueTrials(i);                                                 % estimate i-th phase marker
  trials = find(dataPart1.trialinfo == marker);                             % extract all trials with this marker
  trialinfo(i) = marker;                                                    % put phase marker into new trialinfo
  catTime{1, i} = cell2mat(time(1, trials));                                % concatenate time elements
  for j=1:1:connections
    catPLV{j, i} = cell2mat(PLV(j, trials));                                % concatenate trials   
  end
end

%--------------------------------------------------------------------------
% reorganize catPLV matrix in a mor logic form
%--------------------------------------------------------------------------
elecA = 1:1:numOfElec;
elecB = 1:1:numOfElec;
temp{length(elecA), length(elecB)} = [];
numOfTrials = size(catPLV, 2);

for i=1:1:numOfTrials
  reorgCatPLV{i} = temp;                                                    %#ok<AGROW>
  for j=1:1:connections
    elecBshift = circshift(elecB, -(j-1));
    for k=1:1:numOfElec
      reorgCatPLV{i}{elecA(k), elecBshift(k)} = catPLV{j,i}(k,:);
    end
  end
end

data_out                  = keepfields(dataPart1, {'hdr', 'fsample'});
data_out.trialinfo        = trialinfo;
data_out.dimord           = 'trl_chan1_chan2';
data_out.PLV              = reorgCatPLV;
data_out.time             = catTime;
data_out.label            = dataPart1.label;
data_out.cfg              = cfgPLV;
data_out.cfg.previous{1}  = dataPart1.cfg;
data_out.cfg.previous{2}  = dataPart2.cfg;

end