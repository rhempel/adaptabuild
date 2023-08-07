.. |Product| replace:: ``adaptabuild``

Introduction
============

For any product development effort, it is important to have guiding principles
set out early in the process. This helps the team to make decisions, understand
the purpose of the project, and to clarify why things are the way they are.

The ``adaptabuild`` project has the following design principles:

- Simple now is better than complicated later
- Automate the boring stuff
- Minimize architectural layers in code and tools
- Build trust and transparency by using small steps
- Check status frequently and make adjustments as needed

Notice that there is no mention of specific tools or techniques here. We are
trying to establish a set of values that reflect how we will develop a system,
and these values will also help us to make choices that improve outcomes
for the project and the team.

Remember that ``adaptabuild`` is for *small* Cortex-M class microcontrollers
and does not attempt to play in the same space as Yocto or similar tools for
embedded Linux.

Simple now is better than complicated later
===========================================

When I use this phrase, there is often pushback because it sounds like I am
advocating for making a hack now just to get things done, which increases
technical debt. In fact, this is partly true - but it's not necessarily a bad
thing and here's why.

When we begin a new project, there is a temptation to start with a grand vision
and plan do "do it right this time". We reflect on the mistakes and poor
assumptions of previous projects, or we are told that we need to plan better
so that we don't miss the deadline this time.

For most projects - even "simple" ones - this is almost impossible because
the reality is that the project is probably complex.

We spend so much time doing detailed design, estimating, scheduling, and risk
analysis that we end up believing we have removed uncertainty, and are in
a position of having to stick the design or plan no matter what. Sometimes
there is so much effort invested in the early design phase that we can't bear
the thought of changing direction or cutting scope.

Options
-------

When deciding on tools, architectures, or even next steps to take in a
projects, look for ways to simplify things as much as possible. Here are
some examples:

Vendor Supplied HAL
  Clone the vendor's BSP or HAL as-is and incorporate it as a submodule of
  your project. Go one step further and make a local fork of the vendor's
  git repository for the BSP and create a new branch for your minimal
  local changes. More on this when we discuss using git for trunk based
  development.

Docker Containers
  The days of running true virtual environments like VMWare or VirtualBox
  for firmware development are numbered. It made sense when the debugging
  tools were made by a company that went out of business and only supported
  Windows 200 - thankfully modern Cortex-M class all use JTAG and are well
  supported on Linux. For developers running Windows and MacOS we can now
  take advantage of Docker images to create a unified build environment
  that is exactly the same as your CI/CD pipeline will use. 

Python As The Scripting Language
  In the past I advocated for using ``bash`` or a similar shell Language
  for automating tasks, and that required installing Cygwin or MSYS2 on
  WIndows machines or dealing with subtle differences in default shells.
  There is simply no excuse anymore for not using Python 3.x as your
  standard scripting language, as long as you follow some basic rules to
  ensure your scripts are portable. 

GNU make As The Build System
  There are plenty of alternatives to make out there such as CMake, Meson,
  and even Yocto. In some cases they are layers on top of make, so why
  not spend some effort creating a makefile system that simplifies the
  task of specifying *what* needs to be built and leave the *how* to
  the supporting makefiles that most developers never need to touch.

The key to chosing simple over complicated is that you get started on the
learning path more quickly so that you can make adjustments sooner.  

Automate the boring stuff
=========================

Building a release (or debug) version of your project from scratch on a
new developer's machine is the ultimate test of your process. If you need
to write a 50 page document to lay out the steps needed to install the
IDE and toolchain, and set up your code repositories, and select specific
options before hitting compile in your IDE, then you are probably doing
things the hard way.

In a modern development environment, you should be able to clone a repo
that has *everything* needed to spin up a new Docker container that has
a command lines to:

- Build any variant of your product
- Build the documentation
- Run off-target unit tests and reports
- Build code coverage reports

Your developers should be able to be confident that their unit tests cover
90% of the functionality of your product, and that manual testing can be
minimized to things that have changed.

This is usually only possible when your design is truly decoupled into
testable modules, and you are able to confidently say that a change in
one area will not affect something else.

Of course there are always things we discover in integration on real
hardware, but with a great off-target test suite it will be much easier
to make reasonable guesses about where the problem lies.

Options
-------

When deciding on tools, architectures, or even next steps to take in a
projects, look for ways to automate things as much as possible. The
secion on simplification has many good ideas already, here are some
for automation.

VSCode (or VSCodium) as IDE
  As a long time ``vi`` user and being generally disappointed with
  vendor supplied IDEs, I was surprised to be relatively happy with
  VSCode:
  
  - It doesn't force you to use vendor specific project file
    structures that may not match your actual file structure.
  - It has built in support for git
  - You can attach to a Docker container running your development
    environment
  - You can debug Cortex-M micros in VSCode (yes really!)
  - You can run your builds from a command-line or as tasks

