#!/bin/bash

# Script to automatically resolve merge conflicts in Dart files
# This will generally choose the version from origin/Tuong as it seems more complete

echo "Starting to fix merge conflicts..."

# Function to fix conflicts in a file
fix_file_conflicts() {
    local file="$1"
    echo "Processing: $file"
    
    # Use sed to remove merge conflict markers and keep the origin/Tuong version
    # This is a simplified approach - may need manual review for complex conflicts
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Process the file line by line
    local in_conflict=false
    local keep_lines=true
    
    while IFS= read -r line; do
        if [[ "$line" == "<<<<<<< HEAD" ]]; then
            in_conflict=true
            keep_lines=false
        elif [[ "$line" == "=======" ]]; then
            keep_lines=true
        elif [[ "$line" == ">>>>>>> origin/Tuong" ]]; then
            in_conflict=false
            keep_lines=true
        elif [[ "$in_conflict" == false ]] || [[ "$keep_lines" == true && "$in_conflict" == true ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    # Replace original file with fixed version
    mv "$temp_file" "$file"
    echo "Fixed: $file"
}

# Find all Dart files with merge conflicts
echo "Finding files with merge conflicts..."
conflict_files=$(grep -r "<<<<<<< HEAD" lib/ --include="*.dart" -l)

if [ -z "$conflict_files" ]; then
    echo "No merge conflicts found in Dart files!"
    exit 0
fi

echo "Found conflicts in the following files:"
echo "$conflict_files"
echo ""

# Process each file
for file in $conflict_files; do
    fix_file_conflicts "$file"
done

echo ""
echo "Conflict resolution complete!"
echo "Running flutter clean and pub get..."

flutter clean
flutter pub get

echo "Done! Please review the changes and test the application." 