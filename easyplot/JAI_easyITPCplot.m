function JAI_easyITPCplot(cfg, data)
% JAI_EASYITPCPLOT is a function, which makes it easier to plot a
% inter-trial phase coherence representation within a specific condition of 
% the JAI_DATASTRUCTURE.
%
% Use as
%   JAI_easyITCplot(cfg, data)
%
% where the input data have to be a result from JAI_INTERTRAILPHASECOH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 7 or 'Single_2Hz', see JAI_DATASTRUCTURE)
%   cfg.freqlim     = [begin end] (default: [1 48])
%   cfg.timelim     = [begin end] (default: [0.2 9.8])
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [8])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [8] or [2, 1, 28] 
%  
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRIALPHASECOH, JAI_DATASTRUCTURE

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 7);
freqlim = ft_getopt(cfg, 'freqlim', [1 48]);
timelim = ft_getopt(cfg, 'timelim', [0.2 9.8]);
elec    = ft_getopt(cfg, 'electrode', {'Cz'});

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to either 0, 1 or 2');
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
label     = data.label;                                                     % get labels                                             

cond    = JAI_checkCondition( cond, 'flag', 'itpc' );                       % check cfg.condition definition
if isempty(find(trialinfo == cond, 1))
  error('The selected dataset contains no condition %d.', cond);
else
  trialNum = find(ismember(trialinfo, cond));
end

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  if ischar(elec)
    elec = {elec};
  end
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

% -------------------------------------------------------------------------
% estimate actual limits
% -------------------------------------------------------------------------
time = data.time{trialNum};
freq = data.freq;

[~, idxf1] = min(abs(freq-freqlim(1)));                                     % estimate frequency range
[~, idxf2] = min(abs(freq-freqlim(2)));

[~, idxt1] = min(abs(time-timelim(1)));                                     % estimate time range
[~, idxt2] = min(abs(time-timelim(2)));

% -------------------------------------------------------------------------
% Inter-trial phase coherence representation
% -------------------------------------------------------------------------
imagesc(data.time{trialNum}(idxt1:idxt2), data.freq(idxf1:idxf2), ...
        squeeze(mean(data.itpc{trialNum}(elec, idxf1:idxf2, idxt1:idxt2),1)));
labelString = strjoin(data.label(elec), ',');
if part == 0
  title(sprintf('ITPC - Cond.: %d - Elec.: %s', cond, labelString));
else
  title(sprintf('ITPC - Part.: %d - Cond.: %d - Elec.: %s', ...
        part, cond, labelString));
end

axis xy;
xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel
colorbar;

end
