.. |Product| replace:: ``adaptabuild``

Introduction
============

This document is for developers that need to work on the infrastructure
supporting |Product|. That means everything under the ``make`` and ``doc``
directories.

If you need to learn about making third-party or your own code buildable
under |Product| then refer to the
:doc:`Developer's Setup Guide </developers_setup_guide/developers_setup_guide>`.

As the |Product| project becomes more mature, most teams will be able to start
by writing a simple makefile for each submodule or series of related source
files based on the |Project| example. The real work of |Product| is done behind
the scenes by the files in the ``make`` folder.

