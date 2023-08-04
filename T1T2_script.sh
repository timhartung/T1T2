#!/bin/bash


echo "-----------------------------------------------------------------------------"
echo "T1T2 Processing Script by Hartung, Komnenic, Cooper, Junger, Scheel and Finke"
echo "-----------------------------------------------------------------------------"
echo ""
echo "Please provide file paths and choose ROIs below."
echo ""

# subject_dir="/mnt/HDD/T1T2_pipeline/test_all"
# t1_file="LE_NMDA_117_1_T1w.nii"
# t2_file="LE_NMDA_117_1_T2w.nii"


# Prompt for subject directory path
read -p "Path to subject directory: " subject_dir

# Prompt for T1w nifti file name
read -p "File name of T1w nifti file: " t1_file

# Prompt for T2w nifti file name
read -p "File name of T2w nifti file: " t2_file

# Prompt for region of interest (ROI)
echo ""
echo "Select Region of Interest (ROI):"
echo "1. White matter only (faster)"
echo "2. White matter + deep gray matter (slower)"
read -p "Enter your choice (1/2): " roi_choice

# Check if the last character in subject_dir is a slash
if [[ "${subject_dir}" == */ ]]; then
    # Remove the last slash if needed
    subject_dir="${subject_dir%/}"
fi

# Check if files exist in subject_dir
echo ""
echo "Checking files:"

function check_file_existence() {
    local file_to_check="${subject_dir}/${1}"
    if [[ -e "${file_to_check}" ]]; then
        return 0
    fi
    return 1
}

if [[ "${t1_file}" == *.nii || "${t1_file}" == *.nii.gz ]]; then
    # Check if the exact file exists in subject_dir
    if check_file_existence "${t1_file}"; then
        echo "T1w nifti file found: ${t1_file}"
    else
        echo "T1w nifti file not found in ${subject_dir}"
    fi
else
    # Check if the file with ".nii" extension exists in subject_dir
    if check_file_existence "${t1_file%.nii}.nii"; then
        echo "T1w nifti file found with .nii extension: ${t1_file%.nii}.nii"
        t1_file="${t1_file}.nii"
    else
        # Check if the file with ".nii.gz" extension exists in subject_dir
        if check_file_existence "${t1_file%.nii.gz}.nii.gz"; then
            echo "T1w nifti file found with .nii.gz extension: ${t1_file%.nii.gz}.nii.gz"
            t1_file="${t1_file}.nii.gz"
        else
            echo "T1w nifti file not found in ${subject_dir}"
        fi
    fi
fi

if [[ "${t2_file}" == *.nii || "${t2_file}" == *.nii.gz ]]; then
    # Check if the exact file exists in subject_dir
    if check_file_existence "${t2_file}"; then
        echo "T1w nifti file found: ${t2_file}"
    else
        echo "T1w nifti file not found in ${subject_dir}"
    fi
else
    # Check if the file with ".nii" extension exists in subject_dir
    if check_file_existence "${t2_file%.nii}.nii"; then
        echo "T1w nifti file found with .nii extension: ${t2_file%.nii}.nii"
        t2_file="${t2_file}.nii"
    else
        # Check if the file with ".nii.gz" extension exists in subject_dir
        if check_file_existence "${t2_file%.nii.gz}.nii.gz"; then
            echo "T1w nifti file found with .nii.gz extension: ${t2_file%.nii.gz}.nii.gz"
            t2_file="${t2_file}.nii.gz"
        else
            echo "T1w nifti file not found in ${subject_dir}"
        fi
    fi
fi

echo ""

# Initialize arrays for different ROIs
declare -a rois=()

# Declare ROI key-value associations for FIRST output
declare -A roi_lut=(
    ["L_Thal"]=10
    ["L_Caud"]=11
    ["L_Puta"]=12
    ["L_Pall"]=13
    ["L_Hipp"]=17
    ["L_Amyg"]=18
    ["R_Thal"]=49
    ["R_Caud"]=50
    ["R_Puta"]=51
    ["R_Pall"]=52
    ["R_Hipp"]=53
    ["R_Amyg"]=54
)



