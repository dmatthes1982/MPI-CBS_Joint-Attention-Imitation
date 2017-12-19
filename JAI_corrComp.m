function [ data_icacomp ] = JAI_corrComp( data_ica, data_sensor )
% JAI_CORRCOMP estimates components which have a high correlation (> 80%) 
% with the EOGV and EOGH components of the original data
%
% Use as
%   [ data_icacomp ] = JAI_corrComp( data_ica, data_sensor )
%
% where input data have to be the results from JAI_ICA and JAI_SELECTDATA
%
% See also JAI_ICA and JAI_SELECTDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('Estimate EOG-correlating components at participant 1\n');
data_icacomp.part1 = corrComp(data_ica.part1, data_sensor.part1);
fprintf('Estimate EOG-correlating components at participant 2\n');
data_icacomp.part2 = corrComp(data_ica.part2, data_sensor.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the computation of the correlation coefficient
%--------------------------------------------------------------------------
function [ dataICAComp ] = corrComp( dataICA, dataEOG )

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

dataICAComp.eogvCorr = eogvCorr;
dataICAComp.eoghCorr = eoghCorr;

eogvCorr = abs(eogvCorr);
eoghCorr = abs(eoghCorr);

eogvCorr = (eogvCorr > 0.8);
eoghCorr = (eoghCorr > 0.8);

dataICAComp.label      = dataICA.label;
dataICAComp.topolabel  = dataICA.topolabel;
dataICAComp.topo       = dataICA.topo;
dataICAComp.unmixing   = dataICA.unmixing;
dataICAComp.elements   = dataICA.label(eogvCorr | eoghCorr);

end

