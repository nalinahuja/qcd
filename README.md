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

```
source ~/.qcd/qcd.sh
```

To manually update QCD to a newer release, simply follow the same installation process or use the update flag as described in the usage section. Don't worry, your store file will not be modified during an update.
</p>

## Usage

<p align="justify">
Just like the builtin command <code>cd</code>, simply indicate a valid path relative to the current directory and QCD will navigate to it. Where QCD differs from <code>cd</code> is that you can indicate a keyword or subsequence related to a directory you have previously visited and QCD will attempt to resolve the directory's absolute path and navigate to it.
</p>

<p align="justify">
When indicating a keyword to QCD, it can be the full form of a linked directory and QCD will attempt a case sensitive search using that input. When indicating a prefix or subsequence to QCD, they must start with the first character of the linked directory you wish to navigate to and QCD will attempt a case insensitive search using that input.
</p>

<p align="justify">
QCD ships with a custom completion engine that can be activated by hitting the tab key twice. This engine is able to complete directories of the current working directory as well as linked directories QCD has recorded. It is also able to complete subdirectories of the current working directory, valid symbolic links, and prefix or subsequenced symbolic links.
</p>

<p align="justify">
If multiple paths are resolved from same symbolic link, the user will have to manually choose from a numbered list of unique paths by inputting the number displayed next to the path they wish to navigate to. This selection phase can be exited by passing a blank input or a single character <code>q</code> to the program. There are several redundancies built into the program to entirely avoid or simplify the manual selection process in order to streamline the use of QCD.
</p>

<p align="justify">
QCD offers many different flags to the user to better allow them to manage and use QCD.



The user has the ability to manually create and manage the symbolic links stored by QCD. The <code>-r</code> flag can be used to command QCD to remember the current working directory so that you can navigate to it later. The <code>-m</code> flag can be used to create a directory at the indicated, valid path for which QCD will automatically create a linkage. The <code>-f</code> flag can be used to command QCD to forget matching symbolic links or paths. By indicating <code>-f</code> after a valid link, QCD will forget all instances of the specified link from the store file and it will not show up as a completion suggestion unless you visit a directory with that name. The user can also opt to only indicate <code>-f</code>, which means QCD will forget the link related to the current working directory from the store file. Directory linkages stored by QCD can be listed by using the <code>-l</code> flag and the user can opt to indicate a prefix of a link or a regex string to filter the output. Lastly, the user can choose to clean their store file of defunct symbolic links that point to nonexistent or modified directories with the use of the <code>-c</code> flag. Keep in mind that it's not necessary to manually clean the store file since QCD automatically cleans the store file when a new shell session is started. A full list of different usages and options supported by QCD can be seen below or in your terminal using the <code>-h</code> flag.
</p>

```
Usage:
  qcd                         Change to home directory
  qcd [path]                  Change to valid directory
  qcd [link]/[subdir]/...     Change to linked directory
  qcd [N]..                   Change to Nth parent directory

Options:
  qcd [-h, --help]            Show this help
  qcd [-v, --version]         Show current version
  qcd [-u, --update]          Update to latest version

  qcd [-c, --clean]           Clean store file
  qcd [-l, --list]            List directory linkages
  qcd [-r, --remember]        Remember present directory
  qcd [-f, --forget]          Forget only present directory
  qcd [link] [-f, --forget]   Forget matching symbolic links
  qcd [link] [-l, --list]     List matching directory linkages
  qcd [path] [-m, --mkdir]    Create and switch to new directory
```
