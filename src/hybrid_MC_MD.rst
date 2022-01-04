Hybrid Monte Carlo-Molecular Dynamics (MCMD)
==========================================

In this section, the tips and tricks to get a hybrid MCMD simumlation with GOMC and NAMD running are discussed.
Most of these issues will be handled by the scripts provided with py-MCMD, but the concerns are raised here for users interested in setting up custom systems.  Careful attention should be made to ensure the system is centered in the first octant of 3D space, originates at [boxlength/2, boxlength/2, boxlength/2], and the box length exceeds the radius of gyration of all molecules.

Link to documentation: https://py-mcmd.readthedocs.io/en/latest/
Link to Github Repository: https://github.com/GOMC-WSU/py-MCMD

GOMC Requirements
----------
GOMC currently requires that Box length / 2 exceed the radius of gyration of all molecules in the system.

Grand-Canonical Molecular Dynamics (GCMD) or Gibbs Ensemble with Molecular Dynamics changes the number of molecules in each box.  This will alter the ordering of the molecules, posing a challenge when the user tries to concatenate the trajectories or follow one atom through a trajectory.

The GOMC checkpoint file will reload the molecules in the original order to ensure the GOMC trajectories (PDB/DCD) have a consistent ordering for analysis.  Atoms that are not currently in a specific box are given the coordinate (0.00, 0.00, 0.00). The occupancy value corresponds to the box a molecule is currently in (e.g. 0.00 for box 0; 1.00 for box 1).

The restart binary coordinates, velocities, and box dimensions (xsc) from NAMD need to be loaded along with the checkpoint file, restart PDB, and restart PSF from the previous GOMC cycle.

The python script from the py-MCMD git repository, combine_data_NAMD_GOMC.py, requires the GOMC step reset to 0 every cycle

  .. code-block:: text
  InitStep          0

NAMD Requirements
-----------

GOMC outputs all the files needed to continue a simulation box in Molecule Dynamics (pdb, psf, xsc, coor, vel, xsc).  These files should all be used.

There are certain flexibilities that NAMD allows for that GOMC doesn't support.  To ensure the two systems are compatible the following settings in the NAMD configuration file are required:

Rigid bonds, since GOMC doesn't support bond length sampling.
  .. code-block:: text
rigidBonds          all  ;# needed for 2fs steps

Fixed volume, since GOMC maintains the origin of the box at [box length/2, box length/2, box length/2]
  .. code-block:: text
  # Constant Pressure Control (variable volume)
  useGroupPressure      yes ;# needed for rigidBonds
  useFlexibleCell       no
  useConstantArea       no

Box origin must be centered at [box length/2, box length/2, box length/2]
  .. code-block:: text
  cellOrigin        x_box length/2   	y_box length/2  	z_box length/2

Dynamic Subvolumes for Dual Control Volume Molecular Dynamics
-----------

To define a subvolume in the 
