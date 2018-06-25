function JAI_easyArtfctmapPlot(cfg, cfg_autoart)
% JAI_EASYARTFCTMAPPLOT generates a multiplot of artifact maps for all 
% existing trials. A single map contains a artifact map for a specific 
% condition from which one could determine which electrode exceeds the 
% artifact detection threshold in which time segment. Artifact free 
% segments are filled with green and the segments which violates the 
% threshold are colored in red.
%
% Use as
%   JAI_easyArtfctmapPlot(cfg, cfg_autoart)
%
% where cfg_autoart has to be a result from JAI_AUTOARTIFACT.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     1 - plot map for participant 1
%                     2 - plot map for participant 2 
%
% This function requires the fieldtrip toolbox
%
% See also JAI_AUTOARTIFACT

% Copyright (C) 2018, Daniel Matthes, MPI CBS


% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 1);                                           % get number of participant

label = cfg_autoart.label;                                                  % get labels which were used for artifact detection

if part == 1
  badNumChan  = cfg_autoart.bad1NumChan;
  cfg_autoart = cfg_autoart.part1;
elseif part == 2
  badNumChan  = cfg_autoart.bad2NumChan;
  cfg_autoart = cfg_autoart.part2;
else                                                                        % check validity of cfg.part
  error('Input structure seems to be no cfg_autoart element including participants fields');
end

% -------------------------------------------------------------------------
% Define colormap
% -------------------------------------------------------------------------
cmap = [0.6 0.8 0.4; 1 0.2 0.2];                                            % colormap with two colors, green tone for good segments, red tone for bad once

% -------------------------------------------------------------------------
% Plot artifact map
% -------------------------------------------------------------------------
artfctmap = cfg_autoart.artfctdef.threshold.artfctmap;                      % extract artifact maps from cfg_autoart structure
conditions = size(artfctmap, 2);                                            % estimate number of conditions
elements = sqrt(conditions);                                                % estimate structure of multiplot
rows = fix(elements);                                                       % try to create a nearly square design
rest = mod(elements, rows);

if rest > 0
  if rest > 0.5
    rows    = ceil(elements);
    columns = ceil(elements);
  else
    columns = ceil(elements);
  end
else
  columns = rows;
end

data(:,1) = label;
data(:,2) = num2cell(badNumChan);

f = figure;
pt = uipanel('Parent', f, 'Title', 'Electrodes', 'Fontsize', 12, 'Position', [0.02,0.02,0.09,0.96]);
pg = uipanel('Parent', f, 'Title', 'Artifact maps', 'Fontsize', 12, 'Position', [0.12,0.02,0.86,0.96]);
uitable(pt, 'Data', data, 'ColumnWidth', {50 50}, 'ColumnName', {'Chans', 'Artfcts'}, 'Units', 'normalized', 'Position', [0.01, 0.01, 0.98, 0.98]);

colormap(f, cmap);                                                          % change colormap for this new figure

for i=1:1:conditions
  subplot(rows,columns,i,'parent', pg);
  imagesc(artfctmap{i},[0 1]);                                              % plot subelements
  xlabel('time in sec');
  ylabel('channels');
end

axes('Units','Normal');                                                     % set main title for the whole figure
h = title('Artifact Map');
set(gca,'visible','off')
set(h,'visible','on')

end