GitLab pipelines or GitHub actions
  Whatever your ``git`` vendor of choice, use their built-in CI
  pipeline tools for your project. If you are using another tool
  like Jenkins already then have a close look and decide if yet
  another tool on a separate machine is worth the trouble.

Python Scripts
  We have already discussed using Python as a scripting language, and
  here we are advocating for building those scripts in such a way so
  that they can be used in multiple ways, this usually means creating
  proper Python classes that can be imported and re-used.

  Wait, isn't that overkill? Maybe, but it helps to reinforce the
  idea that all the code we write should be high quality and testable.

Wherever possible choose automation as a way of freeing up developer
time for challenging tasks. Building a release shouldn't be one of them.

Minimize architectural layers in code and tools
===============================================

Architectural layers are good, too many layers are bad, and layers
that don't really isolate dependencies are terrible.

Every layer that you add to an architecture or process is an
opportunity for information to leak out, or contamination to leak
in. We are not talking about leaking secrets, we are talking about
leaking implementation details across layers, losing information
between layers, and rewriting layers because ... well, because
we don't like how that layer works (or we don't understand it).

The same goes for tools, which is why vendor supplied code generators
and project build systems are often sources of great confusion and
wasted time.

Options
-------

When deciding on tools, architectures, or even next steps to take in a
projects, look for ways to reduce layers as much as possible. If you
need a layer, take care to design it so that it is truly a layer
and not just a way of reaching into another layer to get implementation
details.

Vendor Supplied HAL
  Leave the vendor supplied HAL as-is and create your own branch where
  the only addition is ``adaptabuild.mak`` to build the full HAL as
  a library. This ensures that when vendor supplied changes come, you
  will have a much easier time merging with those changes.

Logical Device HAL
  The trap that is easy to fall into here is designing a generic HAL
  for GPIO, or Serial comms, or ADC inputs. This is usually a wasted
  effort because you end up needing a generic configuration file to
  set up your peripheral maps between the generic HAL and the vendor
  HAL.

  Instead, consider writing a logical device HAL for switch input,
  or battery charging, or file systems and divide that into the
  common code and MCU specific code. The reality is that you will
  only need to support one (maybe two) MCU variants so writing the
  MCU specific code twice is not a big deal if you separated the
  layers properly.

  Another advantage is that it makes testing your logical device API
  much easier if you can mock out the hardware.

Sphinx for Documentation
  As much as possible, put your project specific documentation in the
  same repo as the source code. This makes it possible to retreive
  test plans, design guides, API descriptions as they were when the
  code was committed!

  Take advantage of Sphinx' ability to leverage Doxygen to create
  documentation from C code, which means you can put detailed design
  notes right in the code and they automatically generate browsable
  documentation when your project is built.

  No additional layers to an external documentation tool or repository
  means developers have much less friction to keeping docs up to date
  and actually useful for their teammates.

We will discuss effective layering techniques for code in the
TDD section.

Build trust and transparency by using small steps
=================================================

We have long since learned that most projects in the complex domain
are difficult to estimate and plan accurately. Are we absolutely sure
that the boards are going be delivered on that date? Is Kelly going
to find a new job? What if the other must-win projects needs help
in 6 months and we lose two developers?

These are all things that could happen, and just adding buffer to the
schedule isn't good enough, because it will *always* get eaten up.

This is a common complaint about firmware teams - they often seem
to take longer to get things done than planned, and when they fix
last minute issues or add features, something else breaks.

Options
-------

When you need to build trust in your team across the organization, look
for ways to make even small steps visible. Make sure that you are
seen as a team that is actively working to get better at what you do.

Off Target Test Driven Development
  Don't waste time waiting for the prototype boards to arrive by
  spending it doing detailed designes, estimates, and risk analysis.
  Instead, work together with your team to create a design that is
  testable off-target. Practice doing TDD now, before you need to
  get prototype boards up and running.

  You will be able to demonstrate passing test cases, better code
  coverage, and build confidence that your team is creating truly
  decoupled modules that can be reused.

Vendor Supplied Demo Boards
  Sometimes you will be able to use a vendor supplied board to get
  the core of your product and its variants up and running. Use
  this opportunity to iron out your development toolchain and git
  processes. It's not going to be easier than now.

Use GitHub or Gitlab to host your Documentation
  This document is written in ReStrucured Text and rendered in ability
  pipeline using SPhinx. Your team should be able to automatically
  deploy these documents and make them browsable for anyone that
  needs to see what's going on.
  
  That includes code coverage and unit test results. Most likely
  nobody will look at them outside your team, but you are sharing
  them openly and they don't take any time or thought to create
  because you automated the boring stuff.

Building trust is incredibly difficult, and the longer your team
has been perceived as not dependable the longer it takes to earn
trust back - but it's worth it.

Check status frequently and make adjustments as needed
======================================================
