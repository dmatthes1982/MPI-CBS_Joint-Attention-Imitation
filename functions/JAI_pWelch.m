function [ data ] = JAI_pWelch( cfg, data )
% JAI_PWELCH calculates the power spectral density using Welch's method for
% every condition of every participant in the dataset.
%
% Use as
%   [ data ] = JAI_pWelch( cfg, data)
%
% where the input data hast to be the result from JAI_SEGMENTATION
%
% The configuration options are
%   cfg.foi = frequency of interest - begin:resolution:end (default: 1:1:50)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_SEGMENTATION

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi = ft_getopt(cfg, 'foi', 1:1:50);

% -------------------------------------------------------------------------
% psd settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'mtmfft';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for all channels
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 'maxperlen';                                          % do not use padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Calculate power spectral density using Welch's method
% -------------------------------------------------------------------------
fprintf('<strong>Calc power spectral density of participant 1...</strong>\n');
ft_warning off;
data.part1 = ft_freqanalysis(cfg, data.part1);
ft_warning on;
data.part1 = pWelch(data.part1);

fprintf('<strong>Calc power spectral density of participant 2...</strong>\n');
ft_warning off;
data.part2 = ft_freqanalysis(cfg, data.part2); 
ft_warning on;
data.part2 = pWelch(data.part2);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_pWelch ] = pWelch(data_psd)
% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');  

val       = ismember(generalDefinitions.condNum, data_psd.trialinfo);
trialinfo = generalDefinitions.condNum(val)';
powspctrm = zeros(length(trialinfo), length(data_psd.label), length(data_psd.freq));

for i = 1:1:length(trialinfo)
  val       = ismember(data_psd.trialinfo, trialinfo(i));
  tmpspctrm = data_psd.powspctrm(val,:,:);
  powspctrm(i,:,:) = median(tmpspctrm, 1);
end

data_pWelch.label = data_psd.label;
data_pWelch.dimord = data_psd.dimord;
data_pWelch.freq = data_psd.freq;
data_pWelch.powspctrm = powspctrm;
data_pWelch.trialinfo = trialinfo;
data_pWelch.cfg.previous = data_psd.cfg;
data_pWelch.cfg.pwelch_median = 'yes';
data_pWelch.cfg.pwelch_mean = 'no';

end