function [ component ] = JAI_corrComp( data_icacomp, data )
% JAI_CORRCOMP estimates components which have a high correlation (> 80%) 
% with the EOGV and EOGH components of the original data
%
% Use as
%   [ component ] = JAI_corrcoef( data_icacomp, data )
%
% where input data have to be the results from JAI_ICA and JAI_SELECTDATA
%
% See also JAI_ICA and JAI_SELECTDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('Estimate correlating components at participant 1\n');
component.part1 = corrComp(data_icacomp.part1, data.part1);
fprintf('Estimate correlating components at participant 2\n');
component.part2 = corrComp(data_icacomp.part2, data.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which is called after selecting channels
%--------------------------------------------------------------------------
function [ comp ] = corrComp( dataICA, dataEOG )

numOfComp = length(dataICA.label);

eogvCorr = zeros(2,2,numOfComp);
eoghCorr = zeros(2,2,numOfComp);

eogvNum = strcmp('EOGV', dataEOG.label);
eoghNum = strcmp('EOGH', dataEOG.label);

for i=1:numOfComp
  eogvCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eogvNum,:), ...
                              dataICA.trial{1}(i,:));
  eoghCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eoghNum,:), ...
                              dataICA.trial{1}(i,:));
end

eogvCorr = squeeze(eogvCorr(1,2,:));
eoghCorr = squeeze(eoghCorr(1,2,:));

comp.eogvCorr = eogvCorr;
comp.eoghCorr = eoghCorr;

eogvCorr = abs(eogvCorr);
eoghCorr = abs(eoghCorr);

eogvCorr = (eogvCorr > 0.8);
eoghCorr = (eoghCorr > 0.8);

comp.label      = dataICA.label;
comp.topolabel  = dataICA.topolabel;
comp.topo       = dataICA.topo;
comp.unmixing   = dataICA.unmixing;
comp.elements   = dataICA.label(eogvCorr | eoghCorr);

end

