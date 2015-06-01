function tStack = saSaveStack(tStack)
% Save image stack and results

disp('aiSaveStack: Saving image stack...')
sResultsFile = 'ai_image_stack.mat';

save(sResultsFile, 'tStack', '-V7.3');

fprintf('saSaveStack: Saved image stack in folder %s\n', pwd)

return