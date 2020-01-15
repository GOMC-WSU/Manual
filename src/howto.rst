How to?
=======

In this section, we are providing a summary of what actions or modification need to be done in order to answer your simulation problem.


Visualizing Simulation
----------------------

If ``CoordinatesFreq`` is enabled in configuration file, GOMC will output the molecule coordinates every 
specified stpes. The PDB and PSF output (merging of atom entries) has already been mentioned/explained in 
previous sections. To recap: The PDB file's ATOM entries' occupancy is used to represent the box the molecule 
is in for the current frame. All molecules are listed in order in which they were read (i.e. if box 0 has 
:math:`1, 2, ..., N1` molecules and box 1 has :math:`1, 2, ..., N2` molecules, then all of the molecules in 
box 0 are listed first and all the molecules in box 1, i.e. :math:`1, 2 ,... ,N1`, :math:`N1 + 1, ..., N1 + N2`). 
PDB frames are written as standard PDBs to consecutive file frames.

To visualize, open the output PDB and PSF files by GOMC using VMD, type this command in the terminal:

For all simulation except Gibbs ensemble that has one simulation box:

.. code-block:: bash

  $ vmd   ISB_T_270_k_merged.psf  ISB_T_270_k_BOX_0.pdb

For Gibbs ensemble, visualizing the first box:

.. code-block:: bash

  $ vmd   ISB_T_270_k_merged.psf  ISB_T_270_k_BOX_0.pdb

For Gibbs ensemble, visualizing the second box:

.. code-block:: bash

  $ vmd   ISB_T_270_k_merged.psf  ISB_T_270_k_BOX_1.pdb

.. note:: Restart coordinate file (OutputName_BOX_0_restart.pdb) cannot be visualize using merged psf file, because atom number does not match. However, you can still open it in vmd using following command and vmd will automatically find the bonds of the molecule based on the coordinates.

.. code-block:: bash

  $ vmd   ISB_T_270_k_BOX_0_restart.pdb



Build molecule and topology file
----------------------------------

There are many open-source software that can build a molecule for you, such as `Avagadro <https://avogadro.cc/docs/getting-started/drawing-molecules/>`__ ,
`molefacture <http://www.ks.uiuc.edu/Research/vmd/plugins/molefacture/>`__ in VMD and more. Here we use molefacture features to not only build a molecule,
but also creating the topology file.


Regular molecule
^^^^^^^^^^^^^^^^^

First, make sure that VMD is installed on your computer. Then, to learn how to build a single PDB file and topology file for united atom butane molecule, 
please refer to this `document <https://github.com/GOMC-WSU/Workshop/blob/master/NVT/butane/build/Molefacture.pdf>`__ .

We encourage to try to go through our workshop materials:

-   To try two days workshop, execute the following command in your terminal to clone the workshop:

    .. code-block:: bash

        $ git  clone    https://github.com/GOMC-WSU/Workshop.git --branch master --single-branch
        $ cd   Workshop

    or simply download it from `GitHub <https://github.com/GOMC-WSU/Workshop/tree/master>`__ .

-   To try two hours workshop, execute the following command in your terminal to clone the workshop:

    .. code-block:: bash

        $ git  clone    https://github.com/GOMC-WSU/Workshop.git --branch AIChE --single-branch
        $ cd   Workshop

    or simply download it from `GitHub <https://github.com/GOMC-WSU/Workshop/tree/AIChE>`__ .


Molecule with dummy atoms
^^^^^^^^^^^^^^^^^^^^^^^^^

To simulate a molecule that includes one or more atoms with electrostatic interaction only and no LJ interaction (i.e. dummy atom near of the oxygen along 
the bisector of the HOH angle in `TIP4P water model <http://dx.doi.org/10.1063/1.2121687>`__\), we must perform the following steps 
to define the dummy atom/atoms:

1.  Create a PDB file for single water molecule atoms (H1, O, H2) and a dummy atom (M, in this example), where dummy atom located at 0.150 Å of oxygen and along
    the bisector of the H1-O-H2 angle.

.. code-block:: text 

    CRYST1    0.000    0.000    0.000  90.00  90.00  90.00 P 1           1
    ATOM      1  O   TIP4    1      -0.189   1.073   0.000  0.00  0.00           O
    ATOM      2  H1  TIP4    1       0.768   1.114   0.000  0.00  0.00           H
    ATOM      3  H2  TIP4    1      -0.469   1.988   0.000  0.00  0.00           H
    ATOM      4  M   TIP4    1      -0.102   1.195   0.000  0.00  0.00           D
    END

