## QCD

<p align="justify">
QCD is a bash utility that allows the user to quickly change the current directory by specifying a symbolic link or a valid directory. QCD is installed at <i>~/.qcd</i> and works completely locally by storing links in a file called <i>store</i> which is by located within the program folder. QCD works by storing links and their absolute path as you visit them and storing them such that if a keyword is passed to QCD, it can resolve the absolute path from the endpoint if it has been seen by QCD.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository is comparatively larger.
</p>

<p align="justify">
Then, navigate to the location where the QCD repository contents have been downloaded and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd.sh">install_qcd</a> script. This script will install QCD to your home directory as a hidden folder which contains the QCD program and add the QCD command to your terminal configuration. When the install script finishes, please restart your terminal and source your terminal profile to fully configure the installation.
</p>

## Usage

<p align="justify">
Just like the command cd, simply indicate a valid path from the current directory or keyword related to a path you have previously visited and QCD will resolve the directory and switch to it. QCD has the ability complete the path based on the contents of the current directory and previously visited ones. QCD can also resolve full paths to subdirectories of linked paths by simply indicating the link followed by a subdirectory of that link, just like a normal path, and QCD will automatically expand the link and navigate to the subdirectory if it exists. QCD also comes featured with a custom completion script that allows completion of linked paths and their subdirectories.

The user also has the ability to manage the symbolic links stored by QCD. By indicating -f after a link, QCD will remove all instances of the link from the store file and it will not show up unless you revisit that directory. The user can also opt to only indicate -f, which means QCD will remove the current working directory from the store file. Additionally, the user can choose to clean their store file of invalid directories by indicating only -c after the QCD command. However, it's not necessary to manually clean the store file since QCD automatically cleans the store file when a new shell session is started.
</p>

```
Help:
  qcd -h                Show Usage

Change Directories:
  qcd [path]			      Change To Valid Path
  qcd [link]/[subdir]		Change To Linked Path With Opt. Subdir

Link Management:
  qcd -c			          Cleanup Store File
  qcd -f		            Forget Current Directory
  qcd [link] -f	      	Forget Symbolic Link
```
