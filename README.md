## QCD

<p align="justify">
QCD is a bash utility that allows the user to quickly change the current directory by specifying an endpoint or a valid directory. QCD is installed at <i>~/.qcd</i> and works completely locally by storing visited endpoints in a file called <i>store</i> which is by located within the program folder. QCD works by storing endpoints and their absolute path as you visit them and storing them such that if a keyword is passed to QCD, it can resolve the absolute path from the endpoint if it has been seen by QCD.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository contains comparatively larger.
</p>

<p align="justify">
Once you have completed the above task, navigate to the location where the QCD repository contents have been downloaded and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install_qcd">install_qcd</a> script. This script will install QCD to your home directory as a hidden folder which contains the QCD program and the store file and add the QCD function to your terminal configuration.
</p>

## Usage

<p align="justify">
Just like the command cd, simply indicate a valid path from the current directory or keyword related to a path you have previously visited and QCD will resolve the directory and switch to it. QCD has the ability complete the path based on the contents of the current directory and previously visited endpoints. This means that if you want to go to a subdirectory of a previously visited directory, you only need to specify the keyword to that directory followed by the subdirectory. If multiple paths exist to the same endpoint, you will have to manually select which one to jump to. If the keyword or indicated directory in the is not found, an error will appear. The user also has the ability to manage the linked paths they have stored. By indicating -f after a link, QCD will remove all instances of the link from the store file and it will not show up unless you revisit that directory. Additionally, the user can choose to clean their store file of invalid directories by indicating only -c after the QCD command.
</p>

```
# Navigate To Valid Path
qcd $PATH

# Navigate To/Forget Linked Path
qcd $LINK [-f]

# Clean Store File
qcd -c
```
