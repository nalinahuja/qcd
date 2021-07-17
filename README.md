## qcd
<p align="justify">
qcd is a bash utility that extends upon the exisiting capabilities of the builtin command <code>cd</code>. It allows the user to quickly change from one directory to another by specifying a valid path, directory alias, directory prefix, or character subsequence to the program as a commandline argument. qcd works completely locally and utilizes common builtin commands to achieve this functionality making it extremely portable across systems that run bash. qcd operates out of the directory <code>~/.qcd</code> and remembers which directories you visit by storing symbolic linkages on disk. This file allows qcd to quickly search for and resolve the absolute path from a symbolic linkage and switch to that directory given a recognizable input.
</p>

## Compatibility
<p align="justify">
qcd is compatible with macOS and popular Linux distributions in bash environments between v3.2 and v5.1.
</p>

## Dependencies
<p align="justify">
qcd does not require any special dependencies to operate as a command line utility and uses common builtin commands during normal execution. However, there are some optinal dependencies that may be missing depending on the operating system qcd is installed on. Some operating systems do not natively ship with the <code>curl</code> command which is used by qcd to download updates, making it a non-critical dependency. This means that if the user wants to use qcd's update functionality, then they will have to manually install this dependency using a tool like <a href="https://ubuntu.com/server/docs/package-management"><code>apt</code></a> or <a href="https://brew.sh"><code>brew</code></a>.
</p>

## Setup

#### Downloading qcd
<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja/qcd/releases">release</a> page of this repository and download the latest version of qcd. This download can be done within a browser environment or using a command line program like <code>wget</code> or <code>curl</code> as shown below.

```bash
# Using wget
command wget https://github.com/nalinahuja/qcd/archive/v2.1.zip

# Using curl
command curl -sL https://github.com/nalinahuja/qcd/archive/v2.1.zip > v2.1.zip
```

Alternatively, you can clone this <a href="https://github.com/nalinahuja/qcd">repository</a> but it is recommended that you download the most recent release since the repository is comparatively larger in size.
</p>

#### Installing qcd
<p align="justify">
Navigate to the location where qcd has been downloaded onto your machine, unzip the archive if needed, and run the <a href="https://github.com/nalinahuja/qcd/blob/master/install.sh">install.sh</a> script. This executable will install qcd into the directory <code>~/.qcd</code> and add the qcd command to your terminal profile. When the installation finishes, please source your terminal profile and restart your terminal to fully configure the installation.<br><br>If you would like to do a manual installation of qcd, all you need to do is move the program files you downloaded, besides the <a href="https://github.com/nalinahuja/qcd/blob/master/install.sh">install.sh</a> file, into a directory named <code>~/.qcd</code> which you will have to create yourself. Then restart your terminal after adding the following command to it.

```bash
command source ~/.qcd/qcd.sh
```

#### Updating qcd
To manually update qcd to a newer release, simply follow the same installation process or use the update flag as described in the flags section below. Don't worry, qcd's lookup file will not be modified during an update.
</p>

## Usage

#### Input Format
<p align="justify">
Just like the builtin command <code>cd</code>, you can specifiy either an absolute or relative path as a commandline argument and qcd will navigate to it. Where qcd differs from <code>cd</code> is that you can indicate a keyword, prefix, or character subsequence related to a directory that qcd has previously seen and the program will attempt to resolve the directory's absolute path and navigate to it.
</p>

```bash
# Standard Input    # Special Input
qcd [path]          qcd [keyword, prefix, subsequence]
```

<p align="justify">
When a keyword is passed to qcd as input, the program will attempt a case sensitive search for the matching directory. When passing a prefix or character subsequence to qcd as input, the program will attempt a case insensitive search for the matching directory. In the latter input format, the input must start with the first character of the linked directory you wish to navigate to since qcd expects a subsequence rooted at the first character of the directory you wish to navigate to.<br><br>Assume for the following examples that a non-local directory <code>node-modules</code> exists and it has been added to qcd's lookup file.
</p>

```bash
# Path Example           # Keyword Example    # Prefix Example    # Subsequence Example
qcd ./../node-modules    qcd node-modules     qcd node            qcd nm
```

<p align="justify">
qcd is able to interpret file system sequences like <code>.</code> and <code>..</code> and also accept a special input in the format <code>n..</code> which will tell qcd to jump to the nth parent directory relative to the present working directory.
</p>

```bash
# File System Sequences    # nth Parent Directory
qcd ./../[directory]       qcd [n]..
```

<p align="justify">
These usages can be viewed anytime using the help flag described in the usage section below.
</p>

