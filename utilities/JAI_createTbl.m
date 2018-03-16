function JAI_createTbl( cfg )
% JAI_CREATETBL generates '*.xls' files for the documentation of the data 
% processing process. Currently three different types of doc files are
% supported.
%
% Use as
%   JAI_createTbl( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01826/eegData/DualEEG_JAI_processedData/00_settings/')
%   cfg.type        = type of documentation file (options: 'settings', 'plv', 'itpc')
%   cfg.param       = additional params for type 'plv' (options: '2Hz', 'theta', 'alpha', '20Hz', 'beta', 'gamma');
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% Explanation:
%   type settings - holds information about the selectable values: fsample, reference and ICAcorrVal
%   type plv      - holds the number of good trials for each condition in case of plv estimation
%   type itpc     - holds the number of good trials for each condition in case of itpc estimation
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', ...
          '/data/pt_01826/eegData/DualEEG_JAI_processedData/00_settings/');
type        = ft_getopt(cfg, 'type', []);
param       = ft_getopt(cfg, 'param', []);
sessionStr  = ft_getopt(cfg, 'sessionStr', []);

if isempty(type)
  error(['cfg.type has to be specified. It could be either ''settings'''...
         ', ''plv'' or ''itpc''.']);
end

if strcmp(type, 'plv')
  if isempty(param)
    error([ 'cfg.param has to be specified. Selectable options: ''2Hz'', '...
            '''theta'', ''alpha'', ''20Hz'', ''beta'', ''gamma''']);
  end
end

if isempty(sessionStr)
  error('cfg.sessionNum has to be specified');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Create table
% -------------------------------------------------------------------------
switch type
  case 'settings'
    T = table(1,{'unknown'},{'unknown'},0,{'unknown'},0,0,0,{'unknown'}, ...
                {'unknown'});
    T.Properties.VariableNames = ...
        {'dyad', 'badChanPart1', 'badChanPart2', 'fsample', 'reference',...
         'ICAcorrVal1', 'ICAcorrVal2', 'artThreshold', 'artRejectPLV', ...
         'artRejectITPC'};
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);
  case 'plv'
    A(1) = {1};
    A(2:26) = {0};
    T = cell2table(A);
    B = num2cell(generalDefinitions.condNum);
    C = cellfun(@(x) sprintf('S%d', x), B, 'UniformOutput', 0);                            
    VarNames = [{'dyad'} C];
    T.Properties.VariableNames = VarNames;
    filepath = [desFolder type '_' param '_' sessionStr '.xls'];
    writetable(T, filepath); 
  case 'itpc'
    A(1) = {1};
    A(2:51) = {0};
    T = cell2table(A); 
    B = num2cell(generalDefinitions.condNum);
    C = cellfun(@(x) sprintf('S%d_01', x), B, 'UniformOutput', 0);
    D = cellfun(@(x) sprintf('S%d_02', x), B, 'UniformOutput', 0);
    VarNames = [{'dyad'} C D];
    T.Properties.VariableNames = VarNames;
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);    
  otherwise
    error(['cfg.type is not valid. Use either ''settings'', ''plv'' or '...
         '''itpc''.']);
end

end

