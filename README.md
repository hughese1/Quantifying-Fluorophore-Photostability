# Quantifying-Fluorophore-Photostability
Analysis pipeline for quantifying fluorophore photostability. 

# 1. Camera Characterization 
Overview: In order to proceed with data processing and analysis, an initial step of camera characterization must be done to calculate the pixel dependent offset, variance, and gain of the system using the methods described by Huang et al ([Video-rate nanoscopy using sCMOS camera–specific single-molecule localization algorithms | Nature Methods](https://www.nature.com/articles/nmeth.2488)). These calculations are done automatically with the provided “CameraCharacterization.m” MATLAB script, or can be done by the user’s preferred method.

To run the attached script,

1.	Camera offset and camera variance are calculated from 10,000 dark images. Camera offset is measured per-pixel as the average readout over these 10,000 dark images, and variance is measured per-pixel as the variance of these images. 
