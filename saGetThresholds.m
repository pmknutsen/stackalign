function tStack = saGetThresholds(tStack)
% Get thresholds manually
%
% TODO Ask for channel interactively
%


% Get indices of tdTomato and BS images
iTom = find(strcmpi({tStack.sStain}, 'tdTom'));
iBS = find(strcmpi({tStack.sRegion}, 'BS'));
iTom = intersect(iTom, iBS);

hFig = figure;
hAx = axes();
colormap gray

hFig(2) = figure;
hAx(2) = axes();

hFig(3) = figure;
hAx(3) = axes();
colormap gray

set(hAx, 'position', [0 0 1 1])

vTranslate = zeros(size(tStack(1).tTransform.vTranslate));
nRotate = 0;
mStack = [];
if ~isfield(tStack, 'nBWLevel')
    tStack(1).nBWLevel = [];
end
for iImg = iTom
    
    % Get image and subtract median filtered image
    mImg = double(tStack(iImg).mImg);
    mImgMedFilt = tStack(iImg).mImgMedFilt;
    mImg = mImg - mImgMedFilt;
    
    figure(hFig(3))
    imagesc(mImg)
    
    % Normalize image
    mImg = mImg - min(mImg(:));
    mImg = mImg ./ max(mImg(:));
    
    % Threshold automatically
    if isempty(tStack(iImg).nBWLevel)
        tStack(iImg).nBWLevel = graythresh(mImg);
    end
    
    % Adjust threshold manually
    while 1
        mBW = im2bw(mImg, tStack(iImg).nBWLevel);
        
        % Remove objects larger than 10 pixels
        
        % Remove single pixels
        mBW = xor(bwareaopen(mBW, 1),  bwareaopen(mBW, 200));
        
        hIm = imagesc(mBW, 'parent', hAx(1));
        axis image
        mBW = bwareaopen(mBW, 3);
        figure(hFig(1))
        
        % Wait for user key press
        %   Up arrow  - increase threshold
        %   Up arrow  - decrease threshold
        %   Enter     - next image pair
        set(hFig(1), 'CurrentCharacter', '0')
        waitfor(hFig(1), 'CurrentCharacter')
        nChar = double(get(hFig(1), 'CurrentCharacter'));
        switch nChar
            case 30
                % Increase threshold (up arrow)
                tStack(iImg).nBWLevel = tStack(iImg).nBWLevel + .01;
            case 31
                % Decrease threshold (down arrow)
                tStack(iImg).nBWLevel = tStack(iImg).nBWLevel - .01;
            case 13
                % Proceed to next image pair
                break
        end
    end
    
    % Pad image to avoid edge effects
    mBW = padmatrix(mBW, [nPadSize nPadSize nPadSize nPadSize]);
    
    % Compute cumulative transformation values
    nRotate = nRotate + tStack(iImg).tTransform.nRotate;
    vTranslate = vTranslate + tStack(iImg).tTransform.vTranslate;
    
    % Rotate image
    mBW = imrotate(mBW, nRotate, 'nearest', 'crop');    
    
    % Translate image
    T = maketform('affine', [1 0 0; 0 1 0; vTranslate(1:2).*nResizeFact 1]);
    mBW = imtransform(mBW, T, 'XData',[1 size(mBW, 2)], 'YData',[1 size(mBW, 1)]);
    
    tStack(iImg).mBW = sparse(mBW);
    
    if isempty(mStack)
        mStack = mBW;
    else
        mStack(:, :, end+1) = mBW;
    end
    
    hIm = imagesc(mBW, 'parent', hAx(1));
    axis image
    
    % Display labeled pixels in 3D
    [iY iX] = find(mBW);
    vRand = rand(numel(iX), 1) - 1;
    iZ = ones(numel(iX), 1) .* find(iTom == iImg) + vRand;
    
    hold(hAx(2), 'on')
    axes(hAx(2))
    plot3(iX, iY, iZ, 'k.', 'markersize', 1)
    axis square
    view(3)
    axes(hAx(1))
    
    drawnow
end

return
