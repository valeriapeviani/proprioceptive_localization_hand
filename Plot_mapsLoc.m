function [mapfig] = Plot_mapsLoc(preproc_data_name, paths, options);
% INPUTS:
% preproc_data_name (string: file name of the preproc data, obtained from PreprocessingLoc function
% warning: this code works if all the ten landmarks are represented, and they are ordered starting from the thumb fingertip (=1), to the little knuckle (=10).
% Otherwise, it needs to be modified.
% paths (data structure)
    % paths.data = directory of the data;
    % paths.out = directory of where to save the preprocessed data 
% options: 
% options.plotReal = 1; % if actual hand map has to be plotted
% options.colorActual = [0 0 0]; % color for actual landmarks
% options.colorPerc = [1 0 0]; % colors for perceived landmarks
% options.colmap = hot; % colormap for density plot
% options.resolution = 10; % resolution of density plot 

% OUTPUTS:
% mapfig (figure) - representing: 1) perceived and actual map, 2) density
% plot of pointings

%% load data
preproc_data = readtable([paths.out preproc_data_name]);

%% define subjects and landmarks
nsubj = unique(preproc_data.subj);
alltarg = unique(preproc_data.LM);

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
minX = min([preproc_data.percX]);
maxX = max([preproc_data.percX]);
minY = min([preproc_data.percY]);
maxY = max([preproc_data.percY]);


%% compute average real and perceived positions

for lm = 1: length(alltarg)
    if options.plotReal == 1
        avgreal(lm,1) = mean(preproc_data.realX(preproc_data.LM == lm,:));
        avgreal(lm,2) = mean(preproc_data.realY(preproc_data.LM == lm,:));
    end
    avgperc(lm,1) = mean(preproc_data.percX(preproc_data.LM == lm,:));
    avgperc(lm,2) = mean(preproc_data.percY(preproc_data.LM == lm,:));
end

%% plot average real hand with all perceived positions
% scatter real and perceived
mapfig = figure;
set(gcf, 'Position',  [100, 100, 1100, 400])
alpha = 0.4;

subplot(1,2,1)
if options.plotReal == 1
    scatter(avgreal(:,1), avgreal(:,2), 1, options.colorActual(1,:), 'filled', 'MarkerFaceAlpha', alpha);
    hold on
    scatter(preproc_data.realX , preproc_data.realY , 2, options.colorActual(1,:), 'filled', 'MarkerFaceAlpha', alpha);
end
scatter(avgperc(:,1), avgperc(:,2), 1, options.colorPerc(1,:), 'filled', 'MarkerFaceAlpha', alpha);
scatter(preproc_data.percX , preproc_data.percY , 2, options.colorPerc(1,:), 'filled', 'MarkerFaceAlpha', alpha);
hold on

% line plots
if options.plotReal == 1
    for ll = 1:liness
        eval(sprintf('p = plot(avgreal(l%d,1), avgreal(l%d,2), ''Color'', options.colorActual(1,:) , ''LineWidth'', 1);', ll,ll));
    end
end

hold on
for ll = 1:liness
    eval(sprintf('p = plot(avgperc(l%d,1), avgperc(l%d,2), ''Color'', options.colorPerc(1,:) , ''LineWidth'', 1);', ll,ll));
end

xlabel('cm');
ylabel('cm');
xlim([minX-2 maxX+2])
ylim([minY-2 maxY+2])
ax = gca;

%% create a 0 matrix for denisity plot
maxhordif = round((maxX - minX)*options.resolution, 0);
maxverdif = round((maxY - minY)*options.resolution, 0);

maxhordif = round((ax.XLim(2) - ax.XLim(1))*options.resolution, 0);
maxverdif = round((ax.YLim(2) - ax.YLim(1))*options.resolution, 0);


inputmat_norm = zeros(maxverdif, maxhordif);
inputmat_norm_mask = zeros(maxverdif, maxhordif);

%% fill in the matrix

for hh = 1: size(inputmat_norm, 2)
    for vv = 1:size(inputmat_norm, 1)
        % count how many values have a specific X and Y coordinate
        densnum = length(find(round(preproc_data.percX.*options.resolution,0)== hh & round(preproc_data.percY.*options.resolution,0)== vv));
        inputmat_norm(vv,hh) = densnum;
    end
end

for lm = 1:length(alltarg)
    real_inputmat_norm(lm,1) = round(avgreal(lm,1).*options.resolution,0);
    real_inputmat_norm(lm,2) = round(avgreal(lm,2).*options.resolution,0);
    perc_inputmat_norm(lm,1) = round(avgperc(lm,1).*options.resolution,0);
    perc_inputmat_norm(lm,2) = round(avgperc(lm,2).*options.resolution,0);
    
end

inputmat_norm_padded = padarray(inputmat_norm,abs(maxhordif - maxverdif),0,'post');

%% plot density plot

subplot(1,2,2)
img = imagesc(inputmat_norm_padded);
set(gca,'YDir','normal')
cols = options.colmap;
colhalf = cols([1 7:end],:);
colormap(colhalf);
xlabel('X (cm)');
ylabel('Y (cm)');
c = colorbar;
c.Label.String = 'Number of pointings';
xlim([minX*options.resolution-2*options.resolution maxX*options.resolution+2*options.resolution])
ylim([minY*options.resolution-2*options.resolution maxY*options.resolution+2*options.resolution])

ax2 = gca;
ax2.XTickLabel = ax.XTickLabel;
ax2.YTickLabel = ax.YTickLabel;


end

       