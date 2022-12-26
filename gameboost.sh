#!/bin/sh
# Copyright © 2022 Bartek Jasicki <thindil@laeran.pl>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#################
# Configuration #
#################
# Enable the settings related to the Nvidia graphic cards. You probably can
# disable it, if you don't have that card. If set to 1 (default) it is enabled,
# when set to 0, disabled
nvidia_boost=1
# Enable the settings related to the Wine program. If you don't run a Windows
# game, you can disable it. If set to 1 (default) it is enables, when set to 0,
# disabled
wine_boost=1
# The nice command level. Setting this value a bit higher than 0 may give some
# perfomance boost, especially for games which heavily use system resources,
# like a processor, a disk or a graphic card. The reason is, many games'
# heaviest tasks are graphic rendering or reading resources from the disk which
# are the system's tasks, thus the game wait on the others for them,
# unnecessary using system's resources. Don't set the value below 0 as for it
# the game will require root permissions to run, which isn't a best idea.
# Recommended settings are between 0 and 5, any value higher can degrade
# performance. To disable this feature completely, set it to 0.
nice_level=3

# Check if a command to execute entered. If not, show the error dialog and
# stop the script
if [ $# -eq 0 ]
then
   zenity --error --text="Enter the command to execute" --title="GameBoost error"
   return 1
fi

# Ask for password to execute sudo command via zenity password dialog
pass=$(zenity --password --title="GameBoost")

# If the user entered an empty password, or cancelled the password dialog,
# show the error dialog and stop the script.
if [ -z "$pass" ]
then
   zenity --error --text="Cancelled starting the game." --title="GameBoost error"
   return 1
fi

# Check if the user entered the proper password. If not, show the dialog with
# the information about the problem and stop the script.
if ! echo "$pass" | sudo -S ls "$HOME" > /dev/null; then
   zenity --error --text="Invalid password entered." --title="GameBoost error"
   exit 1
fi

#################
# Nvidia cards  #
#################
# Set some Nvidia related graphic card settings. It may have a different
# impact on your performance, thus it is a good idea to test various settings
# for them
if [ $nvidia_boost -eq 1 ]; then
   # During heavy load of CPU (processor), usually Nvidia threading
   # optimization can cause lags. To disable it, set this variable to 0
   # (default). To enable it, set it to 1.
   export __GL_THREADED_OPTIMIZATIONS=0

   # Setting other than default value for the __GL_YIELD variable can have some
   # negative impact on performance of the Nvidia cards. Especially on the
   # older models of them. Unsetting it, sets the variable to the default
   # version. Other values are NOTHING and USLEEP.
   unset __GL_YIELD

   # Disable synchronization with the monitor vertical refresh rate. Enabling
   # it can cause tearing especially on dual monitors setups. Usually it is
   # better to enable it in the game setting. To disable it, set this variable
   # to 0 (default). To enable it, set it to 1.
   export __GL_SYNC_TO_VBLANK=0

   # Remove the limitation of the shader cache size. The cache will not be
   # cleanup unless it changed. It can give some performance boost especially
   # when the game uses a lot of shaders. To remove size limit, set this
   # variable to 1 (default). To bring back size limit, remove the setting.
   export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

   # Disable Nvidia antialiasing setting and let the game use its own. Usually
   # it is better to enable it in the game settings. In some cases, disabling
   # it can give small boost in performance and reduce tearing. To bring back
   # the values from nvidia-settings, remove these lines. Available values are
   # from 0 to 5 but not every Nvidia card (especially an ancient one) support
   # all of them. It is also recommended to change all these settings to the
   # one level, like 0 or 3 for each.
   export __GL_FSAA_MODE=0
   export __GL_DEFAULT_LOG_ANISO=0
   export __GL_LOG_MAX_ANISO=0

   # Force the Nvidia graphic card to Maximum Performance mode. This can give a
   # small boost of FPS. Important, if you have more than one graphic card and
   # the Nvidia card isn't the first, change the number of the card in [gpu:0].
   # To get all available Nvidia cards installed, type in terminal:
   # nvidia-settings -q gpus
   # Remember the previous value of the setting. If you plan to play in
   # multiboxing mode, it could be a good idea to set this value manually
   powermizer=$(nvidia-settings -tq '[gpu:0]/GPUPowerMizerMode')
   # And set the new value for the setting
   nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1'
fi

#################
# Windows games #
#################
# Set some settings useful when running Windows games. It may have a different
# impact on your performance, thus it is a good idea to test various settings
# for them
if [ $wine_boost -eq 1 ]; then
   # Disable Wine logging. When a game produces a lot of Wine log messages it
   # can have a big impact on the performance. If you want to bring the default
   # setting, comment the line below. For the list of available debugging
   # options for Wine, please refer to the Wine project documentation. There
   # are too much of them to mention them all.
   export WINEDEBUG=-all

   # Disable logging for DXVK. The same as above, when DXVK produces a lot of
   # messages it can have impact on the performance. To bring default setting,
   # comment the line. For the list of available debugging options for DXVK,
   # please refer to the project documentation.
   export DXVK_LOG_LEVEL=none

   # Enable asynchronous patch for DXVK. Works only when you use the special
   # version of DXVK, https://github.com/Sporif/dxvk-async instead of the
   # standard. Which is recommended for the better performance. To disable the
   # patch, set the variable value to 0 or comment the line below.
   export DXVK_ASYNC=1

   # Enable using shared memory by the staging version of the Wine. Works only
   # with wine-proton or Wine with staging patches applied. In some cases it
   # can give a large boost in performance. To disable the setting, comment the
   # line below.
   export STAGING_SHARED_MEMORY=1
fi

#################
# FreeBSD       #
#################
# Set some FreeBSD kernel settings. Same as the settings above, it may have a
# different effect in various games, thus it may be a good idea to experiment
# with them a bit.

# Maximal (lowest) priority for the process threads to trigger preemption. The
# default value is 80, but usually, for desktop it is recommended to set it to
# 120. Setting it to 0 mean that all threads of all processes should trigger
# preemption. The max value is 250 (disable it completely). Setting it to 0
# prevents some sudden freezes in a couple of games, especially run by Wine. If
# you want to experiment with this value, it is a good idea to start with
# border values (0 and 250) to see which one has better impact on the game
# performance.

# Remember the previous value of the setting. If you plan to play in
# multiboxing mode, it could be a good idea to set this value manually
preempt_thresh=$(sysctl -n kern.sched.preempt_thresh)
# And set the new value for the setting
echo "$pass" | sudo -S sysctl kern.sched.preempt_thresh=0

# It is probably a good idea to reset the user's password stored in the
# memory before we run the command.
pass=""

# Run the selected command, passes as the first argument to the script. If you
# want to execute command with arguments, pass the whole command in quotes. For
# example ./gameboost.sh "mygame --somearg --anotherarg"
if [ $nice_level -eq 0 ]; then
   $1
else
   nice -n $nice_level "$1"
fi

# Ask for password again to execute sudo command via zenity password dialog
pass=$(zenity --password --title="GameBoost")

# If the user entered an empty password, or cancelled the password dialog,
# show the error dialog and stop the script.
if [ -z "$pass" ]
then
   zenity --error --text="Cancelled restoring the previous settings." --title="GameBoost error"
   return 1
fi

# Reset the kernel settings to their previous values. You may need to change
# the values below to your settings.
echo "$pass" | sudo -S sysctl kern.sched.preempt_thresh="$preempt_thresh"

# Reset the Nvidia graphic card settings to the previous values. Same as above,
# if you have different the default settings, please edit the values.
if [ $nvidia_boost -eq 1 ]; then
   nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=$powermizer"
fi
