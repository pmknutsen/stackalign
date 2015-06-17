function tStack = saGetThresholds(tStack, sName, iRefImg, varargin)
% Threshold individual images interactively
%
% This function opens an interactive GUI, using the keyboard and mouse to
% filter and image in order to extract labeled regions. The following
% filters are available:
%
%   Remove pixels along edges of image (automatic)
%   Remove connected objects smaller N pixels (keys Z and X)
%   Remove objects with eccentricities lower than N (keys A and S)
%   Remove regions manually (Left/Middle button to remove; Right for undo)
%
% After an image has been filtered, press Enter to proceed to the next.
% Press R to reset filter settings.
%
% Usage:
%   tStack = saGetThresholds(tStack, sName, iRefImg)
%   tStack = saGetThresholds(tStack, sName, iRefImg, tParams)
%
%   sName is the name of the field in tStack where coordinates of
%   thresholded pixels are stored in an [X Y] by I matrix.
%
%   tParams is an optional structure with parameters:
%       tParams.nThreshStep         Intensity threshold step
%       tParams.nObjSizeThresh      Object size threshold (remove smaller)
%       tParams.nObjSizeThreshStep  Object size threshold step
%       tParams.nEccThresh          Object eccentricity threshold (0 - 1)
%       tParams.nEccThreshStep      Eccentricity threshold step
%       tParams.nClickRad           Radius of manually removed regions
%

% Get analysis parameters
hAx = [];
if nargin < 3
    error('Too few inputs')
elseif nargin == 4
    tUserParms = varargin{1};
else
    tUserParms = struct([]);
end

