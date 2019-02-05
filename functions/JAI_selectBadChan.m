function [ data_badchan ] = JAI_selectBadChan( data_raw, data_noisy )
% JAI_SELECTBADCHAN can be used for selecting bad channels visually. The
% data will be presented in two different ways. The first fieldtrip
% databrowser view shows the time course of each channel. The second view
% shows the total power of each channel and is highlighting outliers. The
% bad channels can be marked within the JAI_CHANNELCHECKBOX gui.
%
% Use as
%   [ data_badchan ] = JAI_selectBadChan( data_raw, data_noisy )
%
% where the first input has to be concatenated raw data and second one has
% to be the result of JAI_ESTNOISYCHAN.
%
% The function requires the fieldtrip toolbox
%
% SEE also JAI_DATABROWSER, JAI_ESTNOISYCHAN and JAI_CHANNELCHECKBOX

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Check data
% -------------------------------------------------------------------------
if numel(data_raw.part1.trialinfo) ~= 1 || numel(data_raw.part2.trialinfo) ~= 1
  error('First dataset has more than one trial. Data has to be concatenated!');
end

if ~isfield(data_noisy.part1, 'totalpow')
  error('Second dataset has to be the result of JAI_ESTNOISYCHAN!');
end

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
JAI_easyTotalPowerBarPlot( cfg, data_noisy );
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
JAI_databrowser( cfg, data_raw );
cfgCC.maxchan = fix(numel(data_raw.part1.label) * 0.1);                     % estimate 10% of the total number of channels in the data
badLabel = JAI_channelCheckbox( cfgCC );
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
close(gcf);                                                                 % close also total power diagram when the channelCheckbox will be closed
if any(strcmp(badLabel, 'TP10'))
  warning backtrace off;
  warning(['You have rejected ''TP10'', accordingly selecting linked ' ...
           'mastoid as reference in step [4] - Preproc II will lead '...
           'into an error.']);
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

data_badchan.part1 = data_noisy.part1;

if ~isempty(badLabel)
  data_badchan.part1.badChan = data_raw.part1.label(ismember(...
                                          data_raw.part1.label, badLabel));
else
  data_badchan.part1.badChan = [];
end

cfg.part      = 2;
  
fprintf('<strong>Select bad channels of participant %d...</strong>\n', cfg.part);
JAI_easyTotalPowerBarPlot( cfg, data_noisy );
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
JAI_databrowser( cfg, data_raw );
cfgCC.maxchan = fix(numel(data_raw.part2.label) * 0.1);                     % estimate 10% of the total number of channels in the data
badLabel = JAI_channelCheckbox( cfgCC );
close(gcf);                                                                 % close also databrowser view when the channelCheckbox will be closed
close(gcf);                                                                 % close also total power diagram when the channelCheckbox will be closed
if any(strcmp(badLabel, 'TP10'))
  warning backtrace off;
  warning(['You have rejected ''TP10'', accordingly selecting linked ' ...
           'mastoid as reference in step [4] - Preproc II  will lead '...
           'into an error.']);
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

data_badchan.part2 = data_noisy.part2;

if ~isempty(badLabel)
  data_badchan.part2.badChan = data_raw.part2.label(ismember(...
                                          data_raw.part2.label, badLabel));
else
  data_badchan.part2.badChan = [];
end

end
