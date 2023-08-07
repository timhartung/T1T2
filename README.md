# T1T2

**by Tim J. Hartung, Darko Komnenic, Graham Cooper, Valentin Jünger, Michael Scheel and Carsten Finke**

*Charité - Universitätsmedizin Berlin*

*August 2023*
  
## Introduction
 
This is a fully automated script to derive the standardized T1-weighted / T2-weighted (T1T2) ratio from T1-weighted and T2-weighted brain MRI images. It serves as a proof of concept that fast and automated T1T2 value extraction is possible. The pipeline was adapted from Cooper and colleagues.[^1] We used the standardization method by Misaki and colleagues.[^2]

**The curent version is intended FOR TESTING PURPOSES ONLY.**

## 1. Installation

### Required Software

The script uses commands from Advanced Normalization Tools (ANTs) and FMRIB Software Library (FSL).

- To install ANTs, follow instructions on the [ANTs github](http://stnava.github.io/ANTs/).
- To install FSL, follow instructions on the [FSL wiki](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation).


### Recommended Software Versions

The script has been developed and tested with the following software versions:
- Ubuntu 20.04
- ANTs 2.4.4
- FSL 6.0.5


## 2. Setup

The script extracts T1T2 values for specified regions from a single human subject. We recommend the following folder structure:
- one folder per subject, containing:
  - one nifti file for the T1-weighted MR image
  - one nifti file for the T2-weighted MR image
- directory name = subject ID


## 3. Usage

1. On a Linux or Mac OS system, open a terminal and navigate to the directory where the script is located:
`cd /path/to/script/location`
2. Execute the script:
`bash T1T2_script.sh`
3. You will then be prompted to:

    1. provide the path to the subject directory
    2. provide the file name of the T1w nifti file
    3. provide the file name of the T2w nifti file
    4. choose a set of regions of interest (ROIs; white matter only OR white matter and deep gray matter structures)


## 4. Results

The script will print the T1T2 values for selected ROIs to the terminal. It also creates a log file (T1T2_log.txt) in the subject folder, which includes the T1T2 ratio median and interquartile range for each ROI.

The results are to be treated with caution for the following reasons:

- There are currently no normative values from healthy population samples.
- This version of the script does not contain lesion masking. If your participants have localized brain lesions, the values are biased as a result.
- There are no automated quality checks for segmentation. Please check the ROI masks that are stored in the subdirectory "masks" in each subject folder. If the segmentation is incorrect, the T1T2 values are likely to also be incorrect.

## 5. Alternative Strategies

This script is meant to be fast and easy to use. In research settings, more elaborate methods may be chosen. We currently suggest considering the following alternatives:

- [Freesurfer](https://surfer.nmr.mgh.harvard.edu/) recon-all (instead of FSL SIENAX and FIRST) for more fine-grained and precise segmentation.
- For clinical samples: Automatic lesion segmentation, e.g. using [LST](https://www.statistical-modelling.de/lst.html).
- Spatial transformation to a position which is halfway between the T1w and T2w image to ensure that both images undergo equivalent processing steps.

[^1]: Cooper, G., Finke, C., Chien, C., Brandt, A. U., Asseyer, S., Ruprecht, K., Bellmann-Strobl, J., Paul, F., & Scheel, M. (2019). Standardization of T1w/T2w Ratio Improves Detection of Tissue Damage in Multiple Sclerosis. Frontiers in Neurology, 10, 334. (https://doi.org/10.3389/fneur.2019.00334)

[^2]: Misaki, M., Savitz, J., Zotev, V., Phillips, R., Yuan, H., Young, K. D., Drevets, W. C., & Bodurka, J. (2015). Contrast enhancement by combining T1- and T2-weighted structural brain MR Images: Contrast Enhancement with T1w and T2w MRI. Magnetic Resonance in Medicine, 74(6), 1609–1620. (https://doi.org/10.1002/mrm.25560)
