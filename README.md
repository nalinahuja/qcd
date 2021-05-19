## QCD
<p align="justify">
QCD is a bash utility that extends upon the exisiting capabilities of the builtin command <code>cd</code>. It allows the user to quickly change from one directory to another by specifying a valid path, directory keyword, directory prefix, or character subsequence to the program as a command line argument. QCD works completely locally and utilizes common builtin commands to achieve this functionality making it extremely portable across systems that support bash. QCD operates out of the directory <code>~/.qcd</code> and learns which directories you visit by storing symbolic links and their corresponding absolute paths in a file called <code>store</code>. This allows QCD to quickly resolve the absolute path of a symbolic link given a recognizable input and switch to that directory.
</p>

## Compatibility
<p align="justify">
QCD is compatible with macOS and popular Linux distributions in bash environments between v3.2 and v5.1.
</p>

## Dependencies
<p align="justify">
QCD does not require any special dependencies to operate as a command line utility and uses common builtin commands during execution. However, there may be some dependencies missing depending on the operating system QCD is installed on. Some operating systems do not natively ship with the <code>curl</code> command which is used by QCD to download updates, making it a non-critical dependency. This means that if the user wants to use QCDs update functionality, then they will have to manually install this dependency using a tool like <a href="https://ubuntu.com/server/docs/package-management"><code>apt</code></a> or <a href="https://brew.sh"><code>brew</code></a>.
</p>

## Installation

#### Downloading QCD
<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of QCD. You can perform this download within a browser environment or using a command line utility like <code>wget</code> or <code>curl</code> as shown below.

```bash
# Using Wget
command wget https://github.com/nalinahuja22/qcd/archive/v2.0.3.zip

# Using Curl
command curl -sL https://github.com/nalinahuja22/qcd/archive/v2.0.3.zip > v2.0.3.zip
```

Alternatively, you can clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release since the git repository is comparatively larger.
</p>

#### Installing QCD
<p align="justify">
Navigate to the location where QCD has been downloaded onto your machine, unzip the archive if needed, and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install.sh">install.sh</a> script. This executable will install QCD into the directory <code>~/.qcd</code> and add the QCD command to your terminal profile. When the installation finishes, please source your terminal profile and restart your terminal to fully configure the installation.<br><br>If you would like to do a manual installation of QCD, all you need to do is move the program files you downloaded, besides the <a href="https://github.com/nalinahuja22/qcd/blob/master/install.sh">install.sh</a> file, into the directory <code>~/.qcd</code> which you will have to create yourself. Then source your terminal profile after adding the following command to it and restart your terminal.

```bash
command source ~/.qcd/qcd.sh
```

#### Updating QCD
To manually update QCD to a newer release, simply follow the same installation process or use the update flag as described in the flags section. Don't worry, QCDs lookup file will not be modified during an update.
</p>

## Usage

#### Input Format
<p align="justify">
Just like the builtin command <code>cd</code>, simply indicate a valid path relative to the current working directory and QCD will navigate to it. Where QCD differs from <code>cd</code> is that you can indicate a keyword, prefix, or subsequence related to a directory that QCD has previously seen and the program will attempt to resolve the directory's absolute path and navigate to it.
</p>

```bash
# Standard Input    # Special Input
qcd [path]          qcd [keyword, prefix, subsequence]
```

<p align="justify">
When a keyword is passed to QCD as input, the program will attempt a case sensitive search for the matching directory. When passing a prefix or subsequence to QCD as input, the program will attempt a case insensitive search for the matching directory. In the previous input format, the input must start with the first character of the linked directory you wish to navigate to since QCD expects a subsequence rooted at the first character of the linked directory.<br><br>Assume for the following examples that a directory <code>node-modules</code> exists and has been added to QCDs lookup file.
</p>

```bash
# Path Example           # Keyword Example    # Prefix Example    # Subsequence Example
qcd ./../node-modules    qcd node-modules     qcd node            qcd nm
```

<p align="justify">
QCD is able to interpret file system sequences like <code>.</code> and <code>..</code> during file system navigation and accept a special input in the format <code>N..</code> which will tell QCD to jump to the Nth parent directory relative to the current working directory.
</p>

```bash
# File System Sequences    # nth Parent Directory
qcd ./../[directory]       qcd [n]..
```

<p align="justify">
These usages can be viewed anytime using the help flag described in the usage section.
</p>

