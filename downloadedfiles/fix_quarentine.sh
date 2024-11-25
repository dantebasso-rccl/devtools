#!/bin/bash

input=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -in)
      input="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 -in <directory_or_file>"
      exit 1
      ;;
  esac
done

if [ -z "$input" ]; then
  echo "You must specify a directory or a file with -in option."
  exit 1
fi

if [ -d "$input" ]; then
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
  process_directory "$input"
elif [ -f "$input" ]; then
  echo "Removing com.apple.quarantine from $input"
  xattr -d com.apple.quarantine "$input"
else
  echo "The provided input is neither a valid directory nor a file."
  exit 1
fi

echo "Process completed."
