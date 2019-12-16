%% Parameters 

dataname = 'mydata.xls'; % insert data file name 
paths.data = 'pathdata\'; % insert data directory 
paths.out = 'pathdataout\'; % insert directory where to save preprocessed

% the excel sheet should contain the raw XY pixel coordinates of the perceived and actual landmarks
% data must be in long format (each row is a trial)
% the code will read the following variables, organized in columns:
% - subj (subj id: must be a number),
% - itemN (ordinal number of the trial)
% - LM (landmark: must be a number, 1 to 10 (usually) 1 to 5 fingertips (thumb to little) and 6 to 10 knuckles (thumb to little)),
% - percX (X coordinate of perceived landmark position for that trial)
% - percY (Y coordinate of perceived landmark position for that trial)
% - realX (X coordinate of real landmark position for that trial)
% - realY (Y coordinate of perceived landmark position for that trial)
% - convIDX (conversion index: number of pixels per cm)


%% Preprocessing
options.removemissing = 1;  % 1 = remove missing observations; 
options.normalize = 1;      % 1 = normalize data by dividing pixel coordinates by the conversion index; 
options.rotate = 1;         % 1 = apply rotation to the coordinates, so that index-little axis is horizontal for each participant
options.transpose = 1;      % 1 = transpose the coordinates so that they have a common origin
options.removeoutliers = 1; % 1 = remove outliers based on mahalanobis distance
options.pct_outliers = 95;  % percentile above and below which the mahalanobis distance is considered an outlier

[preproc_data, Noutliers] = PreprocessingLoc(dataname, paths, options);

%% Compute and plot systematic errors 
preproc_data_name = 'preproc_data.xlsx';  %file name of the preproc data 
options.needplot = 0;               % 1 if plot of average systematic error for each participant has to be plotted
options.colorActual = [0 0 0];      % color for actual landmarks
options.colorPerc = [1 0 0];        % colors for perceived landmarks

[preproc_systerr_data] = Systematic_errorsLoc(preproc_data_name, paths, options);

%% Compute and plot angle consistency 
systerr_data_name = 'preproc_systerr_data.xlsx';  %file name of the preproc data 
options.needplot = 1; %polar plots of systematic errors

[AngleCons_eachSUBJ, AngleCons_eachLM, AvgAngle_eachSUBJ, AvgAngle_eachLM] = Angle_consistencyLoc(systerr_data_name, options, paths);

%% PCA
systerr_data_name = 'preproc_systerr_data.xlsx';  %file name of the preproc data 
options.cmp2keep = [1:1:10]; % number of components to keep in recovered data
options.dims = {'X', 'Y'}; % dimensions to run the PCA on 
options.cmp2plot = 1; % components to plot
options.zoomfact = 1; % factor to multiply each average component

[resPCA] = PCALoc(systerr_data_name, options, paths);

%% Plot raw actual and perceived map, and pointing density
preproc_data_name =  'preproc_data.xlsx';
options.plotReal = 1;               % if includes actual hand plot
options.colorActual = [0 0 0];      % color for actual landmarks
options.colorPerc = [1 0 0];        % colors for perceived landmarks
options.colmap = hot;               % colormap for density plot
options.resolution = 10;            % resolution of density plot 

[mapfig] = Plot_mapsLoc(preproc_data_name, paths, options);


