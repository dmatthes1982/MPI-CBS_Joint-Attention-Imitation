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
eventvalues = { 'S111','S239', ...                                          % Same object - Beginning (duration: 120 sec)
                'S  2','S130', ...                                          % View motion - Beginning (duration: 120 sec)
                'S  3','S131', ...                                          % Same motion - Beginning (duration: 120 sec)
                'S 31','S159', ...                                          % Contingent Imitation 1 imitates 2 (duration: 180 sec)
                'S 32','S160', ...                                          % Contingent Imitation 2 imitates 1 (duration: 180 sec)
                'S 41','S169', ...                                          % Contingent Other Action 1 reacts on 2 (duration: 180 sec)
                'S 42','S170', ...                                          % Contingent Other Action 2 reacts on 1 (duration: 180 sec)
                'S 51','S179', ...                                          % Spontaneous Imitation I (duration: 180 sec)
                'S 52','S180', ...                                          % Spontaneous Imitation II (duration: 180 sec)
                'S105','S233', ...                                          % Conversation (duration: 300 sec)
                'S100','S228', ...                                          % Single / no Entrainment (duration: 180 sec)
                'S101','S229', ...                                          % Dual 1 shows to 2 / no Entrainment (duration: 180 sec)  
                'S102','S230', ...                                          % Dual 2 shows to 1 / no Entrainment (duration: 180 sec)
                'S  7','S135', ...                                          % Single / 2Hz Entrainment (duration: 180 sec)
                'S  8','S136', ...                                          % Dual 1 shows to 2 / 2Hz Entrainment (duration: 180 sec)  
                'S  9','S137', ...                                          % Dual 2 shows to 1 / 2Hz Entrainment (duration: 180 sec)
                'S 10','S138', ...                                          % Single / 10Hz Entrainment (duration: 180 sec)
                'S 11','S139', ...                                          % Dual 1 shows to 2 / 10Hz Entrainment (duration: 180 sec)  
                'S 12','S140', ...                                          % Dual 2 shows to 1 / 10Hz Entrainment (duration: 180 sec)
                'S 20','S148', ...                                          % Single / 20Hz Entrainment (duration: 180 sec)
                'S 21','S149', ...                                          % Dual 1 shows to 2 / 20Hz Entrainment (duration: 180 sec)  
                'S 22','S150', ...                                          % Dual 2 shows to 1 / 20Hz Entrainment (duration: 180 sec)
                'S  4','S132', ...                                          % Same object - End (duration: 120 sec)
                'S  5','S133', ...                                          % View motion - End (duration: 120 sec)
                'S  6','S134', ...                                          % Same motion - End (duration: 120 sec)
                };

samplingRate = 500;
duration = zeros(239,1);                                                    % specify general trial length
duration([111, 2,   3,   4,   5,   6,  ...
          239, 130, 131, 132, 133, 134 ...
          ])  = 120 * samplingRate;
duration([31,  32,  41,  42,  51,  52,  100, 101, 102, ... 
          159, 160, 169, 170, 179, 180, 228, 229, 230, ...
          7,   8,   9,   10,  11,  12,  20,  21,  22,  ...
          135, 136, 137, 138, 139, 140, 148, 149, 150  ...
          ]) = 180 * samplingRate;
duration([105, 233 ...
          ]) = 300 * samplingRate;
              
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
    case 132
      cfg.trl(i,4) = 4;
    case 133
      cfg.trl(i,4) = 5;
    case 134
      cfg.trl(i,4) = 6;
    case 135
      cfg.trl(i,4) = 7;
    case 136
      cfg.trl(i,4) = 8;
    case 137
      cfg.trl(i,4) = 9;
    case 138
      cfg.trl(i,4) = 10;
    case 139
      cfg.trl(i,4) = 11;
    case 140
      cfg.trl(i,4) = 12;
    case 148
      cfg.trl(i,4) = 20;
    case 149
      cfg.trl(i,4) = 21;
    case 150
      cfg.trl(i,4) = 22;
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
    case 228
      cfg.trl(i,4) = 100;
    case 229
      cfg.trl(i,4) = 101;
    case 230
      cfg.trl(i,4) = 102;
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