2.  Pack your desire number of TIP4 water molecule in a box using packmol, as explained before.

3.  Include the dummy atom (M) and its charge in your topology file. Define a bond between oxygen and dummy atom.
    Use vmd and build script to generate your PSF files.

.. code-block:: text 

    * Custom top file -- TIP4P water

    MASS   1  OH    15.9994  O !
    MASS   2  HO     1.0080  H !
    MASS   3  MO     0.0000  D ! Dummy atom for TIP4P model

    DEFA FIRS none LAST none
    AUTOGENERATE ANGLES DIHEDRALS

    RESI TIP4           0.0000 ! TIP4P water
    GROUP
    ATOM O      OH      0.0000 !        O
    ATOM H1     HO      0.5564 !     /  |  \
    ATOM H2     HO      0.5564 !    /   M   \
    ATOM M      MO     -1.1128 !  H1        H2
    BOND   O  H1   O  H2   O  M       
    PATCHING FIRS NONE LAST NONE

    END

4.  Define all bonded parameters (bond, angles, and dihedral) and nonbonded parameters in your parameter file. 

.. code-block:: text 

    *parameteres for TIP4P

    BONDS
    !
    !V(bond) = Kb(b - b0)**2
    !
    !atom type          Kb          b0   
    OH   HO    99999999999       0.9572 ! TIP4P O-H bond length  
    OH   MO    99999999999       0.1500 ! TIP4P M-O bond length


    ANGLES
    !
    !V(angle) = Ktheta(Theta - Theta0)**2
    !
    !atom types         Ktheta       Theta0  
    HO   OH   HO    9999999999999    104.52  ! H-O-H Fix Angle
    HO   OH   MO    9999999999999     52.26  ! H-O-M Fix Angle


    DIHEDRALS
    !
    !V(dihedral) = Kchi(1 + cos(n(chi) - delta))
    !
    !atom types             Kchi    n   delta


    NONBONDED 
    !
    !V(Lennard-Jones) = Eps,i,j[(Rmin,i,j/ri,j)**12 - 2(Rmin,i,j/ri,j)**6]
    !
    !atom  ignored      epsilon      Rmin/2   ignored   eps,1-4    Rmin/2,1-4
    HO      0.000000     0.00000    0.000000    0.0     0.0         0.0
    MO      0.000000     0.00000    0.000000    0.0     0.0         0.0
    OH      0.000000    -0.18521    1.772873    0.0     0.0         0.0



Simulate rigid molecule
------------------------

Currently, GOMC can simulate rigid molecules for any molecular topology in NVT and NPT ensemble, if none of the Monte Carlo moves that lead to change in
molecular configuration (e.g. ``Regrowth``, ``Crankshaft``, ``IntraSwap``, and etc.) was used.

In general, GOMC can simulate rigid molecules in all ensembles for the following molecular topology:

1.  Linear and branched molecules with no dihedrals. For instance, carbon dioxide, dimethyl ether, and all water models (SPC, SPC/E, TIP3P, TIP4P, etc).

2.  Cyclic molecules, where at least two atoms in all defined angles, belong to the body of the ring. For instance, benzene, toluene, Xylene, and more.

.. important::

    1.  For linear and branched molecule, the molecule's bonds and angles  will be adjusted according to the equilibrium values, defined in parameter file.

    2.  For cyclic molecules, the molecule's bonds and angles would not change! It is very important to create the initial molecule with correct bonds and angles. 


Setup rigid  molecule
^^^^^^^^^^^^^^^^^^^^^^

To simulate the rigid molecules in GOMC, we need to perform the following steps:

1.  Define all bonds in topology file and use **AUTOGENERATE ANGLES DIHEDRALS** in topology file to specify all angles and dihedral in PSF files.

2.  Define all bond parameters in the parameter file. If you wish to not to include the bond energy in your simulation, set the 
    the :math:`K_b` to a large value i.e. "999999999999".

3.  Define all angle parameters in the parameter file. If you wish to not to include the bend energy in your simulation, set the
    the :math:`K_{\theta}` to a large value i.e. "999999999999".

4.  Define all dihedral parameters in parameter file. If you wish to not to include the dihedral energy in your simulation, set the all 
    the :math:`C_n` to zero. **For cyclic molecules only**



Restart the simulation
----------------------

