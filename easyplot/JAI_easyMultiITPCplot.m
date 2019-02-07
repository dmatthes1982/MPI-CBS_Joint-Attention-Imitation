function JAI_easyMultiITPCplot(cfg, data)
% JAI_EASYMULTIITPCPLOT is a function, which makes it easier to plot a 
% multi inter-trial phase coherence representation of all electrodes in a 
% specific condition on a head model.
%
% Use as
%   JAI_easyMultiITPCplot(cfg, data)
%
% where the input data have to be a result from JAI_INTERTRAILPHASECOH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2
%   cfg.condition   = condition (default: 7 or 'Single_2Hz', see JAI_DATASTRUCTURE)
%   cfg.freqlim     = [begin end] (default: [1 48])
%   cfg.timelim     = [begin end] (default: [0.2 9.8])
%  
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRIALPHASECOH, JAI_DATASTRUCTURE

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cfg.part    = ft_getopt(cfg, 'part', 1);
cfg.cond    = ft_getopt(cfg, 'condition', 7);
cfg.freqlim = ft_getopt(cfg, 'freqlim', [1 48]);
cfg.timelim = ft_getopt(cfg, 'timelim', [0.2 9.8]);

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(cfg.part, [0,1,2])                                             % check cfg.part definition
  error('cfg.part has to either 0, 1 or 2');
end

