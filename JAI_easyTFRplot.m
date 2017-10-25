function JAI_easyTFRplot(cfg, data)
% JAI_EASYTFRPLOT is a function, which makes it easier to plot a
% time-frequency-spectrum of a specific condition and trial from the 
% JAI_DATASTRUCTURE.
%
% Use as
%   JAI_easyTFRPlot(cfg, data)
%
% where the input data is a results from JAI_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%   cfg.condition   = condition (default: 111 or 'SameObject', see JAI_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%   cfg.trial       = number of trial (default: 1)
%   cfg.freqlimits  = [begin end] (default: [2 50])
%   cfg.timelimits  = [begin end] (default: [4 116])
%
% This function requires the fieldtrip toolbox
%
% See also FT_SINGLEPLOTTFR, JAI_TIMEFREQANALYSIS, JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 111);
elec    = ft_getopt(cfg, 'electrode', 'Cz');
trl     = ft_getopt(cfg, 'trial', 1);
freqlim = ft_getopt(cfg, 'freqlimits', [2 50]);
timelim = ft_getopt(cfg, 'timelimits', [4 116]);

if part < 1 || part > 2                                                     % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

if part == 1                                                                % get trialinfo
  trialinfo = data.part1.trialinfo;
elseif part == 2
  trialinfo = data.part2.trialinfo;
end

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

if part == 1                                                                % get labels
  label = data.part1.label;                                             
elseif part == 2
  label = data.part2.label;
end

if isnumeric(elec)
  if elec < 1 || elec > 32
    error('cfg.elec hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elec = find(strcmp(label, elec));
  if isempty(elec)
    error('cfg.elec hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------

ft_warning off;

cfg                 = [];                                                       
cfg.maskstyle       = 'saturation';
cfg.xlim            = timelim;
cfg.ylim            = freqlim;
cfg.zlim            = 'maxmin';
cfg.trials          = trl;                                                  % select trial (or 'all' trials)
cfg.channel         = elec;
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

colormap jet;                                                               % use the older and more common colormap

switch part
  case 1
    ft_singleplotTFR(cfg, data.part1);
    title(sprintf('Part.: %d - Cond.: %d - Elec.: %s - Trial: %d', ...
          part, cond, ...
          strrep(data.part1.label{elec}, '_', '\_'), trlInCond));      
  case 2
    ft_singleplotTFR(cfg, data.part2);
    title(sprintf('Part.: %d - Cond.: %d - Elec.: %s - Trial: %d', ...
          part, cond, ...
          strrep(data.part2.label{elec}, '_', '\_'), trlInCond));
end

xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel

ft_warning on;

end