Restart the simulation with ``Restart``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you intend to start a new simulation from previous simulation state, you can use this option. Restarting the simulation with ``Restart`` **would not** result in 
an identitcal outcome, as if previous simulation was continued.
Make sure that in the previous simulation config file, the flag ``RestartFreq`` was activated and the restart PDB file/files (``OutputName``\_BOX_0_restart.pdb) 
and merged PSF file (``OutputName``\_merged.psf) were printed. 

In order to restart the simulation from previous simulation we need to perform the following steps to modify the config file:

1.  Set the ``Restart`` to True.

2.  Use the dumped restart PDB file to set the ``Coordinates`` for each box.

3.  Use the dumped merged PSF file to set the ``Structure`` for both boxes.

4.  It is a good practice to comment out the ``CellBasisVector`` by adding '#' at the beginning of each cell basis vector. However, GOMC will override 
    the cell basis information with the cell basis data from restart PDB file/files.

5.  Use the different ``OutputName`` to avoid overwriting the output files.


Here is the example of starting the NPT simulation of dimethyl ether, from equilibrated NVT simulation:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    Restart         true

    Coordinates     0   dimethylether_NVT_BOX_0_restart.pdb

    Structure       0   dimethylether_NVT_merged.psf

    #CellBasisVector1   0	45.00	0.00	0.00
    #CellBasisVector2   0	0.00	55.00	0.00
    #CellBasisVector3   0	0.00	0.00	45.00

    OutputName          dimethylether_NPT


Here is the example of starting the NPT-GEMC simulation of dimethyl ether, from equilibrated NVT simulation:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    Restart         true

    Coordinates     0   dimethylether_NVT_BOX_0_restart.pdb
    Coordinates     1   dimethylether_NVT_BOX_1_restart.pdb

    Structure       0   dimethylether_NVT_merged.psf
    Structure       1   dimethylether_NVT_merged.psf

    #CellBasisVector1   0	45.00	0.00	0.00
    #CellBasisVector2   0	0.00	55.00	0.00
    #CellBasisVector3   0	0.00	0.00	45.00

    #CellBasisVector1   1	45.00	0.00	0.00
    #CellBasisVector2   1	0.00	55.00	0.00
    #CellBasisVector3   1	0.00	0.00	45.00

    OutputName          dimethylether_NPT_GEMC

Restart the simulation with ``RestartCheckpoint``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you intend to continue your simulation from previous simulation, you can use this option. Restarting the simulation with ``RestartCheckpoint`` would result in an 
identitcal outcome, as if previous simulation was continued.
Make sure that in the previous simulation config file, the flag ``RestartFreq`` and ``CheckpointFreq`` were activated and the restart PDB file/files (``OutputName``\_BOX_0_restart.pdb)
, merged PSF file (``OutputName``\_merged.psf), and checkpoint file (``checkpoint.dat``) were printed. 

In order to restart the simulation from previous simulation we need to perform the following steps to modify the config file:

1.  Set the ``RestartCheckpoint`` to True.

2.  Use the dumped restart PDB file to set the ``Coordinates`` for each box.

3.  Use the dumped merged PSF file to set the ``Structure`` for both boxes.

4.  It is a good practice to comment out the ``CellBasisVector`` by adding '#' at the beginning of each cell basis vector. However, GOMC will override 
    the cell basis information with the cell basis data from restart PDB file/files.

5.  Use the different ``OutputName`` to avoid overwriting the output files.


Here is the example of restarting the NPT simulation of dimethyl ether, from equilibrated NVT simulation:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    RestartCheckpoint   true

    Coordinates     0   dimethylether_NVT_BOX_0_restart.pdb

    Structure       0   dimethylether_NVT_merged.psf

    #CellBasisVector1   0	45.00	0.00	0.00
    #CellBasisVector2   0	0.00	55.00	0.00
    #CellBasisVector3   0	0.00	0.00	45.00

    OutputName          dimethylether_NPT


Here is the example of restarting the NPT-GEMC simulation of dimethyl ether, from equilibrated NVT simulation:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    RestartCheckpoint   true

    Coordinates     0   dimethylether_NVT_BOX_0_restart.pdb
    Coordinates     1   dimethylether_NVT_BOX_1_restart.pdb

    Structure       0   dimethylether_NVT_merged.psf
    Structure       1   dimethylether_NVT_merged.psf

    #CellBasisVector1   0	45.00	0.00	0.00
    #CellBasisVector2   0	0.00	55.00	0.00
    #CellBasisVector3   0	0.00	0.00	45.00

    #CellBasisVector1   1	45.00	0.00	0.00
    #CellBasisVector2   1	0.00	55.00	0.00
    #CellBasisVector3   1	0.00	0.00	45.00

    OutputName          dimethylether_NPT_GEMC


