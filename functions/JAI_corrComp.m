function [ data_eogcomp ] = JAI_corrComp( data_icacomp, data_sensor )
% JAI_CORRCOMP estimates components which have a high correlation (> 80%) 
% with the EOGV and EOGH components of the original data
%
% Use as
%   [ data_eogcomp ] = JAI_corrComp( data_icacomp, data_sensor )
%
% where input data_icacomp has to be the results of JAI_ICA and 
% data_sensor the results of JAI_SELECTDATA
%
% This function requires the fieldtrip toolbox
%
% See also JAI_ICA and JAI_SELECTDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('Estimate EOG-correlating components at participant 1\n');
data_eogcomp.part1 = corrComp(data_icacomp.part1, data_sensor.part1);
fprintf('Estimate EOG-correlating components at participant 2\n');
data_eogcomp.part2 = corrComp(data_icacomp.part2, data_sensor.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the computation of the correlation coefficient
%--------------------------------------------------------------------------
function [ dataEOGComp ] = corrComp( dataICAComp, dataEOG )

numOfComp = length(dataICAComp.label);

eogvCorr = zeros(2,2,numOfComp);
eoghCorr = zeros(2,2,numOfComp);

eogvNum = strcmp('EOGV', dataEOG.label);
eoghNum = strcmp('EOGH', dataEOG.label);

for i=1:numOfComp
  eogvCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eogvNum,:), ...
                              dataICAComp.trial{1}(i,:));
  eoghCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eoghNum,:), ...
                              dataICAComp.trial{1}(i,:));
end

eogvCorr = squeeze(eogvCorr(1,2,:));
eoghCorr = squeeze(eoghCorr(1,2,:));

dataEOGComp.eogvCorr = eogvCorr;
dataEOGComp.eoghCorr = eoghCorr;

eogvCorr = abs(eogvCorr);
eoghCorr = abs(eoghCorr);

eogvCorr = (eogvCorr > 0.8);
eoghCorr = (eoghCorr > 0.8);

dataEOGComp.label      = dataICAComp.label;
dataEOGComp.topolabel  = dataICAComp.topolabel;
dataEOGComp.topo       = dataICAComp.topo;
dataEOGComp.unmixing   = dataICAComp.unmixing;
dataEOGComp.elements   = dataICAComp.label(eogvCorr | eoghCorr);

end

