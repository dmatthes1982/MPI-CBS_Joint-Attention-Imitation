function [ cfgArtifacts ] = JAI_databrowser( cfg, data )
% JAI_DATABROWSER displays a certain joint attention imitation project 
% dataset using a appropriate scaling.
%
% Use as
%   JAI_databrowser( cfg, data )
%
% where the input can be the result of JAI_IMPORTDATASET,
% JAI_PREPROCESSING or JAI_SEGMENTATION
%
% The configuration options are
%   cfg.dyad      = number of dyad (no default value)
%   cfg.part      = number of participant (default: 1)
%   cfg.artifact  = Nx2 matrix with artifact segments (default: [])
%   cfg.channel   = channels of interest (default: 'all')
%   cfg.ylim      = vertical scaling (default: [-100 100]);
%   cfg.blocksize = duration in seconds for cutting the data up (default: [])
%
% This function requires the fieldtrip toolbox
%
% See also JAI_IMPORTDATASET, JAI_PREPROCESSING, JAI_SEGMENTATION, 
% JAI_DATASTRUCTURE, FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad      = ft_getopt(cfg, 'dyad', []);
part      = ft_getopt(cfg, 'part', 1);
artifact  = ft_getopt(cfg, 'artifact', []);
channel   = ft_getopt(cfg, 'channel', 'all');
ylim      = ft_getopt(cfg, 'ylim', [-100 100]);
blocksize = ft_getopt(cfg, 'blocksize', []);

if isempty(dyad)                                                            % if dyad number is not specified
  event = [];                                                               % the associated markers cannot be loaded and displayed
else                                                                        % else, load the stimulus markers 
  source = '/data/pt_01826/eegData/DualEEG_JAI_rawData/';
  filename = sprintf('DualEEG_JAI_%02d.vhdr', dyad);
  path = strcat(source, filename);
  event = ft_read_event(path);                                              % read stimulus markers
  
  eventCell = squeeze(struct2cell(event))';                   
  if any(strcmp(eventCell(:,2), 'S128'))                                    % check if stimulus markers are effected with the 'S128' error 
    match     = ~strcmp(eventCell(:,2), 'S128');                            % correct the error  
    event     = event(match);
    eventCell = squeeze(struct2cell(event))';
    eventNum  = zeros(size(eventCell, 1) - 2, 1);
    for i=3:size(eventCell, 1)
      eventNum(i-2) = sscanf(eventCell{i,2},'S%d');    
    end
    eventNum = eventNum - 128;
    for i=3:size(eventCell, 1)
      event(i).value = sprintf('S%3d', eventNum(i-2));    
    end
  end
end

if part < 1 || part > 2                                                     % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

% -------------------------------------------------------------------------
% Configure and start databrowser
% -------------------------------------------------------------------------
cfg                               = [];
cfg.ylim                          = ylim;
cfg.blocksize                     = blocksize;
cfg.viewmode                      = 'vertical';
cfg.artfctdef.threshold.artifact  = artifact;
cfg.continuous                    = 'no';
cfg.channel                       = channel;
cfg.event                         = event;
cfg.showcallinfo                  = 'no';

fprintf('Databrowser - Participant: %d\n', part);

switch part
  case 1
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, data.part1);
    else
      ft_databrowser(cfg, data.part1);
    end
    
  case 2
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, data.part2);
    else
      ft_databrowser(cfg, data.part2);
    end
    
end

end
