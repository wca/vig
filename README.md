# Will's Illumos change test repository

This repository contains an unmodified fork of the illumos-gate master under
the illumos-master branch.  This repository's 'master' branch is a
disconnected branch that contains scripts intended to assist in testing
changes against illumos-gate, within a Vagrant-managed virtual machine.

# Usage

This repository is intended to be forked and used for illumos-gate patches.
Contributions to this repository's master copy should consist solely of
changes to the master branch's script collection.  Periodically, the
illumos-master branch will be updated from the master illumos-gate repository.

This section details how to use forks of this repository.

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

* `./git/vig host fromscratch`

This will take between 4 and 24 hours, depending on your system.  The time
is spent as follows:

* ~10% VM setup, test boot environment install/setup, other overhead
* ~35% building illumos-gate
* ~55% running the zfs test suite
