function [ data_badchan ] = JAI_selectBadChan( data_raw )
% JAI_SELECTBADCHAN can be used for selecting bad channels visually. The
% data will be presented in the fieldtrip databrowser view and the bad
% channels will be marked in the JAI_CHANNELCHECKBOX gui. The function
% returns a fieldtrip-like datastructure which includes only a cell array 
% for each participant with the selected bad channels.
%
% Use as
%   [ data_badchan ] = JAI_selectBadChan( data_raw )
%
% where the input has to be raw data
%
% The function requires the fieldtrip toolbox
%
% SEE also JAI_DATABROWSER and JAI_CHANNELCHECKBOX

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Databrowser settings
% -------------------------------------------------------------------------
cfg             = [];
cfg.ylim        = [-200 200];
cfg.blocksize   = 120;
cfg.part        = 1;
cfg.plotevents  = 'no';

% -------------------------------------------------------------------------
% Selection of bad channels
% -------------------------------------------------------------------------
fprintf('<strong>Select bad channels of participant %d...</strong>\n', cfg.part);
JAI_databrowser( cfg, data_raw );
badLabel = JAI_channelCheckbox();
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
if any(strcmp(badLabel, 'TP10'))
  warning backtrace off;
  warning(['You have repaired ''TP10'', accordingly selecting linked ' ...
           'mastoid as reference in step [2] - preprocessing is not '...
           'longer recommended.']);
  warning backtrace on;
end
if length(badLabel) >= 2
  warning backtrace off;
  warning(['You have selected more than one channel. Please compare your ' ... 
           'selection with the neighbour definitions in 00_settings/general. ' ...
           'Bad channels will exluded from a repairing operation of a ' ...
           'likewise bad neighbour, but each channel should have at least '...
           'two good neighbours.']);
  warning backtrace on;
end
fprintf('\n');
  
if ~isempty(badLabel)
  data_badchan.part1.badChan = data_raw.part1.label(ismember(...
                                          data_raw.part1.label, badLabel));
else
  data_badchan.part1.badChan = [];
end

cfg.part      = 2;
  
fprintf('<strong>Select bad channels of participant %d...</strong>\n', cfg.part);
JAI_databrowser( cfg, data_raw );
badLabel = JAI_channelCheckbox();
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
if any(strcmp(badLabel, 'TP10'))
  warning backtrace off;
  warning(['You have repaired ''TP10'', accordingly selecting linked ' ...
           'mastoid as reference in step [2] - preprocessing is not '...
           'longer recommended']);
  warning backtrace on;
end
if length(badLabel) >= 2
  warning backtrace off;
  warning(['You marked more than one channel. Please compare your ' ... 
           'selection with the neighbour overview in 00_settings/general. ' ...
           'Bad channels will not used for repairing a likewise bad ' ...
           'neighbour, but each channel should have at least two good '...
           'neighbours.']);
  warning backtrace on;
end
fprintf('\n');
  
if ~isempty(badLabel)
  data_badchan.part2.badChan = data_raw.part2.label(ismember(...
                                          data_raw.part2.label, badLabel));
else
  data_badchan.part2.badChan = [];
end

end
