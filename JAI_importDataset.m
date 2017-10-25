function [ data ] = JAI_importDataset(cfg)
% JAI_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data ] = JAI_importDataset(cfg)
%
% The configuration options are
%   cfg.path = source path' (i.e. '/data/pt_01826/eegData/DualEEG_JAI_rawData/')
%   cfg.part = number of participant
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path = ft_getopt(cfg, 'path', []);
part = ft_getopt(cfg, 'part', []);

if isempty(path)
  error('No source path is specified!');
end

if isempty(part)
  error('No specific participant is defined!');
end

headerfile = sprintf('%sDualEEG_JAI_%02d.vhdr', path, part);

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
% definition of all possible stimuli, two for each condition, the first on 
% is the original one and the second one handles the 'video trigger bug'
eventvalues = { 'S111','S239', ...                                          % Same object (Duration: 120 sec)
                'S  2','S130', ...                                          % View motion (Duration: 120 sec)
                'S  3','S131', ...                                          % Same motion (Duration: 120 sec)
                'S 31','S159', ...                                          % Contingent Imitation 1 imitates 2 (Duration: 180 sec)
                'S 32','S160', ...                                          % Contingent Imitation 2 imitates 1 (Duration: 180 sec)
                'S 41','S169', ...                                          % Contingent Other Action 1 reacts on 2 (Duration: 180 sec)
                'S 42','S170', ...                                          % Contingent Other Action 2 reacts on 1 (Duration: 180 sec)
                'S 51','S179', ...                                          % Spontaneous Imitation I (Duration: 180 sec)
                'S 52','S180', ...                                          % Spontaneous Imitation II (Duration: 180 sec)
                'S105','S233', ...                                          % Conversation (Duration: 300 sec)
                };

samplingRate = 500;
duration = zeros(239,1);                                                    % specify general trial length
duration([111, 2, 3, 239, 130, 131])  = 120 * samplingRate;
duration([31, 32, 41, 42, 51, 52, 159, 160, 169, 170, 179, 180]) = ...
                                        180 * samplingRate;
duration([105, 233])                  = 300 * samplingRate;
              
% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
% basis configuration for data import
cfg                     = [];
cfg.dataset             = headerfile;
cfg.trialfun            = 'ft_trialfun_general';
cfg.trialdef.eventtype  = 'Stimulus';
cfg.trialdef.prestim    = 0;
cfg.showcallinfo        = 'no';
cfg.feedback            = 'error';
cfg.trialdef.eventvalue = eventvalues;

cfg = ft_definetrial(cfg);                                                  % generate config for segmentation
cfg = rmfield(cfg, {'notification'});                                       % workarround for mergeconfig bug                       

for i = 1:1:size(cfg.trl, 1)                                                % set specific trial lengths
  cfg.trl(i, 2) = duration(cfg.trl(i, 4)) + cfg.trl(i, 1) - 1;
end

for i = size(cfg.trl):-1:2                                                  % reject duplicates
  if cfg.trl(i,4) == cfg.trl(i-1,4)
    cfg.trl(i-1,:) = [];
  end
end

for i = 1:1:size(cfg.trl)                                                   % correct false stimulus numbers
  switch cfg.trl(i,4)
    case 130
      cfg.trl(i,4) = 2;
    case 131
      cfg.trl(i,4) = 3;
    case 159
      cfg.trl(i,4) = 31;
    case 160
      cfg.trl(i,4) = 32;
    case 169
      cfg.trl(i,4) = 41;
    case 170
      cfg.trl(i,4) = 42;
    case 179
      cfg.trl(i,4) = 51;
    case 180
      cfg.trl(i,4) = 52;
    case 233
      cfg.trl(i,4) = 105;
    case 239
      cfg.trl(i,4) = 111;
  end
end

dataTmp = ft_preprocessing(cfg);                                            % import data

data.part1 = dataTmp;                                                       % split dataset into two datasets, one for each participant
data.part1.label = strrep(dataTmp.label(1:32), '_1', '');
for i=1:1:length(dataTmp.trial)
  data.part1.trial{i} = dataTmp.trial{i}(1:32,:);
end

data.part2 = dataTmp;
data.part2.label = strrep(dataTmp.label(33:64), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.part2.trial{i} = dataTmp.trial{i}(33:64,:);
end

end
