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

fprintf('Calc PLVs with a center frequency of %d Hz...\n', ...           
         data.centerFreq);
dataTmp.dyad  = phaseLockingValue(cfg, data.part1, data.part2);
dataTmp.centerFreq = data.centerFreq; 

data = dataTmp;

end

function [data_out] = phaseLockingValue(cfgPLV, dataPart1, dataPart2)

numOfTrials             = length(dataPart1.trial);
numOfElec               = length(dataPart1.label);
shifts                  = numOfElec - 1;
timeOrg                 = dataPart1.time;
trial_p1                = dataPart1.trial;
trial_p2                = dataPart2.trial;

N                                 = cfgPLV.winlen * dataPart1.fsample;
PLV{shifts+1, numOfTrials}        = []; 
time{shifts+1, numOfTrials}       = [];

for i = 1:1:numOfTrials
  VarA = trial_p1{i};
  VarB = trial_p2{i};
  for j = 0:1:shifts
    VarB_shifted = circshift(VarB, -j);
    trialdiff = VarA - VarB_shifted;
    lenOfTrial = length(trialdiff(1,:));
    if N > lenOfTrial
      error('PLV window length is larger than the trial length, choose another size!');
    else
      numOfPLV = fix(lenOfTrial/N);
      for k = 1:1:numOfPLV
        if mod(N, 2) == 0
          time{j+1, i}(1,k) = timeOrg{i}((k-1)*N + (N./2+1));
        else
          time{j+1, i}(1,k) = (timeOrg{i}((k-1)*N + (fix(N./2)+1)) + ...
                                timeOrg{i}((k-1)*N + (fix(N./2)+2))) / 2;
        end
      end
    end
    for l=1:1:numOfElec
      for m=1:1:numOfPLV
        window = trialdiff(l,(m-1)*N + 1:m*N);
        PLV{j+1,i}(l,m) = abs(sum(exp(1i*window))/N);
      end
    end
  end  
end

numOfDiffTrials = length(unique(dataPart1.trialinfo));                      % merge all PLV values of one condition in one trial
trialinfo = zeros(numOfDiffTrials, 1);
condPLV{shifts+1, numOfDiffTrials} = [];
condTime{shifts+1, numOfDiffTrials} = [];

begsample = 1;

for i=1:1:numOfDiffTrials
  stim = dataPart1.trialinfo(begsample);
  endsample = find(dataPart1.trialinfo == stim, 1, 'last');
  trialinfo(i) = stim;
  for j=0:1:shifts
    condPLV{j+1, i} = cell2mat(PLV(j+1, begsample:endsample));
    condTime{j+1, i} = cell2mat(time(j+1, begsample:endsample));
  end
  begsample = endsample + 1;
end

data_out                  = keepfields(dataPart1, {'hdr', 'fsample'});
data_out.trialinfo        = trialinfo;
data_out.PLV              = condPLV;
data_out.time             = condTime;
data_out.label            = dataPart1.label;
data_out.labelCircShift   = 0:-1:-(length(data_out.label)-1);
data_out.cfg              = cfgPLV;
data_out.cfg.previous{1}  = dataPart1.cfg;
data_out.cfg.previous{2}  = dataPart2.cfg;

end