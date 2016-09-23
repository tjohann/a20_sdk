Storyline Bananapi-M1
=====================

The bananapi is used as a classical embedded device with lots of other stuff connected to it.


Overview
--------

Here's an overview of the connected sensors/device to my bananapi:

![Alt text](../../pics/overview.jpg?raw=true "Overview")

All needed drivers and schematics/pinouts are provided via my different projects:

	https://github.com/tjohann/mydriver.git
	https://github.com/tjohann/time_triggert_env.git
	https://github.com/tjohann/lcd160x_driver.git
	https://github.com/tjohann/can_lin_env.git

See also /opt/a20_sdk/externals/Makefile.


Kernel
------

I use a RT-PREEMPT patched kernel (https://rt.wiki.kernel.org/index.php/Main_Page) on the device. As you can see on the pics below the difference are really huge.

Kernel configuration menu for preempt model:
![Alt text](../../pics/kernel_config_preempt_model.png?raw=true "Kernel config menu")

Cyclictest run with PREEMPT instead of Server or Desktop (the normal preemption model provided by all linux distributions including void-linux):
![Alt text](../../pics/cyclictest_patched_kernel_with_preempt.png?raw=true "PREEMPT instead of Server/Desktop")

Cyclictest run with RT-PREEMPT patched kernel and rt-basic:
![Alt text](../../pics/cyclictest_patched_kernel_with_rt-basic.png?raw=true "RT-PREEMPT and rt-basic")

Cyclictest run with RT-PREEMPT patched kernel and rt-full:
![Alt text](../../pics/cyclictest_patched_kernel_with_rt-full.png?raw=true "RT-PREEMPT and rt-basic")

