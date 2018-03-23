function JAI_easyMultiTFRplot(cfg, data)
% JAI_EASYTFRPLOT is a function, which makes it easier to create a multi
% time frequency response plot of all electrodes of specific condition and 
% trial on a head model.
%
% Use as
%   JAI_easyTFRPlot(cfg, data)
%
% where the input data is a results from JAI_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = number of participant (1 or 2) (default: 1)
%   cfg.condition   = condition (default: 101 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.trial       = number of trial (default: 1)
%   cfg.freqlimits  = [begin end] (default: [2 30])
%   cfg.timelimits  = [begin end] (default: [4 116])
%
% This function requires the fieldtrip toolbox
%
% See also FT_MULTIPLOTTFR, JAI_TIMEFREQANALYSIS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 111);
trl     = ft_getopt(cfg, 'trial', 1);
freqlim = ft_getopt(cfg, 'freqlimits', [2 30]);
timelim = ft_getopt(cfg, 'timelimits', [4 116]);

if ~ismember(part, [1,2])                                                   % check cfg.part definition
  error('cfg.part has to either 1 or 2');
end

switch part
  case 1
    data = data.part1;
  case 2
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));


cond    = JAI_checkCondition( cond );                                       % check cfg.condition definition    
trials  = find(trialinfo == cond);
if isempty(trials)
  error('The selected dataset contains no condition %d.', cond);
else
  numTrials = length(trials);
  if numTrials < trl                                                        % check cfg.trial definition
    error('The selected dataset contains only %d trials.', numTrials);
  else
    trlInCond = trl;
    trl = trl-1 + trials(1);
  end
end

ft_warning off;

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath),...
     'lay');

colormap 'jet';

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.maskstyle     = 'saturation';
cfg.xlim          = timelim;
cfg.ylim          = freqlim;
cfg.zlim          = 'maxmin';
cfg.trials        = trl;
cfg.channel       = {'all', '-V1', '-V2', '-Ref', '-EOGH', '-EOGV'};
cfg.layout        = lay;

cfg.showlabels    = 'no';
cfg.showoutline   = 'yes';
cfg.colorbar      = 'yes';

cfg.showcallinfo  = 'no';                                                   % suppress function call output

ft_multiplotTFR(cfg, data);
title(sprintf('Part.: %d - Cond.: %d - Trial: %d', part, cond, trlInCond));      
  
ft_warning on;

end