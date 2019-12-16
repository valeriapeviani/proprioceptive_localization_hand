
function [preproc_data, Noutliers] = PreprocessingLoc(dataname, paths, options);

% INPUTS: data, paths, options
% data (string: name of excel data);
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
% paths (data structure)
    % paths.data = directory of the data;
    % paths.out = directory of where to save the preprocessed data 
% options (data structure)
    % options.removemissing   % 1 = remove missing observations
    % options.normalize       % 1 = normalize data by dividing pixel coordinates by the conversion index
    % options.rotate          % 1 = apply rotation to the coordinates, so that index-little axis is horizontal for each participant
    % options.transpose       % 1 = transpose the coordinates so that they have a common origin
    % options.removeoutliers  % 1 = remove outliers based on mahalanobis distance
    % options.pct_outliers    % percentile above and below which the mahalanobis distance is considered an outlier

% OUTPUTS: preprocessed data and total number of outliers
    % preproc_data (table) - (also saved as excel file)
    % Noutliers: number of total outlier observations
    
    %% load data
    data = readtable([paths.data dataname]);
    
    %% take away missing values
    if options.removemissing == 1;
        nan2remove = find(isnan(data.percX(:)));
        nan2remove = sort(nan2remove, 'descend');
        for nn = 1:length(nan2remove)
            data(nan2remove(nn),:) = [];
        end
    end
    
    %% normalize raw XY coordinates
    if options.normalize == 1;
        data.percX = data.percX./data.convIDX;
        data.percY = data.percY./data.convIDX;
        data.realX = data.realX./data.convIDX;
        data.realY = data.realY./data.convIDX;
    end
    
    %% define subjects and landmarks
    nsubj = unique(data.subj);
    alltarg = unique(data.LM);
    
    %% compute average real  positions
    
    % for the entire sample
    for lm = 1: length(alltarg)
        avgreal_raw(lm,1) = mean(data.realX( data.LM == lm,:));
        avgreal_raw(lm,2) = mean(data.realY( data.LM == lm,:));
        
        % and for each subject
        for ss = 1:length(nsubj)
            avgreal_eachsubj_raw(lm,1,ss) = mean(data.realX(data.subj == nsubj(ss) & data.LM == lm,:));
            avgreal_eachsubj_raw(lm,2,ss) = mean(data.realY(data.subj == nsubj(ss) & data.LM == lm,:));
        end
    end
    
    %% rotate coordinates so that index-little axis is horizontal
    if options.rotate == 1;
        % compute horizontal vector
        horiz_vec = [1 0]; % 1 horizontal dimension, 0 vertical dimension: it is an horizontal vector
        
        % compute vector between index and little
        for ss = 1:length(nsubj)
            idx_little_realvec(ss,:)= [avgreal_eachsubj_raw(7,1,ss) - avgreal_eachsubj_raw(10,1,ss)  avgreal_eachsubj_raw(7,2,ss) - avgreal_eachsubj_raw(10,2,ss)] ;
            
            % angle between them
            a3d = [idx_little_realvec(ss,:) 0]; %make vector in 3 dimensions
            b3d = [horiz_vec 0];
            
            ThetaInDegrees(ss,:) = 360 - atan2d(norm(cross(a3d,b3d)),dot(a3d,b3d));
            
            % Create rotation matrix (counterclockwise)
            R = [cosd(ThetaInDegrees(ss,:)) -sind(ThetaInDegrees(ss,:)); sind(ThetaInDegrees(ss,:)) cosd(ThetaInDegrees(ss,:))];
            % Rotate your points
            coord2rotate_perc = [data.percX(data.subj == nsubj(ss)) data.percY(data.subj == nsubj(ss))] ;
            rotated = zeros(size(coord2rotate_perc,1),2);
            coord2rotate_real = [data.realX(data.subj == nsubj(ss)) data.realY(data.subj == nsubj(ss))] ;
            rotated2 = zeros(size(coord2rotate_real,1),2);
            
            for ii = 1:size(coord2rotate_perc,1)
                temp = coord2rotate_perc(ii,:)';
                temp2 = coord2rotate_real(ii,:)';
                rotated(ii,:) = (R*temp)';
                rotated2(ii,:) = (R*temp2)';
            end
            data.percX(data.subj == nsubj(ss)) = rotated(:,1);
            data.percY(data.subj == nsubj(ss)) = rotated(:,2);
            data.realX(data.subj == nsubj(ss)) = rotated2(:,1);
            data.realY(data.subj == nsubj(ss)) = rotated2(:,2);
        end
    end
    
    %% traspose coordinates so that they have the same origin
    % by adding the same XY factor
    
    if options.transpose == 1;
        for ss = 1:length(nsubj)
            dataX = data.percX(data.subj == nsubj(ss));
            dataY = data.percY(data.subj == nsubj(ss));
            transX =  -( min(dataX));
            transY = -( min(dataY));
            data.percX(data.subj == nsubj(ss)) = data.percX(data.subj == nsubj(ss))+ repmat(transX +2, size(dataX,1), 1);
            data.percY(data.subj == nsubj(ss)) = data.percY(data.subj == nsubj(ss)) + repmat(transY +2, size(dataY,1), 1);
            data.realX(data.subj == nsubj(ss)) = data.realX(data.subj == nsubj(ss))+ repmat(transX +2, size(dataX,1), 1);
            data.realY(data.subj == nsubj(ss)) = data.realY(data.subj == nsubj(ss)) + repmat(transY +2, size(dataY,1), 1);
        end
    end
    
    %% take off outliers using mahalanobis distance
    
    if options.removeoutliers == 1;
        for ss = 1:length(nsubj)
            for lm = 1:length(alltarg)
                datax = data.percX(data.subj == nsubj(ss) & data.LM == lm);
                datay = data.percY(data.subj == nsubj(ss) & data.LM == lm);
                d2mahal = mahal([datax datay], [datax datay]);
                data.MD(data.subj == nsubj(ss) & data.LM == lm) = d2mahal;
                ChiDistr = chi2pdf(d2mahal,2); % mahalanobis distance follows chi-sq distribution with 2 degrees of freedom (because I have 2 dimensional data)
                thresh = chi2inv(options.pct_outliers/100,2);  % those falling above chosen percentile of that distribution are outliers
                data.outliers(data.subj == nsubj(ss) & data.LM == lm & data.MD > thresh) = 1;
            end
        end
        Noutliers = sum(data.outliers);
        data = data(data.outliers == 0,:);
    end
    %% compute average real and perceived positions
    
    for lm = 1: length(alltarg)
        % grand averages
        avgreal(lm,1) = mean(data.realX(data.LM == lm,:));
        avgreal(lm,2) = mean(data.realY(data.LM == lm,:));
        avgperc(lm,1) = mean(data.percX(data.LM == lm,:));
        avgperc(lm,2) = mean(data.percY(data.LM == lm,:));
        % averages for each subject
        for ss = 1:length(nsubj)
            avgreal_eachsubj(lm,1,ss) = mean(data.realX(data.subj == nsubj(ss) & data.LM == lm,:));
            avgreal_eachsubj(lm,2,ss) = mean(data.realY(data.subj == nsubj(ss) & data.LM == lm,:));
        end
    end
    
    %% save workspace
    data.outliers = [];
    data.MD = [];
    writetable(data, [paths.out 'preproc_data.xlsx']);
    preproc_data = data;
    
end
