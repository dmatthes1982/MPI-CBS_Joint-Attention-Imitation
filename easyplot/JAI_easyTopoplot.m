function JAI_easyTopoplot(cfg , data)
% JAI_EASYTOPOPLOT is a function, which makes it easier to plot the
% topographic distribution of the power over the head.
%
% Use as
%   JAI_easyTopoplot(cfg, data)
%
%  where the input data have to be a result from JAI_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.freqrange   = limits for frequency in Hz (e.g. [6 9] or 10) (default: 10) 
%
% This function requires the fieldtrip toolbox
%
% See also JAI_PWELCH, JAI_DATASTRUCTURE

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part        = ft_getopt(cfg, 'part', 1);
condition   = ft_getopt(cfg, 'condition', 111);
freqrange   = ft_getopt(cfg, 'freqrange', 10);

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to be either 0, 1 or 2');
end

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

condition = JAI_checkCondition( condition );                                % check cfg.condition definition    
if isempty(find(trialinfo == condition, 1))
  error('The selected dataset contains no condition %d.', condition);
else
  trialNum = ismember(trialinfo, condition);
end

if numel(freqrange) == 1
  freqrange = [freqrange freqrange];
end

% -------------------------------------------------------------------------
% Generate topoplot
% -------------------------------------------------------------------------
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath), 'lay');

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.xlim          = freqrange;
cfg.zlim          = 'maxmin';
cfg.trials        = trialNum;
cfg.colormap      = 'jet';
cfg.marker        = 'on';
cfg.colorbar      = 'yes';
cfg.style         = 'both';
cfg.gridscale     = 200;                                                    % gridscale at map, the higher the better
cfg.layout        = lay;
cfg.showcallinfo  = 'no';

ft_topoplotER(cfg, data);

if part ~= 0
  title(sprintf('Power - Participant %d - Condition %d - Freqrange [%d %d]', ...
                part, condition, freqrange));
else
  title(sprintf('Power - Condition %d - Freqrange [%d %d]', ...
                condition, freqrange));
end

set(gcf, 'Position', [0, 0, 750, 550]);
movegui(gcf, 'center');
              
end
