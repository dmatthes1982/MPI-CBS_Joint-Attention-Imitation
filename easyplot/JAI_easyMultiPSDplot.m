function JAI_easyMultiPSDplot(cfg, data)
% JAI_EASYMULTIPSDPLOT is a function, which makes it easier to plot the
% power spectral density of all electrodes within a specific condition on a
% head model.
%
% Use as
%   JAI_easyMultiPSDplot(cfg, data)
%
% where the input data have to be a result from JAI_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%
% This function requires the fieldtrip toolbox
%
% See also JAI_PWELCH, JAI_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cfg.part    = ft_getopt(cfg, 'part', 1);
cfg.cond    = ft_getopt(cfg, 'condition', 111);

if ~ismember(cfg.part, [0,1,2])                                             % check cfg.part definition
  error('cfg.part has to either 0, 1 or 2');
end

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

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

trialinfo = dataPlot.trialinfo;                                             % get trialinfo

cfg.cond = JAI_checkCondition( cfg.cond );                                  % check cfg.condition definition    
if isempty(find(trialinfo == cfg.cond, 1))
  error('The selected dataset contains no condition %d.', cfg.cond);
else
  trialNum = find(ismember(trialinfo, cfg.cond));
end

% -------------------------------------------------------------------------
% Load layout informations
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath),...
     'lay');

[selchan, sellay] = match_str(dataPlot.label, lay.label);                   % extract the subselection of channels that is part of the layout
eogvchan          = match_str(dataPlot.label, {'V1', 'V2'});                % determine the vertical eog channles 
chanX             = lay.pos(sellay, 1);
chanY             = lay.pos(sellay, 2);
chanWidth         = lay.width(sellay);
chanHeight        = lay.height(sellay);

% -------------------------------------------------------------------------
% Multi power spectral density (PSD) plot 
% -------------------------------------------------------------------------
datamatrix  = squeeze(dataPlot.powspctrm(trialNum, selchan, :));            %#ok<FNDSB> % extract the powerspctrm matrix    
xval        = dataPlot.freq;                                                % extract the freq vector
xmax        = max(xval);                                                    % determine the frequency maximum
val         = ~ismember(selchan, eogvchan);                                 
ymaxchan    = selchan(val);
ymax        = max(max(datamatrix(ymaxchan, 1:48)));                         % determine the power maximum of all channels expect V1 und V2

hold on;                                                                    % hold the figure
cla;                                                                        % clear all axis

% plot the layout
ft_plot_lay(lay, 'box', 0, 'label', 0, 'outline', 1, 'point', 'no', ...
            'mask', 'no', 'fontsize', 8, 'labelyoffset', ...
            1.4*median(lay.height/2), 'labelalignh', 'center', ...
            'chanindx', find(~ismember(lay.label, {'COMNT', 'SCALE'})) );

% plot the channels
for k=1:length(selchan) 
  yval = datamatrix(k, :);
  setChanBackground([0 xmax], [0 ymax], chanX(k), chanY(k), ...             % set background of the channel boxes to white
                    chanWidth(k), chanHeight(k));
  ft_plot_vector(xval, yval, 'width', chanWidth(k), 'height', chanHeight(k),...
                'hpos', chanX(k), 'vpos', chanY(k), 'hlim', [0 xmax], ...
                'vlim', [0 ymax], 'box', 0);
end

% add the comment field
k = find(strcmp('COMNT', lay.label));
comment = date;
comment = sprintf('%0s\nxlim=[%.3g %.3g]', comment, 0, xmax);
comment = sprintf('%0s\nylim=[%.3g %.3g]', comment, 0, ymax);

ft_plot_text(lay.pos(k, 1), lay.pos(k, 2), sprintf(comment), ...
             'FontSize', 8, 'FontWeight', []);

% plot the SCALE object
k = find(strcmp('SCALE', lay.label));
if ~isempty(k)
  x = lay.pos(k,1);
  y = lay.pos(k,2);
  plotScales([0 xmax], [0 ymax], x, y, chanWidth(1), chanHeight(1));