.. Note:: As of right now, restarting is not supported for Multi-Sim.


Recalculate the energy 
-----------------------

GOMC is capable of recalculate the energy of previous simulation snapshot, with same or different force field. Simulation snapshot is the printed molecule's 
coordinates at specific steps, which controls by ``CoordinatesFreq``. First, we need to make sure that in the previous simulation config file, the flag ``CoordinatesFreq`` 
was activated and the coordinates PDB file/files (``OutputName``\_BOX_0.pdb) and merged PSF file (``OutputName``\_merged.psf) were printed. 

In order to recalculate the energy from previous simulation we need to perform the following steps to modify the config file:

1.  Set the ``Restart`` to True.

2.  Use the dumped coordinates PDB file to set the ``Coordinates`` for each box.

3.  Use the dumped merged PSF file to set the ``Structure`` for both boxes.

4.  Set the ``RunSteps`` to zero to activare the energy recalculation.

5.  Use the different ``OutputName`` to avoid overwriting the merged PSF files.

.. note::   GOMC only recalculated the energy terms and does not recalulate the thermodynamic properties. Hence, no output file, except merged PSF file, will be 
            generated.

Here is the example of recalculating energy from previous NVT simulation snapshot:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    Restart         true

    Coordinates     0   dimethylether_NVT_BOX_0.pdb

    Structure       0   dimethylether_NVT_merged.psf

    RunSteps        0

    OutputName          Recalculate




Simulate adsorption
--------------------

GOMC is capable of simulating gas adsorption in rigid framework using GCMC and NPT-GEMC simulation. In this section, we discuss how to generate PDB and PSF file,
how to modify the configuration file to simulate adsorption.


Build PDB and PSF file
^^^^^^^^^^^^^^^^^^^^^^

Generating PDB and PSF file for reservoir is similar to generating PDB and PSF file for isobutane, explained before. Here, we are focusing on how to generate
PDB and PSF file for adsorbent.
As mensioned before, GOMC can only read PDB and PSF file as input file. If you are using "\*.cif" file for your adsorbent, you need to perform few steps 
to extend the unit cell and export it as PDB file. There are two ways that you can prepare your adsorption simulation:


1.  **Using High Throughput Screening (HTS)**

    GOMC development group created a python code combined with Tcl scripting to automatically generate GOMC input files for adsorption simulation. 
    In this code, we use CoRE-MOF repository created by `Snurr et al. <https://pubs.acs.org/doi/abs/10.1021/cm502594j>`__ to prepare the simulation input file.

    To try this code, execute the following command in your terminal to clone the HTS repository:

    .. code-block:: bash

         $ git  clone    https://github.com/GOMC-WSU/Workshop.git --branch HTS --single-branch
         $ cd   Workshop

    or simply download it from `GitHub <https://github.com/GOMC-WSU/Workshop/tree/HTS>`__ . 

    Make sure that you installed all `GOMC software requirement <https://github.com/GOMC-WSU/Workshop/blob/HTS/GOMC_Software_Requirements.pdf>`__\. Follow the 
    "Readme.md" for more information.


