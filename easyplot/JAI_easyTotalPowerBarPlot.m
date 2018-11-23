function JAI_easyTotalPowerBarPlot( cfg, data )
% JAI_EASYTOTALPOWERBARPLOT shows the total power of all available
% channels. The channels are ordered in ascending order and outliers are
% highlighted.
% 
% Use as
%   JAI_easyTotalPowerBarPlot( cfg, data)
%
% where the input has to be a result of JAI_SELECTBADCHAN.
%
% The configuration option is
%   cfg.part        = number of participant (default: 1)
%
% This function requires the fieldtrip toolbox
%
% See also JAI_SELECTBADCHAN

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part        = ft_getopt(cfg, 'part', 1);

if ~ismember(part, [1, 2])
  error('cfg.part has to be 1 or 2');
end

switch part
  case 1
    data = data.part1;
  case 2
    data = data.part2;
end

% -------------------------------------------------------------------------
% Create the bar plot
% -------------------------------------------------------------------------
[pow, index] = sort(data.totalpow);                                         % sort the channels in ascending order

outliers  = data.outliers(index);
label     = data.label(index);

figure();
b = bar(pow);
b.FaceColor   = 'flat';
b.CData(outliers,:)  = repmat([1,0,0], sum(outliers), 1); 
set(gca, 'XTick', 1:numel(label), 'XTickLabel', label);

dim = [0.2 0.5 0.4 0.3];                                                    % add textbox with statistical information
q3  = sprintf('Q3:          %d', data.quartile(3));
m   = sprintf('Median:   %d', data.quartile(2));
q1  = sprintf('Q1:          %d', data.quartile(1));
iq  = sprintf('IQR:         %d', data.interquartile);
bp  = sprintf('BP:          %d...%d Hz', data.freqrange{1});
str = {'Info box:', '', q3, m, q1, iq, 'Outliers:  > 1.5 * IQR + Q3', bp};
annotation('textbox',dim,'String',str,'FitBoxToText','on',...
            'BackgroundColor','white');

end
