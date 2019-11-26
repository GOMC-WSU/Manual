Compiling GOMC
==============

GOMC generates four executable files for CPU code; ``GOMC_CPU_GEMC`` (Gibbs ensemble), ``GOMC_CPU_NVT`` (NVT ensemble), ``GOMC_CPU_NPT`` (isobaric-isothermal ensemble), and ``GOMC_CPU_GCMC`` (Grand canonical ensemble). In case of installing CUDA Toolkit, GOMC will generate additional four executable files for GPU code; ``GOMC_GPU_GEMC``, ``GOMC_GPU_NVT``, ``GOMC_GPU NPT``, and ``GOMC_GPU_GCMC``.

This section guid users to compile GOMC in Linux or Windows.

Linux
-----
First, navigate your command line to the GOMC base directory. To compile GOMC on Linux, give permission to "metamake.sh" by running the following command and execute it:

.. code-block:: bash

  $ chmod u+x metamake.sh
  $ ./metamake.sh

This script will create a bin directory and run cmake file to compile the code as well. All executable files will be generated in the “bin” directory.

Windows
-------
To compile GOMC on in Windows, follow these steps:

1. Open the Windows-compatible CMake GUI.
2. Set the Source Folder to the GOMC root folder.
3. Set the build Folder to your Build Folder.
4. Click configure, select your compiler/environment
5. Wait for CMake to finish the configuration.
6. Click configure again and click generate.
7. Open the CMake-generated project/solution etc. to the desired IDE (e.g Visual Studio).
8. Using the solution in the IDE of choice build GOMC per the IDE’s standard release compilation/exe- cutable generation methods.

.. Note:: You can also use CMake from the Windows command line if its directory is added to the PATH environment variable.

Configuring CMake
-----------------
GOMC uses CMAKE to generate multi-platform intermediate files to compile the project. In this section, you can find all the information needed to configure CMake.
We recommend using a different directory for the CMake output than the home directory of the project as CMake tend to generate lots of files.
CMake has a ridiculously expansive set of options, so this document will only reproduce the most obviously relevant ones. When possible, options should be passed into CMake via command line options rather than the CMakeCached.txt file:


CMAKE_BUILD_TYPE
  To get the best performance you should build the project in release mode. In CMake GUI you can set the value of "CMAKE_BUILD_TYPE" to "Release" and in CMake command line you can add the following to the CMake:

  .. code-block:: bash
  
    -DCMAKE_BUILD_TYPE=Release

  To compile the GOMC in debug mode, in CMake GUI, change the value of "CMAKE_BUILD_TYPE" to "Debug" and in CMake command line you can add the following to the CMake:

  .. code-block:: bash

    -DCMAKE_BUILD_TYPE=Debug
  
  Other options are "<None | ReleaseWithDebInfo | MinSizeRel>".

CMAKE_CXX_COMPILER
  This option will set the compiler. It is recommended to use the Intel Compiler and linking tools, if possible (icc/icpc/etc.). They significantly outperform the default GNU and Visual Studio compiler tools and are available for free for academic use with registration.

CMAKE_CXX_FLAGS_RELEASE:STRING
  To run the parallel version of CPU code, it needs to be compiled with openmp library. Open the file "CMakeCache.txt", while still in the "bin" folder, and change the value from "-O3 -DNDEBUG" to "-O3 -qopenmp -DNDEBUG". Recompile the GOMC by typing the command:

  .. code-block:: bash

    $ make

ENSEMBLE_NVT
  You can turn the compilation of CPU version of NVT ensemble on or off using this option.
  -DENSEMBLE_NVT=<On | Off>

ENSEMBLE_NPT
  You can turn the compilation of CPU version of NPT ensemble on or off using this option.
  -DENSEMBLE_NPT=<On | Off>

ENSEMBLE_GCMC
  You can turn the compilation of CPU version of GCMC ensemble on or off using this option.
  -DENSEMBLE_GCMC=<On | Off>

ENSEMBLE_GEMC
  You can turn the compilation of CPU version of GEMC ensemble on or off using this option.
  -DENSEMBLE_GEMC=<On | Off>

ENSEMBLE_GPU_NVT
  You can turn the compilation of GPU version of NVT ensemble on or off using this option.
  -DENSEMBLE_NVT=<On | Off>

ENSEMBLE_GPU_NPT
  You can turn the compilation of GPU version of NPT ensemble on or off using this option.
  -DENSEMBLE_NPT=<On | Off>

ENSEMBLE_GPU_GCMC
  You can turn the compilation of GPU version of GCMC ensemble on or off using this option.
  -DENSEMBLE_GCMC=<On | Off>

ENSEMBLE_GPU_GEMC
  You can turn the compilation of GPU version of GEMC ensemble on or off using this option.
  -DENSEMBLE_GEMC=<On | Off>
