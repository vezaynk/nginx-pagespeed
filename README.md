# NGINX + Pagespeed

This is a repository with the intent of archiving various verious of the Debian variant of nginx pre-packaged with the pagespeed module for your convenience. The availability of of versions will be quite arbitrary: those that I personally use.

For the unfamiliar, Pagespeed is a great piece of software with makes your website faster by applying a wide-variety of opt-in optimization strategies such as [compression, resizing, inlining and caching among others](https://www.modpagespeed.com/examples/). There is basically no downside to using this.

## Motivation

Getting NGINX into a comfortable state is a pain. Not because of anything wrong with it, but rather because of how slim the standard install is: no https, no websockets, etc as they are all meant to be modules. While this is a very sound and forward-thinking architecture, it pushes the burden of figuring out a sane setup onto the user most of who just want a working web server.

Luckily, most distributions handle all that stuff in advance by forking it, making a few small changes and bundling it with a dozen modules. Thus we get a more-or-less standardized, batteries-included setup by installing a single package. Wonderous!

This does have the downside that the average user would have a hard time taking a vanilla nginx setup for whatever reason and making a small change as they would have redo all the changes their distributor did as well. This is a pain I have certainly felt many times. By the case of NGINX has frustrated me so much that I decided to do go through the trouble of doing it properly.

The main change in question is, of course, the inclusion of the Pagespeed module.

## Install from GitHub

The fastest way to get going is to use my prebuilt packages. Simply clone this repository and install whatever version you need. 

The most straight-forward way of installing everything as needed is as follows:

```bash
sudo dpkg -i libnginx-mod-*_1.14.2-2_amd64.deb
sudo dpkg -i nginx-full_1.14.2-2_amd64.deb
```

Be sure to remove any existing NGINX installs beforehand to avoid conflicts.

Holding the package will allow 
```bash
sudo apt-mark hold nginx-full
```

## Install from Repository (Experimental)

I have a hard time suggesting anyone to actually do this, but hey! Why not, right?

I'm trying to get some sort of fancy packaging system up and running, but for the moment, it's not great. I will shoe-horn it once it's nicer.

To have a go at it, add `deb [trusted=yes] https://deb.knyazev.io/latest/ /` to your `sources.list` and install whatever you need.


## Compile from Source!

The process to patch Debian's NGINX is straight-forward but strangly undocumented. I suppose this is the case because people fall into one of two camps: Those who have no idea and those for whom this is trivial which ends up not producing any documentation whatsoever. My friends, worry not. I am here to change that.

Of course, all of this is unnecessary if the version of debian you seek has already been patched in this repository. Ideally, I would have you do this in a clone of this repository, but that is not a burden I wish to impose until there are tangible benefits to using it beyond a single store.

Nonetheless, the entire process generates a lot of files in the working directory, so I will have to insist on you creating a new working directory for sake of the preservation of your sanity.

The first thing to do is to get your hands on the the NGINX source from Debian, Pagespeed from Apache and prepare it for use:

```bash
git clone https://salsa.debian.org/nginx-team/nginx.git
cd nginx/debian/modules
git clone https://github.com/apache/incubator-pagespeed-ngx
cd incubator-pagespeed-nginx
git checkout 11ba8ea ## Find current hash: https://github.com/apache/incubator-pagespeed-ngx/releases/tag/latest-stable
echo `echo wget -O psol.tar.gz; cat PSOL_BINARY_URL` | BIT_SIZE_NAME=x64 bash
tar -xzvf psol.tar.gz
```

The above process uses the latest release, but that is not necessary. You can compile the `psol` locally instead of downloading them. This however, is a time consuming process which is more likely to break.

The second thing to do is to patch NGINX's build rules by finding the declaration of the `common_configure-flags` variable in `debian/rules` and appending `--add-module=$(MODULESDIR)/incubator-pagespeed-ngx` to it:

```bash
# configure flags
common_configure_flags := \
--with-cc-opt="$(debian_cflags)" \
--with-ld-opt="$(debian_ldflags)" \
--prefix=/usr/share/nginx \
***SNIP***
--with-http_v2_module \
--with-http_dav_module \
--with-http_slice_module \
--with-threads \
--add-module=$(MODULESDIR)/incubator-pagespeed-ngx ## Add me ##
```

Then we build:

```bash
sudo dpkg-buildpackage -rfakeroot -uc -b
```

The above command may occasionally prompt you to use the Release binaries to which you probably want to say `[Y]es`. Also it will take a really long time.

Once that is done, you may install. If you have a previous installation, remove `nginx-full` and everything relating to it. After that, you may install the new packages:

```bash
sudo dpkg -i libnginx-mod-*_1.14.2-2_amd64.deb
sudo dpkg -i nginx-full_1.14.2-2_amd64.deb
```

Last but not least, we don't want our package manager to undo all our hard work in the next update, so lets prevent that:

```bash
sudo apt-mark hold nginx-full
```
