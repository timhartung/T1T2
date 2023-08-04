# T1T2

**by Tim J. Hartung, Darko Komnenic, Graham Cooper, Valentin Jünger, Michael Scheel and Carsten Finke**

*Charité - Universitätsmedizin Berlin*

*August 2023*


This is a fully automated script to derive the standardized T1-weighted / T2-weighted (T1T2) ratio from T1-weighted and T2-weighted brain MRI images. It serves as a proof of concept that fast and automated T1T2 value extraction is possible. The concept and general outline of the pipeline follows the method as described by Cooper et al. 

**The curent version is intended for testing purposes only.**

## 1 Installation

### Required Software

The script uses commands from Advanced Normalization Tools (ANTs) and FMRIB Software Library (FSL).

To install ANTs, follow instructions the [ANTs github](http://stnava.github.io/ANTs/).

To install FSL, follow instructions on the [FSL wiki](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation).


### Recommended Software Versions

The script has been developed and tested with the following software versions:
- Ubuntu 20.04
- ANTs 2.4.4
- FSL 6.0.5


## 2 Setup

The script extracts T1T2 values for specified regions from a single human subject. We recommend the following folder structure:
- one folder per subject, containing:
  - one nifti file for the T1-weighted MR image
  - one nifti file for the T2-weighted MR image
- directory name = subject ID


## 3 Using the script

1. On a Linux or Mac OS system, open a terminal and navigate to the directory where the script is located:
`cd /path/to/script/location`
2. Execute the script:
`bash T1T2_script.sh`
3. You will then be prompted to:
   a. provide the path to the subject directory
   b. provide the file name of the T1w nifti file
   c. provide the file name of the T2w nifti file
   d. choose a set of regions of interest (ROIs; white matter only OR white matter and deep gray matter structures)


## 4 Results

The script will print the T1T2 values for selected to the terminal. It also creates a log file (T1T2_log.txt) in the subject folder, which includes the T1T2 ratio median and interquartile range for each ROI.

