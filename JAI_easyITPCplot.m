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
%   cfg.condition   =  condition (default: 111 or 'SameObject', see JAI_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%  
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRAILPHASECOH, JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 111);
elec    = ft_getopt(cfg, 'electrode', 'Cz');

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
% inter-trial phase coherence representation
% -------------------------------------------------------------------------
switch part
  case 1
    imagesc(data.part1.time{trialNum}, data.part1.freq, ...
              squeeze(data.part1.itpc{trialNum}(elec,:,:)));
    title(sprintf('ITPC - Part.: %d - Cond.: %d - Elec.: %s', ...
          part, cond, ...
          strrep(data.part1.label{elec}, '_', '\_')));
  case 2
    imagesc(data.part2.time{trialNum}, data.part2.freq, ...
              squeeze(data.part2.itpc{trialNum}(elec,:,:)));
    title(sprintf('ITPC - Part.: %d - Cond.: %d - Elec.: %s', ...
          part, cond, ...
          strrep(data.part2.label{elec}, '_', '\_')));
end

axis xy;
xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel
colorbar;

end
