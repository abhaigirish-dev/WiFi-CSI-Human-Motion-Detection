# Wi-Fi CSI Based Human Motion Detection

## Project Overview

This project investigates human motion detection and activity classification using Wi-Fi Channel State Information (CSI).

The system processes CSI data using Digital Signal Processing (DSP) techniques and extracts features for Machine Learning based activity classification.

## System Pipeline

Wi-Fi CSI Dataset
        ↓
CSI Data Loading
        ↓
Amplitude Extraction
        ↓
Signal Preprocessing
        ↓
DSP Filtering
        ↓
Feature Extraction
        ↓
Machine Learning
        ↓
Human Activity Classification

## DSP Processing

The CSI data is converted from complex values into amplitude information.

The signal is then processed using:

- Median filtering
- Butterworth low-pass filtering
- Frequency-domain analysis / FFT

These operations reduce noise and highlight motion-related variations in the CSI signal.

## Feature Extraction

Features are extracted from the processed CSI signals.

The feature set includes time-domain and frequency-domain characteristics such as:

- Mean
- Standard deviation
- Variance
- RMS
- Peak-to-peak value
- Dominant frequency
- Spectral energy
- Spectral centroid
- Spectral entropy

## Machine Learning

The extracted CSI features are used for activity classification.

The Phase 1 implementation includes machine-learning classification and evaluation using the prepared training and testing data.

## Activities

The project focuses on human activity classes including:

- Sit Still
- Walking
- Falling

## Project Files

### MATLAB
Contains the final MATLAB result data.

### DSP
Contains DSP-related project material.

### ML
Contains machine-learning related project material.

### Hardware
Contains the live-motion / hardware implementation files.

### Figures
Contains experimental results and plots.

### Presentation
Contains the project presentation.

## Phase 1 Result

The final MATLAB result file contains the processed CSI data, extracted features, training/testing data, classifier information, predictions and evaluation results.

## Future Hardware Implementation

The next stage is implementation using two ESP32 boards for Wi-Fi CSI acquisition and real-time human motion detection.

## Project Status

- [x] CSI dataset processing
- [x] Amplitude extraction
- [x] DSP preprocessing
- [x] Feature extraction
- [x] Machine learning classification
- [x] Result visualization
- [ ] ESP32 hardware integration
- [ ] Real-time hardware classification
