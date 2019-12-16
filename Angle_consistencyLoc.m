function [AngleCons_eachSUBJ, AngleCons_eachLM, AvgAngle_eachSUBJ, AvgAngle_eachLM] = Angle_consistencyLoc(systerr_data_name, options, paths);
% INPUTS:
% systerr_preproc_data (string: file name of the preproc data with systematic errors, obtained from Systematic_errorsLoc function
% options (data structure)
    % options.needplot  = 1 for angle consistency plot
% paths (data structure)
    % paths.data = directory of the data;
    % paths.out = directory of where to save the systematic error preprocessed data 
% OUTPUTS:
% AngleCons_eachSUBJ (table) - also saved as excel file - angle consistency
%   values for each subject
% AngleCons_eachLM (table) - also saved as excel file - angle consistency
%   values for each subject and landmark 
% AvgAngle_eachSUBJ (table) - also saved as excel file - average angle
% 	 for each subject
% AvgAngle_eachLM (table) - also saved as excel file - average angle
% 	 for each subject and LM
% anglefig (figure) - polar plots of average systematic errors for each
% landmark and participant

%% load data
preproc_systerr_data = readtable([paths.out systerr_data_name]);

%% define subjects and landmarks
nsubj = unique(preproc_systerr_data.subj);
alltarg = unique(preproc_systerr_data.LM);

%% compute inter-trial phase clustering for each subject, and for each LM

% transform angles in complex numbers
preproc_systerr_data.compl_plane = exp(1*i*deg2rad(preproc_systerr_data.angle_syst_er));

% extract magnitude of the vector as the mean of the vectors of
% theta in the complex plane. That is the coherence of the phase
% and extract preferred angle
for ss = 1:length(nsubj)
    % for each subject
    dataSUB = preproc_systerr_data.compl_plane(preproc_systerr_data.subj == nsubj(ss));
    ITPC_eachsubj(ss) = abs(mean(dataSUB));
    prefangle_eachsub(ss) = angle(mean(dataSUB));
    if prefangle_eachsub(ss) <0
        prefangle_eachsub_deg(ss) =180 + rad2deg(prefangle_eachsub(ss) + pi);
    else
        prefangle_eachsub_deg(ss) = rad2deg(prefangle_eachsub(ss));
    end
    
    % for each subject and landmark
    for lm = 1:length(alltarg)
        dataSUBLM = preproc_systerr_data.compl_plane(preproc_systerr_data.subj == nsubj(ss) & preproc_systerr_data.LM == lm);
        ITPC_eachsubandLM(ss,lm) = abs(mean(dataSUBLM));
        prefangle_eachSUBLM(ss,lm) = angle(mean(dataSUBLM));
        if prefangle_eachSUBLM(ss,lm) < 0 ;
            prefangle_eachSUBLM_deg(ss,lm) = 180 + rad2deg(prefangle_eachSUBLM(ss,lm)+pi);
        else
            prefangle_eachSUBLM_deg(ss,lm) = rad2deg(prefangle_eachSUBLM(ss,lm));
        end
    end
end

%% tableize and save
% table ITPC for each subject and landmark
ITPC_eachLM = array2table([nsubj ITPC_eachsubandLM]);
for lm = 1:length(alltarg)
    eval(sprintf('Vnames{lm} = ''AngCons_lm%d'';', lm));
end
ITPC_eachLM.Properties.VariableNames = ['Subj' Vnames];
writetable(ITPC_eachLM, [paths.out 'AngleCons_eachLM.xlsx']);
AngleCons_eachLM = ITPC_eachLM;

% table avg angle for each subject and landmark
angle_eachLM = array2table([nsubj prefangle_eachSUBLM_deg]);
for lm = 1:length(alltarg)
    eval(sprintf('Vnames{lm} = ''AvgAng_lm%d'';', lm));
end
angle_eachLM.Properties.VariableNames = ['Subj' Vnames];
writetable(angle_eachLM, [paths.out 'AvgAngle_eachLM.xlsx']);
AvgAngle_eachLM = angle_eachLM;

% ITPC table for each subject
ITPC_eachSUBJ = array2table([nsubj ITPC_eachsubj']);
ITPC_eachSUBJ.Properties.VariableNames = {'Subj', 'AngCons'};

writetable(ITPC_eachSUBJ, [paths.out 'AngleCons_eachSUBJ.xlsx']);
AngleCons_eachSUBJ = ITPC_eachSUBJ;

% avg angle table for each subject
avangle_eachSUBJ = array2table([nsubj prefangle_eachsub_deg']);
avangle_eachSUBJ.Properties.VariableNames = {'Subj', 'AvgAng'};

writetable(avangle_eachSUBJ, [paths.out 'AvgAngle_eachSUBJ.xlsx']);
AvgAngle_eachSUBJ = avangle_eachSUBJ;

if options.needplot == 1
    
    %% polar plot for each landmark
    anglefig = figure;
    set(gcf, 'Position',  [100, 100, 1000, 700])
    
    kk = 1;
    for lm = 1:length(alltarg)
        for ss = 1:length(nsubj)
            angle2plot = angle(mean(preproc_systerr_data.compl_plane(preproc_systerr_data.LM == lm & preproc_systerr_data.subj == nsubj(ss))));
            abs2plot(lm,ss) = abs(mean(preproc_systerr_data.compl_plane(preproc_systerr_data.LM == lm & preproc_systerr_data.subj == nsubj(ss))));
            subplot(2,5,kk)
            ppl = polarplot([angle2plot angle2plot],[0 1], 'Color', 'k' );
            title({['LM ' num2str(lm) ', ']; ['angle cons. = ' num2str(round(mean(abs2plot(lm,:),2),3)) '\pm' num2str(round(std(ITPC_eachsubandLM(:,lm),[])/sqrt(length(nsubj)),3))]});
            hold on
            set(gca, 'RLim', [0 1], 'RTick', [1], 'ThetaTick', [0 90 180 270], 'RMinorGrid', 'on' , 'RAxisLocation', 60, 'FontSize', 8);
        end
        kk = kk+1;
    end
    
end
end




