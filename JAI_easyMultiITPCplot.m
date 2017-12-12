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
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.freqlimits  = [begin end] (default: [1 48])
%   cfg.timelimits  = [begin end] (default: [0.2 9.8])
%  
% This function requires the fieldtrip toolbox
%
% See also JAI_INTERTRIALPHASECOH, JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cfg.part    = ft_getopt(cfg, 'part', 1);
cfg.cond    = ft_getopt(cfg, 'condition', 111);
freqlim = ft_getopt(cfg, 'freqlimits', [1 48]);
timelim = ft_getopt(cfg, 'timelimits', [0.2 9.8]);

if cfg.part < 1 || cfg.part > 2                                             % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

if length(freqlim) ~= 2                                                     % check cfg.freqlimits definition
  error('cfg.freqlimits has to be a 1x2 vector: [begin end]');
end

if length(timelim) ~= 2                                                     % check cfg.timelimits definition
  error('cfg.timelimits has to be a 1x2 vector: [begin end]');
end

if cfg.part == 1                                                                 
  trialinfo = data.part1.trialinfo;                                         % get specific trialinfo and
  dataPlot  = data.part1;                                                   % extract data of selected participant
elseif cfg.part == 2
  trialinfo = data.part2.trialinfo;
  dataPlot  = data.part2;
  
end

cfg.cond = JAI_checkCondition( cfg.cond );                                  % check cfg.condition definition    
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

[~, idxf1] = min(abs(freq-freqlim(1)));                                     % estimate frequency range 
freqlim(1) = freq(idxf1);

[~, idxf2] = min(abs(freq-freqlim(2)));
freqlim(2) = freq(idxf2);

[~, idxt1] = min(abs(time-timelim(1)));                                     % estimate time range
timelim(1) = time(idxt1);

[~, idxt2] = min(abs(time-timelim(2)));
timelim(2) = time(idxt2);

itpcMin = nanmin(dataPlot.itpc{trialNum}(:));                               % estimate itpc limits
itpcMax = nanmax(dataPlot.itpc{trialNum}(:));

itpclim = [itpcMin itpcMax];

% -------------------------------------------------------------------------
% load head layout informations
% -------------------------------------------------------------------------
load('mpi_customized_acticap32.mat','lay');

[selchan, sellay] = match_str(dataPlot.label, lay.label);                   % take the subselection of channels that is contained in the layout
chanX             = lay.pos(sellay, 1);
chanY             = lay.pos(sellay, 2);
chanWidth         = lay.width(sellay);
chanHeight        = lay.height(sellay);

% -------------------------------------------------------------------------
% multi inter-trial phase coherence representation
% -------------------------------------------------------------------------
datamatrix = dataPlot.itpc{trialNum}(selchan, idxf1:idxf2, idxt1:idxt2);    % extract the data matrix    

hold on;                                                                    % hold the figure
cla;                                                                        % clear all axis

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

% add the head model
ft_plot_lay(lay, 'box', 0, 'label', 0, 'outline', 1, 'point', 'no', ...
            'mask', 'no', 'fontsize', 8, 'labelyoffset', ...
            1.4*median(lay.height/2), 'labelalignh', 'center', ...
            'chanindx', find(~ismember(lay.label, {'COMNT', 'SCALE'})) );

% add the comment field
k = find(strcmp('COMNT', lay.label));
comment = date;
comment = sprintf('%0s\nxlim=[%.3g %.3g]', comment, timelim(1), timelim(2));
comment = sprintf('%0s\nylim=[%.3g %.3g]', comment, freqlim(1), freqlim(2));
comment = sprintf('%0s\nzlim=[%.3g %.3g]', comment, itpclim(1), itpclim(2));

ft_plot_text(lay.pos(k, 1), lay.pos(k, 2), sprintf(comment), ...
             'FontSize', 8, 'FontWeight', []);

% add the mean over all channels
k = find(strcmp('SCALE', lay.label));
cdata = squeeze(mean(datamatrix, 1));
mask = ~isnan(cdata);
mask = double(mask);
ft_plot_matrix(cdata, 'clim', itpclim, 'tag', 'cip', 'highlightstyle',...
               'saturation', 'highlight', mask, 'hpos', lay.pos(k, 1), ...
               'vpos', lay.pos(k, 2), 'width', lay.width(k), ...
               'height', lay.height(k))

colorbar;                                                                   % add the colorbar                                                                
axis tight;                                                                 % format the layout
axis off;                                                                   % remove teh axis
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
    fprintf('selected cfg.electrode = {%s}\n', join_str(', ', cfg.electrode));
    % ensure that the new figure appears at the same position
    figure('Position', get(gcf, 'Position'));
    JAI_easyITPCplot(cfg, data);
  end
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION which transform a cell array of labels into a string
%--------------------------------------------------------------------------
function t = join_str(separator,cells)

if isempty(cells)
  t = '';
  return;
end

if ischar(cells)
  t = cells;
  return;
end

t = char(cells{1});

for i=2:length(cells)
  t = [t separator char(cells{i})];                                         %#ok<AGROW>
end

end
