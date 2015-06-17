function tStack = saGetResizedImg(tStack, nResizeFact)
% Create low-resolution version of image
%
% This lower resolution version is used, when available, by other functions
% to speed up rotation, translation, clicking operations etc.
%

fprintf('saGetResizedImg: Resizing %d images...\n', length(tStack))

for i = 1:length(tStack)
    fprintf ('Resizing image %d / %d \r', i, numel(tStack))
    tStack(i).mImgLoRes = imresize(tStack(i).mImg, 1/nResizeFact);
    tStack(i).nResizeFact = nResizeFact;
end

fprintf('\nsaGetResizedImg: Done resizing %d images.\n', i)

return
