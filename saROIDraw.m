function tStack = saROIDraw(tStack, sName, iRefImg)
% Draw boundaries around an anatomical region
%
% Usage:
%   tStack = saROIDraw(tStack, 'MyArea', iRefImg)
%
% where iRefImg are the indices of reference images. If you prefer to work
% in a different order, simple re-order iRefImg, e.g. fliplr(iRefImg).
%
% ROI coordinates are saved in a new field of tStack, with the 'Boundary'
% suffix.
%
% Note that ROIs are saved in the coordinates of the original image.
%
%

hFig = figure('color', 'k', ...
    'numbertitle', 'off', ...
    'name', sprintf('%s: Middle button = Next section', sName));
hAx = axes;

sROIName = sprintf('v%sBoundary', sName);

if ~isfield(tStack, sROIName)
    tStack(1).(sROIName) = [];
end

for i = iRefImg

    % Get image (use low resolution version if available)
    nResizeFact = 1;
    if isfield(tStack, 'mImgLoRes')
        nResizeFact = tStack(i).nResizeFact;
    end
    
    % Get image
    mImg = saImageChannels(tStack, tStack(i).nSectionNumber, 'lowres');
    
    % Pad image to avoid edge effects
    nPadSize = round(saGetPadSize(tStack) / nResizeFact);
    
    mImPad = [];
    for j = 1:size(mImg, 3)
        mImPad(:,:,j) = padmatrix(mImg(:,:,j), [nPadSize nPadSize nPadSize nPadSize]);
    end
    mImg = mImPad;
    clear mImPad;
    
    % Transform image
    vImgSize = size(mImg);
    nRotate = tStack(i).tTransform.nCumRotate;
    vTranslate = tStack(i).tTransform.vCumTranslate ./ nResizeFact;
    mImg = saImgTransform(mImg, nRotate, vTranslate);
    
    % Display and get ROI
    if ~ishandle(hAx) % figure was closed
        return
    end
    
    hold(hAx, 'off')
    imagesc(mImg)
    colormap gray
    axis image off
    title(sprintf('%d/%d: Red = Previous, Green = Current, Blue = Next', ...
        tStack(i).nSectionNumber, tStack(end).nSectionNumber), ...
        'color', 'w', 'fontsize', 12)
        
    % Set axis limits so minimum of padding is shown
    [row, col] = find(mImg(:,:,1) > 0);
    set(hAx, 'xlim', [min(col)*.9 max(col)*1.1], 'ylim', [min(row)*.9 max(row)*1.1], 'position', [.05 .05 .9 .9])
    
    % Plot ROI of previous, current and next image
    mExROIsCols = [1 0 0; 0 1 0; 0 0 1];
    iPlotExImg = find(iRefImg == i) + [-1 0 1];
    for j = iPlotExImg
        if (j > 0) && (j <= length(iRefImg))
            mROI = [];
            if ~isempty(tStack(iRefImg(j)).(sROIName))
                % Transform ROIs by their respective transforms (ie. not
                % that of the current frame)
                nRotateThis = tStack(iRefImg(j)).tTransform.nCumRotate;
                vTranslateThis = tStack(iRefImg(j)).tTransform.vCumTranslate ./ nResizeFact;
                mROI = (tStack(iRefImg(j)).(sROIName) ./ nResizeFact) + nPadSize;
                mROI = saROITransform(mROI, vImgSize, nRotateThis, vTranslateThis);
            end
            if ~isempty(mROI)
                hold(hAx, 'on')
                plot(mROI(:, 1), mROI(:, 2), '.', 'markersize', 0.5, ...
                    'color', mExROIsCols(iPlotExImg == j, :))
            end
        end
    end

    % Get spline interpolated ROI
    [~, vX, vY] = roispline(mImg, 'natural');
    
    if ~isempty(vX)
        % Transform points to original image coordinates
        mROI = saROITransform([vX vY], size(mImg), -nRotate, -vTranslate, 'reverse');
        mROI(:,1) = (mROI(:,1) - nPadSize) * nResizeFact;
        mROI(:,2) = (mROI(:,2) - nPadSize) * nResizeFact;
        
        % Save new ROI coordinates
        tStack(i).(sROIName) = mROI;
    end
end

disp('saROIDraw: Done drawing ROI boundaries.')

return