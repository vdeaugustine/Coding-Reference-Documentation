#!/bin/bash

# export.sh
#
# Purpose: Concatenates text-based files from a project directory into a single output file.
# It can optionally include a directory tree structure, rename output files automatically,
# save metadata about the concatenation, and process specific files or the entire project.
#
# Usage:
#   ./export.sh [options] [output_file] [file1 file2 ...]
#
# Options:
#   -noTree     Exclude the directory tree structure from the output.
#   -rename     Automatically rename the output file if it already exists by appending a counter.
#   -saveMeta   Save a metadata file (`concatenation_metadata.txt`) alongside the output file.
#
# Arguments:
#   output_file (optional): The name of the output file. Defaults to `exportedCode_YYYY_MM_DD_HH_MM.txt`.
#   file1 file2 ... (optional): Specific file names to include. If not provided, the script processes all text-based files.
#
# Examples:
#   ./export.sh
#     Concatenates all text-based files into a default-named file, including the directory tree.
#
#   ./export.sh -noTree
#     Concatenates all text-based files into a default-named file, excluding the directory tree.
#
#   ./export.sh -rename my_export.txt
#     Concatenates all text-based files into `my_export.txt`. If `my_export.txt` exists,
#     it will be renamed (e.g., `my_export1.txt`). Includes the directory tree.
#
#   ./export.sh -saveMeta custom_output.log file1.js path/to/file2.py
#     Concatenates `file1.js` and `path/to/file2.py` into `custom_output.log`. Saves metadata.
#     Includes the directory tree.

# Hardcoded directory path (root of the project)
# Get the absolute path to the script's directory
directory="$(cd "$(dirname "$0")" && pwd)"

# Output directory - User's Downloads folder
output_directory="$HOME/Downloads"

# Metadata file name
metadata_file="concatenation_metadata.txt"

# Script's own filename
script_name="$(basename "$0")"

# Default values
include_tree=true
auto_rename=false
save_metadata=false
output_file=""
concatenate_all=true
file_names=()

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -noTree)
            include_tree=false
            shift
            ;;
        -rename)
            auto_rename=true
            shift
            ;;
        -saveMeta)
            save_metadata=true
            shift
            ;;
        *)
            if [ -z "$output_file" ]; then
                output_file="$1"
            else
                concatenate_all=false
                file_names+=("$1")
            fi
            shift
            ;;
    esac
done

# If no output_file is provided as an argument, generate one based on date and time
if [ -z "$output_file" ]; then
    output_file="exportedCode_$(date +"%Y_%m_%d_%H_%M").txt"
fi

