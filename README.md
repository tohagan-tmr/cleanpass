## How to use the cleanpass scripts

This describes how to use `cleanpass-config.sh` and `cleanpass.sh` bash scripts to remove passwords from source code by replacing them with an alterntative unique string.  The same technique can be used to search & replace other configuration strings(e.g. to set a local developer path or local database name). 

You can add clean/smudge rules to a local `.git/config` file, but for passwords it's probably safer to configure these
rules as a global GIT config saved to `~/.gitconfg` which is what the `cleanpass-config.sh` script does.

Reference
- https://developers.redhat.com/articles/2022/02/02/protect-secrets-git-cleansmudge-filter

## To find files with passwords

    $ grep -rl 'password'

To avoid logging the password to your bash history file use ...

    $ grep -rl `cat < /dev/tty`

... then enter your password followed by Ctrl-D

## Setup GIT's Smudge and Clean filters to replace embedded passwords.

These script prompt for passwords rather than use paramaters to avoid logging the password to your bash history file

Create password filters in GIT global settings

    $ cleanpass-config.sh cleanpass1
    Password: ******
    Replace with: ******

    $ cleanpass-config.sh cleanpass2
    Password: ******
    Replace with: ******

Per repository ... find files with a password and apply filter.

    $ cleanpass.sh 
    Filter name: cleanpass1
    Password: ******

    $ cleanpass.sh 
    Filter name: cleanpass2
    Password: ******

These commands append rules to a .gitattributes file so you may want to review/edit these changes.

## Known limitations

These scripts currently won't work with passwords or replace strings that contain the '/' character. This is fixable - just not done yet.

If you need to replace mulitple passwords in one file then the current solution won't work as GIT will only apply *the last* filter per filename referenced by a .gitattributes file.

To fix this, combine mulitple search/replace instructions into a single sed command like so and give the filter a new name.

    $ git config --global "filter.${myfilter}.clean" "sed -e 's/${pass1}/${replace1}/g' -e 's/${pass2}/${replace2}/g'"
    $ git config --global "filter.${myfilter}.smudge" "sed --e 's/${replace1}/${pass1}/g' e 's/${replace2}/${pass2}/g'"
