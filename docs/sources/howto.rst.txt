How to?
=======

In this section, we are providing a summary of what actions or modification need to be done in order to answer your simulaiton problem.


Build a molecule and topology file
----------------------------------

There are many open-source software that can build a molecule for you, such as `Avagadro <https://avogadro.cc/docs/getting-started/drawing-molecules/>`__ ,
`molefacture <http://www.ks.uiuc.edu/Research/vmd/plugins/molefacture/>`__ in VMD and more. Here we use molefacture features to not only build a molecule,
but also creating the topology file.

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



Restart / Recalculate
----------------------

Restart the simulation
^^^^^^^^^^^^^^^^^^^^^^

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


Recalculate the energy 
^^^^^^^^^^^^^^^^^^^^^^

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

    Make sure that you installed all `GOMC software requirement <https://github.com/GOMC-WSU/Workshop/blob/HTS/GOMC_Software_Requirements.pdb>`__\. Follow the 
    "Readme.md" for more information.


2.  **Manual preparation**

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

To simulation adsorption using GCMC ensemble, we need to perform the following steps to modify the config file:

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

To simulation adsorption using NPT-GEMC ensemble, simulaiton box 0 is used for adsorbent with fixed volume and simulaiton box 1 is used for adsorbate, where
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
