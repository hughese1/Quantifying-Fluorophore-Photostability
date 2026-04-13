%% Calculate offset, variance, and gain for each pixel for calibration of photobleaching project
clear all;
close all;
tic;

%% Update folders for inputs and outputs:
allthefolders="E:\Lavis\CameraCalibration_20251125"; % folder containing characterization data
% expected format is subfolders for each brightness level, with the lowest
% number corresponding to the dark counts (bright_100cts for example)

% Output paths for where you want to save your outputs:
outpath_offset="E:\Lavis\CameraCalibration_2272026\offsets2";%path for offset tif and tifs of average value at each brightness
outpath_var="E:\Lavis\CameraCalibration_2272026\variances2"; %path for tifs of variance at each brightness level
outpath_gain="E:\Lavis\CameraCalibration_2272026\gain2";%path for saving per pixel gain tif


%% Proceed with calculations:
folders = dir(allthefolders);
folders = folders([folders.isdir] & ~ismember({folders.name},{'.','..'}));
numfolders = numel(folders);

mkdir(outpath_var);
mkdir(outpath_offset);
mkdir(outpath_gain);

addpath("saveastiff_4.5")

% get image dims assuming everything is the same size in x,y
folderpath = fullfile(allthefolders, folders(1).name);
tifFiles = dir(fullfile(folderpath, '*.tif'));
firstPath = fullfile(folderpath, tifFiles(1).name);
info1 = imfinfo(firstPath);
xdim = info1(1).Width;
ydim = info1(1).Height;

%% Loop through folders (one per brightness level)
gain = zeros(ydim,xdim);
intercept = zeros(ydim,xdim);
avgStack = zeros(ydim, xdim, numfolders-1);
varStack = zeros(ydim, xdim, numfolders-1);
npx = ydim*xdim;

avgAll = zeros(npx * (numfolders-1), 1);
varAll = zeros(npx * (numfolders-1), 1);

offset   = [];
variance = [];

for folnum = 1:numfolders
    fprintf('Processing folder %d / %d\n', folnum, numfolders);
    folderpath = fullfile(allthefolders, folders(folnum).name);
    tifFiles   = dir(fullfile(folderpath, '*.tif'));
    darktotal  = numel(tifFiles);

    % Count total frames
    timeptv = zeros(darktotal, 1, 'uint32');
    for a = 1:darktotal
        fpath = fullfile(folderpath, tifFiles(a).name);
        inf_a = imfinfo(fpath);
        timeptv(a) = numel(inf_a);
    end
    timepts = sum(double(timeptv));

    % Load all frames into 3D stack
    firstPath = fullfile(folderpath, tifFiles(1).name);
    getsettings = imread(firstPath, 1);
    im3d = zeros(ydim, xdim, timepts, 'like', getsettings);
    timeptspast  = 0;

    for i = 1:darktotal
        fpath = fullfile(folderpath, tifFiles(i).name);
        vol = tiffreadVolume(fpath);
        im3d(:,:, timeptspast+1 : timeptspast+timeptv(i)) = vol;
        timeptspast = timeptspast + double(timeptv(i));
    end
    pxavgs    = mean(double(im3d), 3);
    variances = var(double(im3d), 0, 3);
    idx = (folnum-2)*npx + 1 : (folnum-1)*npx;
    if folnum == 1
        % Save offset and variance (dark frame)
        offset   = pxavgs;
        variance = variances;
        saveastiff(pxavgs,char(fullfile(outpath_offset, 'offset.tif')));
        saveastiff(variances,char(fullfile(outpath_var,    'variance.tif')));
    else
        saveastiff(pxavgs, char(fullfile(outpath_offset, sprintf('perpx_averageimage_%03d.tif', folnum))));
        saveastiff(variances,char(fullfile(outpath_var, sprintf('perpixvariance_%03d.tif', folnum))));
        avgim = pxavgs    - offset;
        varim = variances - variance;
        avgAll(idx) = avgim(:);
        varAll(idx) = varim(:);
        avgStack(:,:,folnum-1) = avgim;
        varStack(:,:,folnum-1) = varim;
    end

end

for ypx = 1:ydim
    for xpx = 1:xdim
        meanVals_px = squeeze(avgStack(ypx, xpx, :));
        varVals_px  = squeeze(varStack(ypx, xpx, :));
        p = polyfit(meanVals_px, varVals_px, 1);
        gain(ypx, xpx) = p(1);  % slope
        intercept(ypx, xpx) = p(2);  % intercept
        if xpx == xdim/2 && ypx == ydim/2
            % Plot variance vs mean for middle pixel
            figure;
            scatter(meanVals_px, varVals_px, 500, '.'); 
            ylabel('Variance');
            title('Variance v avg at h/2,w/2');
            grid on;
        end
    end
end

filename3 = fullfile(outpath_gain,'gain.tif');
saveastiff(gain,char(filename3));

filename4 = fullfile(outpath_gain,'intercept.tif');
saveastiff(intercept,char(filename4));

figure;
tiledlayout(1,3)
nexttile
imshow(offset,[])
title("Offset")

nexttile
imshow(variance,[])
title("Variance")

nexttile
imshow(gain,[])
title("Gain")


gainmap=gain;
varmap=variance;
offsetmap=offset;

save('cameracalibrationoutput.mat',"gainmap","varmap","offsetmap")

% 
% %% sanity check:
% figure;
% scatter(avgAll, varAll, 500, '.'); 
% ylabel('Variance');
% title('Variance v avg for all px');
% grid on;

toc;