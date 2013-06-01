# bashdb - Functions
#
# This file contains all the needed function to run the bashdb script
#
# Author: Ryan Kadwell <ryan@riaka.ca>


# After each line we will call this function to check our current line and
# all set breakpoints and break conditions
function _step_trap()
{
    _current_line=$1


    if (( $_steps >= 0 )); then
        let _steps=$(($_steps - 1))
    fi

    # check if we have reached one of our breakpoints
    if _at_linenumber; then
        _print_message "Reached breakpoint!"
        _show_trace
        _command_loop
    elif [ -n "$_break_condition" ]; then
        _print_message "Break condition $_break_condition true"
        _show_trace
        _command_loop
    else
        _show_trace
        _command_loop
    fi
}

# show the trace message if we are in trace mode.
function _show_trace()
{
    (( $_trace )) && _print_message "$PS4 : ${_lines[$_current_line]}"
}

# The main command loop
function _command_loop()
{
    local cmd args

    while read -e -p "@$_current_line> " cmd args; do
        case $cmd in
            \?|h)
                # display the menu
                _display_menu ;;
            bc)
                # set a break condition
                _setdb $args ;;
            bp)
                # set a break point or list break points.
                _setbp $args ;;
            cb)
                # clear one of the break points
                _clearbp $args ;;
            ds)
                # display the script we are working with
                _displayscript ;;
            g)
                # start/resume execution of this script
                return ;;
            q)
                exit ;;
            s)
                # step through script default to 1
                let _steps=${args:-1}
                return ;;
            x)
                # toggle execution trace
                _set_trace ;;
            !*)
                # pass to the shell
                eval ${cmd#!} $args ;;
            *)
                _print_message "Invalid command: '$cmd'" ;;
        esac
    done
}

# Test if we are at a given line number
function _at_linenumber()
{
    local i=0

    # loop through the breakpoints array and check to see if any of them
    # the current line number. If they do return true (0) otherwise return
    # false.
    if [ "$_linebp" ]; then
        while (( $i < ${#_linebp[@]} )); do
            if (( ${_linebp[$i]} == $_current_line )); then
                return 0
            fi
            let i=$i+1
        done
    fi

    return 1
}

# set a breakpoint at a given line number
function _setbp()
{
    local i

    if [ -z "$1" ]; then
        _listbp
    elif [ $(echo $1 | grep '^[0-9]*') ]; then
        _linebp=($(echo $( (for i in ${_linebp[*]} $1; do
            echo $i; done) | sort -n) ))
        _print_message "Breakpoint set at line $1"
    else
        _print_message "Please specify a numberic line number"
    fi
}

# List break points
function _listbp()
{
    if [ -n "$_linebp" ]; then
        _print_message "Breakpoints at lines: ${_linebp[*]}"
    else
        _print_message "No breakpoints have been set"
    fi

    _print_message "Break on condition:"
    _print_message "$_brcond"
}

# Clear individual or all break points
function _clearbp()
{
    local i bps

    if [ -z "$1" ]; then
        unset _linebp[*]
        echo "Breakpoints cleared"
    elif [ $(echo $1 | grep '^[0-9]*') ]; then
        bps=($(echo $(for i in ${_linebp[*]}; do
            if (( $1 != $i )); then
                echo $i;
            fi; done) ))
        unset _linebp[*]
        _linebp=(${bps[*]})
        _print_message "Breakpoint cleared at line $1"
    else
        _print_message "Please specify a numeric line number"
    fi
}

# set or clear a break condition
function _setbc()
{
    if [ -n "$*" ]; then
        _brcond=$args
        _print_message "Break when true: $_brcond"
    else
        brcond=
        _print_message "Break condition cleared"
    fi
}

# print out the shell script with markings for break points
function _displayscript()
{
    local i=1 j=0 bp cl

    (
        while (( $i <= ${#_lines[@]} )); do
            if [ ${_linebp[$j]} ] && (( ${_linebp[$j]} == $i)); then
                bp='*'
                let j=$j+1
            else
                bp=' '
            fi

            if (( $_current_line == $i )); then
                cl=">>"
            else
                cl="  "
            fi

            echo "$i:$bp $cl ${_lines[$i]}"
            let i=$(($i+1))
        done
    ) | less
}

# toggle execution trace on/off
function _set_trace()
{
    let _trace="! $_trace"
    if (( $_trace )); then
        _print_message "Execution Trace: ON"
    else
        _print_message "Execution Trace: OFF"
    fi
}

# prints passed arguments to Standard Error
function _print_message()
{
    echo -e "$@" >&2
}

# print command menu
function _display_menu()
{
    _print_message 'bashdb commands:
    bp [N]        set breakpoint at line N
    bp            list breakpoints and break condition
    bc string     set break condition to string
    bc            clear break condition
    cb [N]        clear breakpoint at line N
    cb            clear all breakpoints
    ds            display the test script and breakpoints
    g             start/resume execution
    s [N]         execute N statements
    x             toggle execution tracing on/off
    h, ?          print this menu
    ! string      passes string to a shell
    q             quit'
}

# remove temporary file
function _cleanup()
{
    rm $_debugfile 2>/dev/null
}
