Storyline Cubietruck-Plus
=========================

The cubietruck-plus is used a master node for my cluster (baalue) with xfce (www.xfce.org) as desktop environment. The main goal is to use the 8 cores as a powerful preproccesor for distcc usage (build-cluster).

Baalue is my common embedded development environment. It is a cluster with 8 worker nodes and 1 master nodes (a cubietruck). I use it for 2 different usecases:

	- distributed build via distcc (see https://github.com/tjohann/baalue_distcc.git)
	- plattform for parallel programming within distributed address space

![Alt text](../../pics/baalue_cluster_03.jpg?raw=true "Baalue nodes")
