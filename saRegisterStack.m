function tStack = saRegisterStack(tStack)
% Register images in the stack consequtively to previous image in stack
%
% Examples:
%   Register all images
%       tStack = aiRegisterStack(tStack)
%
%   Register images with a particular stain:
%       iNissl = aiGetIndicesByStain(tStack, 'Nissl');
%       tStack = aiRegisterStack(tStack(iNissl))
%

hFig = findobj('Tag', 'aiRegisterStackFigure');
if isempty(hFig)
    hFig = figure('Tag', 'aiRegisterStackFigure');
end
hAx = axes();
colormap gray
f = 2;

tTransform = struct('vTranslate', [0 0], 'nRotate', 0);
bShowRed = true;
bShowGreen = true;
tStack(1).tTransform = tTransform; % zero transform of first image

while 1
    iRefImg = f-1;
    iImg = f;
    
    if isfield(tStack, 'mImgLoRes')
        vImSize = size(tStack(iRefImg).mImgLoRes);
        mRefImg = double(tStack(iRefImg).mImgLoRes);
        mImg = double(tStack(iImg).mImgLoRes);
    else
        vImSize = size(tStack(iRefImg).mImg);
        mRefImg = double(tStack(iRefImg).mImg);
        mImg = double(tStack(iImg).mImg);
    end
    
    if isempty(tStack(iImg).tTransform)
        tStack(iImg).tTransform = tTransform;
    end
    
    % Reference image
    mRefImg = mRefImg - min(mRefImg(:));
    mRefImg = mRefImg ./ max(mRefImg(:));
    
    % Image to be aligned
    mImg = mImg - min(mImg(:));
    mImg = mImg ./ max(mImg(:));
    
    % Rotate/translate image
    nRotate = tStack(iImg).tTransform.nRotate;
    vTranslate = tStack(iImg).tTransform.vTranslate(1:2);
    mImg = aiImgTransform(mImg, nRotate, vTranslate);

    % Combine as RGB
    clear mRGB
    if bShowRed
        mRGB(:,:,1) = mRefImg;
    else
        mRGB(:,:,1) = zeros(vImSize);
    end
    if bShowGreen
        mRGB(:,:,2) = mImg;
    else
        mRGB(:,:,2) = zeros(vImSize);
    end
    mRGB(:,:,3) = zeros(vImSize);
    
    hIm = image(mRGB);
    axis image
    
    % Wait for user key press
    %   Arrows  - translation
    %   z, x    - rotation
    %   1, 2    - toggle display of red/green image
    %   Enter   - next image pair
    title('Arrow keys = Translate,  [z x] = Rotate,  [1 2] = Toggle Channels', 'color', 'w')
    set(hFig, 'CurrentCharacter', '0', 'color', 'k')
    waitfor(hFig, 'CurrentCharacter')
    nChar = double(get(hFig, 'CurrentCharacter'));
    axis(hAx, 'off')
    
    switch nChar
        case 28
            % Translate left (left arrow)
            tStack(iImg).tTransform.vTranslate(1) = tStack(iImg).tTransform.vTranslate(1) - 5;
        case 29
            % Translate right (right arrow)
            tStack(iImg).tTransform.vTranslate(1) = tStack(iImg).tTransform.vTranslate(1) + 5;
        case 30
            % Translate up (up arrow)
            tStack(iImg).tTransform.vTranslate(2) = tStack(iImg).tTransform.vTranslate(2) - 5;
        case 31
            % Translate down (down arrow)
            tStack(iImg).tTransform.vTranslate(2) = tStack(iImg).tTransform.vTranslate(2) + 5;
        case 120
            % Rotate clockwise (x)
            tStack(iImg).tTransform.nRotate = tStack(iImg).tTransform.nRotate - 2;
        case 122
            % Rotate counter-clockwise (z)
            tStack(iImg).tTransform.nRotate = tStack(iImg).tTransform.nRotate + 2;
        case 49
            % Toggle red image
            bShowRed = ~bShowRed;
        case 50
            % Toggle green image
            bShowGreen = ~bShowGreen;
        case 13
            % Proceed to next image pair
            f = f + 1;
            if f > length(tStack), break; end
    end
    drawnow
end
disp('saRegisterStack: Done registering images.')
close(hFig)
return
