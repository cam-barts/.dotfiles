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
git config core.fileMode false

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

### docker-cleanup

> Pull new images and clean up system 

~~~sh
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once
docker system prune -a
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

### git-branch-cleanup

> Delete all branches without upstreams

~~~sh
git fetch --all --prune
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
~~~


### transcribe

> Transcribe an MP3 file into text

**OPTIONS**
* filename
	* flags: -f --filename
    * type: string
    * desc: File to transcribe

~~~sh
whisper "$filename" -f txt --model medium.en
~~~

## edit

> Edit the Global Maskfile

~~~sh
xdg-open "obsidian://adv-uri?vault=Nux&filepath=60%20Interests%2F63%20Configs%2FGlobal%20Maskfile.md"
~~~

## hoarder

> Interface with Karakeep (Hoarder)

~~~sh
mask --maskfile ~/.config/maskfile.md hoarder --help
docker run --rm ghcr.io/karakeep-app/karakeep-cli:release --help
~~~

### bookmarks

> List bookmarks

~~~sh
docker run --rm ghcr.io/karakeep-app/karakeep-cli:release --api-key $(secret-tool lookup service "Hoarder API Key") --server-addr https://hoarder.coder.cam bookmarks list
~~~

#### add

> Add a new bookmark

**OPTIONS**
* url
	* flags: -u --url
    * type: string
    * desc: URL to save

~~~sh
if [[ -z "$url" ]]; then
    url=$(gum input --placeholder "Link")
fi
docker run --rm ghcr.io/karakeep-app/karakeep-cli:release --api-key $(secret-tool lookup service "Hoarder API Key") --server-addr https://hoarder.coder.cam bookmarks add --link "$url"
~~~