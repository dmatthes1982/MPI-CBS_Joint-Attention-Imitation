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
trlDuration   = ft_getopt(cfg, 'length', 200);
overlap       = ft_getopt(cfg, 'overlap', 0);

if mod(trlDuration, 2)
  error('Choose even number for trial leght!');
else
  trlLength = data.part1.fsample * trlDuration / 1000;
end

numOfOrgTrials  = size(data.part1.trialinfo, 1);
numOfTrials     = zeros(1, numOfOrgTrials);
trialinfo       = data.part1.trialinfo;
sampleinfo      = data.part1.sampleinfo;

switch overlap
  case 0
    for i = 1:numOfOrgTrials
      numOfTrials(i) = fix((sampleinfo(i,2) - sampleinfo(i,1) +1) ...
                    / trlLength);
                    
    end
  case 50
    for i = 1:numOfOrgTrials
      numOfTrials(i) = 2 * fix((sampleinfo(i,2) - sampleinfo(i,1) +1) ...
                    / trlLength) - 1;
                    
    end
  otherwise
    error('Currently there is only overlapping of 0 or 50% permitted');
end

numOfAllTrials = sum(numOfTrials);

% -------------------------------------------------------------------------
% Generate trial matrix
% -------------------------------------------------------------------------
trl       = zeros(numOfAllTrials, 4);
endsample = 0;

switch overlap
  case 0
    for i = 1:numOfOrgTrials
      begsample = endsample + 1;
      endsample = begsample + numOfTrials(i) - 1;
      trl(begsample:endsample, 1) = sampleinfo(i,1):trlLength: ...
                                    (numOfTrials(i)-1) * trlLength + ...
                                    sampleinfo(i,1);
      trl(begsample:endsample, 3) = 0:trlLength: ...
                                    (numOfTrials(i)-1) * trlLength;
      trl(begsample:endsample, 2) = trl(begsample:endsample, 1) ... 
                                    + trlLength - 1;
      trl(begsample:endsample, 4) = trialinfo(i);
    end
  case 50
    for i = 1:numOfOrgTrials
      begsample = endsample + 1;
      endsample = begsample + numOfTrials(i) - 1;
      trl(begsample:endsample, 1) = sampleinfo(i,1):trlLength/2: ...
                                    (numOfTrials(i)-1) * (trlLength/2) + ...
                                    sampleinfo(i,1);
      trl(begsample:endsample, 3) = 0:trlLength/2: ...
                                    (numOfTrials(i)-1) * (trlLength/2);
      trl(begsample:endsample, 2) = trl(begsample:endsample, 1) ... 
                                    + trlLength - 1;
      trl(begsample:endsample, 4) = trialinfo(i);
    end
end

end

