function [passband] = JAI_pbSelectbox()
% JAI_PBSELECTBOX is a function, which displays a small GUI for the
% specification of passbands. It returns a cell array including the minimum
% and maximum frequency of each passband.
%
% Use as
%   [ passband ]  = JAI_pbSelectbox( cfg )
%
% This function requires the fieldtrip toolbox.
%
% SEE also UIFIGURE, UIEDITFIELD, UIBUTTON, UIRESUME, UIWAIT

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
pbSelectbox = uifigure;
pbSelectbox.Position = [150 400 360 265];
pbSelectbox.CloseRequestFcn = @(pbSelectbox, evt)SaveButtonPushed(pbSelectbox);
pbSelectbox.Name = 'Specifiy passbands';

% Create fmin label
fminlbl = uilabel(pbSelectbox);
fminlbl.Position = [154 225 52 15];
fminlbl.Text = 'fmin';
% Create fmax label
fmaxlbl = uilabel(pbSelectbox);
fmaxlbl.Position = [263 225 54 15];
fmaxlbl.Text = 'fmax';

% Create 2Hz label
twoHz.lbl = uilabel(pbSelectbox);
twoHz.lbl.Position = [45 200 80 15];
twoHz.lbl.Text = '2Hz';
% Create 2Hz fmin editfield
twoHz.fmin = uieditfield(pbSelectbox, 'numeric');
twoHz.fmin.Position = [125 200 80 15];
twoHz.fmin.Value = 1.9;
twoHz.fmin.Limits = [1 1.9];
% Create 2Hz fmax editfield
twoHz.fmax = uieditfield(pbSelectbox, 'numeric');
twoHz.fmax.Position = [235 200 80 15];
twoHz.fmax.Value = 2.1;
twoHz.fmax.Limits = [2.1 3];

% Create theta label
theta.lbl = uilabel(pbSelectbox);
theta.lbl.Position = [45 175 80 15];
theta.lbl.Text = 'theta';
% Create theta fmin editfield
theta.fmin = uieditfield(pbSelectbox, 'numeric');
theta.fmin.Position = [125 175 80 15];
theta.fmin.Value = 4;
theta.fmin.Limits = [3 6.8];
% Create theta fmax editfield
theta.fmax = uieditfield(pbSelectbox, 'numeric');
theta.fmax.Position = [235 175 80 15];
theta.fmax.Value = 7;
theta.fmax.Limits = [4.2 8];

% Create alpha label
alpha.lbl = uilabel(pbSelectbox);
alpha.lbl.Position = [45 150 80 15];
alpha.lbl.Text = 'alpha';
% Create alpha fmin editfield
alpha.fmin = uieditfield(pbSelectbox, 'numeric');
alpha.fmin.Position = [125 150 80 15];
alpha.fmin.Value = 8;
alpha.fmin.Limits = [8 11.8];
% Create alpha fmax editfield
alpha.fmax = uieditfield(pbSelectbox, 'numeric');
alpha.fmax.Position = [235 150 80 15];
alpha.fmax.Value = 12;
alpha.fmax.Limits = [8.2 13];

% Create 20Hz label
twentyHz.lbl = uilabel(pbSelectbox);
twentyHz.lbl.Position = [45 125 80 15];
twentyHz.lbl.Text = '20Hz';
% Create 20Hz fmin editfield
twentyHz.fmin = uieditfield(pbSelectbox, 'numeric');
twentyHz.fmin.Position = [125 125 80 15];
twentyHz.fmin.Value = 19;
twentyHz.fmin.Limits = [18 20.8];
% Create 20Hz fmax editfield
twentyHz.fmax = uieditfield(pbSelectbox, 'numeric');
twentyHz.fmax.Position = [235 125 80 15];
twentyHz.fmax.Value = 21;
twentyHz.fmax.Limits = [19.2 22];

% Create beta label
beta.lbl = uilabel(pbSelectbox);
beta.lbl.Position = [45 100 80 15];
beta.lbl.Text = 'beta';
% Create beta fmin editfield
beta.fmin = uieditfield(pbSelectbox, 'numeric');
beta.fmin.Position = [125 100 80 15];
beta.fmin.Value = 13;
beta.fmin.Limits = [13 29.8];
% Create beta fmax editfield
beta.fmax = uieditfield(pbSelectbox, 'numeric');
beta.fmax.Position = [235 100 80 15];
beta.fmax.Value = 30;
beta.fmax.Limits = [13.2 30];

% Create gamma label
gamma.lbl = uilabel(pbSelectbox);
gamma.lbl.Position = [45 75 80 15];
gamma.lbl.Text = 'gamma';
% Create beta fmin editfield
gamma.fmin = uieditfield(pbSelectbox, 'numeric');
gamma.fmin.Position = [125 75 80 15];
gamma.fmin.Value = 31;
gamma.fmin.Limits = [30 47.8];
% Create beta fmax editfield
gamma.fmax = uieditfield(pbSelectbox, 'numeric');
gamma.fmax.Position = [235 75 80 15];
gamma.fmax.Value = 48;
gamma.fmax.Limits = [31.2 250];

% Create SaveButton
btn = uibutton(pbSelectbox, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(pbSelectbox);
btn.Position = [130 27 100 21];
btn.Text = 'Save';

% Create ValueChangedFcn pointers
twoHz.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(twoHz);
twoHz.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(twoHz);
theta.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(theta);
theta.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(theta);
alpha.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(alpha);
alpha.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(alpha);
twentyHz.fmin.ValueChangedFcn = @(fmin, evt)EditFieldValueChanged(twentyHz);
twentyHz.fmax.ValueChangedFcn = @(fmax, evt)EditFieldValueChanged(twentyHz);
beta.fmin.ValueChangedFcn     = @(fmin, evt)EditFieldValueChanged(beta);
beta.fmax.ValueChangedFcn     = @(fmax, evt)EditFieldValueChanged(beta);
gamma.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(gamma);
gamma.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(gamma);

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(pbSelectbox);

if ishandle(pbSelectbox)                                                    % if gui still exists
  passband = {[twoHz.fmin.Value     twoHz.fmax.Value], ...                  % return existing selection
              [theta.fmin.Value     theta.fmax.Value], ...
              [alpha.fmin.Value     alpha.fmax.Value], ...
              [twentyHz.fmin.Value  twentyHz.fmax.Value], ...
              [beta.fmin.Value      beta.fmax.Value], ...
              [gamma.fmin.Value     gamma.fmax.Value], ...
              };
  delete(pbSelectbox);
else                                                                        % otherwise return default settings
  passband = {[1.9  2.1], ...
              [4    7], ...
              [8    12], ...
              [19   21], ...
              [13   30], ...
              [31   48], ...
              };
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(pbSelectbox)
  uiresume(pbSelectbox);                                                    % resume from wait status                                                                             
end

% edit field value changed function
function EditFieldValueChanged(passband)
  passband.fmin.Limits(2) = passband.fmax.Value - 0.2;                      % assure a minimum bandwidth of 0.2 Hz
  passband.fmax.Limits(1) = passband.fmin.Value + 0.2;
end
