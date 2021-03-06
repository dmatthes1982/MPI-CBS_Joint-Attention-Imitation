function [ data ] = JAI_importDataset(cfg)
% JAI_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data ] = JAI_importDataset(cfg)
%
% The configuration options are
%   cfg.path          = source path (i.e. '/data/pt_01826/eegData/DualEEG_JAI_rawData/')
%   cfg.dyad          = number of dyad
%   cfg.noichan       = channels which are not of interest (default: [])
%   cfg.continuous    = 'yes' or 'no' (default: 'no')
%   cfg.prestim       = define pre-Stimulus offset in seconds (default: 0)
%   cfg.rejectoverlap = reject first of two overlapping trials, 'yes' or 'no' (default: 'yes')
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, JAI_DATASTRUCTURE

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path          = ft_getopt(cfg, 'path', []);
dyad          = ft_getopt(cfg, 'dyad', []);
noichan       = ft_getopt(cfg, 'noichan', []);
continuous    = ft_getopt(cfg, 'continuous', 'no');
prestim       = ft_getopt(cfg, 'prestim', 0);
rejectoverlap = ft_getopt(cfg, 'rejectoverlap', 'yes');

if isempty(path)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No specific dyad is defined!');
end

headerfile = sprintf('%sDualEEG_JAI_%02d.vhdr', path, dyad);

if strcmp(continuous, 'no')
  % -----------------------------------------------------------------------
  % Load general definitions
  % -------------------------------------------------------------------------
  filepath = fileparts(mfilename('fullpath'));
  load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

  % definition of all possible stimuli, two for each condition, the first 
  % on is the original one and the second one handles the 'video trigger 
  % bug'
  eventvalues = [ generalDefinitions.condMark(1,:) ...
                generalDefinitions.condMark(2,:) ];
  samplingRate = 500;
  dur = (generalDefinitions.duration + prestim) * samplingRate;
              
  % -----------------------------------------------------------------------
  % Generate trial definition
  % -----------------------------------------------------------------------
  % basis configuration for data import
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.trialfun            = 'ft_trialfun_general';
  cfg.trialdef.eventtype  = 'Stimulus';
  cfg.trialdef.prestim    = prestim;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'error';
  cfg.trialdef.eventvalue = eventvalues;

  cfg = ft_definetrial(cfg);                                                % generate config for segmentation
  if isfield(cfg, 'notification')
    cfg = rmfield(cfg, {'notification'});                                   % workarround for mergeconfig bug
  end

  for i = 1:1:size(cfg.trl, 1)                                              % correct false stimulus numbers (128 bug)
    if any(generalDefinitions.condNum128Bug == cfg.trl(i,4))
      element = generalDefinitions.condNum128Bug == cfg.trl(i,4);
      cfg.trl(i,4) = generalDefinitions.condNum(element);
    end
  end

  for i = 1:1:size(cfg.trl, 1)                                              % set specific trial lengths
    element = generalDefinitions.condNum == cfg.trl(i,4);
    cfg.trl(i, 2) = dur(element) + cfg.trl(i, 1) - 1;
  end

  for i = size(cfg.trl):-1:2                                                % reject duplicates
    if cfg.trl(i,4) == cfg.trl(i-1,4)
      cfg.trl(i-1,:) = [];
    end
  end
  
  if strcmp(rejectoverlap, 'yes')                                           % if overlapping trials should be rejected
    overlapping = find(cfg.trl(1:end-1,2) > cfg.trl(2:end, 1));             % in case of overlapping trials, remove the first of theses trials
    if ~isempty(overlapping)
      for i = 1:1:length(overlapping)
        warning off backtrace;
        warning(['trial %d with marker ''S%3d''  will be removed due to '...
               'overlapping data with its successor.'], ...
               overlapping(i), cfg.trl(overlapping(i), 4));
        warning on backtrace;
      end
      cfg.trl(overlapping, :) = [];
    end
  end
else
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'no';
end

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
if ~isempty(noichan)
  noichan = cellfun(@(x) strcat('-', x), noichan, ...
                          'UniformOutput', false);
  noichanp1 = cellfun(@(x) strcat(x, '_1'), noichan, ...
                          'UniformOutput', false);
  noichanp2 = cellfun(@(x) strcat(x, '_2'), noichan, ...
                          'UniformOutput', false);
  cfg.channel = [{'all'} noichanp1 noichanp2];                              % exclude channels which are not of interest
else
  cfg.channel = 'all';
end

dataTmp = ft_preprocessing(cfg);                                            % import data

numOfChan = numel(dataTmp.label)/2;

data.part1 = dataTmp;                                                       % split dataset into two datasets, one for each participant
data.part1.label = strrep(dataTmp.label(1:numOfChan), '_1', '');
for i=1:1:length(dataTmp.trial)
  data.part1.trial{i} = dataTmp.trial{i}(1:numOfChan,:);
end

data.part2 = dataTmp;
data.part2.label = strrep(dataTmp.label(numOfChan+1:end), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.part2.trial{i} = dataTmp.trial{i}(numOfChan+1:end,:);
end

end
