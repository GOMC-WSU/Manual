Hybrid Monte Carlo-Molecular Dynamics (MCMD)
============================================

In this section, the tips and tricks to get a hybrid MCMD simumlation with GOMC and NAMD running are discussed.
Most of these issues will be handled by the scripts provided with py-MCMD, but the concerns are raised here for users interested in setting up custom systems.  Careful attention should be made to ensure the system is centered in the first octant of 3D space, originates at [boxlength/2, boxlength/2, boxlength/2], and the box length excedes the radius of gyration of all molecules.

Link to documentation: https://py-mcmd.readthedocs.io/en/latest/

Link to Github Repository: https://github.com/GOMC-WSU/py-MCMD

GOMC Requirements
----------------------
GOMC currently requires that Box length / 2 excede the radius of gyration of all molecules in the system.

Grand-Canonical Molecular Dynamics (GCMD) or Gibbs Ensemble with Molecular Dynamics changes the number of molecules in each box.  This will alter the ordering of the molecules, posing a challenge when the user tries to concatenate the trajectories or follow one atom through a trajectory.

The GOMC checkpoint file will reload the molecules in the original order to ensure the GOMC trajectories (PDB/DCD) have a consistent ordering for analysis.  Atoms that are not currently in a specific box are given the coordinate (0.00, 0.00, 0.00). The occupancy value corresponds to the box a molecule is currently in (e.g. 0.00 for box 0; 1.00 for box 1).

The restart binary coordinates, velocities, and box dimensions (xsc) from NAMD need to be loaded along with the checkpoint file, restart PDB, and restart PSF from the previous GOMC cycle.

The python script from the py-MCMD git repository, combine_data_NAMD_GOMC.py, requires the GOMC step reset to 0 every cycle

.. code-block:: text
  
  InitStep          0

NAMD Requirements
----------------------

GOMC outputs all the files needed to continue a simulation box in Molecule Dynamics (pdb, psf, xsc, coor, vel, xsc).  These files should all be used.

There are certain flexibilities that NAMD allows for that GOMC doesn't support.  To ensure the two systems are compatible the following settings in the NAMD configuration file are required:

Rigid bonds, since GOMC doesn't support bond length sampling.
  
.. code-block:: text

  rigidBonds          all  

Fixed volume, since GOMC maintains the origin of the box at [box length/2, box length/2, box length/2]
  
.. code-block:: text

  # Constant Pressure Control (variable volume)
  langevinPiston        off

  useGroupPressure      yes

  useFlexibleCell       no

  useConstantArea       no

Box origin must be centered at [box length/2, box length/2, box length/2]

.. code-block:: text

  cellOrigin        x_box length/2   	y_box length/2  	z_box length/2

Dynamic Subvolumes for Dual Control Volume Molecular Dynamics
-------------------------------------------------------------------

To define a subvolume in the simulation, use the subvolume keywords to choose an subvolume id, center, either the geometric center of a list of atoms or absolute cartesian coordinate, and dimensions.  The residues that can be inserted/deleted in the subvolume, custom chemical potential, and periodicity of the subvolume may also be specified.  Fugacity can be replaced for chemical potential.  A chemical gradient can be established in the simulation by defining two or more subvolume with different chemical potentials of a given residue.  After the molecule is inserted/deleted within one subvolume, it diffuses out and is inserted/deleted from the other at a different chemical potential, forming a gradient.

To define two control volumes forming a gradient from the left to the right of the box

.. code-block:: text

    SubVolumeBox     		0       0         

    SubVolumeDim     		0       left_one_fifth y_dim_box_0 z_dim_box_0

    SubVolumeResidueKind 	0   	DIOX       

    SubVolumeRigidSwap   	0   	true 

    SubVolumeCenter		0	left_center y_origin_box z_origin_box

    SubVolumePBC		0	XYZ

    SubVolumeChemPot		0	DIOX	-2000


    SubVolumeBox     		1       0         

    SubVolumeDim     		1       right_one_fifth  y_dim_box_0 z_dim_box_0

    SubVolumeResidueKind 	1   	DIOX       

    SubVolumeRigidSwap   	1   	true 

    SubVolumeCenter		1	right_center y_origin_box z_origin_box

    SubVolumePBC		1	XYZ

    SubVolumeChemPot		1	DIOX	-4000
