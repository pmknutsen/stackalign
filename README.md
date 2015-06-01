###StackAlign

StackAlign is a Matlab toolbox for aligning images in a stack. It is primarily intended to align low-resolution images taken with a standard, fluorescence microscope.

StackAlign can perform some basic image processing and analysis functions such as:

* Thresholding (e.g. for locating regions of fluorescence)
* ROI selection
* 3D displays of ROIs and thresholded images

StackAlign is work-in-progress.


###Documentation

####Filename conventions
StackAlign always works in the current directory. Use the cd() command to change directory before running any of the StackAlign functions.

It is assumed that all image files in the current directory belong to the same image stack, and that they have the following filename structure:

Speciment_Region_Slide_Section_Stain.tiff

Example: CX34_BS_1_08_Nissl.tiff


####Toolbox functions
saLoadStack                   Load images in current directory
saConvertToUINT16             Convert all images to UINT16
saSortStack                   Sort stack by slide and section number
saRegisterStack               Register images in stack (translation, rotation)
saMedianFilterImg             Median filter images
saDistributeTransform         Distribute transformation parameters
saDistributeTransform  
saROIDraw               
saGetThresholds



