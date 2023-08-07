.. adaptabuild documentation master file, created by
   sphinx-quickstart on Thu Jul 27 00:01:03 2023.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to the adaptabuild documentation!
=========================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

.. toctree::
   :maxdepth: 2
   :caption: Design Principles
   :hidden:

   design_principles/design_principles

.. toctree::
   :maxdepth: 2
   :caption: Developer's Setup Guide
   :hidden:

   developers_setup_guide/developers_setup_guide

- :doc:`Design Principles </design_principles/design_principles>`
- :doc:`Developer's Setup Guide </developers_setup_guide/developers_setup_guide>`

What is adaptabuild?
====================

The adaptabuild framework is a set of design prinicples, tools, and
templates that is designed to simplify the daily work of developers that
are building firmware for Cortex-M and similar devices.

By adhering to a few principles that reduce the friction of modern
embedded systems development, we can build confidence and trust that
our development system is as robust as our product.

- Use Docker containers to provide a uniform build environment that
  can be set up on any host machine, including remote CI/CD servers.
- Use git as the version control system, to leverage the power of
  submodules, tags, and semantic versioning to automate the deployment
  of your firmware to production.
- Prefer VSCode (or VSCodium) as the IDE to simplify environment
  setup.
- Use Python for scripting instead of the shell to allow more expressive
  scripts.
- Minimize the effort required to add files to a project by using a
  JSON file format that can be transfomed into makefiles.
- Use Sphinx to create documentation that lives with the code so that
  it accurately reflects the code it is checked out with.
- Support Test Driven Development of embedded systems code by providing
  guidelines for building decoupled systems that are actually testable.
- Take advantage of containerization to run unit tests and coverage
  analysis off-target to automate reporting and create confidence.
- Allow building multiple target products, MCUs, and configurations
  from the same source tree, and guarantee that each variant uses its
  own object files.

The adaptabuld framework is the result of over 40 years of embedded systems
development experience where I have learned to strike a balance between
structure and flexibility in the process of maturing a design from early 
prototypes to production-ready firmware.

This framework has worked for me and teams I have led, and I hope it
works for you as well - if you have any feedback to share, please feel
free to do so. I'm always learning and welcome constructive discussions.

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
