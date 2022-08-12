Gameboost is a simple shell script to tweak FreeBSD settings for running games.
It is inspired by [gamemode](https://github.com/FeralInteractive/gamemode) for
Linux. It is designed to set some tweaks to the system before execute the
selected command and restore them after. The script should be run by normal
users, not the root user. Also, it may require to write some configuration
to it. Please, read further to get more details about it.  If you read this
file on GitHub: **please don't send pull requests here**. All will be
automatically closed. Any code propositions should go to the
[Fossil](https://www.laeran.pl/repositories/gameboost) repository.

At this moment the script support only Nvidia graphic cards tweaks. Any help
with Intel or AMD GPUs is welcome.

Currently, the script tested with a few Windows games, and it can reduce or even
prevent some problems like random freezes and boost FPS a little.

### Dependencies

If you use Nvidia graphic card:

* Nvidia driver proper for your graphic card, for example, the newest: `pkg
  install nvidia-driver`
* Nvidia settings utility: `pkg nvidia-settings`

The script has also its own dependencies:

* zenity package for ask for password and show notifications:
  `pkg install zenity`
* sudo package, installed and configured, so the user can create a virtual
  device, `pkg install sudo` and `visudo` and proper changes in the
  configuration.

### Installation

* Put the *gameboost.sh* script when anywhere it will be accessible by the selected
  user.

### Configuration

There are a few things to configure, before using the script. Please, open it
with your favorite text editor and read the first lines of the script,
where the configuration section is. There is everything explained.

### Usage

To execute the selected command with *gameboost.sh*, enter the command as the
argument for the script. For example, if *gameboost.sh* is in PATH, to execute
game *mygame* you can type in terminal: `gamemode.sh mygame`. If you want to
execute *mygame* with additional arguments, put everything in quotes (as one
argument for the script): `gamemode.sh "mygame --somearg --anotherarg"`.

As the tweaks in the script can depend not only on your hardware but also on
the command to execute, it is recommended to experiment a bit with the settings
in the script. If you open it in your favorite editor, each tweak should have
a proper description. If not or it is unclear, feel free to report the issue.

### License

The project is released under 3-Clause BSD license.

### TODO

* Suppport for Intel GPUs
* Support for AMD GPUs
* More tweaks
* Rewrite it as a GUI program (someday)

---
That's all for now, as usual, I have probably forgotten about something important ;)

Bartek thindil Jasicki
