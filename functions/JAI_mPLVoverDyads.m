function [ data_mplv ] = JAI_mPLVoverDyads( cfg )
% JAI_MPLVOVERDYADS estimates the mean of the phase locking values for all 
% conditions and over all dyads.
%
% Use as
%   [ data_mplv ] = JAI_mPLVoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01826/eegData/DualEEG_JAI_processedDataCCA/07b_mplv/')
%   cfg.session   = session number (default: 1)
%   cfg.passband  = select passband of interest (default: 2Hz)
%                   (accepted values: 2Hz, theta, alpha, 20Hz, beta, gamma)
%
% This function requires the fieldtrip toolbox
% 
% See also JAI_CALCMEANPLV

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01826/eegData/DualEEG_JAI_processedDataCCA/07b_mplv/');
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', '2Hz');

bands     = {'2Hz', 'theta', 'alpha', '20Hz', 'beta', 'gamma'};
suffix    = {'2Hz', 'Theta', 'Alpha', '20Hz', 'Beta', 'Gamma'};

if ~any(strcmp(passband, bands))
  error(['Define cfg.passband could only be ''2Hz'', ''theta'', '...
         '''alpha'', ''20Hz'', ''beta'' or ''gamma''.']);
else
  fileSuffix = suffix{strcmp(passband, bands)};
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
fprintf('<strong>Averaging of Phase Locking Values over dyads at %s...</strong>\n', passband);

dyadsList   = dir([path, sprintf('JAI_d*_07b_mplv%s_%03d.mat', ...
                   fileSuffix, session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['JAI_d%d_07b'...
                                   sprintf('%s_', fileSuffix) ...
                                   sprintf('%03d.mat', session)]);          %#ok<AGROW>
end

y = sprintf('%d ', listOfDyads);
selection = false;

while selection == false
  fprintf('The following dyads are available: %s\n', y);
  x = input('Which dyads should be included into the averaging? (i.e. [1,2,3]):\n');
  if ~all(ismember(x, listOfDyads))
    cprintf([1,0.5,0], 'Wrong input!\n');
  else
    selection = true;
    listOfDyads = x;
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_mplv.avgData.trialinfo = generalDefinitions.condNum;

data{1, length(listOfDyads)} = [];
trialinfo{1, length(listOfDyads)} = []; 

for i=1:1:length(listOfDyads)
  filename = sprintf('JAI_d%02d_07b_mplv%s_%03d.mat', listOfDyads(i), ...
                    fileSuffix, session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, sprintf('data_mplv_%s', passband));
  eval(['data_mplv_in=' sprintf('data_mplv_%s', passband) ';']);
  eval(['clear ' sprintf('data_mplv_%s', passband)]);
  data{i} = data_mplv_in.dyad.mPLV;
  trialinfo{i} = data_mplv_in.dyad.trialinfo;
  if i == 1
    data_mplv.centerFreq    = data_mplv_in.centerFreq;
    data_mplv.bpFreq        = data_mplv_in.bpFreq;
    data_mplv.avgData.label = data_mplv_in.dyad.label;
  end
  clear data_mplv_in
end
fprintf('\n');

data = fixTrialOrder( data, trialinfo, generalDefinitions.condNum, ...
                      listOfDyads );

for j=1:1:length(listOfDyads)
  data{j} = cat(3, data{j}{:});
end
if length(listOfDyads) > 1
  data = cat(4, data{:});
end

% -------------------------------------------------------------------------
% Estimate averaged phase locking value (over dyads)
% ------------------------------------------------------------------------- 
if length(listOfDyads) > 1
  data = nanmean(data, 4);
else
  data = data{1};
end
data = squeeze(num2cell(data, [1 2]))';

data_mplv.avgData.mPLV  = data;
data_mplv.dyads         = listOfDyads;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trlInf, trlInfOrg, dyadNum )

emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs
fixed = false;

for k = 1:1:size(dataTmp, 2)
  if ~isequal(trlInf{k}, trlInfOrg')
    missingPhases = ~ismember(trlInfOrg, trlInf{k});
    missingPhases = trlInfOrg(missingPhases);
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
            sprintf('Dyad %d: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
            dyadNum(k), missingPhases));
    [~, loc] = ismember(trlInfOrg, trlInf{k});
    tmpBuffer = [];
    tmpBuffer{length(trlInfOrg)} = [];                                       %#ok<AGROW>
    for l = 1:1:length(trlInfOrg)
      if loc(l) == 0
        tmpBuffer{l} = emptyMatrix;
      else
        tmpBuffer(l) = dataTmp{k}(loc(l));
      end
    end
    dataTmp{k} = tmpBuffer;
    fixed = true;
  end
end

if fixed == true
  fprintf('\n');
end

end
