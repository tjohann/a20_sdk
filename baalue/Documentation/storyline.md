Storyline Baalue
================

Baalue is my common embedded development environment. It is a cluster with 8 worker nodes and 1 master nodes. I use it for 2 different usecases:

	- distributed build via distcc
	- plattform for parallel programming within distributed address space


Hardware
========

A bananapi is used as worker cluster node and a cubietruck is the master node of it.


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

Use a Pine64 as the basic node for Baalue2.



