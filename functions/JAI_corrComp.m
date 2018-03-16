function [ data_eogcomp ] = JAI_corrComp( cfg, data_icacomp, data_sensor )
% JAI_CORRCOMP estimates components which have a high correlation (> 80%) 
% with the EOGV and EOGH components of the original data
%
% Use as
%   [ data_eogcomp ] = JAI_corrComp( data_icacomp, data_sensor )
%
% The configuration options are
%    cfg.threshold = correlation threshold for marking eog-like components (range: 0...1, default: [0.8 0.8])
%                    one value for each participant
%
% where input data_icacomp has to be the results of JAI_ICA and 
% data_sensor the results of JAI_SELECTDATA
%
% This function requires the fieldtrip toolbox
%
% See also JAI_ICA and JAI_SELECTDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
threshold  = ft_getopt(cfg, 'threshold', [0.8 0.8]);

if (any(threshold < 0) || any(threshold > 1) )
  error('The threshold definition is out of range [0 1]');
end

% -------------------------------------------------------------------------
% Estimate correlating components
% -------------------------------------------------------------------------
fprintf('<strong>Estimate EOG-correlating components at participant 1...</strong>\n');
data_eogcomp.part1 = corrComp(data_icacomp.part1, data_sensor.part1, threshold(1));
fprintf('<strong>Estimate EOG-correlating components at participant 2...</strong>\n');
data_eogcomp.part2 = corrComp(data_icacomp.part2, data_sensor.part2, threshold(2));

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the computation of the correlation coefficient
%--------------------------------------------------------------------------
function [ dataEOGComp ] = corrComp( dataICAComp, dataEOG, th )

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

eogvCorr = (eogvCorr > th);
eoghCorr = (eoghCorr > th);

dataEOGComp.label      = dataICAComp.label;
dataEOGComp.topolabel  = dataICAComp.topolabel;
dataEOGComp.topo       = dataICAComp.topo;
dataEOGComp.unmixing   = dataICAComp.unmixing;
dataEOGComp.elements   = dataICAComp.label(eogvCorr | eoghCorr);

end