switch cfg.part                                                             % check validity of cfg.part
  case 0
    if isfield(data, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
    dataPlot = data;
  case 1
    if ~isfield(data, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    dataPlot = data.part1;
  case 2
    if ~isfield(data, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    dataPlot = data.part2;
end

if length(cfg.freqlim) ~= 2                                                 % check cfg.freqlim definition
  error('cfg.freqlimits has to be a 1x2 vector: [begin end]');
end

if length(cfg.timelim) ~= 2                                                 % check cfg.timelim definition
  error('cfg.timelimits has to be a 1x2 vector: [begin end]');
end

trialinfo = dataPlot.trialinfo;                                             % get trialinfo

cfg.cond = JAI_checkCondition( cfg.cond, 'flag', 'itpc' );                  % check cfg.condition definition
if isempty(find(trialinfo == cfg.cond, 1))
  error('The selected dataset contains no condition %d.', cfg.cond);
else
  trialNum = find(ismember(trialinfo, cfg.cond));
end

% -------------------------------------------------------------------------
% estimate actual limits
% -------------------------------------------------------------------------
time = dataPlot.time{trialNum};
freq = dataPlot.freq;

[~, idxf1] = min(abs(freq-cfg.freqlim(1)));                                 % estimate frequency range
freqlim(1) = freq(idxf1);

[~, idxf2] = min(abs(freq-cfg.freqlim(2)));
freqlim(2) = freq(idxf2);

[~, idxt1] = min(abs(time-cfg.timelim(1)));                                 % estimate time range
timelim(1) = time(idxt1);

[~, idxt2] = min(abs(time-cfg.timelim(2)));
timelim(2) = time(idxt2);

itpcMin = nanmin(dataPlot.itpc{trialNum}(:));                               % estimate itpc limits
itpcMax = nanmax(dataPlot.itpc{trialNum}(:));

itpclim = [itpcMin itpcMax];

% -------------------------------------------------------------------------
% Load layout informations
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath),...
     'lay');

[selchan, sellay] = match_str(dataPlot.label, lay.label);                   % take the subselection of channels that is contained in the layout
chanX             = lay.pos(sellay, 1);
chanY             = lay.pos(sellay, 2);
chanWidth         = lay.width(sellay);
chanHeight        = lay.height(sellay);

% -------------------------------------------------------------------------
% Multi inter-trial phase coherence representation
% -------------------------------------------------------------------------
datamatrix = dataPlot.itpc{trialNum}(selchan, idxf1:idxf2, idxt1:idxt2);    % extract the data matrix    

hold on;                                                                    % hold the figure
cla;                                                                        % clear all axis

% plot the layout
ft_plot_lay(lay, 'box', 0, 'label', 0, 'outline', 1, 'point', 'no', ...
            'mask', 'no', 'fontsize', 8, 'labelyoffset', ...
            1.4*median(lay.height/2), 'labelalignh', 'center', ...
            'chanindx', find(~ismember(lay.label, {'COMNT', 'SCALE'})) );


% plot the channels
for k=1:length(selchan)                                                     
  cdata = squeeze(datamatrix(k, :, :));
  nans_mask = ~isnan(cdata);
  mask = double(nans_mask);
  ft_plot_matrix(cdata, 'clim', itpclim, 'tag', 'cip', 'highlightstyle',... 
                'saturation', 'highlight', mask, 'hpos', chanX(k), ...
                'vpos', chanY(k), 'width', chanWidth(k), ...
                'height', chanHeight(k));
end

% add the comment field
k = find(strcmp('COMNT', lay.label));
comment = date;
comment = sprintf('%0s\nxlim=[%.3g %.3g]', comment, timelim(1), timelim(2));
comment = sprintf('%0s\nylim=[%.3g %.3g]', comment, freqlim(1), freqlim(2));
comment = sprintf('%0s\nzlim=[%.3g %.3g]', comment, itpclim(1), itpclim(2));

ft_plot_text(lay.pos(k, 1), lay.pos(k, 2), sprintf(comment), ...
             'FontSize', 8, 'FontWeight', []);

% plot the SCALE object
k = find(strcmp('SCALE', lay.label));
cdata = squeeze(mean(datamatrix, 1));
mask = ~isnan(cdata);
mask = double(mask);
ft_plot_matrix(cdata, 'clim', itpclim, 'tag', 'cip', 'highlightstyle',...
               'saturation', 'highlight', mask, 'hpos', lay.pos(k, 1), ...
               'vpos', lay.pos(k, 2), 'width', lay.width(k), ...
               'height', lay.height(k))

% set figure title
if cfg.part == 0
  title(sprintf('ITPC - Cond.: %d', cfg.cond));
else
  title(sprintf('ITPC - Part.: %d - Cond.: %d', cfg.part, cfg.cond));
end
             
colorbar;                                                                   % add the colorbar                                                                
axis tight;                                                                 % format the layout
axis off;                                                                   % remove the axis
hold off;                                                                   % release the figure

% Make the figure interactive
% add the cfg/data/channel information to the figure under identifier 
% linked to this axis
ident                 = ['axh' num2str(round(sum(clock.*1e6)))];            % unique identifier for this axis
set(gca,'tag',ident);
info                  = guidata(gcf);
info.(ident).x        = lay.pos(:, 1);
info.(ident).y        = lay.pos(:, 2);
info.(ident).label    = lay.label;
info.(ident).cfg      = cfg;
info.(ident).data     = data;
guidata(gcf, info);
set(gcf, 'WindowButtonUpFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyITPCplot}, ...
    'event', 'WindowButtonUpFcn'});
set(gcf, 'WindowButtonDownFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyITPCplot}, ...
    'event', 'WindowButtonDownFcn'});
set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyITPCplot}, ...
    'event', 'WindowButtonMotionFcn'});

end

%--------------------------------------------------------------------------
% SUBFUNCTION which is called after selecting channels
%--------------------------------------------------------------------------
function select_easyITPCplot(label, varargin)
% fetch cfg/data based on axis indentifier given as tag
ident = get(gca,'tag');
info  = guidata(gcf);
cfg   = info.(ident).cfg;
data  = info.(ident).data;
if ~isempty(label)
  if any(ismember(label, {'SCALE', 'F9', 'F10', 'V1', 'V2'}))
    cprintf([1,0.5,0], 'Selection of SCALE, F9, F10, V1, or V2 is currently not supported.\n');
  else
    cfg.electrode = label;
    fprintf('selected cfg.electrode = {%s}\n', vec2str(cfg.electrode, [], [], 0));
    % ensure that the new figure appears at the same position
    figure('Position', get(gcf, 'Position'));
    JAI_easyITPCplot(cfg, data);
  end
end

end
