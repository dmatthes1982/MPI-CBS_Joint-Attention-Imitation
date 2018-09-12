function JAI_easyTopoplotCCA( cfg, data_cca )
% JAI_EASYTOPOPLOTCCA is a function which can be used to plot the 
% distribution over the head of selected CCA components.
%
% Use as
%   JAI_easyTopoplotCCA( cfg, data_cca )
%
% where the input data have to be a result of JAI_CCA.
%
% The configuration options are 
%   cfg.part        = number of participant (1 or 2) (default: 1)
%   cfg.condition   = condition (default: 111 or 'SameObjectB', see JAI_DATASTRUCTURE)
%   cfg.component   = number of component(s) (examples: 1, [1,3,5], [1:23], 'all' (default: 'all')
%
% This function requires the fieldtrip toolbox
%
% See also JAI_DATASTRUCTURE, JAI_CCA, FT_TOPOLOTIC

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part  = ft_getopt(cfg, 'part', 1);
cond  = ft_getopt(cfg, 'condition', 111);
comp  = ft_getopt(cfg, 'component', 'all');

switch part                                                                 % check validity of cfg.part
  case 1
    data_cca = data_cca.part1;
  case 2
    data_cca = data_cca.part2;
  otherwise
    error('Only 1 and 2 are valid options for cfg.part!');
end

if ~isnumeric(comp)
  if strcmp(comp, 'all')
    comp = 1:1:length(data_cca.label);
  else
    error('Wrong cfg.component definition! See help JAI_easyTopoplotCCA.');
  end
end

trialinfo = data_cca.trialinfo;                                             % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

cond  = JAI_checkCondition( cond );                                         % check cfg.condition definition    
trl   = find(trialinfo == cond);
if isempty(trl)
  error('The selected dataset contains no condition %d.', cond);
end

% -------------------------------------------------------------------------
% Select condition
% -------------------------------------------------------------------------
data_cca.time       = data_cca.time(trl);
data_cca.trialinfo  = data_cca.trialinfo(trl);
data_cca.sampleinfo = data_cca.sampleinfo(trl,:);
data_cca.trial      = data_cca.trial(trl);
data_cca.topo       = data_cca.topo{trl};
data_cca.unmixing   = data_cca.unmixing{trl};

% -------------------------------------------------------------------------
% Plot topoplot
% -------------------------------------------------------------------------
cfg               = [];
cfg.component     = comp;
cfg.layout        = 'mpi_customized_acticap32.mat';
cfg.zlim          = 'maxabs';

cfg.comment       = 'no';
cfg.showcallinfo  = 'no';
cfg.colorbar      = 'yes';

figure(1);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colormap 'jet';
ft_info off;
ft_topoplotIC(cfg, data_cca);
ft_info on;

end

