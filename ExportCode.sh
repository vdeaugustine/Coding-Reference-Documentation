# Usage Examples
# Default (overwrite, with tree, ignores self): ./script.sh
# Output file: concatenated.txt, overwrites if exists, includes tree in both concatenated.txt and concatenation_metadata.txt, excludes the script itself.
# Custom output, overwrite, with tree: ./script.sh output.txt
# Output file: output.txt, overwrites if exists, includes tree in both files, excludes the script.
# No tree, overwrite: ./script.sh -noTree
# Output file: concatenated.txt, overwrites if exists, no tree in either file, excludes the script.
# Auto-rename, with tree: ./script.sh -rename
# Output file: concatenated.txt (or concatenated1.txt, etc., if exists), includes tree in both files, excludes the script.
# Custom output, auto-rename, no tree: ./script.sh -noTree -rename output.txt
# Output file: output.txt (or output1.txt, etc., if exists), no tree in either file, excludes the script.
# Custom output, auto-rename, with tree: ./script.sh -rename output.txt
# Output file: output.txt (or output1.txt, etc., if exists), includes tree in both files, excludes the script.
# Notes
# The script assumes it is located in the project root directory (via dirname "$0"). If run from a different directory (e.g., via a path like ./scripts/script.sh), ensure the directory variable correctly points to the project root.
# The tree structure in both files respects the same exclusion rules (.gitignore, node_modules, .git, and now the script itself), ensuring consistency.
# The artifact_id is reused to indicate this is an update to the previous artifact.

#!/bin/bash

# Hardcoded directory path (root of the project)
directory="$(dirname "$0")"

# Output directory - User's Downloads folder
output_directory="$HOME/Downloads"

# Metadata file name
metadata_file="concatenation_metadata.txt"

# Script's own filename
script_name="$(basename "$0")"

# Parse arguments
include_tree=true
auto_rename=false
output_file=""
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
        *)
            if [ -z "$output_file" ]; then
                output_file="$1"
            else
                echo "Error: Too many arguments."
                exit 1
            fi
            shift
            ;;
    esac
done
if [ -z "$output_file" ]; then
    output_file="concatenated.txt"
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

echo "Concatenating text-based files from the Baseball Savant Downloader Chrome Extension project..."

# Function to check if file is in .gitignore or is the script itself
is_ignored() {
    local file="$1"
    local relative_path="${file#$directory/}"
    local filename="${file##*/}"
    
    # Check if the file is the script itself
    if [ "$filename" = "$script_name" ]; then
        return 0 # True, file is the script itself
    fi
    
    # Check direct patterns in gitignore
    if grep -q "^$relative_path$" "$directory/.gitignore" 2>/dev/null; then
        return 0 # True, file is ignored
    fi
    
    # Check directory patterns in gitignore
    while [[ "$relative_path" == */* ]]; do
        relative_path="${relative_path%/*}"
        if grep -q "^$relative_path/$" "$directory/.gitignore" 2>/dev/null; then
            return 0 # True, directory is ignored
        fi
    done
    
    # Check filename patterns in gitignore
    if grep -q "^$filename$" "$directory/.gitignore" 2>/dev/null; then
        return 0 # True, filename is ignored
    fi
    
    # Check for node_modules and other common patterns
    if [[ "$file" == *"node_modules"* ]] || [[ "$file" == *".git"* ]]; then
        return 0 # True, file is in node_modules or .git directory
    fi
    
    return 1 # False, file is not ignored
}

# Function to generate directory tree
generate_tree() {
    local current_dir="$1"
    local indent="$2"
    local items=("$current_dir"/*)
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local base_item="${item##*/}"
        if [ $i -eq $((${#items[@]}-1)) ]; then
            local connector="└── "
        else
            local connector="├── "
        fi
        if [ -d "$item" ] && ! is_ignored "$item"; then
            echo "$indent$connector$base_item/"
            generate_tree "$item" "$indent    "
        elif [ -f "$item" ] && ! is_ignored "$item"; then
            echo "$indent$connector$base_item"
        fi
    done
}

# Array to store the filenames in order
file_list=()
total_files=0

# Function to recursively concatenate text-based files
concatenate_files() {
    local current_dir="$1"

    for file in "$current_dir"/*; do
        # Skip if file is in .gitignore or is the script itself
        if is_ignored "$file"; then
            continue
        fi
        
        if [ -f "$file" ]; then
            # Check if the file is a text-based file
            if [[ $(file -b --mime-type "$file") == text/* || "$file" == *.xcdatamodeld ]]; then
                echo "Processing file: ${file##*/}"
                echo "===== ${file##*/} =====" >> "$output_directory/$output_file"
                # Exclude empty lines and lines containing "//" or "///"
                awk '!/^( *$|\/\/|\/\/\/)/' "$file" >> "$output_directory/$output_file"

                # Add filename to the array
                file_list+=("${file##*/}")
                ((total_files++))
            fi
        elif [ -d "$file" ]; then
            # Skip node_modules, .git directories
            if [[ "$file" != *"node_modules"* ]] && [[ "$file" != *".git"* ]]; then
                # Recursively call the function for nested directories
                concatenate_files "$file"
            fi
        fi
    done
}

# Call the function with the initial directory
concatenate_files "$directory"

# Append directory tree to output file if required
if [ "$include_tree" = true ]; then
    echo -e "\n===== Directory Tree Structure =====" >> "$output_directory/$output_file"
    echo "${directory##*/}/" >> "$output_directory/$output_file"
    generate_tree "$directory" "    " >> "$output_directory/$output_file"
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

# Create the metadata file
echo "Creating metadata file: $metadata_file"
echo "$metadata_content" > "$output_directory/$metadata_file"
echo -e "\nList of files included in the concatenation:" >> "$output_directory/$metadata_file"
echo -e "\n============\n" >> "$output_directory/$metadata_file"
printf '%s\n' "${file_list[@]}" >> "$output_directory/$metadata_file"

# Include directory tree in metadata file if required
if [ "$include_tree" = true ]; then
    echo -e "\nDirectory tree structure:" >> "$output_directory/$metadata_file"
    echo "${directory##*/}/" >> "$output_directory/$metadata_file"
    generate_tree "$directory" "    " >> "$output_directory/$metadata_file"
fi

echo -e "\nConcatenation complete! Output file: $output_directory/$output_file"
echo "This file contains all text-based files from the Baseball Savant Downloader Chrome Extension project,"
echo "which helps users download baseball videos from Baseball Savant for analysis and review."
