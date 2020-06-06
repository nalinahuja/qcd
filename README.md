## QCD

<p align="justify">
QCD is a bash utility that allows the user to quickly change to a different directory by specifying a symbolic link or a valid path. QCD is installed at <i>~/.qcd</i> and works completely locally by storing symbolic links in a file called <i>store</i> which is by located within the program folder. QCD works by storing symbolic links and their respective absolute paths as you visit them and storing them in a way such that if a keyword is passed to QCD, it can resolve the absolute path from the keyword if it has been seen by QCD.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded on your machine and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd.sh">install_qcd</a> script. This executable script will install QCD to your home directory as a hidden folder which contains the QCD program and add the QCD command to your terminal configuration. When the install script finishes, please restart your terminal and source your terminal profile to fully configure the installation.<br><br>To update QCD to a newer release, simply follow the same installation process. Don't worry, your store file will not be modified during installation.
</p>

## Usage

<p align="justify">
Just like the command <i>cd</i>, simply indicate a valid path from the current directory or keyword related to a path you have previously visited and QCD will resolve the full path and switch to it. QCD has the ability to complete the path of both subdirectories of the current working directory and subdirectories of linked paths via a custom completion function that can be activated by hitting the tab key twice, just like most bash commands. QCD does this by identifying the source of the path, whether it be a link of the present working directory and then expanding symbolic links to their actual path if present. If multiple paths are found that lead to a directory matching the symbolic link, then the user will have to manually choose from a numbered list of unique paths by inputting the number next to the path you wish to navigate to. This selection phase can be exited either by sending a SIGINT to QCD or by passing a blank input or a single character <i>q</i> to the program.<br><br>The user also has the ability to manage the symbolic links stored by QCD in the store file. The -a flag is used to add the current directory as a link to the store file so that you can quickly navigate to it later. The -a flag also adds the link to the completion suggestions. The -f flag is used to remove links and paths from the store file. By indicating -f after a link, QCD will remove all instances of the link from the store file and it will not show up as a completion suggestion unless you revisit that directory. The user can also opt to only indicate -f, which means QCD will remove the current working directory from the store file. Additionally, the user can choose to clean their store file of defunct symbolic links to non-existent directories by indicating -c after the QCD command. Keep in mind that it's not necessary to manually clean the store file a lot since QCD automatically cleans the store file when a new shell session is started.
</p>

```
Usage:
  qcd                       Change To Home Dir
  qcd [path]                Change To Valid Path
  qcd [link]/[subdir]/...   Change To Linked Path

Options:
  qcd -h                    Show This Help
  qcd -c                    Clean Store File
  qcd -f                    Forget Current Dir
  qcd -r                    Remember Current Dir
  qcd [link] -f             Forget Symbolic Link
```
