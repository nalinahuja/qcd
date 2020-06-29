## QCD

<p align="justify">
QCD is a bash utility that extends upon the exisiting capabilities of the builtin command <i>cd</i>. It allows the user to quickly change from one directory to another by specifying a valid path or symbolic link to the program as a command line argument. QCD utilizes common builtin commands to achieve this functionality and works completely locally by storing symbolic links in a file called <i>store</i> which is located within the program folder <i>~/.qcd</i>. QCD learns which directories you visit by storing symbolic links and their corresponding absolute paths in a way such that if a symbolic link is passed to QCD, the program can resolve the absolute path and navigate to that directory so long as QCD has visited it previously. The program is designed to deliver a snappy experience while still packing a lot of functionality.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded to on your machine and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd.sh">install_qcd</a> script. This executable will install QCD to your home directory as a hidden folder <i>~/.qcd</i> which contains the QCD shell program and add the QCD command to your terminal configuration. When the install script finishes, please restart your terminal and source your terminal profile to fully configure the installation.<br><br>To update QCD to a newer release, simply follow the same installation process or use the -u flag as described in the usage section. Don't worry, your store file will not be modified during the update.
</p>

## Dependencies

<p align="justify">
QCD does not require any dependencies to operate as a command line utility. The only dependency it requires is the <i>curl</i> command which is used internally by QCD to download updates when using the -u flag. Please make sure that this command is installed on your machine if you want to use the self update functionality within QCD.
</p>

## Usage

<p align="justify">
Just like the builtin command <i>cd</i>, simply indicate a valid path or keyword related to a path you have previously visited and QCD will navigate to that directory. QCD ships with a custom completion engine that can be activated by hitting the tab key twice. The engine is able to complete subdirectories of the current working directory and symbolic links QCD has recorded. This completion engine is also able to complete subdirectories of a linked path by indicating a forward slash after a symbolic link and hitting the tab key again to view the subdirectories of that linked path.<br><br>If multiple paths are matched with the symbolic link, the user will have to manually choose from a numbered list of unique paths by inputting the number next to the path you wish to navigate to. There are several redundancies built into the program to entirely avoid or simplify the manual selection process to streamline the use of QCD. This selection phase can be exited by passing a blank input or a single character <i>q</i> to the program.<br><br>The user also has the ability to manage the symbolic links stored by QCD. The -a flag can be used to add the current working directory as a symbolic link to the store file and completion engine so that you can quickly navigate to it later. The -f flag is used to remove symbolic links or paths from the store file. By indicating -f after a link, QCD will remove all instances of the specified link from the store file and it will not show up as a completion suggestion unless you revisit that directory. The user can also opt to only indicate -f, which means QCD will remove the current working directory from the store file. Lastly, the user can choose to clean their store file of defunct symbolic links that point to non-existent or modified directories with the use of the -c flag. Keep in mind that it's not necessary to manually clean the store file a lot since QCD automatically cleans the store file when a new shell session is started.
</p>

```
Usage:
  qcd                       Change to home directory
  qcd [path]                Change to valid directory
  qcd [link]/[subdir]/...   Change to linked directory
  qcd [N]..                 Change to Nth parent directory

Options:
  qcd -h                    Show this help
  qcd -v                    Show current version
  qcd -u                    Update to latest version

  qcd -c                    Clean store file
  qcd -r                    Remember present directory
  qcd -f                    Forget only present directory
  qcd [link] -f             Forget all matching symbolic links
```
