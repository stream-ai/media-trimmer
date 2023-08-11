# media-trimmer
A Linux command-line utility to cleanup audio or video files and prepare them for sharing with others.

This script prepares media files for sharing with others by cleaning up silence at the beginning of the file, converting the file to MP3, and making sure that the fast-forward functionality works.

The silence trimming feature works by trimming everything from the beginning of the audio file so long as at least 15 seconds of silence is detected. So for example, suppose you start recording a Zoom call before the other participants join the line. Let's say that 10 seconds after you start the recording, you say "Test," followed by silence for 2 minutes. Then your other participants join the line and the conversation begins. This utility will trim everything up to when the participants join the line, including when you said "Test."

This utility doesn't change the original files, but it does create some temporary files and a new "output" directory where the processed files will go.

New files created by this tool will be saved with the original filename plus `-trimmed.mp3` in the `./output` directory.
