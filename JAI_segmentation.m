function [ data ] = JAI_segmentation( data )
% JAI_SEGMENTATION segments the data of each condition into segments with a
% duration of 5 seconds
%
% Use as
%   [ data ] = JAI_segmentation( data )
%
% where the input data can be the result from JAI_IMPORTDATASET or
% JAI_PREPROCESSING
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_IMPORTDATASET, JAI_PREPROCESSING, FT_REDEFINETRIAL,
% JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = 5;                                                    % segmentation into 5 seconds long segments
cfg.overlap         = 0;                                                    % no overlap

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fSample = data.part1.fsample;
segLength = cfg.length;
trialLength = length(data.part1.trial{1}(1,:));
subseg = trialLength / (segLength * fSample);

if fSample == 500
  trialinfo = data.part1.trialinfo;
end
    
fprintf('Segment data of participant 1...\n');
ft_info off;
ft_warning off;
data.part1 = ft_redefinetrial(cfg, data.part1);
    
fprintf('Segment data of participant 2...\n');
ft_info off;
ft_warning off;
data.part2 = ft_redefinetrial(cfg, data.part2);
    
if fSample == 500                                                           % calc trialinfo for subsegmented data in case of overlapping trials
  sampleinfo = data.part1.sampleinfo;                                       % this step is only necessary if no downsampling is used
  overlap = 0;
  
  for j=2:1:size(sampleinfo, 1)
    if sampleinfo(j,1) < sampleinfo(j-1, 2)
      overlap = 1;
      break;
    end
  end
  if (overlap == 1)
    numOfTrials = length(trialinfo);
    tmpTrialinfo = zeros(subseg * numOfTrials, 1);
    for k=1:1:numOfTrials
      for l=1:1:subseg
        tmpTrialinfo((k-1)*subseg + l) = trialinfo(k);
      end
    end
    trialinfo = tmpTrialinfo;
    data.part1.trialinfo = trialinfo;                                       % correct trialinfo for subsegmented data in case of overlapping trials
    data.part2.trialinfo = trialinfo;
  end
end

ft_info on;
ft_warning on;
