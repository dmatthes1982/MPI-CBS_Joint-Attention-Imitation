function JAI_easyPowPlot(cfg, data)
% JAI_EASYPOWPLOT is a function, which makes it easier to plot the
% signal power within a specific condition of the JAI_DATASTRUCTURE
%
% Use as
%   JAI_easyPowPlot(cfg, data)
%
% where the input data have to be a result from JAI_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.baseline    = baseline condition (default: [], can by any valid condition)
%                     the values of the baseline condition will be subtracted
%                     from the values of the selected condition (cfg.condition)
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [8])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [8] or [2, 1, 28]
%   cfg.avgelec     = plot average over selected electrodes, options: 'yes' or 'no' (default: 'no')
%
% This function requires the fieldtrip toolbox
%
% See also JAI_PWELCH, JAI_DATASTRUCTURE

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 1);
condition = ft_getopt(cfg, 'condition', 111);
baseline  = ft_getopt(cfg, 'baseline', []);
elec      = ft_getopt(cfg, 'electrode', {'Cz'});
avgelec   = ft_getopt(cfg, 'avgelec', 'no');

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
label     = data.label;                                                     % get labels 

condition    = JAI_checkCondition( condition );                             % check cfg.condition definition
if isempty(find(trialinfo == condition, 1))
  error('The selected dataset contains no condition %d.', condition);
else
  trialNum = ismember(trialinfo, condition);
end

if ~isempty(baseline)
  baseline    = JAI_checkCondition( baseline );                             % check cfg.baseline definition
  if isempty(find(trialinfo == baseline, 1))
    error('The selected dataset contains no condition %d.', baseline);
  else
    baseNum = ismember(trialinfo, baseline);
  end
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

if ~ismember(avgelec, {'yes', 'no'})                                        % check cfg.avgelec definition
  error('cfg.avgelec has to be either ''yes'' or ''no''.');
end

% -------------------------------------------------------------------------
% Plot power spectrum
% -------------------------------------------------------------------------
legend('-DynamicLegend');
hold on;

if isempty(baseline)                                                        % extract the powerspctrm matrix
  powData = squeeze(data.powspctrm(trialNum,:,:));
else
  powData = squeeze(data.powspctrm(trialNum,:,:)) - ...                     % subtract baseline condition
            squeeze(data.powspctrm(baseNum,:,:));
end

if strcmp(avgelec, 'no')
  for i = 1:1:length(elec)
    plot(data.freq, powData(elec(i),:), ...
        'DisplayName', data.label{elec(i)});
  end
else
  labelString = strjoin(data.label(elec), ',');
  plot(data.freq, mean(powData(elec,:), 1), 'DisplayName', labelString);
end

if part == 0                                                                % set figure title
  if isempty(baseline)
    title(sprintf('Power - Cond.: %d', condition));
  else
    title(sprintf('Power - Cond.: %d-%d', condition, baseline));
  end
else
  if isempty(baseline)
    title(sprintf('Power - Part.: %d - Cond.: %d', part, condition));
  else
    title(sprintf('Power - Part.: %d - Cond.: %d-%d', part, condition, ...
                  baseline));
  end
end

xlabel('frequency in Hz');                                                  % set xlabel
ylabel('power in uV^2');                                                    % set ylabel

hold off;

end