# Create subject ID from folder name
id=${subject_dir##*/} # retain the part after the last slash


# Start Processing 
echo ""
echo "-----------------------------------------"
echo "--- T1T2 Processing for ${id} ---"
echo "-----------------------------------------"


echo "-----------------------------------" > ${subject_dir}/T1T2_log.txt
echo "--- T1T2 Log for ${id} ---" >> ${subject_dir}/T1T2_log.txt
echo "-----------------------------------" >> ${subject_dir}/T1T2_log.txt
echo "Processing started at:" >> ${subject_dir}/T1T2_log.txt
date +"%F %T" >> ${subject_dir}/T1T2_log.txt
echo "" >> ${subject_dir}/T1T2_log.txt
echo "" >> ${subject_dir}/T1T2_log.txt


# Write the entered values to log
echo "Subject Directory: $subject_dir" >> ${subject_dir}/T1T2_log.txt
echo "T1w Nifti File: $t1_file" >> ${subject_dir}/T1T2_log.txt
echo "T2w Nifti File: $t2_file" >> ${subject_dir}/T1T2_log.txt
echo "" >> ${subject_dir}/T1T2_log.txt

# Step 1: Bias field correction

echo ""
echo "Step 1/9: Bias field correction for T1w and T2w images."

N4BiasFieldCorrection -d 3 -v 0 -s 4 -b [ 180 ] -c [ 50x50x50x50, 0.0 ] -i ${subject_dir}/$t1_file -o [ ${subject_dir}/${id}_T1w_biascor.nii.gz, ${subject_dir}/${id}_T1w_biasfield.nii.gz ]
N4BiasFieldCorrection -d 3 -v 0 -s 4 -b [ 180 ] -c [ 50x50x50x50, 0.0 ] -i ${subject_dir}/$t2_file -o [ ${subject_dir}/${id}_T2w_biascor.nii.gz, ${subject_dir}/${id}_T2w_biasfield.nii.gz ]

if [[ -e "${subject_dir}/${id}_T1w_biascor.nii.gz" ]] && \
   [[ -e "${subject_dir}/${id}_T2w_biascor.nii.gz" ]]; then
    echo "[$(date +"%H:%M:%S")] Step 1/9: Successfully applied bias field correction for T1w and T2w images (ANTS N4BiasFieldCorrection)." >> "${subject_dir}/T1T2_log.txt"
    echo "" >> "${subject_dir}/T1T2_log.txt"
else
    echo "[$(date +"%H:%M:%S")] Step 1/9: ERROR - Bias field correction for T1w and T2w images failed (ANTS N4BiasFieldCorrection)." >> "${subject_dir}/T1T2_log.txt"
    exit 1
fi




# Step 2: Robust FOV

echo ""
echo "Step 2/9: Applying robust field of view."

robustfov -i ${subject_dir}/${id}_T1w_biascor.nii.gz -r ${subject_dir}/${id}_T1w_robustfov.nii.gz
robustfov -i ${subject_dir}/${id}_T2w_biascor.nii.gz -r ${subject_dir}/${id}_T2w_robustfov.nii.gz

if [[ -e "${subject_dir}/${id}_T1w_robustfov.nii.gz" ]] && \
   [[ -e "${subject_dir}/${id}_T2w_robustfov.nii.gz" ]]; then
    echo "[$(date +"%H:%M:%S")] Step 2/9: Successfully applied robust field of view to bias field corrected T1w and T2w images (FSL robustfov).">> ${subject_dir}/T1T2_log.txt
    echo "" >> "${subject_dir}/T1T2_log.txt"
else
    echo "[$(date +"%H:%M:%S")] Step 2/9: ERROR - Application of robust field of view failed (FSL robustfov).">> ${subject_dir}/T1T2_log.txt
    exit 1
fi


# Step 3: Reorient to standard
echo ""
echo "Step 3/9: Reorienting to standard."

fslreorient2std ${subject_dir}/${id}_T1w_robustfov.nii.gz ${subject_dir}/${id}_T1w_reoriented.nii.gz
fslreorient2std ${subject_dir}/${id}_T2w_robustfov.nii.gz ${subject_dir}/${id}_T2w_reoriented.nii.gz

if [[ -e "${subject_dir}/${id}_T1w_reoriented.nii.gz" ]] && \
   [[ -e "${subject_dir}/${id}_T2w_reoriented.nii.gz" ]]; then
    echo "[$(date +"%H:%M:%S")] Step 3/9: Successfully reoriented corrected and cropped T1w and T2w images to standard (FSL fslreorient2std).">> ${subject_dir}/T1T2_log.txt
    echo "" >> "${subject_dir}/T1T2_log.txt"
else
    echo "[$(date +"%H:%M:%S")] Step 3/9: ERROR - Reorienting to standard failed (FSL fslreorient2std).">> ${subject_dir}/T1T2_log.txt
    exit 1
fi



# Step 4: Coregistration

echo ""
echo "Step 4/9: Coregistering T2w image to T1w image."

flirt -in ${subject_dir}/${id}_T2w_reoriented.nii.gz  -ref ${subject_dir}/${id}_T1w_reoriented.nii.gz -out ${subject_dir}/${id}_T2w_coregistered.nii.gz

if [[ -e "${subject_dir}/${id}_T2w_coregistered.nii.gz" ]]; then
    echo "[$(date +"%H:%M:%S")] Step 4/9: Successfully coregistered T2w image to T1w image (FSL FLIRT)." >> ${subject_dir}/T1T2_log.txt
    echo "" >> "${subject_dir}/T1T2_log.txt"
else
    echo "[$(date +"%H:%M:%S")] Step 4/9: ERROR - Coregistration of T2w image to T1w image failed (FSL FLIRT)." >> ${subject_dir}/T1T2_log.txt
    exit 1
fi



# Step 5: Brain extraction and segmentation

echo ""
echo "Step 5/9: Running brain extraction and WM/GM segmentation."

sienax ${subject_dir}/${id}_T1w_reoriented.nii.gz -r -d -o ${subject_dir}/${id}_sienax
fslmaths "${subject_dir}/${id}_sienax/I_stdmaskbrain_pve_1_segperiph.nii.gz" -thr 0.9 -bin "${subject_dir}/${id}_sienax/I_stdmaskbrain_pve_1_segperiph_bin.nii.gz"

if [[ -e "${subject_dir}/${id}_sienax/I_stdmaskbrain_pve_1_segperiph.nii.gz" ]]; then
    echo "[$(date +"%H:%M:%S")] Step 5/9: Successfully performed brain extraction and WM/GM segmentation (FSL SIENAX)." >> ${subject_dir}/T1T2_log.txt
else
    echo "[$(date +"%H:%M:%S")] Step 5/9: ERROR - Brain extraction and WM/GM segmentation failed (FSL SIENAX)." >> ${subject_dir}/T1T2_log.txt
    exit 1
fi


cp ${subject_dir}/${id}_sienax/I_brain.nii.gz ${subject_dir}/${id}_T1w_brain.nii.gz
fslmaths ${subject_dir}/${id}_T2w_coregistered.nii.gz -mul ${subject_dir}/${id}_sienax/I_brain_mask.nii.gz ${subject_dir}/${id}_T2w_brain.nii.gz

if [[ -e "${subject_dir}/${id}_T1w_brain.nii.gz" ]] && \
   [[ -e "${subject_dir}/${id}_T2w_brain.nii.gz" ]] ; then
    echo "[$(date +"%H:%M:%S")] ......... Successfully performed brain masking of T1w and T2w images." >> ${subject_dir}/T1T2_log.txt
    echo "" >> "${subject_dir}/T1T2_log.txt"
else
    echo "[$(date +"%H:%M:%S")] ......... ERROR - brain masking failed." >> ${subject_dir}/T1T2_log.txt
    exit 1
fi





# # Step 6: ROI masks

echo ""
echo "Step 6/9: Creating masks for selected ROIs."
echo "[$(date +"%H:%M:%S")] Step 6/9: ROI mask creation." >> ${subject_dir}/T1T2_log.txt

mkdir -p ${subject_dir}/masks

process_roi_choice() {
    local choice=$1
    case $choice in
        1)
            # White matter only
            rois=("All_WM")
            
            echo "......... creating white matter mask."
            cp -f ${subject_dir}/${id}_sienax/I_stdmaskbrain_seg_2.nii.gz ${subject_dir}/masks/${id}_All_WM.nii.gz

            if [[ -e "${subject_dir}/masks/${id}_All_WM.nii.gz" ]]; then
                echo "[$(date +"%H:%M:%S")] ......... Successfully created white matter mask." >> ${subject_dir}/T1T2_log.txt
                echo "" >> "${subject_dir}/T1T2_log.txt"
            else
                echo "[$(date +"%H:%M:%S")] ......... ERROR - white matter mask creation failed." >> ${subject_dir}/T1T2_log.txt
                exit 1
            fi
                     
            ;;
        2)
            # White matter + deep gray matter
            echo "......... creating white matter mask."
            cp -f ${subject_dir}/${id}_sienax/I_stdmaskbrain_seg_2.nii.gz ${subject_dir}/masks/${id}_All_WM.nii.gz

            if [[ -e "${subject_dir}/masks/${id}_All_WM.nii.gz" ]]; then
                echo "[$(date +"%H:%M:%S")] ......... Successfully created white matter mask." >> ${subject_dir}/T1T2_log.txt
            else
                echo "[$(date +"%H:%M:%S")] ......... ERROR - white matter mask creation failed." >> ${subject_dir}/T1T2_log.txt
                exit 1
            fi
            
            echo "......... running deep gray matter segmentation."

            mkdir -p ${subject_dir}/first                        
            run_first_all -i ${subject_dir}/${id}_T1w_brain.nii.gz -o ${subject_dir}/first/${id} -m auto -b -s L_Amyg,L_Caud,L_Hipp,L_Pall,L_Puta,L_Thal,R_Amyg,R_Caud,R_Hipp,R_Pall,R_Puta,R_Thal
            
            if [[ -e "${subject_dir}/first/${id}_all_none_firstseg.nii.gz" ]]; then
                echo "[$(date +"%H:%M:%S")] ......... Successfully ran deep gray matter segmentation (FSL FIRST)." >> ${subject_dir}/T1T2_log.txt
            else
                echo "[$(date +"%H:%M:%S")] ......... ERROR - deep gray matter segmentation failed (FSL FIRST)." >> ${subject_dir}/T1T2_log.txt
                exit 1
            fi
            
            echo "......... creating masks for deep gray matter structures."
            
            rois=("L_Amyg" "L_Caud" "L_Hipp" "L_Pall" "L_Puta" "L_Thal" "R_Amyg" "R_Caud" "R_Hipp" "R_Pall" "R_Puta" "R_Thal")

            for roi in ${rois[@]};do

                fslmaths ${subject_dir}/first/${id}_all_none_firstseg.nii.gz -thr "${roi_lut[$roi]}" -uthr "${roi_lut[$roi]}" -bin ${subject_dir}/masks/${id}_${roi}.nii.gz

            done       
            
            if [[ -e "${subject_dir}/masks/${id}_R_Thal.nii.gz" ]]; then
                echo "[$(date +"%H:%M:%S")] ......... Successfully created deep gray matter masks." >> ${subject_dir}/T1T2_log.txt
            else
                echo "[$(date +"%H:%M:%S")] ......... ERROR - deep gray matter mask creation failed." >> ${subject_dir}/T1T2_log.txt
                exit 1
            fi
            

            rois=("All_WM" "L_Amyg" "L_Caud" "L_Hipp" "L_Pall" "L_Puta" "L_Thal" "R_Amyg" "R_Caud" "R_Hipp" "R_Pall" "R_Puta" "R_Thal")
            ;;
        *)
            echo "Invalid choice. Please select a valid option (1/2)."
            exit 1
            ;;
    esac
}

