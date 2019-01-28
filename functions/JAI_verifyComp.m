function [ data_eogcomp ] = JAI_verifyComp( data_eogcomp, data_icacomp )
% JAI_VERIFYCOMP is a function to verify visually the ICA components having 
% a high correlation with one of the measured EOG signals.
%
% Use as
%   [ data_eogcomp ] = JAI_verifyComp( data_eogcomp, data_icacomp )
%
% where the input data_eogcomp has to be the result of JAI_CORRCOMP ans 
% data_icacomp the result of JAI_ICA
%
% This function requires the fieldtrip toolbox
%
% See also JAI_CORRCOMP, JAI_ICA and FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('<strong>Verify EOG-correlating components at participant 1...</strong>\n');
data_eogcomp.part1 = verifyComp(data_eogcomp.part1, data_icacomp.part1);
fprintf('\n');
fprintf('<strong>Verify EOG-correlating components at participant 2...</strong>\n');
data_eogcomp.part2 = verifyComp(data_eogcomp.part2, data_icacomp.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the verification of the EOG-correlating components
%--------------------------------------------------------------------------
function [ dataEOGComp ] = verifyComp( dataEOGComp, dataICAcomp )

numOfElements = 1:length(dataEOGComp.elements);
idx = find(ismember(dataICAcomp.label, dataEOGComp.elements))';

fprintf(['Select components to reject!\n'...
         'Components which exceeded the selected EOG correlation '...'
         'threshold are already marked as bad.\n'...
         'These are:\n']);

for i = numOfElements
  [~, pos] = max(abs([dataEOGComp.eoghCorr(idx(i)) ...
                  dataEOGComp.eogvCorr(idx(i))]));
  if pos == 1
    corrVal = dataEOGComp.eoghCorr(idx(i)) * 100;
  else
    corrVal = dataEOGComp.eogvCorr(idx(i)) * 100;
  end
  fprintf('[%d] - component %d - %2.1f %% correlation\n', i, idx(i), corrVal);
end

cfg               = [];
cfg.rejcomp       = idx;
cfg.blocksize     = 30;
cfg.layout        = 'mpi_customized_acticap32.mat';
cfg.colormap      = 'jet';
cfg.showcallinfo  = 'no';

ft_warning off;
badComp = ft_icabrowser(cfg, dataICAcomp);
ft_warning on;

if sum(badComp) == 0
  cprintf([1,0.5,0],'No components are selected!\n');
  cprintf([1,0.5,0],'NOTE: The following cleaning operation will keep the data as it is!\n');
end

dataEOGComp.elements = dataICAcomp.label(badComp);

end
