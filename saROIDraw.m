function tStack = saROIDraw(tStack, sName)
% Draw boundaries around an anatomical region
%
% Examples:
%   tStack = aiROIDraw(tStack, 'SpVI')
%

hFig = figure;
hAx = axes;

sROIName = sprintf('v%sBoundary', sName);

if ~isfield(tStack, sROIName)
    tStack(1).(sROIName) = [];
end

tStack(1).(sROIName) = [];

for i = fliplr(iNissl) % work in reverse order

    mImg = double(tStack(i).mImg) - double(tStack(i).mImgMedFilt);
    
    % Pad image to avoid edge effects
    nPadSize = 500;
    mImg = padmatrix(mImg, [nPadSize nPadSize nPadSize nPadSize]);
    
    % Compute the cumulative transformation
    iI_curr = find(iNissl == i); % current index
    vTranslate = zeros(size(tStack(1).tTransform.vTranslate));
    nRotate = 0;    
    for ii = iNissl(1:iI_curr)
        nRotate = nRotate + tStack(ii).tTransform.nRotate;
        vTranslate = vTranslate + tStack(ii).tTransform.vTranslate;
    end
    
    % Rotate image
    mImg = imrotate(mImg, nRotate, 'nearest', 'crop');    
    
    % Translate image
    T = maketform('affine', [1 0 0; 0 1 0; vTranslate(1:2).*nResizeFact 1]);
    mImg = imtransform(mImg, T, 'XData',[1 size(mImg, 2)], 'YData',[1 size(mImg, 1)]);
    
    % Display smaller-version image (for speed)
    mImg = imresize(mImg, 1/nResizeFact);
    
    % Display and get ROI
    clf(hFig)
    imagesc(mImg)
    colormap gray
    axis image
    title('Down = green, Up = red')

    % Plot ROI of previous image
    i_previous = find(iNissl == i) - 1;
    if i_previous > 0
        iPrevious = iNissl(i_previous);
        vX = tStack(iPrevious).(sROIName)(:,1) ./ nResizeFact;
        vY = tStack(iPrevious).(sROIName)(:,2) ./ nResizeFact;
        if ~isempty(vX)
            hold on
            plot(vX, vY, 'g--')
        end
    end

    % Plot ROI of next image
    i_next = find(iNissl == i) + 1;
    if i_next <= length(iNissl)
        iNext = iNissl(i_next);
        vX = tStack(iNext).(sROIName)(:,1) ./ nResizeFact;
        vY = tStack(iNext).(sROIName)(:,2) ./ nResizeFact;
        if ~isempty(vX)
            hold on
            plot(vX, vY, 'r--')
        end
    end

    % Get spline interpolated ROI
    [~, vX, vY] = roispline(mImg, 'natural');
    
    if ~isempty(vX)
        vX = vX * nResizeFact;
        vY = vY * nResizeFact;
        tStack(i).(sROIName)(:,1) = vX(:);
        tStack(i).(sROIName)(:,2) = vY(:);
    end
end

disp('saROIDraw: Done drawing SpVi boundaries.')

return