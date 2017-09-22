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
timeOrg                 = dataPart1.time;
trial1                  = dataPart1.trial;
trial2                  = dataPart2.trial;

trialdiff{numOfTrials}  = [];
for i=1:1:numOfTrials
  trialdiff{i}          = trial1{i} - trial2{i};
end


N                       = cfgPLV.winlen * dataPart1.fsample;
PLV{numOfTrials}        = []; 
time{numOfTrials}       = [];

for i=1:1:numOfTrials
  lenOfTrial = length(trialdiff{i}(1,:));
  if N > lenOfTrial
    error('PLV window length is larger than the trial length, choose another size!');
  else
    numOfPLV = fix(lenOfTrial/N);
    for j=1:1:numOfPLV
      if mod(N, 2) == 0
        time{i}(1,j) = timeOrg{i}((j-1)*N + (N./2+1));
      else
        time{i}(1,j) = (timeOrg{i}((j-1)*N + (fix(N./2)+1)) + ...
                        timeOrg{i}((j-1)*N + (fix(N./2)+2))) / 2;
      end
    end
  end
  for k=1:1:numOfElec
    for l=1:1:numOfPLV
      window = trialdiff{i}(k,(l-1)*N + 1:l*N);
      PLV{i}(k,l) = abs(sum(exp(1i*window))/N);
    end
  end
end

numOfDiffTrials = length(unique(dataPart1.trialinfo));                      % merge all PLV values of one condition in one trial
trialinfo = zeros(numOfDiffTrials, 1);
condPLV{numOfDiffTrials} = [];
condTime{numOfDiffTrials} = [];

begsample = 1;

for i=1:1:numOfDiffTrials
  stim = dataPart1.trialinfo(begsample);
  endsample = find(dataPart1.trialinfo == stim, 1, 'last');
  trialinfo(i) = stim;
  condPLV{i} = cell2mat(PLV(begsample:endsample));
  condTime{i} = cell2mat(time(begsample:endsample));
  begsample = endsample + 1;
end

data_out                  = keepfields(dataPart1, {'hdr', 'fsample'});
data_out.trialinfo        = trialinfo;
data_out.PLV              = condPLV;
data_out.time             = condTime;
data_out.label            = dataPart1.label;
data_out.cfg              = cfgPLV;
data_out.cfg.previous{1}  = dataPart1.cfg;
data_out.cfg.previous{2}  = dataPart2.cfg;

end