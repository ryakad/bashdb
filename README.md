Bash Debugger
=============

This simple debugger allows you to step through your bash scripts and pause
execution while you examine variables at specified lines or break conditions

Usage
-----

To use this script you simply prepend the call to the script you want to
test with `bashdb`.

bashdb will read off the first parameter as the script you want to debug and
forward any other parameters to that script when it calls it. The script
will then return a prompt for you to enter commands and step through
debugging.

You can enter h or ? at the prompt for a full listing of available commands.

This is an extension of an example from the book "Learning The Bash Shell"
by O'Reilly
