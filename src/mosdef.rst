 Molecular Simulation Design Framework (MoSDeF)
===============================================

In this section, the MosDef python interface for creating customized GOMC simulations are discussed.

Link to documentation: https://mbuild.mosdef.org/en/stable/getting_started/writers/GOMC_file_writers.html

Link to MosDef Examples Repository: https://github.com/GOMC-WSU/GOMC-MoSDeF

Link to Youtube tutorials : https://www.youtube.com/playlist?list=PLdxD0z6HRx8Y9VhwcODxAHNQBBJDRvxMf

Link to signac documentation: https://signac.io/

The Molecular Simulation Design Framework (MosDeF) is a GOMC-compatible software that allows these simulations to be transparent and reproducible and permits the easy generation of all the required files to run a GOMC simulation (the forcefield, coordinate, and topology files GOMC control file).  The MoSDeF software also lowers the entry barrier for new users, minimizes the expert knowledge traditionally required to set up a simulation, and streamlines this process for more experienced users.  MoSDeF is comprised of several conda packages (mBuild, foyer, and gmso), which are stand-alone packages; however, they are designed to all work seamlessly together, which is the case with MoSDeF-GOMC.  

In general, molecules imported or built using mBuild,  packed into a simulation box(s) and passed into the charmm writer function with additional parameters as arguments.  The charmm writer then atom-types the simulation box's molecules using foyer, obtaining the molecular force field parameters.  The next step utilizes the charmm writer to output the forcefield files, PDB/PSF, and GOMC control files, all the files needed to run a GOMC simulation.  This MoSDeF-GOMC software is fully scriptable and compatible with Signac, allowing a fully automated and reproducible workflow.  
