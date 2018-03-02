function [ badLabel ] = JAI_channelCheckbox()
% JAI_CHANNELCHECKBOX is a function, which displays a small GUI for the 
% selection of bad channels. It returns a cell array including the labels
% of the bad channels
%
% Use as
%   [ badLabel ] = JAI_channelCheckbox()
%
% SEE also UIFIGURE, UICHECKBOX, UIBUTTON, UIRESUME, UIWAIT

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
SelectBadChannels = uifigure;
SelectBadChannels.Position = [150 400 535 235];
SelectBadChannels.Name = 'Select bad channels';

% Create FzCheckBox
Fz = uicheckbox(SelectBadChannels);
Fz.Text = 'Fz';
Fz.Position = [45 175 80 15];
% Create F3CheckBox
F3 = uicheckbox(SelectBadChannels);
F3.Text = 'F3';
F3.Position = [125 175 80 15];
% Create F7CheckBox
F7 = uicheckbox(SelectBadChannels);
F7.Text = 'F7';
F7.Position = [205 175 80 15];
% Create F9CheckBox
F9 = uicheckbox(SelectBadChannels);
F9.Text = 'F9';
F9.Position = [285 175 80 15];
% Create FT7CheckBox
FT7 = uicheckbox(SelectBadChannels);
FT7.Text = 'FT7';
FT7.Position = [365 175 80 15];
% Create FC3CheckBox
FC3 = uicheckbox(SelectBadChannels);
FC3.Text = 'FC3';
FC3.Position = [445 175 80 15];

% Create FC1CheckBox
FC1 = uicheckbox(SelectBadChannels);
FC1.Text = 'FC1';
FC1.Position = [45 150 80 15];
% Create CzCheckBox
Cz = uicheckbox(SelectBadChannels);
Cz.Text = 'Cz';
Cz.Position = [125 150 80 15];
% Create C3CheckBox
C3 = uicheckbox(SelectBadChannels);
C3.Text = 'C3';
C3.Position = [205 150 80 15];
% Create T7CheckBox
T7 = uicheckbox(SelectBadChannels);
T7.Text = 'T7';
T7.Position = [285 150 80 15];
% Create CP3CheckBox
CP3 = uicheckbox(SelectBadChannels);
CP3.Text = 'CP3';
CP3.Position = [365 150 80 15];
% Create PzCheckBox
Pz = uicheckbox(SelectBadChannels);
Pz.Text = 'Pz';
Pz.Position = [445 150 80 15];

% Create P3CheckBox
P3 = uicheckbox(SelectBadChannels);
P3.Text = 'P3';
P3.Position = [45 125 80 15];
% Create P7CheckBox
P7 = uicheckbox(SelectBadChannels);
P7.Text = 'P7';
P7.Position = [125 125 80 15];
% Create PO9CheckBox
PO9 = uicheckbox(SelectBadChannels);
PO9.Text = 'PO9';
PO9.Position = [205 125 80 15];
% Create O1CheckBox
O1 = uicheckbox(SelectBadChannels);
O1.Text = 'O1';
O1.Position = [285 125 80 15];
% Create O2CheckBox
O2 = uicheckbox(SelectBadChannels);
O2.Text = 'O2';
O2.Position = [365 125 80 15];
% Create PO10CheckBox
PO10 = uicheckbox(SelectBadChannels);
PO10.Text = 'PO10';
PO10.Position = [445 125 80 15];

% Create P8CheckBox
P8 = uicheckbox(SelectBadChannels);
P8.Text = 'P8';
P8.Position = [45 100 80 15];
% Create P4CheckBox
P4 = uicheckbox(SelectBadChannels);
P4.Text = 'P4';
P4.Position = [125 100 80 15];
% Create CP4CheckBox
CP4 = uicheckbox(SelectBadChannels);
CP4.Text = 'CP4';
CP4.Position = [205 100 80 15];
% Create TP10CheckBox
TP10 = uicheckbox(SelectBadChannels);
TP10.Text = 'TP10';
TP10.Position = [285 100 80 15];
% Create T8CheckBox
T8 = uicheckbox(SelectBadChannels);
T8.Text = 'T8';
T8.Position = [365 100 80 15];
% Create C4CheckBox
C4 = uicheckbox(SelectBadChannels);
C4.Text = 'C4';
C4.Position = [445 100 80 15];

% Create FT8CheckBox
FT8 = uicheckbox(SelectBadChannels);
FT8.Text = 'FT8';
FT8.Position = [45 75 80 15];
% Create FC4CheckBox
FC4 = uicheckbox(SelectBadChannels);
FC4.Text = 'FC4';
FC4.Position = [125 75 80 15];
% Create FC2CheckBox
FC2 = uicheckbox(SelectBadChannels);
FC2.Text = 'FC2';
FC2.Position = [205 75 80 15];
% Create F4CheckBox
F4 = uicheckbox(SelectBadChannels);
F4.Text = 'F4';
F4.Position = [285 75 80 15];
% Create F8CheckBox
F8 = uicheckbox(SelectBadChannels);
F8.Text = 'F8';
F8.Position = [365 75 80 15];
% Create F10CheckBox
F10 = uicheckbox(SelectBadChannels);
F10.Text = 'F10';
F10.Position = [445 75 80 15];

% Create SaveButton
btn = uibutton(SelectBadChannels, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(SelectBadChannels);
btn.Position = [217 27 101 21];
btn.Text = 'Save';

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(SelectBadChannels);

if ishandle(SelectBadChannels)                                              % if gui still exists
  badLabel = [Fz.Value; F3.Value; F7.Value; F9.Value; FT7.Value; ...        % return existing selection
              FC3.Value; FC1.Value; Cz.Value; C3.Value; T7.Value; ...
              CP3.Value; Pz.Value; P3.Value; P7.Value; PO9.Value; ...
              O1.Value; O2.Value; PO10.Value; P8.Value; P4.Value; ...
              CP4.Value; TP10.Value; T8.Value; C4.Value; FT8.Value; ...
              FC4.Value; FC2.Value; F4.Value; F8.Value; F10.Value];
  label    = {'Fz', 'F3', 'F7', 'F9', 'FT7', 'FC3', 'FC1' 'Cz', 'C3', ...
              'T7', 'CP3', 'Pz', 'P3', 'P7', 'PO9', 'O1', 'O2', 'PO10',...
              'P8', 'P4', 'CP4', 'TP10', 'T8', 'C4', 'FT8', 'FC4', ...
              'FC2', 'F4', 'F8', 'F10'};
  badLabel = label(badLabel);
  if isempty(badLabel)
    badLabel = [];
  end
  delete(SelectBadChannels);                                                % close gui
else                                                                        % if gui was already closed (i.e. by using the close symbol)
  badLabel = [];                                                            % return empty selection
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(SelectBadChannels)
  uiresume(SelectBadChannels);                                              % resume from wait status                                                                             
end