% Default parameters (any can be passed as fields of tUserParms
tParms.nThreshStep = 0.005;
tParms.nObjSizeThresh = 0;
tParms.nObjSizeThreshStep = 2;
tParms.nEccThreshStep = .01;
tParms.nClickRad = 20;
tParms.nEccThresh = .4;

% Replace defaults with user-set parameters
csParms = fieldnames(tUserParms);
for p = 1:length(csParms)
    tParms.(csParms{p}) = tUserParms.(csParms{p});
end

% Split parameters into variables
csParms = fieldnames(tParms);
for p = 1:length(csParms)
    eval(sprintf('%s = tParms.(csParms{p});', csParms{p}));
end

% Image/threshold figure
hFig = figure;
vPos = get(hFig, 'position');
set(hFig, 'position', [vPos(1:2) 1200 500], 'color', 'k', ...
    'WindowButtonDownFcn', 'set(gcf,''CurrentCharacter'', ''1'');')

centerfig(hFig)
hAx = axes('position', [.5 0 .5 1]);
hAx(2) = axes('position', [0 0 .5 1]);
colormap gray
axis(hAx, 'off')

if ~isfield(tStack, 'nBWLevel'), tStack(1).nBWLevel = []; end
if ~isfield(tStack, 'nObjSizeThresh'), tStack(1).nObjSizeThresh = []; end
if ~isfield(tStack, 'mManualBWMask'), tStack(1).mManualBWMask = []; end
if ~isfield(tStack, 'nEccThresh'), tStack(1).nEccThresh = []; end

for i = iRefImg
    
    % Get image
    if isfield(tStack, 'mImgMedFilt')
        mImg = double(tStack(i).mImg) - double(tStack(i).mImgMedFilt);
    else
        mImg = double(tStack(i).mImg);
    end
        
    % Normalize image
    mImg = mImg - min(mImg(:));
    mImg = mImg ./ max(mImg(:));
    
    % Display image and mask
    cla(hAx(2))
    imagesc(mImg, 'parent', hAx(2))
    hold(hAx(2), 'on')
    hMask = plot(hAx(2), nan, nan, 'r.', 'markersize', 0.5);
    %set(hAx(2), 'clim', [0 .5]) % saturate to bring out sparse bright pixels
    
    % Guess thresholds
    if isempty(tStack(i).nBWLevel), tStack(i).nBWLevel = graythresh(mImg); end
    if isempty(tStack(i).nObjSizeThresh), tStack(i).nObjSizeThresh = nObjSizeThresh; end
    if isempty(tStack(i).mManualBWMask), tStack(i).mManualBWMask = ones(size(mImg)); end
    if isempty(tStack(i).nEccThresh), tStack(i).nEccThresh = nEccThresh; end
    
    % Adjust threshold manually
    while 1
        mBW = im2bw(mImg, tStack(i).nBWLevel);
        
        % Remove connected objects smaller than N pixels
        mBW = bwareaopen(mBW, tStack(i).nObjSizeThresh);

        % Remove circular objects (i.e. low eccentricity)
        % Run this filter if there is less than 2,000 objects
        mBWl = bwlabel(mBW);
        if max(mBWl(:)) < 5000
            tStats = regionprops(mBW, 'Eccentricity');
            mBW = ismember(mBWl, find([tStats.Eccentricity] > tStack(i).nEccThresh));
        end

        % Apply manual mask
        mBW = logical(mBW .* tStack(i).mManualBWMask);
        
        % Remove pixels close to edge of image
        mBW([1 2 end end-1], :) = 0;
        mBW(:, [1 2 end end-1]) = 0;
        
        % Display thresholded image
        cla(hAx(1))
        hIm = imagesc(mBW, 'parent', hAx(1));
        sStr = sprintf('Thresh=%.2f / #Obj=%d / MinSize=%d / MinEcc=%.2f', ...
            tStack(i).nBWLevel, ...
            max(mBWl(:)), ...
            tStack(i).nObjSizeThresh, ...
            tStack(i).nEccThresh);
        text(20, 35, sStr, 'color', 'r', 'parent', hAx(1), 'fontsize', 14, 'fontweight', 'bold')
        %axis(hAx(1), 'tight')

        % Plot mask over original image as dots (overlay with transparency
        % is too slow)
        [vY vX] = find(~tStack(i).mManualBWMask);
        axes(hAx(2))
        hold on
        set(hMask, 'xdata', vX, 'ydata', vY)
        
        % Wait for user key press
        %   Up arrow    Increase intensity threshold
        %   Down arrow  Decrease          "
        %   Z           Decrease connected object size
        %   X           Increase          "
        %   Enter       Next image pair
        set(hFig(1), 'numbertitle', 'off', 'name', ...
            sprintf('%d/%d  Up/Down Keys = Threshold,  Z/X = Object Size', ...
            find(iRefImg == i), numel(iRefImg)), 'color', 'w')
        set(hFig(1), 'CurrentCharacter', '0')
        waitfor(hFig(1), 'CurrentCharacter')
        
        try
            nChar = double(get(hFig(1), 'CurrentCharacter'));
        catch % window was closed
            return
        end
        
        if isempty(nChar), continue; end
        switch nChar
            case 30
                % Increase threshold (up arrow)
                tStack(i).nBWLevel = tStack(i).nBWLevel + nThreshStep;
            case 31
                % Decrease threshold (down arrow)
                tStack(i).nBWLevel = tStack(i).nBWLevel - nThreshStep;
            case 120
                % Increase connected object size (x)
                tStack(i).nObjSizeThresh = tStack(i).nObjSizeThresh + nObjSizeThreshStep;
            case 122
                % Decrease connected object size (z)
                tStack(i).nObjSizeThresh = tStack(i).nObjSizeThresh - nObjSizeThreshStep;
            case 115
                % Increase eccentricity threshold (z)
                tStack(i).nEccThresh = tStack(i).nEccThresh + nEccThreshStep;
            case 97
                % Decrease eccentricity threshold (z)
                tStack(i).nEccThresh = tStack(i).nEccThresh - nEccThreshStep;
            case 114
                % Reset parameters to defaults
                tStack(i).nEccThresh = nEccThresh;
                tStack(i).nObjSizeThresh = nObjSizeThresh;
                tStack(i).nBWLevel = graythresh(mImg);
            case 13
                % Proceed to next image pair
                break
            case 49
                % Process mouse click
                vClick = get(hAx(1), 'CurrentPoint');
                if any(vClick(1,1:2) < 0) % user clicked on image
                    vClick = get(hAx(2), 'CurrentPoint');
                end
                vClick = round(vClick(1, 1:2));
                
                nW = size(mBW, 1);
                nH = size(mBW, 2);
                nX = vClick(1);
                nY = vClick(2);
                nRadVal = nClickRad;
                switch get(hFig(1), 'SelectionType');
                    case 'normal' % left-click; add to mask
                        nMaskVal = 0;
                    case 'alt' % right-click; remove form mask
                        nMaskVal = 1;
                    case 'extend' % middle mouse button
                        nMaskVal = 0;
                        nRadVal = nClickRad * 2;
                end
                mask = bsxfun(@plus, ...
                    ((1:nH) - nX) .^ 2, ...
                    (transpose(1:nW) - nY) .^ 2) < nRadVal^2;
                tStack(i).mManualBWMask(mask) = nMaskVal;
        end
        tStack(i).nBWLevel = min([1 max([0 tStack(i).nBWLevel])]);
        tStack(i).nEccThresh = min([1 max([0 tStack(i).nEccThresh])]);
        tStack(i).nObjSizeThresh = max([0 tStack(i).nObjSizeThresh]);
    end
    
    % Pad image to avoid edge effects
    nPadSize = saGetPadSize(tStack);
    mBW = padmatrix(mBW, [nPadSize nPadSize nPadSize nPadSize]);
    
    % Transform image
    nRotate = tStack(i).tTransform.nCumRotate;
    vTranslate = tStack(i).tTransform.vCumTranslate;
    mBW = saImgTransform(mBW, nRotate, vTranslate);

    % Store thresholded image
    tStack(i).mBW = sparse(mBW);

    % Store pixel coordinates
    [iY iX] = find(mBW);
    iX = (iX - nPadSize);
    iY = (iY - nPadSize);
    nPixRes = (1 / tStack(i).nPixelsMM) * 1000; % pixel resolution, um
    vXum = iX * nPixRes; % transform to metric
    vYum = iY * nPixRes;
    tStack(i).(sName) = [vXum vYum];
    
end
close(hFig)
return
