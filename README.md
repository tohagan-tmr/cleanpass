## What to do if you commit a credential to GIT

You have several options
- Rebuild your git repo [with a search/replace on ALL version of files](https://stackoverflow.com/questions/46950829/how-to-replace-a-string-in-whole-git-history) - takes time and effort and it may be too late!
- **Change the credentials** and then make sure this new credential is not added to GIT by either: 
  - Using `.gitignore` to exlcude files containing credentials. Now need to reconstruct these files per developer. You're also not tracking their deployment version. Best to gather these files into a single excluded folder.
  - Encrypt your credential files using [git-crypt](https://github.com/AGWA/git-crypt) or [git-secret](https://git-secret.io/). Will be binary in GIT so can't diff it. A good option when the file is mostly credentials.     
  - Replace secrets embeeded in source with an alternative unique string in GIT repo using a clean/smudge filter as described below. Can now diff and track changes to other parts of this file. A good option when you're forced to embed credentials into source code.

## How to use the cleanpass scripts to remove passwords from source code.

This describes how to use `cleanpass-config.sh` and `cleanpass.sh` bash scripts to remove passwords from the source code in GIT by replacing them with an alterntative unique string.  The same technique can be used to search & replace other configuration strings(e.g. to set a local developer path or local database name). 

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

These commands append rules to a .gitattributes file so you will want to review/edit these changes.
Often you can just replace a list of files with a pattern.

```
mycredentials.json filter=cleanpass
...
```

## Test that the filtering works and recommit files with credentials

Somehow you need to be able to recommit the files that contain credentials without changing their checked source code when they are checked out.
You will also want to test that the `cleanpass` filters you added to `.gitattributes` are really working as expected. 
I do this in VSCode (or some IDE) so you can see the file changes and verify they are working.

Before you commit any file to GIT ...

1.  Add updated `.gitattributes` file to staging 
2.  Make some small change to each source file that you wish to expect to be filtered and add it to Staging
3.  View changes to the Staged files. You should to confirm that the expected filter was applied (password replaced)
4.  Now undo the change you made to each source file re-add these updated files to Staging
  - Even though you've just undone changes to each file, they should remain in Staging as the filter was applied as well, if not then your filter didn't work

Now you're ready to commit the Staged files with the filter applied.

## Credential rotation

You should be regularly changing system credentials. When you do, don't forget to update the filter rules in `~/.gitconfig`.

## Known limitations

These scripts currently won't work with passwords or replace strings that contain the '/' character. This is fixable - just not done yet.

If you need to replace mulitple passwords in one file then the current solution won't work as GIT will only apply *the last* filter per filename referenced by a .gitattributes file.  To fix this, combine mulitple search/replace instructions into a single sed command like so and give the filter a new name.

    $ git config --global "filter.${myfilter}.clean" "sed -e 's/${pass1}/${replace1}/g' -e 's/${pass2}/${replace2}/g'"
    $ git config --global "filter.${myfilter}.smudge" "sed --e 's/${replace1}/${pass1}/g' e 's/${replace2}/${pass2}/g'"