2.  **Manual Preparation**

    To illustrate the steps that need to be taken to prepare the PDB and PSF file, we will use an example provided in one of our workshop. Make sure that you 
    installed all `GOMC software requirement <https://github.com/GOMC-WSU/Workshop/blob/master/GOMC_Requirements.pdf>`__\.
    
    To clone the workshop, execute the following command in your terminal to clone the workshop:

    .. code-block:: bash

         $ git  clone    https://github.com/GOMC-WSU/Workshop.git --branch master --single-branch

    or simply download it from `GitHub <https://github.com/GOMC-WSU/Workshop/tree/master>`__ .

    To show how to extend the unit cell of IRMOF-1 and build the PDB and PSF files, change your directory to:

    .. code-block:: bash

         $ cd   Workshop/adsorption/GCMC/argon_IRMOF_1/build/base/.


    In this directory, there is a "README.txt" file, which provides detailed information of steps need to be taken. Here we just provide a summary of these steps:

    -   Extend the unit cell of "EDUSIF_clean_min.cif" file using `VESTA <https://jp-minerals.org/vesta/en/download.html>`__\. To learn how to extend the 
        unit cell, removing bonds, and export it as PDB file, please refere to this `documente <https://github.com/GOMC-WSU/Workshop/blob/master/adsorption/GCMC/argon_IRMOF_1/build/base/VESTA.pdf>`__ to generate "EDUSIF_clean_min.pdb" file.

        .. note:: Generated PDB file does not provide all necessary information. Further modification must be made.

    -   The easy way to generate PSF file is to treat each atom as a separate molecule kind to avoid defining bonds, angles, and dihedrals. To modify the "EDUSIF_clean_min.pdb" file (set the residue ID, resname, ...), execute the following command to generate the 
        "EDUSIF_clean_min_modified.pdb" file.

    .. code-block:: bash

        vmd -dispdev text < convert_VESTA_PDB.tcl

    -   Treating each atom as separate molecule kind will make it easy to generate topology file. Here is an example of topology file where each atom is treated
        as a separate residue kind:

    .. code-block:: text

        * Topology file for IRMOF-1 (Zn4O(BDC)3)
        !
        MASS   1  O     15.999      O  !
        MASS   2  C     12.011      C  !
        MASS   3  H      1.008      H  !
        MASS   4  ZN    65.380      ZN !

        DEFA FIRS none LAST none
        AUTOGENERATE ANGLES DIHEDRALS

        RESI    C         0.000
        GROUP
        ATOM    C   C     0.000
        PATCHING FIRS NONE LAST NONE

        RESI    H         0.000
        GROUP
        ATOM    H   H     0.000
        PATCHING FIRS NONE LAST NONE

        RESI    O          0.000
        GROUP
        ATOM    O   O      0.000
        PATCHING FIRS NONE LAST NONE

        RESI    Zn         0.000
        GROUP
        ATOM    Zn  ZN     0.000
        PATCHING FIRS NONE LAST NONE

        END

    
    -   To generate the PSF file, each molecule kind must be separated and stored in separate pdb file. Then we use VMD to generate the PSF file. 
        All these process are scripted in "build_EDUSIF_auto.tcl" and we just need to execute the following command to generate the "IRMOF_1_BOX_0.pdb" and
        "IRMOF_1_BOX_0.psf" files.

    .. code-block:: bash

        vmd -dispdev text < build_EDUSIF_auto.tcl

    -   Last steps to fix the adsorbent atoms in their position. As mensioned in PDB section, setting the ``Beta = 1.00`` value of a molecule in PDB file, will
        fix that molecule position. This can be done by a text editor but here we use another Tcl scrip to do that. Execute the following command in your terminal
        to set the ``Beta`` value of all atoms in "IRMOF_1_BOX_0.pdb" to 1.00.

    .. code-block:: bash

        vmd -dispdev text < setBeta.tcl


Adsorption in GCMC
^^^^^^^^^^^^^^^^^^

To simulate adsorption using GCMC ensemble, we need to perform the following steps to modify the config file:

1.  Use the generated PDB files for adsorbent and adsorbate to set the ``Coordinates``.

2.  Use the generated PSF files for adsorbent and adsorbate to set the ``Structure``.

3.  Calculate the cell basis vectors for each box and set the ``CellBasisVector1,2,3`` for each box.

.. note::   To calculate the cell basis vector with cell length :math:`\boldsymbol{a} , \boldsymbol{b}, \boldsymbol{c}` and cell angle 
    :math:`\alpha, \beta. \gamma` we use the following equations:

    :math:`a_x = \boldsymbol{a}`

    :math:`a_y = 0.0`

    :math:`a_z = 0.0`

    :math:`b_x = \boldsymbol{b} \times cos(\gamma)`

    :math:`b_y = \boldsymbol{b} \times sin(\gamma)`

    :math:`c_x = \boldsymbol{c} \times cos(\beta)`

    :math:`c_y = \boldsymbol{c} \times \frac{ cos(\alpha) - cos(\beta) \times cos(\gamma) } { sin(\gamma) }`

    :math:`c_z = \boldsymbol{c} \times \sqrt {{sin(\beta)}^2 - { \bigg(\frac{ cos(\alpha) - cos(\beta) \times cos(\gamma) } { sin(\gamma) }} \bigg)^2}`


    ``CellBasisVector1`` = :math:`(a_x , a_y, a_z)`

    ``CellBasisVector2`` = :math:`(b_x , b_y, b_z)`

    ``CellBasisVector3`` = :math:`(c_x , c_y, c_z)`


4.  Set the ``Fugacity`` for adsorbate and include ``Fugacity`` for adsorbent with arbitrary value (e.g. 0.00).