# Call the function to process the ROI choice
process_roi_choice "$roi_choice"







# Step 7: Scaling factor

echo ""
echo "Step 7/9: Computing scaling factor from cortical gray matter."


t1_cortex_median=$(fslstats "${subject_dir}/${id}_T1w_brain.nii.gz" -k "${subject_dir}/${id}_sienax/I_stdmaskbrain_pve_1_segperiph_bin.nii.gz" -p 50)
t2_cortex_median=$(fslstats "${subject_dir}/${id}_T2w_brain.nii.gz" -k "${subject_dir}/${id}_sienax/I_stdmaskbrain_pve_1_segperiph_bin.nii.gz" -p 50)

echo "T1w median in cortical gray matter: $t1_cortex_median"
echo "T2w median in cortical gray matter: $t2_cortex_median"

    
scaling_factor=$(bc <<< "scale=10 ; $t1_cortex_median / $t2_cortex_median")

echo "Scaling factor: $scaling_factor"

echo "" >> ${subject_dir}/T1T2_log.txt
echo "[$(date +"%H:%M:%S")] Step 7/9: Scaling factor computation:" >> ${subject_dir}/T1T2_log.txt
echo "T1w median in cortical gray matter: $t1_cortex_median" >> ${subject_dir}/T1T2_log.txt >> ${subject_dir}/T1T2_log.txt
echo "T2w median in cortical gray matter: $t2_cortex_median" >> ${subject_dir}/T1T2_log.txt >> ${subject_dir}/T1T2_log.txt
echo "Scaling factor: $scaling_factor" >> ${subject_dir}/T1T2_log.txt



