function tStack = saDistributeTransform(tStack, iIndices)
% Copy transformation parameters of indexed images I in tStack to all
% images belonging to the same section (i.e. the other color channels).
%
% Usage:
%   tStack = saDistributeTransform(tStack, I)
%
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
