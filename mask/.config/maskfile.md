# Global Maskfile

## work

> Work Scripts

~~~sh
mask --maskfile ~/.config/maskfile.md work --help
~~~


<!-- A heading defines the command's name -->
### gitconfig

<!-- A blockquote defines the command's description -->
> Sets the appropriate variables for work .gitconfig

<!-- A code block defines the script to be executed -->
~~~sh
git config credential.username cam.barts@cfainstitute.org
git config user.signingkey E08E7B2D3186FB5B
git config user.email cam.barts@cfainstitute.org
git config user.name "Cam Barts"
git config commit.gpgsign true

echo "Update Repo remote like this: git config remote.origin.url=work-github:CFA-Institute/ITSM.DREW.git"
~~~

### jira

> Create a Jira Ticket

~~~sh
#!/bin/bash

project=$(jq -r ".projects[].key" /home/nux/git/work/jira-quick-create/cache.json | fzf --prompt="Select Project ([ESC] for None): ")
epic=$(jq -r '.epics[].summary' /home/nux/git/work/jira-quick-create/cache.json | fzf --prompt="Select Epic ([ESC] for None): ")
/home/nux/git/work/jira-quick-create/.venv/bin/jira-quick-create --project $project --epic "$epic"
~~~


### megalinter

> Run Megalinter on local git repository, in the same way that it runs on github

~~~sh
docker run -e "DEFAULT_WORKSPACE=/github/workspace" -v /var/run/docker.sock:/var/run/docker.sock:rw -v $(pwd):/github/workspace:rw oxsecurity/megalinter:v7
~~~
## home
> Home Scripts

~~~sh
mask --maskfile ~/.config/maskfile.md home --help
~~~

### borg-backup-flashdrive

> Borg Backup to Flashdrive

~~~sh
#!/bin/bash
export DISPLAY=:0
export PYTHON_KEYRING_BACKEND=keyring.backends.SecretService.Keyring
export BORG_PASSCOMMAND='gpg --decrypt /home/nux/borg_pass.gpg'
ntfy publish -t "Borg Backup Started" -p 4 --tags=backup,floppy_disk,star2,stopwatch citadel_events "Borg Backup Started for Warrig Machine"
borg create /mnt/flash/borg_backup::$(date -Is) /home/backup/rsnapshot_backups/ --stats --compression zstd,22
ntfy publish -t "Borg Backup Completed" -p 4 --tags=backup,floppy_disk,star2,white_check_mark citadel_events "Borg Backup Completed for Warrig Machine"
~~~

## utils

> Common Scripts

~~~sh
mask --maskfile ~/.config/maskfile.md utils --help
~~~

### ocr-screenshot

> Read the text of a screenshot


~~~sh
#!/bin/bash

flameshot gui -p /tmp/tess_out.png > /dev/null 2>&1

while ! [ -f /tmp/tess_out.png ];
do
	sleep .5
done
echo "Writing to STDOUT"
echo "------------------------------"
tesseract /tmp/tess_out.png stdout
echo "------------------------------"
rm -rf /tmp/tess_out.png
~~~


### memo

> Write out a memo that will go to memos.coder.cam

~~~sh
#!/usr/bin/env bash

# Retrieve the API key from the keyring
api_url=$(keyring get memos.coder.cam cam@coder.cam)

# Create a temporary file in /tmp
temp_file=$(mktemp /tmp/memo.XXXXXX.md)

# Open the temporary file in the default editor
$EDITOR "$temp_file"

# Read the content of the temporary file
content=$(jq -Rs . "$temp_file")

# Prepare the JSON payload
json="{\"content\": $content}"

# Post the JSON payload to the URL endpoint
curl "$api_url" -X POST -H "Content-Type: application/json" -d "$json"

# Remove the temporary file
rm "$temp_file"
~~~

### clear-sync-conflict

> Find and immediately delete sync conflict

~~~sh
find . -name "*sync-conflict*" -exec rm -rf {} \;
~~~

### parse-python (filename)

> Output better python

~~~python
import argparse
import os
import subprocess
import keyring
from rich import print

open_ai_keyring = keyring.get_password("OpenAI", "camerond.barts@gmail.com")

# Function to split the input into chunks
def split_input(input_str):
    chunks = []
    current_chunk = []
    chunk_splitters = ['\t', '    ',]
    for line in input_str.splitlines():
        if all([splitter not in line for splitter in chunk_splitters]):
            if current_chunk:
                chunks.append('\n'.join(current_chunk))
	            current_chunk = []
        current_chunk.append(line)
    if current_chunk:
        chunks.append('\n'.join(current_chunk))
    return chunks

# Determine the output filename
input_filename = os.getenv("filename", "")
output_filename = os.path.splitext(input_filename)[0] + "_new" + os.path.splitext(input_filename)[1]

# Read the input file
with open(input_filename, 'r') as input_file:
    input_content = input_file.read()

# Split the input into chunks
input_chunks = split_input(input_content)
print(f"Collected {len(input_chunks)} chunks, refactoring...")

# Process each chunk and append the output to the output file
for chunk in input_chunks:
    if 'import' not in chunk:
        process = subprocess.Popen(
        ['chatblade', '--openai-api-key', open_ai_keyring, '-e', '-p', 'python'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
        )
    
        output, _ = process.communicate(input=chunk)
    else:
        output = chunk
    
    with open(output_filename, 'a') as output_file:
        output_file.write(f"{output}\n")

print(f"Script processing complete. Output saved to '{output_filename}', formatting...")
subprocess.Popen(["black", output_filename])
subprocess.Popen(["ruff", "check", output_filename, "--fix"])
~~~
