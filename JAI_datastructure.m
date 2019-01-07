% JAI_DATASTRUCTURE
%
% The data in the --- Joint Attention Imitation Project --- ist structured 
% as follows:
%
% dataset example:
%
% data_raw
%    |               
%    |---- part1 (1x1 fieldtrip data structure for participant 1)    
%    |---- part2 (1x1 fieldtrip data structure for participant 2)
%
% In every substep of the data processing pipeline (i.e. 01_raw,
% 02a_badchan, 02b_preproc1, 03a_icacomp, 03b_eogchan...) N single datasets
% will be created. The number N stands for the current number of dyads 
% within the study. Every dataset for each dyad is stored in a separate 
% *.mat file, to avoid the need of swap memory during data  processing. As 
% described a datasets has always two fields, which are  named part1 and 
% part2. Each field comprises a 1x1 struct with the complete data of a 
% specific participant. The different conditions in this data struct are 
% separated through trials and the field trialinfo contains the condition 
% markers of each trials. In case of subsegmented data the structure 
% contains more than one trial for each condition. The information about 
% the order of the trials of one condition is available through the 
% relating time elements. 
%
% Many functions especially the plot functions need a declaration of the 
% specific condition, which should be selected. The JAI study is described
% by the following conditions:
%
% - SameObjectB       - 111
% - ViewMotionB       - 2
% - SameMotionB       - 3
% - ConImi12          - 31
% - ConImi21          - 32
% - ConOthAct12       - 41
% - ConOthAct21       - 42
% - SponImiI          - 51
% - SponImiII         - 52
% - Conversation      - 105
% - Single_No         - 100
% - Dual12_No         - 101
% - Dual21_No         - 102         
% - Single_2Hz        - 7
% - Dual12_2Hz        - 8
% - Dual21_2Hz        - 9
% - Single_10Hz       - 10
% - Dual12_10Hz       - 11
% - Dual21_10Hz       - 12
% - Single_20Hz       - 20
% - Dual12_20Hz       - 21
% - Dual21_20Hz       - 22
% - SameObjectE       - 4
% - ViewMotionE       - 5
% - SameMotionE       - 6
%
% Furthermore the following four meta conditions are defined for the
% investigation of entrainment by using Inter-trial phase coherence (ITPC):
%
% - MetaNo            - 201
% - Meta2Hz           - 202
% - Meta10Hz          - 203
% - Meta20Hz          - 204
%
% The declaration of the condition is done by setting the cfg.condition
% option with the string or the number of the specific condition.

% Copyright (C) 2017, Daniel Matthes, MPI CBS
