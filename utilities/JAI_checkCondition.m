function [ num ] = JAI_checkCondition( condition, varargin )
% JAI_CHECKCONDITION - This functions checks the defined condition. 
%
% Use as
%   [ num ] = JAI_checkCondition( condition, varargin )
%
% If condition is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If condition is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.
%
% Additional options should be specified in key-value pairs and can be
%   'flag'  = to mark special data which are including a special set of
%             condition markers (i.e. 'itpc')
%
% All available condition strings and numbers are defined in
% JAI_DATASTRUCTURE
%
% SEE also JAI_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get varargin options
% -------------------------------------------------------------------------
flag = ft_getopt(varargin, 'flag');

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/JAI_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

if isempty(flag)
  condNum = generalDefinitions.condNum;
  condString = generalDefinitions.condString;
elseif strcmp(flag, 'itpc')
  condNum = generalDefinitions.condNumITPC;
  condString = generalDefinitions.condStringITPC;
end

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(condition)                                                     % if condition is already numeric
  if ~any(condNum == condition)
    error('%d is not a valid condition', condition);
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  elements = strcmp(condString, condition);
  if ~any(elements)
     error('%s is not a valid condition', condition);
  else
    num = condNum(elements);
  end
end

end
