function tStack = saConvertToUINT16(tStack)
% Convert all images to uint16
for i = 1:numel(tStack)
    tStack(i).mImg = uint16(tStack(i).mImg);
end

disp(sprintf('saConvertToUINT16: Converted %d images to UINT16.', i))
return
