# T1T2

**by Tim J. Hartung, Darko Komnenic, Graham Cooper, Valentin Jünger, Michael Scheel and Carsten Finke**
*Charité - Universitätsmedizin Berlin*
*August 2023*

This is a fully automated script to derive the standardized T1-weighted / T2-weighted (T1T2) ratio from T1-weighted and T2-weighted brain MRI images. It serves as a proof of concept that fast and automated T1T2 value extraction is possible.

**The curent version is intended for testing purposes only.**

## 1 Installation

### Required Software

The script uses commands from Advanced Normalization Tools (ANTs) and FMRIB Software Library (FSL).

To install ANTs, follow instructions the [ANTs github](http://stnava.github.io/ANTs/)

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
  - one nifti file for the T2-weighted MR
- directory name = subject ID
