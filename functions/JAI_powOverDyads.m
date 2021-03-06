function  [ data_pwelchod ] = JAI_powOverDyads( cfg )
% JAI_POWOVERDYADS estimates the mean of the power actifity over dyads
% for all conditions and over all participants.
%
% Use as
%   [ data_pwelchod ] = JAI_powOverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01826/eegData/DualEEG_JAI_processedData/09b_pwelch/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also JAI_PWELCH

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01826/eegData/DualEEG_JAI_processedData/09b_pwelch/');
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');   

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
fprintf('<strong>Averaging power values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('JAI_d*_09b_pwelch_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['JAI_d%d_09b'...
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
    listOfDyads = unique(x);
    numOfDyads  = length(listOfDyads);
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_out.trialinfo = generalDefinitions.condNum';

data{1, 2 * numOfDyads} = [];
trialinfo{1, 2 * numOfDyads} = [];

for i=1:1:numOfDyads
  filename = sprintf('JAI_d%02d_09b_pwelch_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_pwelch');
  data{i}                   = data_pwelch.part1.powspctrm;
  data{i+numOfDyads}        = data_pwelch.part2.powspctrm;
  trialinfo{i}              = data_pwelch.part1.trialinfo;
  trialinfo{i + numOfDyads} = data_pwelch.part2.trialinfo;
  if i == 1
    data_out.label  = data_pwelch.part1.label;
    data_out.dimord = data_pwelch.part1.dimord;
    data_out.freq   = data_pwelch.part1.freq;
  end
  clear data_pwelch
end
fprintf('\n');

data = cellfun(@(x) num2cell(x, [2,3])', data, 'UniformOutput', false);

for i=1:1:2*numOfDyads
  data{i} = cellfun(@(x) squeeze(x), data{i}, 'UniformOutput', false);
end

data = fixTrialOrder( data, trialinfo, generalDefinitions.condNum, ...
                      repmat(listOfDyads,1,2) );

data = cellfun(@(x) cat(3, x{:}), data, 'UniformOutput', false);
data = cellfun(@(x) shiftdim(x, 2), data, 'UniformOutput', false);
data = cat(4, data{:});

% -------------------------------------------------------------------------
% Estimate averaged power spectrum (over dyads)
% -------------------------------------------------------------------------
data = nanmean(data, 4);

data_out.powspctrm  = data;
data_out.dyads      = listOfDyads;

data_pwelchod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum )

emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs
fixed = false;
part = [ones(1,length(dyadNum)/2) 2*ones(1,length(dyadNum)/2)];

for k = 1:1:size(dataTmp, 2)
  if ~isequal(trInf{k}, trInfOrg')
    missingPhases = ~ismember(trInfOrg, trInf{k});
    missingPhases = trInfOrg(missingPhases);
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
            sprintf('Dyad %d/%d: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
            dyadNum(k), part(k), missingPhases));
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
    fixed = true;
  end
end

if fixed == true
  fprintf('\n');
end

end