Here is the example of argon (AR) adsorption at 5 bar in IRMOF-1 using GCMC ensemble:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    Coordinates     0   ../build/base/IRMOF_1_BOX_0.pdb
    Coordinates     1   ../build/reservoir/START_BOX_1.pdb

    Structure       0   ../build/base/IRMOF_1_BOX_0.psf
    Structure       1   ../build/reservoir/START_BOX_1.psf  

    CellBasisVector1    0   36.8140   0.00     0.00
    CellBasisVector2    0   18.2583  31.9880   0.00
    CellBasisVector3    0   18.2712  10.5596  30.1748

    CellBasisVector1    1   40.00     0.00    0.00
    CellBasisVector2    1    0.00    40.00    0.00
    CellBasisVector3    1    0.00    00.00   40.00  

    Fugacity    AR      5.0
    Fugacity    C       0.0
    Fugacity    H       0.0
    Fugacity    O       0.0
    Fugacity    ZN      0.0


Adsorption in NPT-GEMC
^^^^^^^^^^^^^^^^^^^^^^

To simulate adsorption using NPT-GEMC ensemble, simulaiton box 0 is used for adsorbent with fixed volume and simulaiton box 1 is used for adsorbate, where
volume of this box is fluctuating at imposed pressure. To simulation adsorption in NPT-GEMC ensemble we need to perform the following steps to modify the 
config file:

1.  Use the generated PDB file for adsorbent to set the ``Coordinates`` for box 0.

2.  Use the generated PDB file for adsorbate to set the ``Coordinates`` for box 1.

3.  Use the generated PSF file for adsorbent to set the ``Structure`` for box 0.

4.  Use the generated PSF file for adsorbate to set the ``Structure`` for box 1.

5.  Calculate the cell basis vectors for each box and set the ``CellBasisVector1,2,3`` for each box. 

6.  Set the ``GEMC`` simulaiton type to "NPT".

7.  Set the imposed ``Pressure`` (bar) for fluid phase.

8.  Keep the volume of box 0 constant by activating the ``FixVolBox0``.

Here is the example of argon (AR) adsorption at 5 bar in IRMOF-1 using NPT-GEMC ensemble:

.. code-block:: text

    ########################################################
    # Parameters need to be modified
    ########################################################
    Coordinates     0   ../build/base/IRMOF_1_BOX_0.pdb
    Coordinates     1   ../build/reservoir/START_BOX_1.pdb

    Structure       0   ../build/base/IRMOF_1_BOX_0.psf
    Structure       1   ../build/reservoir/START_BOX_1.psf  

    CellBasisVector1    0   36.8140   0.00     0.00
    CellBasisVector2    0   18.2583  31.9880   0.00
    CellBasisVector3    0   18.2712  10.5596  30.1748

    CellBasisVector1    1   40.00     0.00    0.00
    CellBasisVector2    1    0.00    40.00    0.00
    CellBasisVector3    1    0.00    00.00   40.00  

    GEMC        NPT

    Pressure    5.0

    FixVolBox0  true


Calculate Solvation Free Energy 
---------------------------------

GOMC is capable of calcutating absolute solvation free energy in NVT or NPT ensemble. Here 
we are focusing how to setup the GOMC simulation files to calculate absolute solvation free energy.

GOMC outputs the required informations (:math:`\frac{dE_{\lambda}}{d\lambda}`, :math:`\Delta E_{\lambda}`) 
to calculate solvation free energy with various estimators, such as TI, BAR, MBAR, and more.


Setup Simulation Files
^^^^^^^^^^^^^^^^^^^^^^^

1.  **Using FreeEnergy BASH Script**

    GOMC development group created a BASH script combined with Tcl scripting to automatically 
    generate GOMC input files for free energy simulations in NVT (master branch) or NPT (NPT branch) ensemble.

    To try this script, execute the following command in your terminal to clone the FreeEnergy repository:

    .. code-block:: bash

         $ git  clone    https://github.com/msoroush/FreeEnergy.git
         $ cd   FreeEnergy

    or simply download it from `GitHub <https://github.com/msoroush/FreeEnergy.git>`__ . 

    Make sure that you installed all `GOMC software requirement <https://github.com/GOMC-WSU/Workshop/blob/AIChE2019/GOMC_Requirements.pdf>`__\. Follow the 
    `README <https://github.com/msoroush/FreeEnergy/blob/master/README.md>`__ for more information.