#### Completion Engine
<p align="justify">
QCD ships with a custom completion engine that can be activated by hitting the tab key twice. Much like the builtin command <code>cd</code>, this completion engine is able to complete directories of the current working directory and their subdirectories as well as interpret file system sequences like <code>.</code> and <code>..</code> during completion. QCD builds upon these standard features to allow for the completion of directories not in the current working directory using information QCD has stored in its lookup file. It is also able to complete subdirectories of complete, prefix, and subsequenced linked directories.<br><br>Assume for the following examples that a directory <code>node-modules</code> exists and has been added to QCDs lookup file.
</p>

```bash
# Complete Example             # Prefix Example       # Subsequence Example
qcd node-modules/<tab><tab>    qcd node/<tab><tab>    qcd nm/<tab><tab>
```

#### Manual Input
<p align="justify">
If multiple paths are resolved from same symbolic link, the user will have to manually choose the path they wish to navigate to from an arrow key navigable menu which can be cleanly exited from by either pressing the <code>q</code> key or sending a <code>SIGINT</code> to the program. There are several redundancies built into the program to entirely avoid or simplify the manual selection process in order to streamline the use of QCD.
</p>

## Flags
<p align="justify">
QCD offers many different flags that are important to simplifying interaction between the user and QCD.
</p>

#### Remember Directory
<p align="justify">
The remember flag allows the user to add a symbolic links to QCDs lookup file. Without any arguments, QCD will add a linkage to its lookup file that corresponds to the present working directory. The user can specify a valid path after the remember flag to add a linkage specific to that path.

</p>

```bash
# No Arguments          # With Path
qcd [-r, --remember]    qcd [-r, --remember] [path]
```

<p align="justify">
In both cases, the linkage name is automatically derived from the directory path. To set a custom linkage name, please see the <a href="#alias-directory">alias</a> flag usage.
</p>

#### Alias Directory
<p align="justify">
The alias flag allows the user to add a symbolic link for the current directory to QCDs lookup file with a custom alias and this operation can be done as many times as the user desires.
</p>

```bash
# With Alias
qcd [-a, --alias] [alias]
```

<p align="justify">
The alias flag can be used in conjunction with the <a href="#remember-directory">remember</a> flag to alias a non-local directories.
</p>

```bash
# With Remember Flag
qcd [-a, --alias] [alias] [-r, --remember] [path]
```

#### Forget Directory
<p align="justify">
The forget flag allows the user to remove a symbolic links from QCDs lookup file. Without any arguments, QCD will remove a linkage from its lookup file that corresponds to the present working directory. The user can specify a valid path or symbolic link after the forget flag to remove all matching linkages.
</p>

```bash
# No Arguments        # With Path                  # With Linkage
qcd [-f, --forget]    qcd [-f, --forget] [path]    qcd [-f, --forget] [link]
```

#### Options
<p align="justify">
The options flag lists all symbolic links in QCDs lookup file that match the specified input without navigating to a matching local directory, if it exists.
</p>

```bash
qcd [-o, --options] [link]
```

#### Back Directory
<p align="justify">
The back directory flag allows the user to swtich to the directory they most recently switched from and it uses an internally tracked variable similar to $OLDPWD achieve this functionality.
</p>

```bash
qcd [-b, --back-dir]
```

#### Make Directory
<p align="justify">
The make directory flag allow the user to create a directory at a specified path and automatically switch to that directory once it is created. QCD internally adds a symbolic linkage to its lookup file that corresponds to the new directory if QCD is configured to track directories. QCDs directory tracking behavior is explained in the <a href="#track-directories">next</a> section.
</p>

```bash
qcd [-m, --make-dir]
```

#### Track Directories
<p align="justify">
The track directories flag allows the user to toggle the directory tracking behavior of QCD. When directory tracking is enabled, QCD will add new directories to its lookup file as they are visited. This feature is disabled by default.
</p>

```bash
qcd [-t, --track-dirs]
```

#### Clean
<p align="justify">
The clean flag removes symbolic linkages from QCDs lookup file that correspond to directories that may have been renamed or deleted by the user. QCD automatically cleans the lookup file at the start of each bash session, so it is not necessary to manually clean the lookup file too often.
</p>

```bash
qcd [-c, --clean]
```

#### List
<p align="justify">
The list flag outputs the current contents of the lookup file sorted by symbolic link.
</p>

```bash
qcd [-l, --list]
```

#### Other
<p align="justify">
QCD supports a set of standard flags such as the help, version, and update flags.
</p>

```bash
# Help Flag         # Version Flag         # Update Flag
qcd [-h, --help]    qcd [-v, --version]    qcd [-u, --update]
```