# Step 8: sT1/T2 image creation

echo ""
echo "Step 8/9: Creating standardized T1w/T2w image."

# Create scaled T2w image
fslmaths "${subject_dir}/${id}_T2w_brain.nii.gz" -mul $scaling_factor "${subject_dir}/${id}_T2w_scaled.nii.gz"

# Create numerator and denominator of Misaki formula
fslmaths "${subject_dir}/${id}_T1w_brain.nii.gz" -sub "${subject_dir}/${id}_T2w_scaled.nii.gz" "${subject_dir}/${id}_T1_minus_T2s.nii.gz"
fslmaths "${subject_dir}/${id}_T1w_brain.nii.gz" -add "${subject_dir}/${id}_T2w_scaled.nii.gz" "${subject_dir}/${id}_T1_plus_T2s.nii.gz"

# Apply formula and create standardized T1w/T2w image
fslmaths "${subject_dir}/${id}_T1_minus_T2s.nii.gz" -div "${subject_dir}/${id}_T1_plus_T2s.nii.gz" "${subject_dir}/${id}_sT1T2.nii.gz"

echo "" >> ${subject_dir}/T1T2_log.txt

if [[ -e "${subject_dir}/${id}_sT1T2.nii.gz" ]] ; then
    echo "[$(date +"%H:%M:%S")] Step 8/9: Successfully created T1w/T2w image." >> ${subject_dir}/T1T2_log.txt
