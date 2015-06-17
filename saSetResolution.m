function tStack = saSetResolution(tStack)
% Set image resolution
%
%

nPixMM = input('How many pixels per mm? ');

for i = 1:length(tStack)
    tStack(i).nPixelsMM = nPixMM;
end

disp('saSetResolution: Done setting resolution on all images.')

return