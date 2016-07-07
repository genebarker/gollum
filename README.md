## Gollum

[Gollum][1] webapp on Debian 8 (Jessie) with support for HTTP and strict HTTPS ([HSTS][2]).

### Improvements

This production proven image of Gollum just got a little better.. Enjoy!

- upgraded OS to Debian 8.5
- upgraded Gollum to 4.0.1
- upgraded Github Flavored Markdown to 0.6.9
- improved this readme

## Quick Start

1) Create a Git repository for your wiki:

```sh
$ cd
$ mkdir mywiki
$ cd mywiki
$ git init
```

(2) Add a starter document to the repository *(optional)*:

```sh
$ echo "Hello World!" > Home.md
$ git add Home.md
$ git commit -m 'Initial commit'
```

(3) Spin-up the Gollum container:

```sh
$ docker pull genebarker/gollum
$ docker run -d -p 80:80 -v ~/mywiki:/root/wiki genebarker/gollum --http
```

(4) Enjoy

## How to Use

For usage info, just run the image without a command:

```sh
$ docker run --rm genebarker/gollum
```

Which produces the following:

```sh
gollum - a Gollum webapp on Debian 8 Docker Container

usage: genebarker/gollum [OPTION]

The available OPTIONs are:
   --http [GOLLUMOPTION]...       Run Gollum using plain HTTP
   --hsts FQDN [GOLLUMOPTION]...  Run Gollum using HTTPS only
          (must provide FQDN, i.e. mybox.example.com)
   --help                         Display this message

To use wiki repository on the host, mount it, i.e.:
   $ docker run -d -p 80:80 \
       -v /home/me/wiki:/root/wiki \
       genebarker/gollum --http

To run with strict HTTPS creating new self-signed keys:
   $ docker run -d -p 80:80 -p 443:443 \
       genebarker/gollum --hsts mybox.example.com

To run with strict HTTPS using your own keys, mount them, i.e.:
   $ docker run -d -p 80:80 -p 443:443 \
       -v /etc/ssl:/etc/ssl \
       genebarker/gollum --hsts mybox.example.com

   (the cert's CN must match the FQDN)

To run as a rack application, place your config file in the repo,
mount it, and set RACK_APP environment variable to its name, i.e.:
   $ docker run -d -p 80:80 \
       -v /home/me/wiki:/root/wiki \
       -e RACK_APP=config.ru \
       genebarker/gollum --http

To run using a time zone other than UTC, set the TIMEZONE environment
variable to the desired time zone (TZ), i.e.:
   $ docker run -d -p 80:80 \
       -e TIMEZONE=America/Los_Angeles \
       genebarker/gollum --http

To bypass script, just enter desired command, i.e.:
   $ docker run -it genebarker/gollum bash

Key paths in the container:
   /root/wiki     - Wiki content (a git repository)
   /etc/ssl       - SSL keys and certificates
   /etc/ssl/private/ssl-cert-snakeoil.key  - Private SSL key
   /etc/ssl/certs/ssl-cert-snakeoil.pem    - Public SSL cert
```

## Notes

- This image uses GitHub Flavored Markdown ([GFM][3]).
- For a rack application, see the example `config.ru`, and be sure to append its required packages and gems to the respective RUN commands in the `Dockerfile`.
- See the [TZ Database][4] for the available values for the `$TIMEZONE` environment variable.

### Quick Start ###

[1]: https://github.com/gollum/gollum
[2]: https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
[3]: https://guides.github.com/features/mastering-markdown/
[4]: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
