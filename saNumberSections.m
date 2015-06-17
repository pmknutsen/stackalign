function tStack = saNumberSections(tStack)
% Add a field to image stack that indicates the cumulative section number
%
% The function assumes that section numbers start at 1.
%
% If the stack extends over multiple slides, it will ask for the total
% number of sections on each slide.
%
% The function will ask what the section step length is, i.e. for each
% mounted section how many were discarded?
%

% Get cumulative section numbers
mSlideSection = [[tStack.nSlide]' [tStack.nSection]'];

vUniqSlides = unique(mSlideSection(:, 1));

nCumTotal = 0;
for i = 1:numel(vUniqSlides)
    iSlide = vUniqSlides(i);
    
    iThisSlide = mSlideSection(:, 1) == iSlide;
    
    mSlideSection(iThisSlide, 3) = mSlideSection(iThisSlide, 2) + nCumTotal;

    if i < numel(vUniqSlides)
        nCumTotal = nCumTotal + input(sprintf('How many sections on slide %d? ', iSlide));
    end
    
end

% Get number of skipped sections
nSkipStep = input('How many sections were discarded between each mounted section? ');
mSlideSection(:, 3) = mSlideSection(:, 3) .* (nSkipStep + 1);

% Distribute section numbers
for i = 1:length(tStack)
    tStack(i).nSectionNumber = mSlideSection(i, 3);
end

disp('saNumberSections: Done computing section numbering.')

return