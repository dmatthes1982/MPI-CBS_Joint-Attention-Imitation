function [ data ] = JAI_calcMeanPLV( data )
% JAI_CALCMEANPLV estimates the mean of the phase locking values within the 
% different conditions for all dyads and connections.
%
% Use as
%   [ data ] = JAI_calcMeanPLV( data )
%
%  where the input data have to be the result from JAI_PHASELOCKVAL
%
% This function requires the fieldtrip toolbox
% 
% See also JAI_DATASTRUCTURE, JAI_PHASELOCKVAL

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Estimate mean Phase Locking Value (mPLV)
% -------------------------------------------------------------------------

fprintf('Calc mean PLVs with a center frequency of %g Hz...\n', ...           
          data.centerFreq);
numOfTrials = size(data.dyad.PLV, 2);
numOfElecA = size(data.dyad.PLV{1}, 1);
numOfElecB = size(data.dyad.PLV{1}, 2);

data.dyad.mPLV{1, numOfTrials} = [];
for i=1:1:numOfTrials
  data.dyad.mPLV{i} = zeros(numOfElecA, numOfElecB);
  for j=1:1:numOfElecA
    for k=1:1:numOfElecB
    data.dyad.mPLV{i}(j,k) = mean(cell2mat(data.dyad.PLV{i}(j,k)));
    end
  end
end
data.dyad = rmfield(data.dyad, {'time', 'PLV'});

end

