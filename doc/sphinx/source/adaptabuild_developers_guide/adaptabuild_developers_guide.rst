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
files based on the |Product| example. The real work of |Product| is done behind
the scenes by the files in the ``make`` folder.

@startuml
box "path/to/project" #lightyellow
participant "adaptabuild_config.mak" as project
participant "src" as src

box "path/to/adaptabuild" #LightBlue
participant "make" as root
participant "make/mcu" as mcu

autoactivate on
  "project" -> root #DarkSalmon : log.mak
deactivate

"project" -> root #DarkSalmon : adaptabuild.mak
root -> mcu #pink : validate_mcu.mak
note over mcu
  Iterate over all
  supported MCUs
end note
deactivate

root -> project #blue : adaptabuild_project.mak
deactivate

root -> src #blue : MCU
  note over src, root
    Build MCU specific modules
    end note

  src -> src #green : cmsis_core
    src -> root : library.mak
      root -> root : objects.mak
    deactivate root
  deactivate
  deactivate

  src -> src #green : cmsis_device_specific
    src -> root : library.mak
      root -> root : objects.mak
    deactivate root
  deactivate
  deactivate

  src -> src #green : device_hal
    src -> root : library.mak
      root -> root : objects.mak
    deactivate root
  deactivate
  deactivate
deactivate

root -> project #blue : adaptabuild_artifacts.mak
  note over project, root
    Build product specific modules
  end note

  project -> src #violet : module_A
    src -> root : library.mak
      root -> root : objects.mak
      deactivate
      root -> root : cpputest.mak
      deactivate
    deactivate
    deactivate

  project -> src #violet : module_B
    src -> root : library.mak
      root -> root : objects.mak
      deactivate
    deactivate
    deactivate

  project -> src #violet : ...
    src -> root : library.mak
      root -> root : objects.mak
      deactivate
    deactivate
    deactivate

  project -> src #violet : module_n
    src -> root : library.mak
      root -> root : objects.mak
      deactivate
    deactivate
    deactivate
return

@enduml

include $(ADAPTABUILD_PATH)/make/log.mak