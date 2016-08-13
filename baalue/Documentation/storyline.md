Storyline Baalue
================

Baalue is my common embededd development environment. It is a cluster with 8 worker nodes and 2 different master nodes. If I use it as a development plattform baalue_master (see README.md.Network) ist the master node, otherwise baalue_slave is it. The difference is that baalue_master acts as a distcc server and the main usecase is distributed building/development while baalue_slave and all baalue nodes acts as plattform for parrallel programming within distributed address spaces.


Hardware
========

A bananapi is used as worker cluster node and a cubietruck is the master node of it.


Baalue as embedded development environment
==========================================

Supported plattforms (devices):

	- armhf (of course)
	- armel (arm926_sdk.git)
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

Use a Pine64 as the basic node for Baalue2.



