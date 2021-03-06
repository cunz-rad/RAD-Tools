RAD-Tools                                                (C) 2013 Cunz RAD Ltd.
===============================================================================

This repository contains the core files and some basic "Features" for RAD-Tools.

RAD-Tools is an extension to CMake, that allows you to dynamically add features
to a CMake build and to build hierarchies of individual repositories that can
be build stand alone and as a greater, combined part.

General usage
-------------

To use RAD-Tools, create a checkout of this repository in the folder /RAD-Core
of your project. You can do this either via a submodule or by simply copying the
files.

Then write your root CMakeLists.txt following this pattern:

~~~CMake
# Initialize CMake. CMake disallows moving this away from the root
# But it doesn't harm to have it in a subdirectory, too.
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12)
CMAKE_POLICY(VERSION 2.8.12)

# Include the RAD-Core
INCLUDE(RAD-Core/RAD-Core.cmake)

# Initialize the RAD-Core
RAD_INIT(
    FEATURES   QtMacros
               SingleBinDir
)

ADD_SUBDIRECTORY(MyDir1)
ADD_SUBDIRECTORY(MyDir2)
~~~

`RAD_INIT(...)` can be called multiple times (which is the whole intention of
this abstraction). It will scan for RAD-Tools directories only in the first run
but will load required features for subsequent calls, too. Of course they will
only be loaded for the subtree that the `RAD_INIT()` call is made from.

It is also possible to load a feature directly by running
`RAD_CORE_LOAD_FEATURE(Feature [VERBOSE|SILENT])`. A feature loaded in this way
will only be available to the subtree it is loaded for.

It is not possible to load a feature _into a higher level of the file system
hierarchy_.
