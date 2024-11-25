#!/bin/bash

# Define the directory where the files are located
#directory="/Users/dante.basso/.sdkman/candidates/java/11.0.23-open/"
#directory="/Users/dante.basso/Downloads/data-integration/"
directory="cd $HOME/.sdkman/candidates/java/17.0.12-open"

# Check if the directory exists
if [ ! -d "$directory" ]; then
  echo "The directory $directory does not exist."
  exit 1
fi

# Recursive function to traverse the directory and process files
process_directory() {
  for file in "$1"/*; do
    if [ -f "$file" ]; then
      echo "Removing com.apple.quarantine from $file"
      xattr -d com.apple.quarantine "$file"
    elif [ -d "$file" ]; then
      process_directory "$file"  # Recursively process subdirectories
    fi
  done
}

# Start processing the main directory
process_directory "$directory"

echo "Process completed."
