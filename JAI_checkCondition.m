function [ num ] = JAI_checkCondition( condition )
% JAI_CHECKCONDITION - This functions checks the defined condition. 
%
% If condition is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If condition is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = [2, 3, 31, 32, 41, 42, 51, 52, 105, 111];

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(condition)                                                     % if condition is already numeric
  if isempty(find(defaultVals == condition, 1))
    error('%d is not a valid condition', condition);
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  switch condition
    case 'ViewMotion'
      num = 2;
    case 'SameMotion'
      num = 3;
    case 'ConImi12'
      num = 31;
    case 'ConImi21'
      num = 32;
    case 'ConOthAct12'
      num = 41;
    case 'ConOthAct21'
      num = 42;
    case 'SponImiI'
      num = 51;
    case 'SponImiII'
      num = 52;
    case 'Conversation'
      num = 105;
    case 'SameObject'
      num = 111;
    otherwise
      error('%s is not a valid condition', condition);
  end
end
