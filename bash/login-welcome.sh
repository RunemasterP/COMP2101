#!/bin/bash
#
# This script produces a dynamic welcome message
# it should look like
#   Welcome to planet hostname, title name!

# Task 1: Use the variable $USER instead of the myname variable to get your name
# Task 2: Dynamically generate the value for your hostname variable using the hostname command - e.g. $(hostname)
# Task 3: Add the time and day of the week to the welcome message using the format shown below
#   Use a format like this:
#   It is weekday at HH:MM AM.
# Task 4: Set the title using the day of the week
#   e.g. On Monday it might be Optimist, Tuesday might be Realist, Wednesday might be Pessimist, etc.
#   You will need multiple tests to set a title
#   Invent your own titles, do not use the ones from this example

###############
# Variables   #
###############
today=$(date +%A)
#Lazy way to check the days of the week. Do nothing if they don't match.
test $today = "Monday" && title="Grumbler"
test $today = "Tuesday" && title="Confused"
test $today = "Wednesday" && title="Thankful"
test $today = "Thursday" && title="Tired"
test $today = "Friday" && title="Chuffed"
test $today = "Saturday" && title="Weekend Warrior"
test $today = "Sunday" && title="Lazy"
#title="Overlord"
#myname="dennis"
hostname=$(hostname -f)
currentTime=$(date +%T)
###############
# Main        #
###############
greeting="Welcome to planet $hostname, $title $USER! It is currently $currentTime."
echo $greeting