end

% set figure title
if cfg.part == 0
  title(sprintf('PSD - Cond.: %d', cfg.cond));
else
  title(sprintf('PSD - Part.: %d - Cond.: %d', cfg.part, cfg.cond));
end

axis tight;                                                                 % format the layout
axis off;                                                                   % remove the axis
hold off;                                                                   % release the figure

% Make the figure interactive
% add the cfg/data/channel information to the figure under identifier 
% linked to this axis
ident                 = ['axh' num2str(round(sum(clock.*1e6)))];            % unique identifier for this axis
set(gca,'tag',ident);
info                      = guidata(gcf);
info.(ident).x            = lay.pos(:, 1);
info.(ident).y            = lay.pos(:, 2);
info.(ident).label        = lay.label;
info.(ident).cfg          = cfg;
info.(ident).cfg.avgelec  = 'no';
info.(ident).data         = data;
guidata(gcf, info);
set(gcf, 'WindowButtonUpFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyPSDplot}, ...
    'event', 'WindowButtonUpFcn'});
set(gcf, 'WindowButtonDownFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyPSDplot}, ...
    'event', 'WindowButtonDownFcn'});
set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', ...
    true, 'callback', {@select_easyPSDplot}, ...
    'event', 'WindowButtonMotionFcn'});

end

%--------------------------------------------------------------------------
% SUBFUNCTION for plotting the SCALE information
%--------------------------------------------------------------------------
function plotScales(hlim, vlim, hpos, vpos, width, height)

% the placement of all elements is identical
placement = {'hpos', hpos, 'vpos', vpos, 'width', width, 'height', height, 'hlim', hlim, 'vlim', vlim};

ft_plot_box([hlim vlim], placement{:}, 'edgecolor', 'k' , 'facecolor', 'white');

if hlim(1)<=0 && hlim(2)>=0
  ft_plot_vector([0 0], vlim, placement{:}, 'color', 'b');
end

if vlim(1)<=0 && vlim(2)>=0
  ft_plot_vector(hlim, [0 0], placement{:}, 'color', 'b');
end

ft_plot_text(hlim(1), vlim(1), [num2str(hlim(1), 3) ' '], placement{:}, 'rotation', 90, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'top', 'FontSize', 8);
ft_plot_text(hlim(2), vlim(1), [num2str(hlim(2), 3) ' '], placement{:}, 'rotation', 90, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'top', 'FontSize', 8);
ft_plot_text(hlim(1), vlim(1), [num2str(vlim(1), 3) ' '], placement{:}, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
ft_plot_text(hlim(1), vlim(2), [num2str(vlim(2), 3) ' '], placement{:}, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which creates channel boxes with a white background
%--------------------------------------------------------------------------
function setChanBackground(hlim, vlim, hpos, vpos, width, height)

% the placement of all elements is identical
placement = {'hpos', hpos, 'vpos', vpos, 'width', width, 'height', height, 'hlim', hlim, 'vlim', vlim};

ft_plot_box([hlim vlim], placement{:}, 'edgecolor', 'k' , 'facecolor', 'white');

end

%--------------------------------------------------------------------------
% SUBFUNCTION which is called after selecting channels
%--------------------------------------------------------------------------
function select_easyPSDplot(label, varargin)
% fetch cfg/data based on axis indentifier given as tag
ident = get(gca,'tag');
info  = guidata(gcf);
cfg   = info.(ident).cfg;
data  = info.(ident).data;
if ~isempty(label)
  if any(ismember(label, {'SCALE'}))
    cprintf([1,0.5,0], 'Selection of SCALE, F9, F10, V1, or V2 is currently not supported.\n');
  else
    cfg.electrode = label;
    fprintf('selected cfg.electrode = {%s}\n', vec2str(cfg.electrode, [], [], 0));
    % ensure that the new figure appears at the same position
    figure('Position', get(gcf, 'Position'));
    JAI_easyPSDplot(cfg, data);
  end
end

end
