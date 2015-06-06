======================================================================
Runtime environmet and sample projects for "NodeMCU" ESP8266 firmeware
======================================================================

Current status
==============

Includes
--------
- A Generic Linux build environment for NodeMCU including
  o Target compilation to byte-code
  o Host cross-compilation to byte code
  o No compilation
  o For more information see:
    * <"git_root"/tools/build/Makefile.config.mk>
    * <"git_root"/tools/build/Makefile.base.mk>
    * <"git_root"/tools/build/Makefile.template>
    * for help type <make -C "git_root"/tools/build" -f Makefile.template.mk help> 
- Common libraries for micro multi-thread, multi tasking soft real-time
  applications.
- Common libraries for semaphore message communication and synchronization.
- Common libraries for timer allocation
- Usage examples for the above examles

TODO:
-----
- Incorporate the "timer" library in the rest of the libray modules - before this is done
  "timer" is practically a useless library module.
- Interesting project examples!
- Implement all ESP interaction functions in upstream nodemcu-upload project
- Optimize Heap consumption
- Implement libraries in C++ firmware
