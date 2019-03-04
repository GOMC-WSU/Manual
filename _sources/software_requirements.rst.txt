Software Requirements
=====================

C++11 Compliant Compiler
------------------------

- Linux/macOS

  - icpc (Intel C++ Compiler)

    In Linux, the Intel compiler will generally produce the fastest CPU executables (when running on Intel Core processors). Type the following command in a terminal:
    
    .. code-block:: bash

      $ icpc --version

    If gives a version number 16.0.3 (2016 Initial version) or later, you’re all set. Otherwise, we recommend upgrading.

  - g++

    Type the following command in a terminal:
    
    .. code-block:: bash

      $ g++ --version

    If gives a version number 4.4 or later, you’re all set. Otherwise, we recommend upgrading.

- Windows

  Visual Studio Microsoft’s Visual Studio 2010 or later is recommended.

  To check the version: 

  *Help* (top tab) -> *About Microsoft Visual Studio*

  .. image:: _static/vshelp.png

  .. image:: _static/vsabout.png

CMake
-----
To check if cmake is installed:

.. code-block:: bash

  $ which cmake

To check the version number:

.. code-block:: bash

  $ cmake --version

The minimum required version is 2.8. However, we recommend to use version 3.2 or later.

CUDA Toolkit
------------
CUDA is required to compile the GPU executable in both Windows and Linux. However, is not required to compile the CPU code. To download and install CUDA visit NVIDIA’s webpage:

https://developer.nvidia.com/cuda-downloads

https://developer.nvidia.com/cuda

Please refer to CUDA Developer webpages to select an appropriate version for the desired platform. To install CUDA in Linux root/sudo, privileges are generally required. In Windows, administrative access is required.

To check if nvcc is installed:

.. code-block:: bash

  $ which nvcc

To check the version number:

.. code-block:: bash
  
  $ nvcc --version

The GPU builds of the code requires NVIDIA’s CUDA 8.0 or newer.