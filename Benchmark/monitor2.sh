#!/usr/bin/env bash
# memusg -- Measure memory usage of processes in KiB
# Usage: memusg COMMAND [ARGS]...
#
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2010-08-16
############################################################################
# Copyright 2010 Jaeho Shin.                                               #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

set -um

#echo "Start Monitor Script"
#echo "Monitor Script: start Check Inputs"
# check input
[[ $# -gt 0 ]] || { sed -n '2,/^#$/ s/^# //p' <"$0"; exit 1; }

##echo "Monitor Script: End Check Inputs"

#echo "Monitor Script: 3"
DIR="${@: -1}"
#echo "Monitor Script: 4"
# TODO support more options: peak, footprint, sampling rate, etc.
#echo "Monitor Script: 5"
pgid=$(ps -o pgid= $$)
# make sure we're in a separate process group
#echo "Monitor Script: 6"
if [[ "$pgid" == "$(ps -o pgid= $(ps -o ppid= $$))" ]]; then
    #echo "Monitor Script: 6.1"
    cmd=
    #echo "Monitor Script: 6.2"
    set -- "$0" "$@"
    #echo "Monitor Script: 6.3"
    for a; do cmd+="'${a//"'"/"'\\''"}' "; done
    #echo "Monitor Script: 6.4"
    exec setsid bash -c "$cmd"
    #echo "Monitor Script: 6.5"
fi
#echo "Monitor Script: 7"

# detect operating system and prepare measurement
case $(uname) in
    Darwin|*BSD) sizes() { /bin/ps -o rss= -g $1; } ;;
    Linux) sizes() { /bin/ps -o rss= -$1; } ;;
    *) echo "$(uname): unsupported operating system" >&2; exit 2 ;;
esac
#echo "Monitor Script: 8"
# monitor the memory usage in the background.
start=$(($(date +%s%N)/1000000))
(
peak=0
while sizes=$(sizes $pgid)
do
    set -- $sizes
    sample=$((${@/#/+}))
    end=$(($(date +%s%N)/1000000))
    runtime=$((end-start))
    row="$runtime,$sample"
    let peak="sample > peak ? sample : peak"
    echo $row >> $DIR
    sleep 0.1
done
) &
monpid=$!

#echo "End monitor Script 1"

# run the given command
exec ${*: -$#:$#-1}

#echo "End Monitor Script 2"
