## QCD
<p align="justify">
QCD is a bash utility that extends upon the exisiting capabilities of the builtin command <code>cd</code>. It allows the user to quickly change from one directory to another by specifying a valid path, directory keyword, directory prefix, or character subsequence to the program as a command line argument. QCD works completely locally and utilizes common builtin commands to achieve this functionality making it extremely portable across systems that support bash. QCD operates out of the directory <code>~/.qcd</code> and learns which directories you visit by storing symbolic links and their corresponding absolute paths in a file called <code>store</code>. This allows QCD to quickly resolve the absolute path given a recognizable input and switch to that directory.
</p>

## Compatibility
<p align="justify">
QCD is compatible with macOS and popular Linux distributions in bash environments between v3.2 and v5.0.
</p>

## Dependencies
<p align="justify">
QCD does not require any dependencies to operate as a command line utility and uses common builtins during execution. The only dependency it requires is the <code>curl</code> command which is used internally by QCD to download updates. Please make sure that this command is installed on your machine if you want to use the  self update functionality of QCD.<br><br>While not exactly a dependency, please update your bash environment to the latest version to get the best experience possible with QCD.
</p>

## Installation
<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can perform this download within a browser environment or using a command line utility like <code>wget</code> or <code>curl</code>. Alternatively, you can clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release since the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded onto your machine and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd">install_qcd</a> script. This executable will install QCD in the directory <code>~/.qcd</code> and add the QCD command to your terminal profile. When the installation finishes, please source your terminal profile and restart your terminal to fully configure the installation.<br><br>If you would like to do a manual installation of QCD, all you need to do is move the repository contents you downloaded, besides the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd">install_qcd</a> file, into a folder at <code>~/.qcd</code> which you will have to create yourself. Then source your terminal profile after adding the following command to your terminal profile and restart your terminal.

```bash
source ~/.qcd/qcd.sh
```

To manually update QCD to a newer release, simply follow the same installation process or use the update flag as described in the usage section. Don't worry, your store file will not be modified during an update.
</p>

## Usage
<p align="justify">
Just like the builtin command <code>cd</code>, simply indicate a valid path relative to the current directory and QCD will navigate to it. Where QCD differs from <code>cd</code> is that you can indicate a keyword or subsequence related to a directory you have previously visited and QCD will attempt to resolve the directory's absolute path and navigate to it.
</p>

#### Input Format
<p align="justify">
When indicating a keyword to QCD, it can be the complete linked directory and QCD will attempt a case sensitive search using that input. When indicating a prefix or subsequence to QCD, they must start with the first character of the linked directory you wish to navigate to and QCD will attempt a case insensitive search using that input. QCD is also capable of parsing an input of form <code>[N]..</code> and QCD will navigate to the Nth parent directory relative to the current working directory.
</p>

```bash
# Keyword Example    # Prefix Example    # Subsequence Example    # Nth Directory Example
qcd node-modules     qcd node            qcd nm                   qcd 2..
```

#### Completion Engine
<p align="justify">
QCD ships with a custom completion engine that can be activated by hitting the tab key twice. This engine is able to complete directories of the current working directory as well as directories not in the current working directory that QCD has automatically recorded and linked. It is also able to complete subdirectories of the current working directory, complete linked directories, and prefix or subsequenced linked directories.
</p>

```bash
# PWD Example                    # Link Example                 # Subsequence Example
qcd ./node-modules/<tab><tab>    qcd node-modules/<tab><tab>    qcd nm/<tab><tab>
```

#### Manual Input
<p align="justify">
If multiple paths are resolved from same symbolic link, the user will have to manually choose from a numbered list of unique paths by inputting the number displayed next to the path they wish to navigate to. This selection phase can be cleanly exited by passing a blank input or a single character <code>q</code> to the program. There are several redundancies built into the program to entirely avoid or simplify the manual selection process in order to streamline the use of QCD.
</p>

## Flags
<p align="justify">
QCD offers many different flags that are important to simplifying interaction between the user and QCD.
</p>

#### Remember Directory
<p align="justify">
The remember flag adds a symbolic link to QCDs lookup file that corresponds to the present working directory.
</p>

```bash
qcd [-r, --remember]
```

#### Forget Directory
<p align="justify">
The forget flag removes a symbolic link from QCDs lookup file that corresponds to the present working directory. The user can opt to include a complete linkage ahead of the list flag to remove all matching instances of that linkage.
</p>

```bash
qcd [link] [-f, --forget]
```

#### Make Directory
<p align="justify">
The mkdir flag creates a directory at a specified, valid path and switches to that directory. QCD internally adds a symbolic linkage to its lookup file that corresponds to the path of the new directory.
</p>

```bash
qcd [path] [-m, --mkdir]
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
The list flag outputs the current contents of the lookup table in sorted order. The user can include an optional regex string ahead of the list flag to filter the output.
</p>

```bash
qcd [regex] [-l, --list]
```

#### Other
<p align="justify">
QCD offers a set of standard flags including the help, version, and update flags.
</p>

```bash
# Help Flag         # Version Flag         # Update Flag
qcd [-h, --help]    qcd [-v, --version]    qcd [-u, --update]  
```
