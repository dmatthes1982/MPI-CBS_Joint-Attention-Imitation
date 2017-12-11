function [ trl ] = JAI_genTrl( cfg, data )
% JAI_GENTRL is a function which generates a trl fragmentation of 
% continuous data for subsequent artifact detection. This function could be 
% used when the actual segmentation of the data is not needed for the 
% subsequent steps (i.e. in line with the estimation of eye artifacts)
%
% Use as
%   [ trl ] = JAI_genTrl( cfg, data )
%
% where the input data have to be the result from JAI_CONCATDATA
%
% The configuration options are 
%   cfg.length  = trial length in milliseconds (default: 200, choose even number)
%   cfg.overlap = amount of overlapping in percentage (default: 0, permitted values: 0 or 50)
%
% This function requires the fieldtrip toolbox
%
% See also JAI_CONCATDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
length  = ft_getopt(cfg, 'length', 200);
overlap = ft_getopt(cfg, 'overlap', 0);

if mod(length, 2)
  error('Choose even number for trial leght!');
else
  trlLength = data.part1.fsample * 200 / 1000;
end

switch overlap
  case 0
    numOfTrials = fix(data.part1.sampleinfo(2) / trlLength);
  case 50
    numOfTrials = 2 * fix(data.part1.sampleinfo(2) / trlLength) - 1;
  otherwise
    error('Currently there is only overlapping of 0 or 50% permitted');
end

% -------------------------------------------------------------------------
% Generate trial matrix
% -------------------------------------------------------------------------
 trl = zeros(numOfTrials, 4);
 switch overlap
   case 0
     trl(:,3) = 0:trlLength:(numOfTrials-1)*trlLength;
   case 50
     trl(:,3) = 0:trlLength/2:(numOfTrials-1)*(trlLength/2);
 end
 trl(:,1) = trl(:,3) + 1;
 trl(:,2) = trl(:,3) + trlLength;

end

