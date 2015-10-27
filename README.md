# Will's Illumos change test repository

This repository contains scripts intended to assist in testing changes
against illumos-gate, within a Vagrant-managed virtual machine.  The scripts
are structured to also enable running them directly on an illumos system
being tested.

# Usage

First, install VirtualBox, Vagrant, and the vagrant-multiprovider-snap
plugin.  The last of these will usually be installed as follows:

* `vagrant plugin install vagrant-multiprovider-snap`

Then, create or use a premade Vagrant box for OpenIndiana hipster.  If you
want to create your own, you can use a `packer` recipe:

* `git clone git://github.com/wca/oi-packer`
* `cd oi-packer && packer build template.json`

Note that these scripts currently require shared folders, so for now they
only work with VirtualBox.

This will take a while (about an hour), mostly because the steps include a
lot of extra waits for slower machines.  Next, import the Vagrant box that
created for the hypervisor you want:

* `vagrant box add --name oi-hipster-20151003-virtualbox
  ./oi-hipster-20151003.box`

Alternatively, there are premade Vagrant boxes available:

* http://firepipe.net/vagrant/oi-hipster-20151003-virtualbox.box

Once this is done, create a directory to hold metadata for the Vagrant
machine you'll be creating, then clone this repository to it:

* `mkdir oi-hipster-zfs.1`
* `cd oi-hipster-zfs.1`
* `git clone git://github.com/wca/vig`
* `git clone <your illumos-gate repo> illumos-gate`

Now, edit vig/openindiana/Vagrantfile if necessary (the default machine
configuration is 4 VCPUs and 8GB), then fire up an initial build & test run:

* `./vig/vig host fromscratch`

This will take between 4 and 24 hours, depending on your system.  The time
is spent as follows:

* ~10% VM setup, test boot environment install/setup, other overhead
* ~35% building illumos-gate
* ~55% running the zfs test suite

# Performing incremental build/test cycles

To run an incremental test against a specific branch of your illumos-gate
companion repository:

* `./vig/vig host build <branch>`
* `./vig/vig host zfstests`

These two commands can be run independently, although it's worth noting that
the zfstests command expects that a build has already been completed.
