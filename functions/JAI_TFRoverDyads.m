function  [ data_tfrod ] = JAI_TFRoverDyads( cfg )
% JAI_TFROVERDYADS estimates the mean of the time frequency responses for 
% all conditions and over all participants.
%
% Use as
%   [ data_tfrod ] = JAI_TFRoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01826/eegData/DualEEG_JAI_processedData/09a_tfr/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also JAI_TIMEFREQANALYSIS

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01826/eegData/DualEEG_JAI_processedData/09a_tfr/');
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
fprintf('<strong>Averaging TFR values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('JAI_d*_09a_tfr_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['JAI_d%d_09a'...
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
% Load, organize and summarize data
% -------------------------------------------------------------------------
data_out.trialinfo = generalDefinitions.condNum';

numOfTrials = zeros(1, length(data_out.trialinfo));
tfr{length(data_out.trialinfo)} = [];

for i=1:1:numOfDyads
  filename = sprintf('JAI_d%02d_09a_tfr_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_tfr');
  tfr1   = data_tfr.part1.powspctrm;
  tfr2   = data_tfr.part2.powspctrm;
  trialinfo_tmp = data_tfr.part1.trialinfo;
  if i == 1
    data_out.label  = data_tfr.part1.label;
    data_out.dimord = data_tfr.part1.dimord;
    data_out.freq   = data_tfr.part1.freq;
    data_out.time   = data_tfr.part1.time;
    tfr(:) = {zeros(length(data_out.label), length(data_out.freq), ...
                    length(data_out.time))};
  end
  clear data_tfr
  
  tfr1 = num2cell(tfr1, [2,3,4])';
  tfr1 = cellfun(@(x) squeeze(x), tfr1, 'UniformOutput', false);
  [tfr1,trialSpec1] = fixTrialOrder( tfr1, trialinfo_tmp, ...
                                      generalDefinitions.condNum, i, 1);
  
  tfr2 = num2cell(tfr2, [2,3,4])';
  tfr2 = cellfun(@(x) squeeze(x), tfr2, 'UniformOutput', false);
  [tfr2, trialSpec2] = fixTrialOrder( tfr2, trialinfo_tmp, ...
                                      generalDefinitions.condNum, i, 2);
  
  tfr = cellfun(@(x,y,z) x+y+z, tfr, tfr1, tfr2, 'UniformOutput', false);
  numOfTrials = numOfTrials + trialSpec1 + trialSpec2;
end

numOfTrials = num2cell(numOfTrials);

tfr = cellfun(@(x,y) x/y, tfr, numOfTrials, 'UniformOutput', false);
tfr = cat(4, tfr{:}); 
tfr = shiftdim(tfr, 3);

data_out.powspctrm  = tfr;
data_out.dyads      = listOfDyads;

data_tfrod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function [dataTmp, NoT] = fixTrialOrder( dataTmp, trInf, trInfOrg, ...
                                        dyadNum, part )

emptyMatrix = zeros(size(dataTmp{1}, 1), size(dataTmp{1}, 2), ...           % empty matrix
                    size(dataTmp{1}, 3));
fixed = false;
NoT = ones(1, length(trInfOrg));

if ~isequal(trInf, trInfOrg')
  missingPhases = ~ismember(trInfOrg, trInf);
  missingPhases = trInfOrg(missingPhases);
  if ~isempty(missingPhases)
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
          sprintf('Dyad %d/%d: Phase(s) %s missing. Empty matrix(matrices) with zeros created.\n', ...
          dyadNum, part, missingPhases));
    fixed = true;
  end
  [~, loc] = ismember(trInfOrg, trInf);
  tmpBuffer = [];
  tmpBuffer{length(trInfOrg)} = [];
  for j = 1:1:length(trInfOrg)
    if loc(j) == 0
      NoT(j) = 0;
      tmpBuffer{j} = emptyMatrix;
    else
      tmpBuffer(j) = dataTmp(loc(j));
    end
  end
  dataTmp = tmpBuffer;
end

if fixed == true
  fprintf('\n');
end

end
