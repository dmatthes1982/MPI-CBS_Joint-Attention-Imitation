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

if part < 1 || part > 2                                                     % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

if part == 1                                                                % get trialinfo
  trialinfo = data.part1.trialinfo;
elseif part == 2
  trialinfo = data.part2.trialinfo;
end

cond    = JAI_checkCondition( cond );                                       % check cfg.condition definition    
if isempty(find(trialinfo == cond, 1))
  error('The selected dataset contains no condition %d.', cond);
else
  trialNum = find(ismember(trialinfo, cond));
end

if part == 1                                                                % get labels
  label = data.part1.label;                                             
elseif part == 2
  label = data.part2.label;
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
switch part
  case 1
    imagesc(data.part1.time{trialNum}(2:end), data.part1.freq, ...
              squeeze(mean(data.part1.itpc{trialNum}(elec,:,2:end),1)));
    labelString = elec2string(elec, data.part2.label);
    title(sprintf('ITPC - Part.: %d - Cond.: %d - Elec.: %s', ...
          part, cond, labelString));
  case 2
    imagesc(data.part2.time{trialNum}(2:end), data.part2.freq, ...
              squeeze(mean(data.part2.itpc{trialNum}(elec,:,2:end),1)));
    labelString = elec2string(elec, data.part2.label);        
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
