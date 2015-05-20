deb8gollum
----------
This docker image is a Gollum wiki on Debian 8 (Jessie). It also includes an option with an example `gollumrack.rb` for running Gollum as a rack application.

For usage info, just run the image without a command:

    $ docker run --rm genebarker/deb8gollum

```
usage: genebarker/deb8gollum <command> [<args>]

The available commands are:
   gollum [<args>]  Run gollum using given arguments
   ruby FILE        Run gollum FILE as a rack application
                    (file must be located in /root/wiki)
   help             Display this usage guide

The wiki content is a git repository located at:
   /root/wiki

To use a wiki repository on the host, mount it, i.e:
   $ docker run -d -p 4567:4567 \
       -v /home/elvis/mywiki:/root/wiki \
       genebarker/deb8gollum gollum

To run gollum as a rack application, place the app's files in
the wiki repository, then run it, i.e.:
   $ docker run -d -p 4567:4567 \
       -v /home/elvis/mywiki:/root/wiki \
       genebarker/deb8gollum ruby gollumrack.rb

To bypass script, just enter desired command, i.e.:
   $ docker run -i -t genebarker/deb8gollum /bin/bash
```