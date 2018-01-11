function JAI_easyPlot( cfg, data )
% JAI_EASYPLOT is a function, which makes it easier to plot the data of a 
% specific condition and trial from the JAI-data-structure.
%
% Use as
%   JAI_easyPlot(cfg, data)
%
% where the input data can be the results of JAI_IMPORTDATASET or
% JAI_PREPROCESSING
%
% The configuration options are
%   cfg.part      = number of participant (default: 1)
%   cfg.condition = condition (default: 111 or 'SameObjectB', see JAI data structure)
%   cfg.electrode = number of electrode (default: 'Cz')
%   cfg.trial     = number of trial (default: 1)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_DATASTRUCTURE, PLOT

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 1);
cond = ft_getopt(cfg, 'condition', 111);
elec = ft_getopt(cfg, 'electrode', 'Cz');
trl  = ft_getopt(cfg, 'trial', 1);

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

if isnumeric(elec)                                                          % check cfg.electrode definition
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
% Plot timeline
% -------------------------------------------------------------------------
switch part
  case 1
    plot(data.part1.time{trl}, data.part1.trial{trl}(elec,:));
    title(sprintf('Part.: %d - Cond.: %d - Elec.: %s - Trial: %d', ...
          part, cond, ...
          strrep(data.part1.label{elec}, '_', '\_'), trlInCond));      
  case 2
    plot(data.part2.time{trl}, data.part2.trial{trl}(elec,:));
    title(sprintf('Part.: %d - Cond.: %d - Elec.: %s - Trial: %d', ...
          part, cond, ...
          strrep(data.part2.label{elec}, '_', '\_'), trlInCond));
end

xlabel('time in seconds');
ylabel('voltage in \muV');

end
