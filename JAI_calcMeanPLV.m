function [ data ] = JAI_calcMeanPLV( data )
% JAI_CALCMEANPLV estimates the mean of the phase locking values for all
% dyads and electrodes over the different conditions.
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

fprintf('Calc mean PLVs with a center frequency of %d Hz...\n', ...           
          data.centerFreq);
numOfTrials = size(data.dyad.PLV, 2);
shifts = size(data.dyad.PLV, 1);

data.dyad.mPLV{shifts, numOfTrials} = [];
for i=1:1:numOfTrials
  for j=1:1:shifts
    data.dyad.mPLV{j,i} = mean(data.dyad.PLV{j,i}, 2);
  end
end
data.dyad = rmfield(data.dyad, {'time', 'PLV'});

end

