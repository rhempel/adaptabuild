# Introduction

The ``adaptabuild`` project is a result of my almost 40 years of embedded
systems development - it's not at all perfect, but is adaptable to many
development models. Let's start with what ``adaptabuild`` is **not**.

* It's not for building embedded Linux distributions - use
  [Yocto](https://www.yoctoproject.org) for that.

* It's not for building cross platform applications that have to run
  on Windows, MacOS, and Linux - use  [CMake](https://cmake.org) for that.

* It's not for building an embedded system for an incredibly wide variety
  of taget processors - use [Zephyr]ihttps://docs.zephyrproject.org) for that.

* It's not for building an embedd system that can run Python - use
  [MicroPython](https://micropython.org/) for that. 

By now you are thinking what IS ``adaptabuild' good for? It is a framework
that encourages truly modular code by supporting:

* Test Driven Development (TDD)

* Continuous Integration using your favorite CI tools (example uses GitHub actions)

* Useful documentation that is stored and versioned with the code (Sphinx)

* A makefile-based build system that lets you ignore the ugliest parts of ``make``

" A set of "guiding star" principles that simplify your ways of working

The ``adaptabuild`` framework is suited to projects where you are building
one or more products with a common platform of functionality, where there are
variants of the the same product with configurable features, and where there
may be more than one target MCU for the same product.

You can use ``adaptabuild`` to quickly get a new product variant or POC up
and running without diving too far into the complexities of ``make``, and where
you can take advantage of automation to avoid error-prone manual steps.

[!NOTE]  
This is not the documentation for ``adaptabuild`` - it's an overview. For the
actual docs [look here](https://github.com/rhempel/adaptabuild) when we have an
action that build the docs :-)

# Prerequisites

Using ``adaptabuild`` in your daily work has very few requirements - they are
more like strong recommendations.

## Docker

Modern embedded systems developers are a diverse group that use Linux,
Windows, and MacOS machines. This can lead to situations where things
work for one developer and not another, so we encourage teams to move
to a Docker-based Linux environment. No matter what machine they are developing
on, the Docker environment is the same, and it's easier to coordinate
changes to the standard environment.

For most of the projects that would use ``adaptabuild``, the gcc compiler will
support your target devices. If you are using IAR, the latest versions support
running under Linux.

The ``adapatabuild-example`` project has a ``Dockerfile`` that works out
of the box for `gcc-arm`` based development - it can be modified as needed for
other target devices. It also installs all of the tools that support documentation
and off target testing.

## Visual Studio Code

Say what you will, [VSCode](https://code.visualstudio.com/) is a hell of a
good development environment, and this is coming from a guy that insisted 
on using ``vi`` up until very recently.

Once another developer showed me that it was possible to debug a micro that
was attached to a J-Link debuuger running on a Docker image I was sold, and the
great integration with Docker just put icing on the cake.

If you would rather not use a Microsoft supplied product, there is a truly
open source build of the MIT-Licensed VSCode source called [VSCodium](https://vscodium.com/).

And there's an almost-but-not-quite Vim simulator called
[VSCodeVim](https://github.com/VSCodeVim/Vimcode), but if you are the
only developer on the team using it, then be prepared for some finger trouble
when helping other developers, or when they help you.

## Sphinx

The ``Dockerfile`` template installs a ReST based documentation system called
`Sphinx``. So far it's the most useful way I know of for documenting an embedded
system. It supports a number of plugins like:

* [Graphviz](https://graphviz.org/) - tree structures, state diagrams
* [PlantUML](https://plantuml.com/) - seuence diagrams, state diagrams

The nice benefit of storing docs (and tests and ...) in the same repository asi
code is that when you check out a version, you get the tests and docs as they were
when that version was tagged.

## make

The build system for `adaptabuild`` is based on ``make``. The good news is that
we have hidden all of the ugly bits of makefiles in a folder that you should
almost never have to touch. Your submodules are just a list of files that
make up a library - and ``adaptabuild`` manages creating and updating their
dependencies based on standard rules.

The ``adaptabuild`` system also supports building docs, running tests, and creating
code coverage metrics.

## Python

There was a time when I wrote all my automated processes as ``bash`` scripts using
some of the excellent reference material availabe in the
[Bash Guide](https://mywiki.wooledge.org/BashGuide). The time has come to
move on from bending my brain and yours around subtle shell quoting requirements
and bizarre ways of handling basic things like lists.

Use Python for even your simplest scripts - you will benefit from thinking of your
Python scripts as building blocks so take advantage of the ability to write
them to be run standalone or as an object in a larger context.

Yes, it might seem like overkill for the first few scripts, but once you
get the hang of it, you will wonder why we stuck with ``bash`` for so long. Get
into the habit of refactoring your scripts when it makes sense.

# Next Steps

Check out the docs (when they are available add a link) and the ``adaptabuild-example``
that you can use to get started. It builds a progject for a common STM32 board
and can be modified as needed.
