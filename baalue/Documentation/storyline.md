Storyline Baalue
================

Baalue is my common embedded development environment. It is a cluster with 8 worker nodes and 1 master nodes. I use it for 2 different usecases:

	- distributed build via distcc (see https://github.com/tjohann/baalue_distcc.git)
	- plattform for parallel programming within distributed address space


Hardware
========

A bananapi is used as worker cluster node and a cubietruck(-plus) is the master node of it.


Baalue as build server for void-packages
========================================

see https://github.com/tjohann/baalue_distcc.git

To share the build packages you can use the baalue_master node as nfs server. Both images provide everthing you need to setup the server and also for the clients (see https://wiki.voidlinux.eu/Network_filesystem ).

Setup nfs clients:

	ln -s /etc/sv/rpcbind /var/service
	ln -s /etc/sv/statd /var/service   (i use nfs3)

The default fstab entry (see /etc/fstab):

	baalue_master:/mnt/shared/binpkgs /mnt/binpkgs_nfs   nfs defaults,noauto,user,sync,nfsvers=3  0  0

Setup nfs server:

	ln -s /etc/sv/rpcbind /var/service
	ln -s /etc/sv/statd /var/service
	ln -s /etc/sv/nfs-server /var/service

The default export (see /etc/exports):

	/mnt/shared/binpkgs baalue-01(rw,no_subtree_check,sync) baalue-02(rw,no_subtree_check,sync) ... etc

To see what is actually exported:

	showmount -e localhost

Share void-package repository:
![Alt text](pics/nfs_share_void_repo.png?raw=true "void-package repository")

After rsync of the generated packages in void-packages/hostdir/binpkgs to /mnt/shared/binpkgs , you can use them on the clients with
xbps-install --repository=/mnt/binpkgs_nfs THE_PACKAGE.


Baalue as embedded development environment
==========================================

Supported plattforms (devices):

	- armhf (of course)
	- cortex M3 (arm_cortex_sdk.git)
	- bare-metal (via jailhouse)
	- ...

Usecases:

	- act as can/lin nodes
	- act as test plattform
	- act as build server for the supported plattforms
	- ...


Future
======

Use a Cubietruck-Plus (8-core) as master node.



