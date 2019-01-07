function [ data ] = JAI_preprocessing( cfg, data )
% JAI_PREPROCESSING does the basic bandpass filtering of the raw data
% and is calculating the EOG signals.
%
% Use as
%   [ data ] = JAI_preprocessing(cfg, data)
%
% where the input data has to be the result of JAI_IMPORTATASET
%
% The configuration options are
%   cfg.bpfreq            = passband range [begin end] (default: [0.1 48])
%   cfg.bpfilttype        = bandpass filter type, 'but' or 'fir' (default: fir')
%   cfg.bpinstabilityfix  = deal with filter instability, 'no' or 'split' (default: 'no')
%   cfg.part1BadChan      = bad channels of participant 1 which should be excluded (default: [])
%   cfg.part2BadChan      = bad channels of participant 2 which should be excluded (default: [])
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_IMPORTDATASET, JAI_SELECTBADCHAN, FT_PREPROCESSING,
% JAI_DATASTRUCTURE

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq            = ft_getopt(cfg, 'bpfreq', [0.1 48]);
bpfilttype        = ft_getopt(cfg, 'bpfilttype', 'fir');
bpinstabilityfix  = ft_getopt(cfg, 'bpinstabilityfix', 'no');
part1BadChan      = ft_getopt(cfg, 'part1BadChan', []);
part2BadChan      = ft_getopt(cfg, 'part2BadChan', []);

% -------------------------------------------------------------------------
% Channel configuration
% -------------------------------------------------------------------------
if ~isempty(part1BadChan)
  part1BadChan = cellfun(@(x) sprintf('-%s', x), part1BadChan, ...
                      'UniformOutput', false);
end
if ~isempty(part2BadChan)
part2BadChan = cellfun(@(x) sprintf('-%s', x), part2BadChan, ...
                      'UniformOutput', false);
end

part1Chan = [{'all'} part1BadChan];                                         % do bandpassfiltering only with good channels and remove the bad once
part2Chan = [{'all'} part2BadChan];

% -------------------------------------------------------------------------
% Basic bandpass filtering
% -------------------------------------------------------------------------

% general filtering
cfg                   = [];
cfg.bpfilter          = 'yes';                                              % use bandpass filter
cfg.bpfreq            = bpfreq;                                             % bandpass range
cfg.bpfilttype        = bpfilttype;                                         % bandpass filter type
cfg.bpinstabilityfix  = bpinstabilityfix;                                   % deal with filter instability
cfg.trials            = 'all';                                              % use all trials
cfg.feedback          = 'no';                                               % feedback should not be presented
cfg.showcallinfo      = 'no';                                               % prevent printing the time and memory after each function call

printf('Filter data of participant 1 (basic bandpass)...\n');
cfg.channel = part1Chan;
data.part1  = ft_preprocessing(cfg, data.part1);

printf('Filter data of participant 2 (basic bandpass)...\n');
cfg.channel = part2Chan;
data.part2  = ft_preprocessing(cfg, data.part2);

fprintf('Estimate EOG signals for participant 1...\n');
data.part1 = estimEOG(data.part1);

fprintf('Estimate EOG signals for participant 2...\n');
data.part2 = estimEOG(data.part2);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_out ] = estimEOG( data_in )

cfg              = [];
cfg.channel      = {'F9', 'F10'};
cfg.reref        = 'yes';
cfg.refchannel   = 'F10';
cfg.showcallinfo = 'no';
cfg.feedback     = 'no';

eogh             = ft_preprocessing(cfg, data_in);
eogh.label{1}    = 'EOGH';

cfg              = [];
cfg.channel      = 'EOGH';
cfg.showcallinfo = 'no';

eogh             = ft_selectdata(cfg, eogh);

cfg              = [];
cfg.channel      = {'V1', 'V2'};
cfg.reref        = 'yes';
cfg.refchannel   = 'V2';
cfg.showcallinfo = 'no';
cfg.feedback     = 'no';

eogv             = ft_preprocessing(cfg, data_in);
eogv.label{1}    = 'EOGV';

cfg              = [];
cfg.channel      = 'EOGV';
cfg.showcallinfo = 'no';

eogv             = ft_selectdata(cfg, eogv);

cfg               = [];
cfg.showcallinfo  = 'no';
ft_info off;
data_out          = ft_appenddata(cfg, data_in, eogv, eogh);
data_out.fsample  = data_in.fsample;
ft_info on;

end
