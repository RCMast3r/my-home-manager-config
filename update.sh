#!/bin/bash

nix build '.#homeConfigurations.ben.activationPackage'
./result/activate

# Define source and target folder pairs
declare -A folder_pairs=(
    [${HOME}/.nix-profile/share/applications]="${HOME}/.local/share/applications"
    [${HOME}/.nix-profile/share/icons]="${HOME}/.local/share/icons"
    # Add more pairs as needed
)

echo "${folder_pairs}"
# Loop through folder pairs
for source_folder in "${!folder_pairs[@]}"; do
echo "asdf $source_folder"
    target_folder="${folder_pairs[${source_folder}]}"
    
    # Check if source folder exists
    if [ ! -d "$source_folder" ]; then
        echo "Source folder '$source_folder' does not exist."
        continue
    fi
    
    # Check if target folder exists, if not, create it
    if [ ! -d "$target_folder" ]; then
        mkdir -p "$target_folder"
    fi
    
    # Loop through files in the source folder
    for file in "$source_folder"/*; do
        # Extract the filename from the full path
        filename=$(basename "$file")
        
        # Check if a symlink with the same filename already exists in the target folder
        if [ ! -e "$target_folder/$filename" ]; then
            # Create a symlink in the target folder
            ln -s "$file" "$target_folder/$filename"
            echo "Created symlink for '$filename' in '$target_folder'."
        else
            echo "Symlink for '$filename' already exists in '$target_folder'."
        fi
    done
    
    echo "Symlink creation process for '$source_folder' completed."
done
