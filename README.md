## QCD

<p align="justify">
QCD is a bash utility that extends upon the exisiting capabilities of the builtin command <code>cd</code>. It allows the user to quickly change from one directory to another by specifying a valid path or symbolic link to the program as a command line argument. QCD utilizes common builtin commands to achieve this functionality and works completely locally by storing symbolic links in a file called <code>store</code> which is located within the program folder <code>~/.qcd</code>. QCD learns which directories you visit by storing symbolic links and their corresponding absolute paths in a way such that if a symbolic link is passed to QCD, the program can resolve the absolute path and navigate to that directory so long as QCD has previously visited it. The program is designed to deliver a snappy experience while packing a lot of functionality.
</p>

## Compatibility

<p align="justify">
QCD is officially compatible with macOS and popular Linux distributions.
</p>

## Dependencies

<p align="justify">
QCD does not require any dependencies to operate as a command line utility. The only dependency it requires is the <code>curl</code> command which is used internally by QCD to download updates when using the <code>-u<code> flag. Please make sure that this command is installed on your machine if you want to use the self update functionality within QCD.
</p>

## Installation

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can download either via a GUI interface or using a utility like <code>wget</code> or <code>curl</code>. Alternatively, you can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded onto your machine and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd">install_qcd</a> script. This executable will install QCD to your home directory as a hidden folder called <code>~/.qcd</code> and add the QCD command to your terminal configuration. When the install script finishes, please restart your terminal and source your terminal profile to fully configure the installation.<br><br>To update QCD to a newer release, simply follow the same installation process or use the <code>-u<code> flag as described in the usage section. Don't worry, your store file will not be modified during the update.
</p>

## Usage

<p align="justify">
Just like the builtin command <code>cd</code>, simply indicate a valid path or keyword related to a path you have previously visited and QCD will navigate to that directory. QCD ships with a custom completion engine that can be activated by hitting the tab key twice. The engine is able to complete subdirectories of the current working directory and symbolic links QCD has recorded.<br><br>If multiple paths are matched to a symbolic link, the user will have to manually choose from a numbered list of unique paths by inputting the number next to the path they wish to navigate to. There are several redundancies built into the program to entirely avoid or simplify the manual selection process in order to streamline the use of QCD. This selection phase can be exited by passing a blank input or a single character <code>q</code> to the program.<br><br>The user also has the ability to manage the symbolic links stored by QCD. The <code>-r</code> flag can be used to command QCD to remember the current working directory so that you can navigate to it later. The <code>-f</code> flag is used to command QCD to forget matching symbolic links or paths. By indicating <code>-f</code> after a link, QCD will forget all instances of the specified link from the store file and it will not show up as a completion suggestion unless you revisit that directory. The user can also opt to only indicate <code>-f</code>, which means QCD will forget the link related to the current working directory from the store file. Lastly, the user can choose to clean their store file of defunct symbolic links that point to nonexistent or modified directories with the use of the <code>-c</code> flag. Keep in mind that it's not necessary to manually clean the store file since QCD automatically cleans the store file when a new shell session is started. A full list of different usages and options supported by QCD can be seen below or in your terminal using the <code>-h</code> flag.
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
  qcd [-r, --remember]        Remember present directory
  qcd [-f, --forget]          Forget only present directory
  qcd [link] [-f, --forget]   Forget all matching symbolic links
```
