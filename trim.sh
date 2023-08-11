#!/usr/bin/env sh

# Create the output directory if it doesn't exist
mkdir -p ./out

# Function to process a single file
process_file() {
  file="$1"
  # Extract the filename without the extension
  filename="${file%.*}"

  # Determine the file's MIME type
  mime_type=$(file --mime-type -b "$file")

  # Check if the file is an audio or video file
  if [[ "$mime_type" == audio/* ]] || [[ "$mime_type" == video/* ]]; then
    # Re-encode the file with fast-start and convert to temporary MP3
    ffmpeg -i "$file" -movflags +faststart -b:a 192k "${filename}.temp.mp3"

    # Create a variable to control the loop
    keep_trimming=1

    # Loop to repeatedly trim silence from the beginning of the file
    while [ $keep_trimming -eq 1 ]; do
      # Detect silence lasting at least 15 seconds and get the silence_end value
      silence_end=$(ffmpeg -i "${filename}.temp.mp3" -af silencedetect=noise=-30dB:d=15 -f null - 2>&1 | grep -o -P '(?<=silence_end: ).*?(?= |$)' | head -n1)

      if [ ! -z "$silence_end" ]; then
        # If silence is detected, trim it
        ffmpeg -i "${filename}.temp.mp3" -ss "$silence_end" -b:a 192k "${filename}.temp2.mp3"
        # Replace the original temp file with the newly trimmed one
        mv "${filename}.temp2.mp3" "${filename}.temp.mp3"
      else
        # If no silence is detected, exit the loop
        keep_trimming=0
      fi
    done

    # Move the final trimmed file to the output directory
    mv "${filename}.temp.mp3" "./out/${filename}-trimmed.mp3"

    echo "Processed $file"
  else
    echo "Skipped $file (not an audio or video file)"
  fi
}

# Iterate through all files in the current directory
for file in *; do
  if [ -f "$file" ]; then
    process_file "$file" &
  fi
done

# Wait for all background processes to finish
wait

echo "All files processed."
