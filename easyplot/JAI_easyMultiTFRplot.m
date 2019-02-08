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
%   cfg.freqlim     = [begin end] (default: [2 30])
%   cfg.timelim     = [begin end] (default: [4 116])
%
% This function requires the fieldtrip toolbox
%
% See also FT_MULTIPLOTTFR, JAI_TIMEFREQANALYSIS

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 1);
condition = ft_getopt(cfg, 'condition', 111);
freqlim   = ft_getopt(cfg, 'freqlimits', [2 30]);
timelim   = ft_getopt(cfg, 'timelimits', [4 116]);

switch part                                                                 % check validity of cfg.part
  case 0
    if isfield(data, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
  case 1
    if ~isfield(data, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part1;
  case 2
    if ~isfield(data, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));


condition    = JAI_checkCondition( condition );                             % check cfg.condition definition
if isempty(find(trialinfo == condition, 1))
  error('The selected dataset contains no condition %d.', condition);
else
  trialNum = ismember(trialinfo, condition);
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
cfg.trials        = trialNum;
cfg.channel       = {'all', '-V1', '-V2', '-Ref', '-EOGH', '-EOGV'};
cfg.layout        = lay;

cfg.showlabels    = 'no';
cfg.showoutline   = 'yes';
cfg.colorbar      = 'yes';

cfg.showcallinfo  = 'no';                                                   % suppress function call output

ft_multiplotTFR(cfg, data);
title(sprintf('Part.: %d - Cond.: %d', part, condition));
  
ft_warning on;

end