else
    echo "[$(date +"%H:%M:%S")] Step 8/9: ERROR - T1w/T2w image creation failed." >> ${subject_dir}/T1T2_log.txt
    exit 1
fi





# Step 9: Value extraction

echo ""
echo "Step 9/9: Extracting values for selected ROIs."

echo "" >> ${subject_dir}/T1T2_log.txt
echo "[$(date +"%H:%M:%S")] Step 9/9: Extracting values for selected ROIs." >> ${subject_dir}/T1T2_log.txt

echo ""
echo "---------------------------------"


echo "sT1T2 median [IQR] for ${id}:"

echo "" >> ${subject_dir}/T1T2_log.txt
echo "---------------------------------------" >> ${subject_dir}/T1T2_log.txt
echo "sT1T2 median [IQR] for ${id}:" >> ${subject_dir}/T1T2_log.txt

for roi in ${rois[@]};do

    p50="$(printf "%.3f" $(fslstats "${subject_dir}/${id}_sT1T2.nii.gz" -k "${subject_dir}/masks/${id}_${roi}.nii.gz" -p 50))"
    p25="$(printf "%.3f" $(fslstats "${subject_dir}/${id}_sT1T2.nii.gz" -k "${subject_dir}/masks/${id}_${roi}.nii.gz" -p 25))"
    p75="$(printf "%.3f" $(fslstats "${subject_dir}/${id}_sT1T2.nii.gz" -k "${subject_dir}/masks/${id}_${roi}.nii.gz" -p 75))"

    echo -e "${roi}:\t${p50}\t[${p25},${p75}]"
    echo -e "${roi}:\t${p50}\t[${p25},${p75}]" >> ${subject_dir}/T1T2_log.txt
    
done        
echo "---------------------------------"
echo "---------------------------------------" >> ${subject_dir}/T1T2_log.txt



echo "" >> ${subject_dir}/T1T2_log.txt
echo "Finished at:" >> ${subject_dir}/T1T2_log.txt
date +"%F %T" >> ${subject_dir}/T1T2_log.txt

echo ""