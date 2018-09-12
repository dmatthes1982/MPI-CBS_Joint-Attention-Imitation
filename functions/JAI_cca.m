function [data_cca] = JAI_cca( data_bpfilt )
% JAI_cca conducts a canonical correlation analysis using the datasets of 
% both participants
%
% Use as
%   [ data ] = JAI_cca( data_bpfilt )
%
% where the input data have to be the result of JAI_BPFILTERING
%
% See also JAI_BPFILTERING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% CCA decomposition
% -------------------------------------------------------------------------
fprintf('<strong>Run CCA with at a center frequency of %g Hz...</strong>\n', ...           
         data_bpfilt.centerFreq);

data_cca = canonCorrAnalysis( data_bpfilt) ;

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_cca ] = canonCorrAnalysis( data_bpfilt)
% -------------------------------------------------------------------------
% Generate output data structure
% -------------------------------------------------------------------------
data_cca            = struct('part1', [], 'part2', [], 'dyad', []);
data_cca.centerFreq = data_bpfilt.centerFreq;
data_cca.bpFreq     = data_bpfilt.bpFreq;

data_cca.part1.time       = data_bpfilt.part1.time;
data_cca.part1.fsample    = data_bpfilt.part1.fsample;
data_cca.part1.trialinfo  = data_bpfilt.part1.trialinfo;
data_cca.part1.sampleinfo = data_bpfilt.part1.sampleinfo;
data_cca.part1.topolabel  = data_bpfilt.part1.label;

data_cca.part2.time       = data_bpfilt.part2.time;
data_cca.part2.fsample    = data_bpfilt.part2.fsample;
data_cca.part2.trialinfo  = data_bpfilt.part2.trialinfo;
data_cca.part2.sampleinfo = data_bpfilt.part2.sampleinfo;
data_cca.part2.topolabel  = data_bpfilt.part2.label;

numOfTrials = length( data_bpfilt.part1.trial );

data_cca.part1.trial{numOfTrials} = [];
data_cca.part1.topo{numOfTrials}  = [];
data_cca.part1.W{numOfTrials}     = [];

data_cca.part2.trial{numOfTrials} = [];
data_cca.part2.topo{numOfTrials}  = [];
data_cca.part2.W{numOfTrials}     = [];

% -------------------------------------------------------------------------
% Do CCA
% -------------------------------------------------------------------------
for i = 1:1:numOfTrials
  M1 = transpose(data_bpfilt.part1.trial{i});
  M2 = transpose(data_bpfilt.part2.trial{i});
  
  [W1, W2, R] = canoncorr(M1, M2);
  
  if i == 1
    data_cca.dyad.R         = zeros(numOfTrials, length(R));
    data_cca.dyad.dimord    = 'rpt_comp';
    data_cca.dyad.trialinfo = data_cca.part1.trialinfo;
    data_cca.part1.label    = cell(length(R), 1);
    for j = 1:1:length(R)
      data_cca.part1.label{j} = sprintf('cca%03d', j);
    end
    data_cca.part2.label    = data_cca.part1.label;
  end
  
  data_cca.part1.W{i}   = W1;
  data_cca.part2.W{i}   = W2;
  
  data_cca.part1.trial{i} = transpose(M1 * W1);
  data_cca.part2.trial{i} = transpose(M2 * W2);
  
  data_cca.part1.topo{i}      = cov(M1) * W1;
  data_cca.part1.unmixing{i}  = inv(data_cca.part1.topo{i});
  data_cca.part2.topo{i}      = cov(M2) * W2;
  data_cca.part2.unmixing{i}  = inv(data_cca.part2.topo{i});
  
  data_cca.dyad.R(i,:)  = R;
end

end
