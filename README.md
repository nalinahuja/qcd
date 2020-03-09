# QCD

<p align="justify">
QCD is a terminal utility that allows the user to quickly change the current directory by specifying an endpoint or a valid directory. QCD works completely locally and stores visited endpoints in a file called .qcd_store which is by default located at ~/.qcd.
</p>

## Install QCD

<p align="justify">
Please navigate to the <a href="https://github.com/nalinahuja22/qcd/releases">release</a> tab of this repository and download the latest version of this project. You can alternatively clone this <a href="https://github.com/nalinahuja22/spectra">repository</a> but it is recommended that you download the most recent release as the git repository contains comparatively larger.
</p>

<p align="justify">
Navigate to the location where the QCD repository contents have been downloaded and run the install.sh script. This will install QCD to your home directory as a hidden folder (.qcd) which contains the QCD program and the store file.
</p>

```
qcd() {
  if [[ $1 = '-reset' ]]
  then
    > ~/qcd/.qcd_store
  else
    . ~/qcd/qcd.sh $1
  fi
}


## Usage

<p align="justify">

</p>

```
qcd $PATH
```


```
