function JAI_easyPLVplot( cfg, data )
% JAI_EASYPLVPLOT is a function, which makes it easier to plot the PLV 
% values of a specific condition from the JAI_DATASTRUCTURE.
%
% Use as
%   JAI_easyPLVplot( cfg, data )
%
% where the input data has to be the result of JAI_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.elecPart1 = number of electrode of participant 1 (default: 'Cz')
%   cfg.elecPart2 = number of electrode of participant 2 (default: 'Cz')
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_DATASTRUCTURE, PLOT, JAI_PHASELOCKVAL

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond = ft_getopt(cfg, 'condition', 111);
elecPart1 = ft_getopt(cfg, 'elecPart1', 'Cz');
elecPart2 = ft_getopt(cfg, 'elecPart2', 'Cz');

trialinfo = data.dyad.trialinfo;                                            % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));


cond = JAI_checkCondition( cond );                                          % check cfg.condition definition and translate it into trl number    
trl  = find(trialinfo == cond);
if isempty(trl)
  error('The selected dataset contains no condition %d.', cond);
end

label = data.dyad.label;                                                    % get labels

if isnumeric(elecPart1)                                                     % check cfg.electrode definition
  if ~ismember(elecPart1, 1:1:32)
    error('cfg.elecPart1 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart1 = find(strcmp(label, elecPart1));                            
  if isempty(elecPart1)
    error('cfg.elecPart1 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

if isnumeric(elecPart2)                                                     % check cfg.electrode definition
  if ~ismember(elecPart2, 1:1:32)
    error('cfg.elecPart2 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart2 = find(strcmp(label, elecPart2));
  if isempty(elecPart2)
    error('cfg.elecPart2 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot PLV course
% -------------------------------------------------------------------------
plot(data.dyad.time{trl}, data.dyad.PLV{trl}{elecPart1,elecPart2}(:));
title(sprintf(' Cond.: %d - Elec.: %s - %s', cond, ...
              strrep(data.dyad.label{elecPart1}, '_', '\_'), ...
              strrep(data.dyad.label{elecPart2}, '_', '\_')));   

xlabel('time in seconds');
ylabel('phase locking value');

end
