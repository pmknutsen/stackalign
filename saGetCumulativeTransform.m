function tStack = saGetCumulativeTransform(tStack)
% Compute the cumulative transformation parameters (rotation and
% translation) of all sorted sections.
%
% Usage:
%   tStack = saGetCumulativeTransform(tStack)
%
% This function will call saNumberSections() if sections have not already
% been sorted.
%
% The function saDistributeTransform() must be run first.
%

% Get section numbers if not already known
if ~isfield(tStack, 'nSectionNumber')
    tStack = saNumberSections(tStack);
end

% Abort if any of the images have an empty transformation structure
for i = 1:numel(tStack)
    if isempty(tStack(i).tTransform)
        printf('saGetCumulativeTransform: Image %d has no transform parameters. You must run saDistributeTransfor() first.', i)
        return
    end
end

% Iterate over ordered sections
iSectionNums = [tStack.nSectionNumber];

nRotation = 0;
vTranslation = [0 0];
for iNum = unique(iSectionNums)
    iThisSection = iSectionNums == iNum;

    % Assume tTransform is same for all channels
    tTransform = [tStack(iThisSection).tTransform];
    tTransform = tTransform(1);
    
    nRotation = nRotation + tTransform.nRotate;
    vTranslation = vTranslation + tTransform.vTranslate;

    tTransform.nCumRotate = nRotation;
    tTransform.vCumTranslate = vTranslation;
    
    [tStack(iThisSection).tTransform] = deal(tTransform);
end

disp('saGetCumulativeTransform: Computed cumulative stack transformation.')

return
