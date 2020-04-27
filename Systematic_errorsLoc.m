function [preproc_systerr_data] = Systematic_errorsLoc(preproc_data_name, paths, options);

% INPUTS:
% preproc_data (string: file name of the preproc data, obtained from PreprocessingLoc function
% paths (data structure)
    % paths.data = directory of the data;
    % paths.out = directory of where to save the preprocessed data 
% options (data structure)     
    % options.needplot = 1;               % 1 if plot of average systematic error for each participant has to be plotted
    % options.colorActual = [0 0 0];      % color for actual landmarks
    % options.colorPerc = [1 0 0];        % colors for perceived landmarks

% OUTPUTS:
% preproc_systerr_data (table) - also saved as excel file
% systfig (figure) - displayng average systematic error for each landmark
% and subject

%% load data
preproc_data = readtable([paths.out preproc_data_name]);

%% define subjects and landmarks
nsubj = unique(preproc_data.subj);
alltarg = unique(preproc_data.LM);

%% compute systematic error
% error as the vector between the target (X) and endpoint of movement(T) = X - T
% vector has 2 components (horizontal, X and vertical, Y)
preproc_data.vec_syst_er = [preproc_data.percX - preproc_data.realX preproc_data.percY - preproc_data.realY];

%% compute average real and perceived positions

for lm = 1: length(alltarg)
    % grand averages
    avgreal(lm,1) = mean(preproc_data.realX(preproc_data.LM == lm,:));
    avgreal(lm,2) = mean(preproc_data.realY(preproc_data.LM == lm,:));
    avgperc(lm,1) = mean(preproc_data.percX(preproc_data.LM == lm,:));
    avgperc(lm,2) = mean(preproc_data.percY(preproc_data.LM == lm,:));
    % averages for each subject
    for ss = 1:length(nsubj)
        avgreal_eachsubj(lm,1,ss) = mean(preproc_data.realX(preproc_data.subj == nsubj(ss) & preproc_data.LM == lm,:));
        avgreal_eachsubj(lm,2,ss) = mean(preproc_data.realY(preproc_data.subj == nsubj(ss) & preproc_data.LM == lm,:));
    end
end

%% compute magnitude and direction of error

% compute index-little vector (which is horizontal if the coordinates have been rotated)
for ss = 1:length(nsubj)
    idx_little_realvec_rot(ss,:)= [avgreal_eachsubj(7,1,ss) - avgreal_eachsubj(10,1,ss)  avgreal_eachsubj(7,2,ss) - avgreal_eachsubj(10,2,ss)] ;
end

for ii = 1:size(preproc_data,1);
    sub = find(nsubj == preproc_data.subj(ii));
    % compute magnitude of error
    preproc_data.abs_syst_er(ii) = sqrt(preproc_data.vec_syst_er(ii,1)^2 + preproc_data.vec_syst_er(ii,2)^2);
    a3d = [preproc_data.vec_syst_er(ii,:) 0]; %make vector in 3 dimensions
    b3d = [idx_little_realvec_rot(sub,:) 0];
    % compute angle of error (between index-little vector and each error vector)
    ThetaInDegrees = atan2d(norm(cross(a3d,b3d)),dot(a3d,b3d));
    if preproc_data.vec_syst_er(ii,2) < idx_little_realvec_rot(sub,2) & ThetaInDegrees <180
        preproc_data.angle_syst_er(ii) = 360- ThetaInDegrees;
    else
        preproc_data.angle_syst_er(ii) = ThetaInDegrees;
    end
end

%% save dataset
writetable(preproc_data, [paths.out 'preproc_systerr_data.xlsx']);
preproc_systerr_data = preproc_data;

if options.needplot == 1

%% plot average systematic error
% compute min and max
minX = min([preproc_data.percX]);
maxX = max([preproc_data.percX]);
minY = min([preproc_data.percY]);
maxY = max([preproc_data.percY]);

systfig = figure; 
set(gcf, 'Position',  [100, 100, 500, 550])

for ss = 1:length(nsubj)
for lm = 1:length(alltarg)
    data = preproc_systerr_data(preproc_systerr_data.LM ==lm & preproc_systerr_data.subj == nsubj(ss),:);
    if ss == 1 & lm == 1
q = quiver(avgreal(lm,1) ,avgreal(lm,2), mean(data.vec_syst_er(:,1)),mean(data.vec_syst_er(:,2)), '-k', 'LineWidth', 0.1);
hold on
    else
quiver(avgreal(lm,1) ,avgreal(lm,2), mean(data.vec_syst_er(:,1)),mean(data.vec_syst_er(:,2)), '-k', 'LineWidth', 0.1, 'HandleVisibility', 'off');
hold on
    end 
xlim([minX-4 maxX+4])
ylim([minY-4 maxY+4])
end 
end
xlabel('X (cm)');
ylabel('Y (cm)');
hold on 
sc2 = scatter(avgreal(:,1), avgreal(:,2), 20, options.colorActual, 'filled');
sc2.LineWidth = 0.6;
sc2.MarkerEdgeColor = 'k';
sc = scatter(avgperc(:,1), avgperc(:,2), 20, options.colorPerc, 'filled');
sc.LineWidth = 0.6;
sc.MarkerEdgeColor = 'k';
legend({'Average error vector for each participant','Average actual hand', 'Average perceived hand'}, 'Location', 'northoutside');

end 

end






