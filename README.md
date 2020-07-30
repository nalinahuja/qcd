## QCD

<p align="justify">
QCD is a bash utility that extends upon the exisiting capabilities of the builtin command <code>cd</code>. It allows the user to quickly change from one directory to another by specifying a valid path, keyword, or subsequence to the program as a command line argument. QCD utilizes common builtin commands to achieve this functionality and works completely locally by storing symbolic links in a file called <code>store</code> which is located within the program folder <code>~/.qcd</code>. QCD learns which directories you visit by storing symbolic links and their corresponding absolute paths in a way such that if a symbolic link is passed to QCD, the program can resolve the absolute path and navigate to that directory so long as QCD has previously visited it. The program is designed to deliver a snappy experience while packing a lot of functionality.
</p>

## Compatibility

<p align="justify">
QCD is compatible with macOS and popular Linux distributions in bash environments between v3.2 and v5.0.
</p>

## Dependencies

<p align="justify">
QCD does not require any dependencies to operate as a command line utility. The only dependency it requires is the <code>curl</code> command which is used internally by QCD to download updates when using the <code>-u</code> flag. Please make sure that this command is installed on your machine if you want to use the self update functionality of QCD.<br><br>While not exactly a dependency, please update your bash environment to the latest version to get the best experience possible with QCD.
</p>

## Installation

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can perform this download within a browser environment or using a command line utility like <code>wget</code> or <code>curl</code>. Alternatively, you can clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded onto your machine and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd">install_qcd</a> script. This executable will install QCD to your home directory in a hidden folder called <code>~/.qcd</code> and add the QCD command to your terminal configuration. When the install script finishes, please restart your terminal and source your terminal profile to fully configure the installation.<br><br>To update QCD to a newer release, simply follow the same installation process or use the <code>-u</code> flag as described in the usage section. Don't worry, your store file will not be modified during the update.
</p>

## Usage

<p align="justify">
Just like the builtin command <code>cd</code>, simply indicate a valid path relative to the current directory and QCD will navigate to that directory. Where QCD differs from <code>cd</code> is that you can indicate a keyword or subsequence related to a directory you have previously visited and QCD will attempt to resolve the  directory's absolute path and navigate to it. When indicating a keyword, it can be the prefix or the full form of a linked directory. When indicating a subsequence, you must start the subsequence with the first character of the linked directory you wish to navigate to.<br><br>QCD ships with a custom completion engine that can be activated by hitting the tab key twice. This engine is able to complete symbolic links QCD has recorded as well as subdirectories of the current working directory and symbolic links.<br><br>If multiple links share a common prefix, the user can indicate <code>/</code> after a link to tell QCD not to wildcard search the store file and attempt a direct link match. If multiple paths match to the same symbolic link, the user will have to manually choose from a numbered list of unique paths by inputting the number displayed next to the path they wish to navigate to. This selection phase can be exited by passing a blank input or a single character <code>q</code> to the program. There are several redundancies built into the program to entirely avoid or simplify the manual selection process in order to streamline the use of QCD.<br><br>The user also has the ability to manage the symbolic links stored by QCD. The <code>-r</code> flag can be used to command QCD to remember the current working directory so that you can navigate to it later. The <code>-f</code> flag is used to command QCD to forget matching symbolic links or paths. By indicating <code>-f</code> after a link, QCD will forget all instances of the specified link from the store file and it will not show up as a completion suggestion unless you visit a directory with that name. The user can also opt to only indicate <code>-f</code>, which means QCD will forget the link related to the current working directory from the store file. Directory linkages stored by QCD can be listed by using the <code>-l</code> flag and the user can opt to indicate a prefix of a link or a regex string to filter the output. Lastly, the user can choose to clean their store file of defunct symbolic links that point to nonexistent or modified directories with the use of the <code>-c</code> flag. Keep in mind that it's not necessary to manually clean the store file since QCD automatically cleans the store file when a new shell session is started. A full list of different usages and options supported by QCD can be seen below or in your terminal using the <code>-h</code> flag.
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
  qcd [link] [-l, --list]     List matching directory linkages
  qcd [link] [-f, --forget]   Forget matching symbolic links
```