#### Completion Engine
<p align="justify">
qcd ships with a custom completion engine that can be activated by hitting the tab key twice. Much like the builtin command <code>cd</code>, this completion engine is able to complete directories of the present working directory and their subdirectories as well as interpret file system sequences like <code>.</code> and <code>..</code> during completion. qcd builds upon these standard features to allow for the completion of directories not in the present working directory using information qcd has stored in its lookup file. It is also able to complete subdirectories of linked directories based on a keyword, prefix, or character subsequence.<br><br>Assume for the following examples that a non-local directory <code>node-modules</code> exists and it has been added to qcd's lookup file.
</p>

```bash
# Keyword Example              # Prefix Example       # Subsequence Example
qcd node-modules/<tab><tab>    qcd node/<tab><tab>    qcd nm/<tab><tab>
```

#### Manual Input
<p align="justify">
If multiple paths are resolved from same symbolic link, the user will have to manually choose the path they wish to navigate to from an arrow key navigable menu which can be cleanly exited from by either pressing the <code>q</code> key or sending a <code>SIGINT</code> to the program. There are several redundancies built into the program to simplify or entirely avoid manual intervention from the user in order to streamline the use of qcd.
</p>

## Flags
<p align="justify">
qcd offers many different flags that are important to smoothening user experience.
</p>

#### Remember Directory
<p align="justify">
The remember flag allows the user to add a symbolic linkage to qcd's lookup file. Without any arguments, qcd will add a linkage to its lookup file that corresponds to the present working directory. The user can specify a valid path after the remember flag to add a linkage specific to that path.

</p>

```bash
# No Arguments          # With Path
qcd [-r, --remember]    qcd [-r, --remember] [path]
```

<p align="justify">
In both usages, the linkage keyword is automatically derived from the directory path. To set a custom linkage keyword, please see the <a href="#alias-directory">alias</a> flag usage.
</p>

#### Alias Directory
<p align="justify">
The alias flag allows the user to remember the present working directory by a custom linkage keyword. This flag can be used as many times as the user desires on directories that already exist in qcd's lookup file to update linkage keywords.
</p>

```bash
# With Alias
qcd [-a, --alias] [alias]
```

<p align="justify">
The alias flag can be used in conjunction with the <a href="#remember-directory">remember</a> flag to alias non-local directories.
</p>

```bash
# With Remember Flag
qcd [-a, --alias] [alias] [-r, --remember] [path]
```

#### Forget Directory
<p align="justify">
The forget flag allows the user to remove a symbolic linkage from qcd's lookup file. Without any arguments, qcd will remove a linkage from its lookup file that corresponds to the present working directory. The user can specify a valid path or keyword after the forget flag to remove all matching symbolic linkages.
</p>

```bash
# No Arguments        # With Path                  # With Keyword
qcd [-f, --forget]    qcd [-f, --forget] [path]    qcd [-f, --forget] [keyword]
```

#### Options
<p align="justify">
The options flag displays the paths of symbolic linkages in qcd's lookup file that match the specified query in a manually selectable menu for more precise directory navigation. The query argument can be a keyword, prefix, or character subsequence related to symbolic linkages in qcd's lookup file.
</p>

```bash
qcd [-o, --options] [query]
```

#### Back Directory
<p align="justify">
The back directory flag allows the user to swtich back to the directory they most recently switched from.
</p>

```bash
qcd [-b, --back-dir]
```

#### Make Directory
<p align="justify">
The make directory flag allows the user to create a directory at a specified path and automatically switch to that directory once it is created. qcd internally adds a symbolic linkage to its lookup file that corresponds to the new directory if qcd directory trackig is enabled. qcd's directory tracking behavior is explained in the <a href="#track-directories">track</a> flag section.
</p>

```bash
qcd [-m, --make-dir]
```

#### Track Directories
<p align="justify">
The track directories flag allows the user to toggle the directory tracking behavior of qcd. When directory tracking is enabled, qcd will automatically add new directories to its lookup file as they are visited. This feature is disabled by default.
</p>

```bash
qcd [-t, --track-dirs]
```

#### Clean
<p align="justify">
The clean flag removes symbolic linkages from qcd's lookup file that correspond to directories that may have been renamed or deleted. qcd automatically cleans the lookup file at the start of each bash session, so it is not necessary to manually clean the lookup file too often.
</p>

```bash
qcd [-c, --clean]
```

#### List
<p align="justify">
The list flag outputs the current contents of the lookup file sorted by keyword.
</p>

```bash
qcd [-l, --list]
```

#### Other
<p align="justify">
qcd supports a set of standard flags such as the help, version, and update flags.
</p>

```bash
# Help Flag         # Version Flag         # Update Flag
qcd [-h, --help]    qcd [-v, --version]    qcd [-u, --update]
```
