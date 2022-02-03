#!/bin/bash
# 09 Sep 2017
# Author Emanuel Becerra

version='1.0.0'

# Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

# Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# Help function
function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT read_1.fq.gz read_2.fq.gz${NORM}"\\n
  echo -e "Example: ${BOLD}$SCRIPT read_1.fq.gz read_2.fq.gz${NORM}"\\n
  exit 1
}

############### Input ###############

f_file=$1
r_file=$2

# Defaults

o_dir="`date +%d-%b-%y_%Hh%Mm%Ss`"

############### Main Code ###############

# Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

echo -e \\n\\n"##########################################"
echo          "# Starting execution of $SCRIPT "
echo -e       "##########################################"\\n\\n

echo "The current directory is:`pwd`"
echo "The current date is: `date`"
echo "The current user is: `whoami`"
echo -e "The current server is: `hostname`"\\n\\n

# Global Output
mkdir $o_dir

# Trim Galore Output
mkdir $o_dir/Trim_Galore

trim_galore --quality 20 --fastqc --paired -o $o_dir/Trim_Galore $1 $2
