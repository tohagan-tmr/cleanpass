## What to do if you commit a secret or credential to GIT

Because GIT will retain all past versions of your source code, you have several options ...
- Rebuild and replace your git repo [with a search/replace on ALL versions of all files](https://stackoverflow.com/questions/46950829/how-to-replace-a-string-in-whole-git-history) - takes time and effort and it may be too late if the GIT repository has been publicly or internally exposed.
- **Change the credentials** and then choose one of the following options to prevent this in the future ... 

### 1. Move all credentials into environment variables or a secret vault service (with API access) and revise your code and configuration documentation to use these.
  - Typically the best option. 
  - A cloud vault service may also provide key versioning and key rotation reminders.

### 2. Use `.gitignore` to exclude files containing secrets. 
  - To reduce risk, its safest to gather these files into a single file or folder or naming pattern so you can exclude all secrets with a single `.gitignore` rule.
  - Preserve these files or secrets in a password manager.
  - You now need to be able to reconstruct these credential files in the future so you'll need to carefully document paths & formats and perhaps commit a sample file.
  - You're no longer tracking changes to these files, in particular their deployment version.

### 3. Encrypt your credential files using a tool like [git-crypt](https://github.com/AGWA/git-crypt). 
  - These files will now be binary in GIT so you can't diff them. 
  - You may consider this a good option when the files are mostly credentials and rarely change. 
  - This is not intended as an endorsement of `git-crypt`. It's up to you to assess its risk.

### 4. Replace secrets embedded in source code with an alternative unique string in GIT repo
  - Use a GIT clean/smudge filter _as described below_. 
  - You can now diff and track changes to other parts of this file. 
  - You may consider this a good option if you're forced to embed credentials in source code.

## How to use the cleanpass scripts to remove passwords from source code.

This describes how to use `cleanpass-config.sh` and `cleanpass.sh` bash scripts to remove passwords from the source code in GIT by replacing them with an alternative unique string. The same technique can be used to search & replace other configuration strings(e.g. to set a local developer path or local database name). 

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

These script prompt for passwords rather than use parameters to avoid logging the password to your bash history file

Create password filters in GIT **global** settings so they can be used by multiple GIT repositories. 

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
## Other use cases

Although our use case is password or secret replacement, the same technique can be used to replace other values.  For example, a developer could use this method to configure local development path names or test server hostnames.  Generally the same can be better achived using environment variable or configuration files but there may be siutations where these options won't work.  I've used legacy development tools that excluded these options.

## Test that the filtering works and recommit files with credentials

Somehow you need to be able to recommit the files that contain credentials without changing their checked source code when they are checked out. You will also need to test that the `cleanpass` filters you added to `.gitattributes` are really working as expected.  I do this in VSCode (or some IDE tool) so you can see the file changes and verify they are working.

Before you commit any file to GIT ...

1. Add updated `.gitattributes` file to staging 
2. For each filtered file containing credentials ...
  - Make some small change to the file and add it to Staging
  - View the changes in Staging files to confirm that the expected filter was applied (e.g. password replaced)
  - Now undo the change you made to the source file and re-add this change to Staging. Even though you've just undone changes to the file, it should remain in Staging as the filter was applied to it. If not, then your filter didn't work!

Now you're ready to commit the Staged files with the filter applied.

## Credential rotation

You should be regularly changing system credentials. 
When you do, you'll need to change the values in several places 
1.  In your checked out source code.
2.  Twice in the filter rules in `~/.gitconfig`.

## Known limitations

These scripts currently won't work with passwords or replacement strings that contain the '/' character. This is fixable - just not done yet.

If you need to replace multiple passwords in one file then the current solution won't work as GIT will only apply *the last* filter per filename referenced by a .gitattributes file.  To fix this, instead of using `cleanpass-config.sh` ... combine multiple search/replace instructions into a single sed command like so and give the filter a new name. You can use `cleanpass.sh` with this new filter.

    $ git config --global "filter.${myfilter}.clean" "sed -e 's/${pass1}/${replace1}/g' -e 's/${pass2}/${replace2}/g'"
    $ git config --global "filter.${myfilter}.smudge" "sed --e 's/${replace1}/${pass1}/g' e 's/${replace2}/${pass2}/g'"

## Disclaimer

It is solely your responsibility to confirm the validity and correctness of this information. This is not intended as an endorsement of any software or information references. Note also the [MIT license](LICENSE) terms. 