2.  **Manual Preparation**

    To simulate solvation free energy, we need to perform the following steps:

    -   Generate the PDB and PSF files for a system containes 1 solulte + *N* solvent molecules. 

        .. note:: Number of solvent molecules (*N*) must be determined by user, based on the system size. 

    -   Equilibrate your system in NVT ensemble at specified ``Temperature``. 

    -   Equilibrate your system in NPT ensemble at specified ``Temperature`` and ``Pressure``, using 
        PDB and PSF ``restart`` files, generated from previous equilibration simulation.

    -   Determine the number of intermediate states that lead to adequate overlaps between 
        neighboring states.

    -   For each intermediate state (:math:`\lambda_i`), create an unique directory and perform the following steps:

        1.  Use the ``restart`` PDB file, generated from NPT equilibration simulation, to set the ``Coordinates``.

        2.  Use the ``merged`` PSF files, generated from NPT equilibration simulation, to set the ``Structure``.

        3.  Define the free energy parameters in ``config`` file:

            -   Set the frequency of free energy calculation
            
            -   Set the solute molecule kind name (resname) and number (resid)

            -   Set the soft-core parameters

            -   Define the lambda vecotrs for ``VDW`` and ``Coulomb`` interaction

            -   Set the index (:math:`i`) of the lambda vetor (:math:`\lambda`), at which solute-solvent interaction 
                will be coupled with :math:`\lambda_i`, using ``InitialState`` keyword.


            Here is the example of free energy parameters for CO2 (resid 1) solvation, 
            with 9 intermediate states, where the solute-solvent interaction will be 
            coupled with :math:`\lambda_{\texttt{VDW}}(6)= 1.0` , :math:`\lambda_{\texttt{Elect}}(6)= 0.50`.

            .. code-block:: text

                #################################
                # FREE ENERGY PARAMETERS
                #################################
                FreeEnergyCalc true   1000
                MoleculeType   CO2   1
                InitialState   6 
                ScalePower     2
                ScaleAlpha     0.5
                MinSigma       3.0
                ScaleCoulomb   false     
                #states        0    1    2    3    4    5    6    7    8
                LambdaVDW      0.00 0.25 0.50 0.75 1.00 1.00 1.00 1.00 1.00
                LambdaCoulomb  0.00 0.00 0.00 0.00 0.00 0.25 0.50 0.75 1.00

        
        4.  Equilibrate your system in NVT or NPT ensemble.

        5.  Perform the production simulation in NVT or NPT ensemble.


Process GOMC Free Energy Outputs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

I free energy perturbation method, the free energy difference between two states A 
(:math:`\lambda = 0.0`) and B (:math:`\lambda = 1.0`), with N - 2 intermediate states is given by:

.. math::

  \Delta G(A \rightarrow B) = -\frac{1}{\beta} \sum_{i=0}^{N-1} \ln \big< \exp \big(- \beta \Delta E_{i, i+1} \big) \big>_i


where :math:`\Delta E_{i, i+1} = E_{i+1} - E_{i}` is the energy difference of the system between states *i* and *i+1*, 
and :math:`\big< \big>_i` is the ensemble average for simulation performed in intermediate state *i*.


In thermodynamic integration, the free energy change is calculated from

.. math::

  \Delta G(A \rightarrow B) = \int_{\lambda = 0}^{\lambda = 1} \big< \frac{dU_{\lambda}}{d\lambda} \big>_{\lambda} d\lambda

where :math:`\frac{dU_{\lambda}}{d\lambda}` is the derivative of energy with respect 
to :math:`\lambda`, and :math:`\big< \big>_{\lambda}` is the ensemble average for a 
simulation run at intermediate state :math:`\lambda`.


GOMC outputs the raw informations, such as the lambda intermediate states,
the derivative of energy with respective to current lambda (:math:`\frac{dE_{\lambda}}{d\lambda}`), 
the energy different between current lambda state and all other neighboring lambda states 
(:math:`\Delta E_{\lambda}`), which is essential to calculate solvation free energy 
with various estimators, such as TI, BAR, MBAR, and more.


.. figure:: static/FE-snapshot.png

    Snapshot of GOMC free energy output file (Free_Energy_BOX_0\_ ``OutputName``.dat).



There are variety of tools developed to caclulate free energy difference, including 
`alchemlyb <https://github.com/alchemistry/alchemlyb>`__ and 
`alchemical-analysis <https://github.com/MobleyLab/alchemical-analysis>`__ .

