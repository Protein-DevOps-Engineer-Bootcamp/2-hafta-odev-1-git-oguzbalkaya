
# Protein DevOps Engineer Bootcamp

A developer wants a script to build only a specific branch of the project.

- The name of the branch that will build must be given.If current branch is not that branch, change the branch.
- If name of the branch is main or master, warn the user and build the application.
- The user should be able to create a branch thanks to the script.
- The user should be able to specify the debug mode.If the user doesn't want to specify, default value must be false.
- The user should be able to choose the compression type.It can be tar.gz or zip.If the user doesn't want to choose, default value must be false.
- The user should be able to choose the directory to move the files to.If the user doesn't want to choose, default value must be current directory.


## Files

#### build.sh
Main script file.

#### build.conf
Configuration file.It contains a list of names of important branches and draft of the build command.

## Usage

`Note that, target directory means a directory that contains jar files which created by maven.`


 `-b <branch_name>`    Branch name(default=current branch)

 `-n <new_branch>`     Create a new branch

 `-f <zip|tar>`        Compression format.tar=tar.gz, zip=zip.(default=tar)
 
 `-p <artifact_path>`  Copy artifact to specific path(default=current directory)

 `-d <false|true>`     Debug mode(default=false)

 `-s <false|true>`     Skip test(default=false)

 `-r <false|true>`     Remove target directory after compressing.

 
Show help page.

```bash
  ./build.sh --help
```

Create a new branch.

```bash
  ./build.sh -n branch_name
```

Build with default values.

```bash
  ./build.sh
```

Compression format is zip, branch name is main and debug mode is active.

```bash
  ./build.sh -f tar -b main -d true
```

Compression format is zip, branch name is mybranch, debug mode is not active and skip all tests.

```bash
  ./build.sh -f zip -b mybranch -d false -s true 
```

Compression format is tar(default), artifact directory is /home/user/Desktop, delete target directory after compressing and skip all tests.

```bash
  ./build.sh -p /home/user/Desktop/ -s true -r true 
```


## Technologies

- Linux
- Bash Scripting
- Git
- Maven


## License

[GPL3](https://www.gnu.org/licenses/gpl-3.0.html)

