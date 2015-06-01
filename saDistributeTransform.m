function tStack = saDistributeTransform(tStack, iIndices)
% Distribute transformation parameters of Ith images to same-channel images
%
%   tStack = saDistributeTransform(tStack, I)
%
%

for i = iIndices
    nSlide = tStack(i).nSlide;
    nSection = tStack(i).nSection;
    iSlide = find([tStack.nSlide] == nSlide);
    iSection = find([tStack.nSection] == nSection);
    iOtherChannels = setdiff(intersect(iSlide, iSection), i);

    for j = iOtherChannels
        tStack(j).tTransform = tStack(i).tTransform;
    end
    
end

disp('saDistributeTransform: Done distributing parameters.')

return
