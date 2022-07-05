Release 2.75 Notes
==================


The GPL 3.0 License has been replaced by the MIT License. Users should upgrade only if they are comfortable with running code under this new license.

Certain changes have been made which differ from previous GOMC behavior.  New features have been added to assist users and developers in compiling, running, and analyzing, improve reproducability, increase the capacity of GOMC to simulate biological molecules, perform Hybrid Monte-Carlo/Molecular Dynamics simulations, and increase performance.  A non-comprehensive list is provided below.

Differing behavior:

    Previous GOMC versions used REMARKS in the PDB header to save box dimensions and random number generator state.  While this is still currently partially supported, it is in the process of being deprecated and checkpointing should be used.  Secondly, restarting GOMC should no longer be performed using the merged files containing both boxes (\*.BOX_0.pdb, \*.merged.psf) which are produced solely for visualization.  Furthermore, The user should now use the box-specific restart files (pdb, psf, xsc, coor, chk) as input.  Finally, the pdb trajectory files (\*.BOX_0.pdb) are in the process of being deprecated and replaced by binary trajectory files (\*.BOX_0.dcd), though both are currently available.  

Updated Manual Sections:

(1) Introduction 

    GOMC supported Monte Carlo moves

        Force-biased Multiparticle move (Rigid-body displacement or rotation of all molecules)

        Brownian Motion Multiparticle move (Rigid-body displacement or rotation of all molecule

    ..
        Non-Equilibrium Molecule Transfer

        Inter-box subvolume targeted swap

        Intra-box subvolume targeted swap


    GOMC supported molecules

        Biological molecules which consist of multiple residues are now supported.  Care should be taken when generating the molecules such that all bonds, angles, and dihedrals are included in the PSF file.  Support for these molecules is experimental.

(2) Recommended Software Tools

    Molecular Simulation Design Framework (MoSDeF)

(3) Compiling GOMC

    ./metamake.sh [OPTIONS] [ARGUMENTS]

    OPTIONS

        -d
            Compile in debug mode.
        -g
            Compile with gcc.
        -m
            Compile with MPI enabled.
        -p
            Compile with NVTX profiling for CUDA
        -t
            Compile Google tests.

(4) GPU-accelerated GOMC

    A section describing the GPU-accelerated regions of GOMC code is included.

(5) Input File Formats

    Support for binary coordinates, trajectories, box dimensions, velocities, and checkpoint files are included.  Checkpoint files guaruntee trajectory files can be concatenated, along with ensuring no deviation from a single simulation's results in a simulation which was interrupted and restarted.

	(5a) Restart a simulation from a checkpoint

	(5b) Restart from binary coordinates and box dimensions

	(5c) Target insertions to subvolumes

	(5d) Overwrite start step

(6) Hybrid Monte Carlo-Molecular Dynamics (MCMD)

    Instructions on running an alternating Hybrid MCMD algorithm using GOMC and NAMD are included.


