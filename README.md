# Will's Illumos/FreeBSD merge repo

This repository is an amalgamation of Illumos and FreeBSD repositories.  It
serves as an export site of Spectra Logic ZFS changes, with branches against
various versions of FreeBSD/stable and Illumos.

# Usage

This repository is intended to be forked and used for illumos-gate patches.
This section details how to do so.

First, install VirtualBox or VMware, Vagrant, and the vagrant-multiprovider-snap
plugin.  The last of these will usually be installed as follows:

* `vagrant plugin install vagrant-multiprovider-snap`

Then, create a Vagrant box for OpenIndiana hipster:

* `git clone git://github.com/wca/oi-packer`
* `cd oi-packer && packer build template.json`

Note that you may want the `-only=vmware-iso` or `-only=virtualbox-iso`
arguments to `packer build`.

This will take a while (about an hour), mostly because the steps include a
lot of extra waits for slower machines.  Next, import the Vagrant box that
created for the hypervisor you want:

* `vagrant box add --name oi-hipster-20150330 ./oi-hipster-20150330.box`

Once this is done, create a directory to hold metadata for the Vagrant
machine you'll be creating, then clone this repository to a subdirectory
called 'git':

* `mkdir oi-hipster-zfs.1`
* `cd oi-hipster-zfs.1`
* `git clone git://github.com/wca/illumos-gate git`

Now, edit git/openindiana/Vagrantfile if necessary (the default machine
configuration is 4 VCPUs and 8GB), then fire up an initial build & test run:

* `./git/openindiana/fromscratch.sh`

This will take between 4 and 24 hours, depending on your system.  The time
is spent as follows:

* ~10% VM setup, test boot environment install/setup, other overhead
* ~35% building illumos-gate
* ~55% running the zfs test suite
