function JAI_easyPLVplot( cfg, data )
% JAI_EASYPLVPLOT is a function, which makes it easier to plot the PLV 
% values of a specific condition from the JAI-data-structure.
%
% Use as
%   JAI_easyPLVplot( cfg, data )
%
% where the input data has to be the result of JAI_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 111 or 'SameObject', see JAI data structure)
%   cfg.electrode = number of electrode (default: 'Cz')
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_DATASTRUCTURE, PLOT, JAI_PHASELOCKVAL

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond = ft_getopt(cfg, 'condition', 111);
elec = ft_getopt(cfg, 'electrode', 'Cz');

trialinfo = data.dyad.trialinfo;                                            % get trialinfo

cond = JAI_checkCondition( cond );                                          % check cfg.condition definition and translate it into trl number    
trl  = find(trialinfo == cond);
if isempty(trl)
  error('The selected dataset contains no condition %d.', cond);
end

label = data.dyad.label;                                                    % get labels

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
% Plot PLV course
% -------------------------------------------------------------------------
plot(data.dyad.time{trl}, data.dyad.PLV{trl}(elec,:));
title(sprintf(' Cond.: %d - Elec.: %s', cond, ...
              strrep(data.dyad.label{elec}, '_', '\_')));      

xlabel('time in seconds');
ylabel('phase locking value');

end
