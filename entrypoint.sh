#!/bin/bash
set -e
echo "initialize deb8gollum container"
echo "set working directory to: /root/wiki"
cd /root/wiki
if [ "$#" != "0" ]; then
    CMD="$1"
    if [ "$CMD" == 'gollum' ]; then
        echo "perform standard gollum start using following command:"
        echo "   $ $@"
        exec "$@"
        exit
    elif [ "$CMD" == 'ruby' ]; then
        echo "perform a rack gollum start using following command"
        echo "   $ $@"
        if [ "$#" == "1" ]; then
            echo "error: no application file provided."
            exit 1
        fi
        if [ ! -f "$2" ]; then
            echo "error: application file not found."
            exit 1
        fi
        exec "$@"
        exit
    elif [ $CMD == 'help' ]; then
        echo "show help"
    else
        exec "$@"
        exit
    fi
fi

echo
echo "usage: genebarker/deb8gollum <command> [<args>]"
echo
echo "The available commands are:"
echo "   gollum [<args>]  Run gollum using given arguments"
echo "   ruby FILE        Run gollum FILE as a rack application"
echo "                    (file must be located in /root/wiki)"
echo "   help             Display this usage guide"
echo
echo "The wiki content is a git repository located at:"
echo "   /root/wiki"
echo
echo "To use a wiki repository on the host, mount it, i.e:"
echo "   $ docker run -d -p 4567:4567 \\"
echo "       -v /home/elvis/mywiki:/root/wiki \\"
echo "       genebarker/deb8gollum gollum"
echo
echo "To run gollum as a rack application, place the app's files in"
echo "the wiki repository, then run it, i.e.:"
echo "   $ docker run -d -p 4567:4567 \\"
echo "       -v /home/elvis/mywiki:/root/wiki \\"
echo "       genebarker/deb8gollum ruby gollumrack.rb"
echo
echo "To bypass script, just enter desired command, i.e.:"
echo "   $ docker run -i -t genebarker/deb8gollum /bin/bash"
echo
exit 0