# If no file_names specified and not concatenating all, error
if [ "$concatenate_all" = false ] && [ ${#file_names[@]} -eq 0 ]; then
    echo "Error: No file names specified for concatenation."
    exit 1
fi

# Handle existing output file
if [ -f "$output_directory/$output_file" ]; then
    if [ "$auto_rename" = true ]; then
        counter=1
        base_name="${output_file%.*}"
        extension="${output_file##*.}"
        while [ -f "$output_directory/${base_name}${counter}.${extension}" ]; do
            ((counter++))
        done
        output_file="${base_name}${counter}.${extension}"
        echo "File already exists. Renaming to: $output_file"
    else
        echo "File already exists. Overwriting: $output_file"
    fi
fi

# Create or truncate the output file
> "$output_directory/$output_file"

echo "Concatenating text-based files from the ${directory##*/} project..."

# Create temporary repository folder
temp_dir=$(mktemp -d)

# Function to check if file is ignored (used only for concatenate_all mode)
is_ignored() {
    local file="$1"
    local relative_path="${file#$directory/}"
    local filename="${file##*/}"
    if [ "$filename" = "$script_name" ]; then
        return 0
    fi
    if grep -q "^$relative_path$" "$directory/.gitignore" 2>/dev/null; then
        return 0
    fi
    while [[ "$relative_path" == */* ]]; do
        relative_path="${relative_path%/*}"
        if grep -q "^$relative_path/$" "$directory/.gitignore" 2>/dev/null; then
            return 0
        fi
    done
    if grep -q "^$filename$" "$directory/.gitignore" 2>/dev/null; then
        return 0
    fi
    if [[ "$file" == *"node_modules"* ]] || [[ "$file" == *".git"* ]]; then
        return 0
    fi
    return 1
}

# Function to copy all files for concatenate_all mode
copy_all_files() {
    local current_dir="$1"
    for file in "$current_dir"/*; do
        if [ -f "$file" ]; then
            if ! is_ignored "$file"; then
                if [[ $(file -b --mime-type "$file") == text/* || "$file" == *.xcdatamodeld ]]; then
                    relative_path="${file#$directory/}"
                    target_dir="$temp_dir/$(dirname "$relative_path")"
                    mkdir -p "$target_dir"
                    cp "$file" "$target_dir/$(basename "$file")"
                fi
            fi
        elif [ -d "$file" ]; then
            if ! is_ignored "$file"; then
                copy_all_files "$file"
            fi
        fi
    done
}

# Copy files to temp_dir (repository folder)
if [ "$concatenate_all" = true ]; then
    copy_all_files "$directory"
else
    for file_name in "${file_names[@]}"; do
        found=false
        while IFS= read -r -d '' file; do
            found=true
            relative_path="${file#$directory/}"
            target_dir="$temp_dir/$(dirname "$relative_path")"
            mkdir -p "$target_dir"
            cp "$file" "$target_dir/$(basename "$file")"
        done < <(find "$directory" -type f -name "$file_name" -print0)
        if [ "$found" = false ]; then
            echo "Warning: No file named '$file_name' found in the directory tree."
        fi
    done
fi

# Function to concatenate files from temp_dir
concatenate_files() {
    local base_dir="$1"
    local current_dir="$2"
    for file in "$current_dir"/*; do
        if [ -f "$file" ]; then
            relative_path="${file#$base_dir/}"
            echo "Processing file: $relative_path"
            echo "===== $relative_path =====" >> "$output_directory/$output_file"
            awk '!/^( *$|\/\/|\/\/\/)/' "$file" >> "$output_directory/$output_file"
            file_list+=("$relative_path")
            ((total_files++))
        elif [ -d "$file" ]; then
            concatenate_files "$base_dir" "$file"
        fi
    done
}

# Function to generate directory tree from temp_dir
generate_tree() {
    local base_dir="$1"
    local current_dir="$2"
    local indent="$3"
    local items=("$current_dir"/*)
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local relative_path="${item#$base_dir/}"
        local base_item="${item##*/}"
        if [ $i -eq $((${#items[@]}-1)) ]; then
            local connector="└── "
        else
            local connector="├── "
        fi
        if [ -d "$item" ]; then
            echo "$indent$connector$base_item/"
            generate_tree "$base_dir" "$item" "$indent    "
        elif [ -f "$item" ]; then
            echo "$indent$connector$base_item"
        fi
    done
}

# Concatenate files from the repository folder
total_files=0
file_list=()
concatenate_files "$temp_dir" "$temp_dir"

# Append directory tree to output file if required
if [ "$include_tree" = true ]; then
    echo -e "\n===== Directory Tree Structure =====" >> "$output_directory/$output_file"
    echo "${directory##*/}/" >> "$output_directory/$output_file"
    generate_tree "$temp_dir" "$temp_dir" "    " >> "$output_directory/$output_file"
fi

# Calculate metadata
total_lines=$(grep -vcE '^( *$|\/\/|\/\/\/)' "$output_directory/$output_file")
total_chars=$(wc -m < "$output_directory/$output_file")
tokens_estimate=$(echo "scale=0; $total_chars / 3.5" | bc)
current_date=$(date)

# Create the metadata content
metadata_content="Total number of files: $total_files
Total lines in the concatenated file: $total_lines
Total characters in the concatenated file: $total_chars
Tokens estimate: $tokens_estimate
Date of concatenation: $current_date"

# Print metadata to terminal
echo -e "\n======= Metadata =======\n"
echo "$metadata_content"
echo -e "\n=======================\n"

# Create the metadata file if save_metadata is true
if [ "$save_metadata" = true ]; then
    echo "Creating metadata file: $metadata_file"
    echo "$metadata_content" > "$output_directory/$metadata_file"
    echo -e "\nList of files included in the concatenation:" >> "$output_directory/$metadata_file"
    echo -e "\n============\n" >> "$output_directory/$metadata_file"
    printf '%s\n' "${file_list[@]}" >> "$output_directory/$metadata_file"

    # Include directory tree in metadata file if required
    if [ "$include_tree" = true ]; then
        echo -e "\nDirectory tree structure:" >> "$output_directory/$metadata_file"
        echo "${directory##*/}/" >> "$output_directory/$metadata_file"
        generate_tree "$temp_dir" "$temp_dir" "    " >> "$output_directory/$metadata_file"
    fi
fi

# Clean up the temporary repository folder
rm -rf "$temp_dir"

echo -e "\nConcatenation complete! Output file: $output_directory/$output_file"
echo "This file contains selected text-based files from the Baseball Savant Downloader Chrome Extension project,"
echo "which helps users download baseball videos from Baseball Savant for analysis and review."
