function tStack = saGetResizedImg(tStack, nResizeFact)
% Create low-resolution version of image
%
% This lower resolution version is used, when available, by other functions
% to speed up rotation, translation, clicking operations etc.
%

for i = 1:length(tStack)
    tStack(i).mImgLoRes = imresize(tStack(i).mImg, 1/nResizeFact);
    tStack(i).nResizeFact = nResizeFact;
end

disp('saGetResizedImg: Done resizing images.')

return
