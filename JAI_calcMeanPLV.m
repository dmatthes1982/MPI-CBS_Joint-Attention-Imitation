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
numOfTrials = length(data.dyad.PLV);
data.dyad.mPLV{1,numOfTrials} = [];
for j=1:1:numOfTrials
  data.dyad.mPLV{j} = mean(data.dyad.PLV{j}, 2);
end
data.dyad = rmfield(data.dyad, {'time', 'PLV'});

end

