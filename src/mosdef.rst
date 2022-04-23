 Molecular Simulation Design Framework (MoSDeF)
===============================================

In this section, the MosDef python interface for creating customized GOMC simulations are discussed.

Link to documentation: https://mbuild.mosdef.org/en/stable/getting_started/writers/GOMC_file_writers.html

Link to MosDef Examples Repository: https://github.com/GOMC-WSU/GOMC-MoSDeF

Link to Youtube tutorials : https://www.youtube.com/playlist?list=PLdxD0z6HRx8Y9VhwcODxAHNQBBJDRvxMf

MosDef is a transparent and reproducible method for producing GOMC configuration, forcefield, coordianate, and topology files.  A molecule structure (pdb/mol2) and xml forcefield file are used to define specie.  A box is created using MBuild, a wrapper of packmol, which requires the species, number of each specie or density, and box lengths.  The box is passed to the charmm writer which takes GOMC simulation parameters as arguments.  The charmm writer will generate the forcefield files, pdb/psf, and gomc configuration files.
