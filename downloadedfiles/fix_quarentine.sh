#!/bin/bash

directory=""

while getopts "in:" opt; do
  case "$opt" in
    in)
      input="$OPTARG"
      if [ -d "$input" ]; then
        directory="$input"
      elif [ -f "$input" ]; then
        file="$input"
      else
        echo "The provided input is neither a valid directory nor a file."
        exit 1
      fi
      ;;
    *)
      echo "Usage: $0 -in <directory_or_file>"
      exit 1
      ;;
  esac
done

if [ -z "$directory" ] && [ -z "$file" ]; then
  echo "You must specify a directory or a file with -in option."
  exit 1
fi

if [ -n "$directory" ]; then
  process_directory() {
    for item in "$1"/*; do
      if [ -f "$item" ]; then
        echo "Removing com.apple.quarantine from $item"
        xattr -d com.apple.quarantine "$item"
      elif [ -d "$item" ]; then
        process_directory "$item"
      fi
    done
  }
  process_directory "$directory"
else
  echo "Removing com.apple.quarantine from $file"
  xattr -d com.apple.quarantine "$file"
fi

echo "Process completed."
