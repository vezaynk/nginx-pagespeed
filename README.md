# NGINX + Google PageSpeed

[![Build](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/build.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/build.yml)
[![Deploy to Dokku](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/deploy.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/deploy.yml)
[![Health Check](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/health-check.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/health-check.yml)



Configuring NGINX to build correctly is a pain. Not because of anything wrong with it, but rather because of how slim the standard install is: no HTTPS, no Web-Sockets, no PAM, etc., since they are all independent modules. While this is sound in principle, it's inconvenient for end-users.

Luckily, most distributions fork it, make a few changes and bundle it with everyone's favorite modules. Installing NGINX from your distribution's repositories will always give you a batteries-included configuration. This convenience presents a dilemma: either accept what your distribution gives you and lose the flexibility of customizing your installation or bite the bullet and try to figure everything out yourself.

I could no longer accept the default installation once I decided to have [Google PageSpeed](https://developers.google.com/speed/pagespeed/module) on my servers. If you're on this repository, I don't think I need to explain the benefits. In short, Mod PageSpeed is a collection of filters that apply optimizations to content going through it such as compression, minification, conversion to modern formats, lazy-loading, and more.

There was painfully little documentation on the topic of forking a Debian package, but I managed to piece it together. This repository is the result: a seamless way to substitute Debian-flavored NGINX with Debian-flavored NGINX + PageSpeed. Enjoy!

## Installation

This installation guide aims to support any modern Debian-based system (including Ubuntu). Open an issue if it doesn't work. The Debian packages are built on Ubuntu 20.04, and should be compatible with newer releases.

### Download Keys

The GitHub worker signs the packages using the key below. You need to trust them to be able to install the packages.

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8028BE1819F3E4A0
```

### Connect Source

Create `/etc/apt/sources.list.d/nginx-pagespeed.list` and put the following line into it:

```
deb https://nginx-pagespeed.knyz.org/dist/ /
```

This will enable apt to find the PageSpeed-patched versions of NGINX.

### Pin Source

To prevent other sources from overwriting NGINX during updates, pin it by creating `/etc/apt/preferences.d/99nginx-pagespeed` and placing the following inside of it:

```
Package: *
Pin: origin nginx-pagespeed.knyz.org
Pin-Priority: 900
```

This will make apt unconditionally prefer PageSpeed-patched versions of NGINX.

### Installing

- Run `sudo apt update`, look out for any errors.
- Run `apt-cache policy nginx-full`, validate that the selected candidate is from `nginx-pagespeed.knyz.org`.
- Run `sudo apt install nginx-full`, or `nginx-light` depending on what you're looking for

Done!

## Usage

There are more than enough guides around PageSpeed. My recommended setup is to place the following file into `/etc/nginx/conf.d/pagespeed.conf`:

```
pagespeed on;
pagespeed FileCachePath              "/var/cache/pagespeed/";
pagespeed FileCacheSizeKb            102400;
pagespeed FileCacheCleanIntervalMs   3600000;
pagespeed FileCacheInodeLimit        500000;
pagespeed RewriteLevel CoreFilters;
```

Remember to run `sudo systemctl reload nginx` after any changes.


# Repository Status

This repository is largely autonomous, and self-reports important information.

## Health Check [![Health Check](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/health-check.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/health-check.yml)

Health check is the most important flag. If it is failing, it means that a broken build may have been pushed into the repository. Inspect the CI to see if it's a real issue.

Currently, `nginx-extras` is failing. This is not new. Only the check is.

## Deploy to Dokku [![Deploy to Dokku](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/deploy.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/deploy.yml)

The repository is hosted on my company's Dokku server. The Deploy to Dokku flag indicates whether the packages are successfully being pushed upstream. Failure likely indicates that the server is offline for some reason, but will be back soon! The package can be installed directly from this repository in the meantime.

## Build [![Build](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/build.yml/badge.svg)](https://github.com/knyzorg/nginx-pagespeed/actions/workflows/build.yml)

Is this green? If it is, that means that the current Debian upstream is building correctly. If it is red, then it means that updates are not being produced.
