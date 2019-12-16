function [resPCA] = PCALoc(systerr_data_name, options, paths);

% INPUTS:
% systerr_preproc_data (string: file name of the preproc data with systematic errors, obtained from Systematic_errorsLoc function
% paths (data structure)
    % paths.data = directory of the data;
    % paths.out = directory of where to save the systematic error preprocessed data 
% options (data structure)
    % options.cmp2keep = indexes of components to keep in the recovered
        % data (e.g. 3:1:10 if I want disgard first two components)
    % options.dims = error components for PCA (e.g. {'X', 'Y'})
% OUTPUTS:
% resPCA (data structure) of matrix sized trials (t) x variables (v) 
    % resPCA.coeffPCA = PCA coefficients: matrix sized components (c) x variables (v) 
    % resPCA.scoresPCA = PCA z-scores: matrix sized trials (t) x components (c)
    % resPCA.latentPCA = eigenvalues for the covariance: matrix sized components (c) x 1
    % resPCA.tsquaredPCA = Hotelling's T-squared statistics: matrix sized trials (t) x variables (v) 
    % resPCA.explainedPCA = variance explained by each component: matrix sized components (c) x 1
    % resPCA.recovered = recovered data: matrix sized as the original dataset 

%% load data
preproc_systerr_data = readtable([paths.out systerr_data_name]);

%% PCA
alltarg = unique(preproc_systerr_data.LM);
dims = options.dims;
cmp2keep = options.cmp2keep;

for dim = 1:length(dims)
    for lm = 1:length(alltarg)
        sizes(lm) = size(preproc_systerr_data(preproc_systerr_data.LM == lm,:),1);
    end
    maxsize = min(sizes);
    kk = 1;
    % initialize matrix
    inputforPCA = zeros(maxsize,10);
    inputforPCA_centr = zeros(maxsize,10);
    for lm = 1:length(alltarg)
        temp = [];
        eval(sprintf('temp(:,1) = preproc_systerr_data.vec_syst_er_%d(preproc_systerr_data.LM == lm,1);', dim));
        temp(:,2) = preproc_systerr_data.subj(preproc_systerr_data.LM == lm);
        inputforPCA(:,lm) = temp(1:maxsize,1);
        subjN_considered(:,lm) = temp(1:maxsize,2);
        % center values
        inputforPCA_centr(:,lm) = inputforPCA(:,lm) - mean(inputforPCA(:,lm));
        kk = kk+2;
    end
    [coeff,score,latent,tsquared,explained]  = pca(zscore(inputforPCA_centr));
    eval(sprintf('resPCA.coeffPCA_%s = coeff;', dims{dim}));
    eval(sprintf('resPCA.scoresPCA_%s = score;', dims{dim}));
    eval(sprintf('resPCA.latentPCA_%s = latent;', dims{dim}));
    eval(sprintf('resPCA.tsquaredPCA_%s = tsquared;', dims{dim}));
    eval(sprintf('resPCA.explainedPCA_%s = explained;', dims{dim}));
    % recover data with only selected components
    eval(sprintf('resPCA.recovered_%s = inputforPCA * coeff(:,cmp2keep) * coeff(:,cmp2keep)'' ;', dims{dim}));
    
    %% plot PCA
    if options.needplot == 1
        % lines for the plot to resamble the actual hand
        liness = 9;
        l1 = [1 6];
        l2 = [2 7];
        l3 = [3 8];
        l4 = [4 9];
        l5 = [5 10];
        l6 = [6 7];
        l7 = [7 8];
        l8 = [8 9];
        l9 = [9 10];
        
        % compute min and max
        minX = min([preproc_systerr_data.percX]);
        maxX = max([preproc_systerr_data.percX]);
        minY = min([preproc_systerr_data.percY]);
        maxY = max([preproc_systerr_data.percY]);
        
        for lm = 1: length(alltarg)
            % compute average real positions
            avgreal(lm,1) = mean(preproc_systerr_data.realX(preproc_systerr_data.LM == lm,:));
            avgreal(lm,2) = mean(preproc_systerr_data.realY(preproc_systerr_data.LM == lm,:));
        end
        
        for nn = 1:options.cmp2plot
            figure(nn);
            subplot(1,length(dims),dim);
            % line plots
            for ll = 1:liness
                eval(sprintf('p = plot(avgreal(l%d,1), avgreal(l%d,2), ''Color'', 1/255*[153 153 153] , ''LineWidth'', 6);', ll, ll));
                p.Color(4) = 0.25;
                hold on
            end
            
            % compute average component
            cmp2keep = nn;
            recovtemp = inputforPCA * coeff(:,cmp2keep) * coeff(:,cmp2keep)'  ;
            comp(:,dim,nn) = mean(recovtemp)';
            
            
            zoomfact = options.zoomfact;
            for lm = 1:length(alltarg)
                if strcmp(dims{dim}, 'X');;
                    q = quiver(avgreal(lm,1) ,avgreal(lm,2), comp(lm,dim,nn)*zoomfact,0, '-b', 'LineWidth', 0.3);
                    q.MaxHeadSize = 0.8;
                elseif strcmp(dims{dim}, 'Y');;
                    q = quiver(avgreal(lm,1) ,avgreal(lm,2), 0, comp(lm,dim,nn)*zoomfact, '-r', 'LineWidth', 0.3);
                    q.MaxHeadSize = 0.8;
                end
                text(avgreal(lm,1) - 0.3,avgreal(lm,2)+0.7, num2str(round(coeff(lm,dim),2)), 'FontSize', 9);
                hold on
            end
        end
    end
end

end

