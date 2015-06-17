function tStack = saConvertToUINT16(tStack)
% Convert all images to uint16
%
% Converts raw, low-resolution and median filtered images to UINT16.
%

for i = 1:numel(tStack)
    tStack(i).mImg = uint16(tStack(i).mImg);
    if isfield(tStack, 'mImgLoRes')
        tStack(i).mImgLoRes = uint16(tStack(i).mImgLoRes);
    end
    if isfield(tStack, 'mImgMedFilt')
        tStack(i).mImgMedFilt = uint16(tStack(i).mImgMedFilt);
    end
end

disp(sprintf('saConvertToUINT16: Converted %d images to UINT16.', i))

return