1.  **Alchemlyb**

    In `alchemlyb <https://alchemlyb.readthedocs.io/en/latest>`__ , a variety of methods can be 
    used to estimate the free energy, including thermodynamic integration (TI), 
    Bennett acceptance ratio (BAR), and multistate Bennett acceptance ratio (MBAR).
    `alchemlyb <https://alchemlyb.readthedocs.io/en/latest>`__  is also capable of loading GOMC 
    free energy output files (Free_Energy_BOX_0\_ ``OutputName``.dat).

    To learn more about alchemlybe, please refere to `alchemlyb documentation <https://alchemlyb.readthedocs.io/en/latest>`__ 
    or `alchemlyb GitHub <https://github.com/alchemistry/alchemlyb>`__ page.
 
    .. note::

        Currently, alchemlyb does not support the free energy plots, overlap analysis,
        and free energy convergance analysis.


    To use this tool, you must install python 3 and then execute the following command in 
    your terminal to install alchemlyb:

    .. code-block:: bash

         $ pip install alchemlyb


2.  **Alchemical Analysis**

    The alchemical-analysis tools is developed by Mobley group at MIT, to Analyze alchemical free energy 
    calculations conducted in GROMACS, AMBER or SIRE. Alchemical Analysis is still available but deprecated and
    in the process of migrating all functionality to `alchemlyb <https://github.com/alchemistry/alchemlyb>`__ tool.

    Alchemical Analysis tool handles analysis via a slate of free energy methods, including BAR, 
    MBAR, TI, and the Zwanzig relationship (exponential averaging) among others, and provides a good deal 
    of analysis of computed free energies and convergence in order to help you assess the quality of your results.

    Since alchemical-analysis is no longer supported by its developers, the GOMC parser for this tool 
    was implemented and stored in a separate `repository <https://github.com/msoroush/alchemical-analysis>`__. 

    .. note::

        We encourage user to use `alchemlyb GitHub <https://github.com/alchemistry/alchemlyb>`__ tools for plotting, 
        once all the plotting features and free energy analysis was migrated. 
 

    To use this tool, you must install python 2 and then execute the following command in 
    your terminal to clone the alchemical-analysis repository:

    .. code-block:: bash

        $ git  clone    https://github.com/msoroush/alchemical-analysis.git
        $ cd   alchemical-analysis
        $ sudo python setup.py install

Run a Multi-Sim
---------------

GOMC can automatically generate independent simulations with varying parameters from one input file.  
This allows the user to sample a wider seach space.  To do so GOMC must be compiled in MPI mode, 
and a couple of parameters must be added to the conf file.

To compile in MPI mode, navigate to the GOMC/ directory and issue the following commands:

.. code-block:: bash

  $ chmod u+x metamakeMPI.sh
  $ ./metamakeMPI.sh

Then once the compilation is complete, set up the conf file as you would for a standard GOMC simulation.

Finally, select one or more of the following parameters (``Temperature``, ``Pressure``, ``ChemPot``, ``Fugacity``) and enter more than one value for such parameters separated by a tab or space.

  .. code-block:: text

    #################################
    # Mol.  Name Chem.  Pot.  (K)
    #################################
    ChemPot   ISB     -968     -974     -978     -982

  .. code-block:: text

    #################################
    # Mol.  Name Chem.  Pot.  (K)
    #################################
    Fugacity   ISB     -968     -974     -978     -982

  .. code-block:: text

    #################################
    # SIMULATION CONDITION
    #################################
    Temperature   270.00    280.00    290.00    300.00 

  .. code-block:: text

    #################################
    # GEMC TYPE (DEFAULT IS NVT GEMC) 
    #################################
    GEMC        NPT
    Pressure    5.76    5.80    5.84    5.88 

.. Note:: GOMC will allow for more than one of these parameters (i.e. ChemPot and Temperature) to be greater than one, but the number of values given must either match between parameters or be one.  For example, a simulation with five chemPots must have either one temperature or five temperatures.  A simulation with five temperatures couldn't have three pressures.  This would cause GOMC to exit.

A folder will be created for the output of each simulation, and the name will be generated from the parameters you choose. 
A parent folder containing all the child folders will be created so as to not overpopulate the initial directory.  
You may elect to choose the name of the folder in which the sub-folders for each replica are contained.
Enter this name as a string following the ``MultiSimFolderName`` parameter.  If you don't provide this parameter, the default "MultiSimFolderName" will be used.

  .. code-block:: text

    MultiSimFolderName  outputFolderName


.. Note:: To perform a multisim, GOMC must be compiled in MPI mode.  Also, if GOMC is compiled in MPI mode, a multisim must be performed.  To perform a standard simulation, use standard GOMC.


The rest of the conf file should be similar to how you would set up a standard GOMC simulation.

To initiate the multisimulation,

    .. code-block:: bash

       $ mpiexec -n #ofreplicas GOMC_xxx_yyyy <optional#ofthreads> conffile 
