function tStack = saSaveStack(tStack)
% Save image stack and results

disp('saSaveStack: Saving image stack...')
sResultsFile = 'sa_image_stack.mat';

save(sResultsFile, 'tStack', '-V7.3');

fprintf('saSaveStack: Saved image stack in folder %s\n', pwd)

return