function JAI_easyMPLVplot( cfg, data )
% JAI_EASYMPLVPLOT is a function, which makes it easier to plot the mean 
% PLV values from all electrodes of a specific condition from the 
% JAI_DATASTRUCTURE.
%
% Use as
%   JAI_easyPLVplot( cfg, data )
%
% where the input data has to be the result of JAI_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 111 or 'SameObject', see JAI_DATASTRUCTURE)
%
% This function requires the fieldtrip toolbox.
%
% See also JAI_DATASTRUCTURE, PLOT, JAI_PHASELOCKVAL, JAI_CALCMEANPLV

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond = ft_getopt(cfg, 'condition', 111);

trialinfo = data.dyad.trialinfo;                                            % get trialinfo

cond = JAI_checkCondition( cond );                                          % check cfg.condition definition and translate it into trl number    
trl  = find(trialinfo == cond);
if isempty(trl)
  error('The selected dataset contains no condition %d.', cond);
end

% -------------------------------------------------------------------------
% Plot mPLV representation
% -------------------------------------------------------------------------
label = data.dyad.label;
components = 1:1:length(label);

colormap jet;
imagesc(components, components, data.dyad.mPLV{trl});
set(gca, 'XTick', components,'XTickLabel', label);                          % use labels instead of numbers for the axis description
set(gca, 'YTick', components,'YTickLabel', label);
set(gca,'xaxisLocation','top');                                             % move xlabel to the top
title(sprintf(' mean Phase-Locking-Values in Condition: %d', cond));   
colorbar;

end
