% JAI_DATASTRUCTURE
%
% The data in the --- Joint Attention Imitation Project --- ist structured 
% as follows:
%
% Every step of the data processing pipeline (i.e. 01_raw, 02_preproc, 
% 03_tfr1 ...) generates N single datasets, where N describes the current 
% number of dyads within the study. Every dataset for each dyad is stored 
% in a separate *.mat file, to avoid the need of swap memory during data 
% processing. A datasets has always two fields, which are named part1 and 
% part2. Each field comprises a 1x1 struct with the complete data of a 
% specific participant. The different conditions in this data struct are 
% separated through trials and the field trialinfo contains the condition 
% markers of each trials. In case of subsegmented data the structure 
% contains more than one trial for each condition. If no trial was rejected 
% during the preprocessing, there should be 36 trials per condition in the 
% data structure. The information about the order of the trials of one 
% condition is available through the relating time elements. 
%
% dataset example:
%
% data_raw
%    |               
%    |---- part1 (1x1 fieldtrip data structure for participant 1)    
%    |---- part2 (1x1 fieldtrip data structure for participant 2)
%   
%
% Many functions especially the plot functions need a definition of the 
% specific condition, which should be selected. Currently the following 
% conditions are existent:
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
% The defintion of the condition is done by setting the cfg.condition
% option with the string or the number of the specific condition.

% Copyright (C) 2017, Daniel Matthes, MPI CBS