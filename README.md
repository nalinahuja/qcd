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
QCD does not require any dependencies to operate as a command line utility and uses common builtins during execution. The only dependency it requires is the <code>curl</code> command which is used internally by QCD to download updates. Please make sure that this command is installed on your machine if you want to use QCDs the self update functionality. While not a dependency, please update your bash environment to the latest version to get the best possible experience with QCD.
</p>

## Installation

#### Downloading QCD
<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of QCD. You can perform this download within a browser environment or using a command line utility like <code>wget</code> or <code>curl</code> as shown below.

```bash
# Using Wget
command wget https://github.com/nalinahuja22/qcd/archive/v1.17.1.zip

# Using Curl
command curl -sL https://github.com/nalinahuja22/qcd/archive/v1.17.1.zip > v1.17.1.zip
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
To manually update QCD to a newer release, simply follow the same installation process or use the update flag as described in the usage section. Don't worry, your store file will not be modified during an update.
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
# File System Sequences    # Nth Parent Directory
qcd ./../[directory]       qcd [N]..
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
The remember flag adds a symbolic link to QCDs lookup file that corresponds to the present working directory. The user can opt to include a valid path ahead of the remember flag to add a specific path to the lookup file where the linkage name is automatically identified as the last directory in the path by QCD. To set a custom linkage name, the user can include an optional alias ahead of the path.
</p>

```bash
qcd [path] [alias] [-r, --remember]
```

#### Forget Directory
<p align="justify">
The forget flag removes a symbolic link from QCDs lookup file that corresponds to the present working directory. The user can opt to include a complete linkage ahead of the forget flag to remove all matching instances of that linkage.
</p>

```bash
qcd [link] [-f, --forget]
```

#### Make Directory
<p align="justify">
The mkdir flag creates a directory at a specified, valid path and switches to that directory. QCD internally adds a symbolic linkage to its lookup file that corresponds to the path of the new directory if QCD is set to track directories, tracking explained in next section.
</p>

```bash
qcd [path] [-m, --mkdir]
```

#### Track Directories
<p align="justify">
The track directories flag allows the user to change the directory tracking behavior of QCD. By default, QCD will add new directories to its lookup file as they are visited. This flag gives the user the ability to toggle this feature on and off at will.
</p>

```bash
qcd [-t, --track-dirs]
```

#### Options
<p align="justify">
The options flag lists all symbolic links in the store file that match the specified input without navigating to a matching local directory, if it exists.
</p>

```bash
qcd [link] [-o, --options]
```

#### Clean
<p align="justify">
The clean flag removes symbolic linkages from QCDs lookup file that correspond to directories that may have been renamed or deleted by the user. QCD automatically cleans the lookup file when a new shell session is started, so it is not necessary to frequently clean the lookup file manually.
</p>

```bash
qcd [-c, --clean]
```

#### List
<p align="justify">
The list flag outputs the current contents of the lookup file in sorted order. The user can include an optional case sensitive regex string ahead of the list flag to filter the contents of the lookup file.
</p>

```bash
qcd [regex] [-l, --list]
```

#### Other
<p align="justify">
QCD supports a set of standard flags such as the help, version, and update flags.
</p>

```bash
# Help Flag         # Version Flag         # Update Flag
qcd [-h, --help]    qcd [-v, --version]    qcd [-u, --update]
```
