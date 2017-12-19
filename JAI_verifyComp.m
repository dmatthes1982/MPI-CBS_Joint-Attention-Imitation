function [ data_icacomp ] = JAI_verifyComp( data_icacomp, data_ica )
% JAI_VERIFYCOMP is a function to verify visually the ICA components having 
% a high correlation with one of the measured EOG signals.
%
% Use as
%   [ data_icacomp ] = JAI_verifyComp( data_icacomp, data_ica )
%
% where the input data have to be the result of JAI_CORRCOMP an JAI_ICA
%
% See also JAI_CORRCOMP and JAI_ICA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('Verify EOG-correlating components at participant 1\n\n');
data_icacomp.part1 = corrComp(data_icacomp.part1, data_ica.part1);
fprintf('\n');
fprintf('Verify EOG-correlating components at participant 2\n\n');
data_icacomp.part2 = corrComp(data_icacomp.part2, data_ica.part2);
end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the verification of the EOG-correlating components
%--------------------------------------------------------------------------
function [ dataICAComp ] = corrComp( dataICAComp, dataICA )

numOfElements = 1:length(dataICAComp.elements);

cfg               = [];
cfg.layout        = 'mpi_customized_acticap32.mat';
cfg.viewmode      = 'component';
cfg.channel       = find(ismember(dataICA.label, dataICAComp.elements))';
cfg.blocksize     = 30;
cfg.showcallinfo  = 'no';

ft_databrowser(cfg, dataICA);
colormap jet;

commandwindow;
selection = false;
    
while selection == false
  fprintf('\nDo you want to deselect some of theses components?\n')
  for i = numOfElements
    fprintf('[%d] - %s\n', i, dataICAComp.elements{i});
  end
  fprintf('Comma-seperate your selection and put it in squared brackets!\n');
  fprintf('Press simply enter if you do not want to deselect any component!\n');
  x = input('\nPlease make your choice! (i.e. [1,2,3]): ');

  if ~isempty(x)
    if ~all(ismember(x, numOfElements))
      selection = false;
      fprintf('At least one of the selected components does not exist.\n');
    else
      selection = true;
      fprintf('Component(s) %d will not used for eye artifact correction\n', x);
      
      dataICAComp.elements = dataICAComp.elements(~ismember(numOfElements,x));
    end
  else
    selection = true;
    fprintf('No Component will be rejected.\n');
  end
end

close(gcf);

end
