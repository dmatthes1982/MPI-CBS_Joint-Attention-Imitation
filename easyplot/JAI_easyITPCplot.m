function JAI_easyITPCplot(cfg, data)
% JAI_EASYITPCPLOT is a function, which makes it easier to plot a
% inter-trial phase coherence representation of a specific condition from 
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
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [7])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [7] or [2, 1, 27] 
%  
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRIALPHASECOH, JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 111);
elec    = ft_getopt(cfg, 'electrode', {'Cz'});

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to either 0, 1 or 2');
end

switch part
  case 0
  case 1
    data = data.part1;
  case 2
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels                                             

addpath('../utilities');
cond    = JAI_checkCondition( cond );                                       % check cfg.condition definition    
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
% inter-trial phase coherence representation
% -------------------------------------------------------------------------
imagesc(data.time{trialNum}(2:end), data.freq, ...
        squeeze(mean(data.itpc{trialNum}(elec,:,2:end),1)));
labelString = elec2string(elec, data.label);
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

function elecsString = elec2string (elecs, labels)
  elecsString = labels{elecs(1)};
  
  if length(elecs) > 1
    for i = 2:1:length(elecs)
      elecsString = [elecsString, ', ', labels{elecs(i)}];                  %#ok<AGROW>
    end
  end
  
end
