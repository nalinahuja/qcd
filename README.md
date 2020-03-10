## QCD

<p align="justify">
QCD is a terminal utility that allows the user to quickly change the current directory by specifying an endpoint or a valid directory. QCD is installed at __~/.qcd__ and works completely locally by storing visited endpoints in a file called _store_ which is by located within the program folder. QCD works by storing endpoints and their absolute path as you visit them and storing them such that if a keyword is passed to QCD, it can resolve the absolute path from the endpoint if it has been seen by QCD.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/qcd">repository</a> but it is recommended that you download the most recent release as the git repository contains comparatively larger.
</p>

<p align="justify">
Once you have completed the above task, navigate to the location where the QCD repository contents have been downloaded and run the <a href="https://github.com/nalinahuja22/qcd/blob/master/install.sh">install.sh</a> script. This script will install QCD to your home directory as a hidden folder which contains the QCD program and the store file and add the QCD function to your terminal configuration.
</p>

## Usage

<p align="justify">
Just like the command cd, simply indicate a path or keyword of a path you have been to previously and QCD will attempt to navigate to the directory. QCD has the ability to complete the names of keywords and contents of the current directory. If the keyword or a file in the current directory is not found, an error will appear.
</p>

```
qcd $PATH
```
