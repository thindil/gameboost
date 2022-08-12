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
# Enable the settings elated to the Nvidia graphic cards. You probably can
# disable it, if you don't have that card. If set to 1 (default) it is enabled,
# when set to 0, disabled
nvidia_boost=1

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
if [ -z $pass ]
then
   zenity --error --text="Cancelled." --title="GameBoost error"
   return 1
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
   # Force the Nvidia graphic card to Maximum Performance mode. This can give a
   # small boost of FPS. Important, if you have more than one graphic card and
   # the Nvidia card isn't the first, change the number of the card in [gpu:0].
   # To get all available Nvidia cards installed, type in terminal:
   # nvidia-settings -q gpus
   nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1'
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
echo $pass | sudo -S sysctl kern.sched.preempt_thresh=0

# It is probably a good idea to reset the user's password stored in the
# memory before we run the command.
pass=""

# Run the selected command, passes as the first argument to the script. If you
# want to execute command with arguments, pass the whole command in quotes. For
# example ./gameboost.sh "mygame --somearg --anotherarg"
$1

# Ask for password again to execute sudo command via zenity password dialog
pass=$(zenity --password --title="GameBoost")

# If the user entered an empty password, or cancelled the password dialog,
# show the error dialog and stop the script.
if [ -z $pass ]
then
   zenity --error --text="Cancelled." --title="GameBoost error"
   return 1
fi

# Reset the kernel settings to their previous values. You may need to change
# the values below to your settings.
echo $pass | sudo -S sysctl kern.sched.preempt_thresh=120

# Reset the Nvidia graphic card settings to the previous values. Same as above,
# if you have different the default settings, please edit the values.
if [ $nvidia_boost -eq 1 ]; then
   nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=2'
fi
