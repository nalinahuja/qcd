## QCD

<p align="justify">
QCD is a terminal utility that allows the user to quickly change the current directory by specifying an endpoint or a valid directory. QCD works completely locally and stores visited endpoints in a file called store which is by default located at ~/.qcd. QCD works by storing endpoints and their absolute path as you visit them and storing them such that if a keyword is passed to QCD, it can resolve the absolute path from the endpoint if it has been seen by QCD.

Path completion and zsh support coming soon!
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository contains comparatively larger.
</p>

<p align="justify">
Once you have completed the above task, navigate to the location where the QCD repository contents have been downloaded and run the install.sh script. This script will install QCD to your home directory as a hidden folder (~/.qcd) which contains the QCD program and the store file and add the qcd function to your terminal configuration.
</p>

<p align="justify">
After the success of the installation script, please run the following command which allows for both directory and keyword completion in the current directory.
</p>

```
source ~/.qcd/comp.sh
```

## Usage

<p align="justify">
Just like the command cd, simply indicate a path or keyword of a path you have been to previously and qcd will attempt to navigate to the directory. If the keyword is not found, an error will appear.
</p>

```
qcd $PATH
```
