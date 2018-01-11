function [ data_itpc ] = JAI_ITPCoverDyads( cfg )
% JAI_MPLVOVERDYADS estimates the mean of the inter-trial phase coherence 
% values for all conditions and over all dyads.
%
% Use as
%   [ data_itpc ] = JAI_ITPCoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_JAI_processedData/08b_itpc/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_CALCMEANPLV

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_JAI_processedData/08b_itpc/');
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
load('JAI_generalDefinitions.mat', 'generalDefinitions');                                               

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
dyadsList   = dir([path, sprintf('JAI_d*_08b_itpc_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['JAI_d%d_08b'...
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
data_out.trialinfo = generalDefinitions.condNum;

data{1, 2 * numOfDyads} = [];
trialinfo{1, 2 * numOfDyads} = []; 

for i=1:1:numOfDyads
  filename = sprintf('JAI_d%02d_08b_itpc_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_itpc');
  data{i}                   = data_itpc.part1.itpc;                         %#ok<NODEF>
  data{i+numOfDyads}        = data_itpc.part2.itpc;
  trialinfo{i}              = data_itpc.part1.trialinfo;
  trialinfo{i + numOfDyads} = data_itpc.part2.trialinfo;
  if i == 1
    data_out.label  = data_itpc.part1.label;
    data_out.dimord = data_itpc.part1.dimord;
  end
  clear data_itpc
end
fprintf('\n');

data = fixTrialOrder( data, trialinfo, generalDefinitions.condNum, ...
                      repmat(listOfDyads,1,2) );

for j=1:1:2*numOfDyads
  data{j} = cat(4, data{j}{:});
end
data = cat(5, data{:});

% -------------------------------------------------------------------------
% Estimate averaged Phase Locking Value (over dyads)
% ------------------------------------------------------------------------- 
fprintf('Averaging ITPC values over dyads...\n\n');
data = nanmean(data, 5);
data = squeeze(num2cell(data, [1 2 3]))';

data_out.itpc  = data;
data_out.dyads = listOfDyads;

data_itpc = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial Order an creates empty matrices for missing
% phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum )

emptyMatrix = NaN * ones(35,95,5);                                          % empty matrix with NaNs

for k = 1:1:size(dataTmp, 2)
  if ~isequal(trInf{k}, trInfOrg)
    missingPhases = ~ismember(trInfOrg, trInf{k});
    missingPhases = trInfOrg(missingPhases);
    missingPhases = join_str(', ', num2cell(missingPhases)');
    cprintf([0,0.6,0], ...
            sprintf('Dyad %d: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
            dyadNum(k), missingPhases));
    [~, loc] = ismember(trInfOrg, trInf{k});
    tmpBuffer = [];
    tmpBuffer{length(trInfOrg)} = [];                                       %#ok<AGROW>
    for l = 1:1:length(trInfOrg)
      if loc(l) == 0
        tmpBuffer{l} = emptyMatrix;
      else
        tmpBuffer(l) = dataTmp{k}(loc(l));
      end
    end
    dataTmp{k} = tmpBuffer;
  end
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION which transform a cell array of labels into a string
%--------------------------------------------------------------------------
function t = join_str(separator,cells)

if isempty(cells)
  t = '';
  return;
end

if ischar(cells)
  t = cells;
  return;
end

t = char(num2str(cells{1}));

for i=2:length(cells)
  t = [t separator char(num2str(cells{i}))];                                %#ok<AGROW>
end

end
