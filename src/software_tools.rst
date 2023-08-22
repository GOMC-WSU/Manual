Recommended Software Tools
==========================

The listed programs are used in this manual and are generally considered necessary.

Packmol
-------
Packmol is a free molecule packing tool (written in Fortran), created by José Mario Martínez, a professor of mathematics at the State University of Campinas, Brazil. Packmol allows a specified number of molecules to be packed at defined separating distances within a certain region of space. More information regarding downloading and installing Packmol is available on their homepage:

http://www.ime.unicamp.br/~martinez/packmol

.. Warning:: One of Packmol’s limitations is that it is unaware of topology; it treats each molecule or group of molecules as a rigid set of points. It is highly suggested to used the optimized structure of the molecule as the input file to packmol.

.. Warning:: Another more serious limitation is that it is not aware of periodic boundary conditions (PBC). As a result, when using Packmol to pack PDBs for GOMC, it is recommended to pack to a box 1-2 Angstroms smaller than the simulation box size. This prevents hard overlaps over the periodic boundary.

VMD
---

VMD (Visual Molecular Dynamics) is a 3-D visualization and manipulation engine for molecular systems written in C-language. VMD is distributed and maintained by the University of Illinois at Urbana-Champaign. Its sources and binaries are free to download. It comes with a robust scripting engine, which is capable of running python and tcl scripts. More info can be found here:

http://www.ks.uiuc.edu/Research/vmd/

Although GOMC uses the same fundamental file types, PDB (coordinates) and PSF (topology) as VMD, it uses some special tricks to obey certain rules of those file formats. One useful purpose of VMD is visualization and analyze your systems.

.. figure:: static/vmd.png

  A system of united atom isobutane molecules

Nonetheless, the most critical part of VMD is a tool called PSFGen. PSFGen uses a tcl or python script to generate a PDB and PSF file for a system of one or more molecules. It is, perhaps, the most convenient way to generate a compliant PSF file.

.. figure:: static/psfgen.png

  An overview of the PSFGen file generation process and its relationship to VMD/NAMD


.. Tip::
  To read more about PSFGen, reference: 

  `Plugin homepage @ UIUC`_

  .. _Plugin homepage @ UIUC: http://www.ks.uiuc.edu/Research/vmd/plugins/psfgen

  `Generating a Protein Structure File (PSF), part of the NAMD Tutorial from UIUC`_

  .. _Generating a Protein Structure File (PSF), part of the NAMD Tutorial from UIUC: http://www.ks.uiuc.edu/Training/Tutorials/namd/namd-tutorial-html/node6.html

  `In-Depth Overview [PDF]`_

  .. _In-Depth Overview [PDF]: http://www.ks.uiuc.edu/Research/vmd/plugins/psfgen/ug.pdf

Molecular Simulation Design Framework (MoSDeF)
-----------------------------------------------

In this section, the MosDef python interface for creating customized GOMC simulations are discussed.

Link to documentation: https://mbuild.mosdef.org/en/stable/getting_started/writers/GOMC_file_writers.html

Link to MosDef Examples Repository: https://github.com/GOMC-WSU/GOMC-MoSDeF

Link to Youtube tutorials : https://www.youtube.com/playlist?list=PLdxD0z6HRx8Y9VhwcODxAHNQBBJDRvxMf

Link to signac documentation: https://signac.io/

Link to MosDef documentation: https://mosdef.org/

The Molecular Simulation Design Framework (MosDeF) is a GOMC-compatible software that allows these simulations to be transparent and reproducible and permits the easy generation of all the required files to run a GOMC simulation (the forcefield, coordinate, topology and GOMC control files).  This mosdef-gomc package is available via conda.  The MoSDeF software also lowers the entry barrier for new users, minimizes the expert knowledge traditionally required to set up a simulation, and streamlines this process for more experienced users.  MoSDeF is comprised of several conda packages (mBuild, foyer, and gmso), which are stand-alone packages; however, they are designed to all work seamlessly together, which is the case with MoSDeF-GOMC.  

In general, molecules imported or built using mBuild,  packed into a simulation box(s) and passed into the charmm writer function with additional parameters as arguments.  The charmm writer then atom-types the simulation box's molecules using foyer, obtaining the molecular force field parameters.  The next step utilizes the charmm writer to output the forcefield files, PDB/PSF, and GOMC control files, all the files needed to run a GOMC simulation.  This MoSDeF-GOMC software is fully scriptable and compatible with Signac, allowing a fully automated and reproducible workflow. 
 