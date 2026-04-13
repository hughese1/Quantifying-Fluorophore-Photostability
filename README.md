# Quantifying-Fluorophore-Photostability
Analysis pipeline for quantifying fluorophore photostability. The purpose of this pipeline is to extract information about the photon budget of different fluorophores using data from the project-specific ring TIRF scope. This is done by detecting and tracking fluorophores, then reconstructing PSFs for each particle to calculate an expectation value for the total photons emitted over a given fluorophore’s lifetime.

# 1. Camera Characterization 
Overview: In order to proceed with data processing and analysis, an initial step of camera characterization must be done to calculate the pixel dependent offset, variance, and gain of the system using the methods described by Huang et al ([Video-rate nanoscopy using sCMOS camera–specific single-molecule localization algorithms | Nature Methods](https://www.nature.com/articles/nmeth.2488)). These calculations are done automatically with the provided “CameraCharacterization.m” MATLAB script, or can be done by the user’s preferred method.



1.	Camera offset and camera variance are calculated from 10,000 dark images. Camera offset is measured per-pixel as the average readout over these 10,000 dark images, and variance is measured per-pixel as the variance of these images.

<img width="902" height="534" alt="image" src="https://github.com/user-attachments/assets/34208785-8b09-4fde-95bc-1838fc59ec2b" />

2. Per-pixel gain is calculated from the sequences of images collected at varied incident intensity by measuring the per-pixel average and per-pixel variance at each intensity level, then calculating the slope of the variance versus mean at each pixel.
 <img width="975" height="441" alt="image" src="https://github.com/user-attachments/assets/4315e8d6-2b8a-45dc-9a8e-92cc12035095" />

# To run the script,
1. Download "CameraCharacterization" and keep contents saved together in that folder.
2. 2.	Open “CameraCharacterization.m” and update variable “allthefolders” to the path to your directory where your data is stored. Expected format is a folder of subfolders, one for each brightness level, titled such that the lowest number corresponds to the dark counts data (for example, “images100cts,” “images_500cts,” etc.  Each subfolder is expected to contain multipage tif files (directly output from the microscope).

<img width="1153" height="537" alt="image" src="https://github.com/user-attachments/assets/b58ff3bf-c5d3-4432-a039-a8673a861586" />

3.	Update paths for outputs: Outpath_offset, outpath_var, and offset_gain are the paths for saving files for each calculation. Update to where you would like this data stored. The offset, variance, and gain maps will also be saved to “cameracalibration.mat” in the folder containing the script.
<img width="951" height="105" alt="image" src="https://github.com/user-attachments/assets/541b3d0e-54ff-46ea-b201-4cde00b1af0f" />

4. Run script.
   <img width="116" height="110" alt="image" src="https://github.com/user-attachments/assets/eae789c6-ce99-4868-9ddc-571034f374f5" />
   
When complete, the gain, offset, and variance maps will all be saved as tifs as well as in the .mat file. Some other figure windows will also appear:
a.	A figure showing a side by side display of the offset, variance, and gain.
b.	A plot of variance versus gain for a single pixel. This is to assess the linearity / fit. If the plot does not look linear, there may have been a problem with data acquisition.





