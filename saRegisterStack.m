function tStack = saRegisterStack(tStack, iRefImgIndices)
% Register images in the stack consequtively to previous image in stack
%
% Image registration is done manually by viewing the previous image in
% stack in red and the current image in green. By using arrowkeys for
% translation and Z and X keys for rotation, an observer manually aligns
% the current image to the previous image in the stack. Press Enter to
% proceed to the next image in the stack.
%
% Examples:
%       iRefImg = aiGetIndicesByStain(tStack, 'Nissl');
%       tStack = aiRegisterStack(tStack, iRefImg)
%
%   where iRefImg are indices of reference images used for alignment.
%

hFig = findobj('Tag', 'saRegisterStackFigure');
if isempty(hFig)
    hFig = figure('Tag', 'saRegisterStackFigure');
end
hAx = axes();
colormap gray
f = 2;

bShowRed = true;
bShowGreen = true;

% Initialize transform of images that have none already
tTransform = struct('vTranslate', [0 0], 'nRotate', 0);
for i = iRefImgIndices(:)'
    if ~isfield(tStack, 'tTransform')
        tStack(i).tTransform = tTransform;
    end
    if isempty(tStack(i).tTransform)
    tStack(i).tTransform = tTransform;
    end
end

while 1
    iRefImg = iRefImgIndices(f - 1);
    iImg = iRefImgIndices(f);
    
    % Display a warning if this section is separated by more than 1 section
    % from the previous
    nSecDiff = tStack(iImg).nSectionNumber - tStack(iRefImg).nSectionNumber;
    if nSecDiff > 2
        warndlg(sprintf('Current section is separated by %d sections from the previous. Sections may not overlap well.', ...
            nSecDiff ))
    end
    
    if isfield(tStack, 'mImgLoRes')
        vImSize = size(tStack(iRefImg).mImgLoRes);
        mRefImg = double(tStack(iRefImg).mImgLoRes);
        mImg = double(tStack(iImg).mImgLoRes);
        nResizeFact = tStack(iImg).nResizeFact;
    else
        vImSize = size(tStack(iRefImg).mImg);
        mRefImg = double(tStack(iRefImg).mImg);
        mImg = double(tStack(iImg).mImg);
        nResizeFact = 1;
    end
        
    % Reference image
    mRefImg = mRefImg - min(mRefImg(:));
    mRefImg = mRefImg ./ max(mRefImg(:));
    
    % Image to be aligned
    mImg = mImg - min(mImg(:));
    mImg = mImg ./ max(mImg(:));
    
    % Rotate/translate image
    nRotate = tStack(iImg).tTransform.nRotate;
    vTranslate = tStack(iImg).tTransform.vTranslate(1:2) ./ nResizeFact;
    mImg = saImgTransform(mImg, nRotate, vTranslate);

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
    title(sprintf('%d/%d  Arrow keys = Translate,  [z x] = Rotate,  [1 2] = Toggle Channels,  Q = quit', ...
        tStack(iImg).nSectionNumber, max([tStack(iRefImgIndices).nSectionNumber])), ...
        'color', 'w')
    set(hFig, 'CurrentCharacter', '0', 'color', 'k')
    waitfor(hFig, 'CurrentCharacter')
    
    % User closed window
    if ~ishandle(hFig), return; end
    
    nChar = double(get(hFig, 'CurrentCharacter'));
    if isempty(nChar), continue; end
    axis(hAx, 'off')
    
    nTransStep = 2 * nResizeFact;
    nRotStep = 1;
    
    switch nChar
        case 28
            % Translate left (left arrow)
            tStack(iImg).tTransform.vTranslate(1) = tStack(iImg).tTransform.vTranslate(1) - nTransStep;
        case 29
            % Translate right (right arrow)
            tStack(iImg).tTransform.vTranslate(1) = tStack(iImg).tTransform.vTranslate(1) + nTransStep;
        case 30
            % Translate up (up arrow)
            tStack(iImg).tTransform.vTranslate(2) = tStack(iImg).tTransform.vTranslate(2) - nTransStep;
        case 31
            % Translate down (down arrow)
            tStack(iImg).tTransform.vTranslate(2) = tStack(iImg).tTransform.vTranslate(2) + nTransStep;
        case 120
            % Rotate clockwise (x)
            tStack(iImg).tTransform.nRotate = tStack(iImg).tTransform.nRotate - nRotStep;
        case 122
            % Rotate counter-clockwise (z)
            tStack(iImg).tTransform.nRotate = tStack(iImg).tTransform.nRotate + nRotStep;
        case 49
            % Toggle red image
            bShowRed = ~bShowRed;
        case 50
            % Toggle green image
            bShowGreen = ~bShowGreen;
        case 13
            % Proceed to next image pair
            f = f + 1;
            if f > numel(iRefImgIndices), break; end
        case 113 % 'q' for quit
            % Quitting returns modified results
            close(hFig);
            return
    end
    drawnow
end
close(hFig)

disp('saRegisterStack: Done registering images.')
return
