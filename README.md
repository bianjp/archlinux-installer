# Arch Linux installer

Shell scripts that save you time of installing and setting up [Arch Linux](https://www.archlinux.org/).

## Disclaimer

These scripts are not fully tested. Play at your own risk.

## Features

* Install Arch Linux
* Setup Gnome Desktop Environment
* Install and setup some softwares
* __Almost unattended__

In fact, it is just a collection of commands which I'll run when installing Arch Linux manually.

## Prerequisite

To use these scripts, you must have:

* Booted an installation medium. (See [Beginners' Guide](https://wiki.archlinux.org/index.php/Beginners'_guide#Boot_the_installation_medium) for help)
* Prepared your storage devices (See [Beginners' Guide](https://wiki.archlinux.org/index.php/Beginners'_guide#Prepare_the_storage_devices) for help)

Of course, you should also make these scripts available in your installing process. You can use any way you like, for example:

* Save them in your installation medium or other storage devices you can access while installing
* Save them anywhere you can download from while installing

Since `git` in not available in official ISO files, `git clone` while installing won't be a good idea.

## Usage

Change these scripts as you like before executing them.

1. After you've prepared your storage devices, `cd` into this directory, and run:
    ```
    ./install.sh
    ```
2. Reboot and login into Gnome Desktop Environments
3. Open a terminal and run `/archlinux-installer/setup_extra.sh`
4. Reboot

In case some script failed, solve the problem and rerun it. Optionally, remove the commands that has be succefully run from the script before rerunning it to save time.

## License

MIT
