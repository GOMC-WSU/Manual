Input File Formats
==================
In order to run simulation in GOMC, the following files need to be provided:

- GOMC executable
- PDB file(s)
- PSF file(s)
- Parameter file
- Input file "NAME.conf" (proprietary control file)

PDB File
--------
GOMC requires only one PDB file for NVT and NPT ensembles. However, GOMC requires two PDB files for GEMC and GCMC ensembles.

What is PDB file
^^^^^^^^^^^^^^^^
The term PDB can refer to the Protein Data Bank (http://www.rcsb.org/pdb/), to a data file provided there, or to any file following the PDB format. 
Files in the PDB include various information such as the name of the compound, the ATOM and HETATM records containing the coordinates of the molecules, and etc. 
PDB widely used by NAMD, GROMACS, CHARMM, ACEMD, and Amber. GOMC ignore everything in a PDB file except for the REMARK, CRYST1, ATOM, and END records. 
An overview of the PDB standard can be found here:

http://www.wwpdb.org/documentation/file-format-content/format33/sect2.html#HEADER 

http://www.wwpdb.org/documentation/file-format-content/format33/sect8.html#CRYST1 

http://www.wwpdb.org/documentation/file-format-content/format33/sect9.html#ATOM

PDB contains four major parts; ``REMARK``, ``CRYST1``, ``ATOM``, and ``END``. Here is the definition of each field and how GOMC is using them to get the information it requires.

- ``REMARK``:
  This header records present experimental  details, annotations, comments, and information not included in other records (for more information, 
  `click here <http://www.wwpdb.org/documentation/file-format-content/format33/sect2.html#HEADER>`_). 
  
  However, GOMC uses this header to print simulation informations.

  - **Max Displacement** (Å)
  - **Max Rotation** (Degree)
  - **Max volume exchange** (:math:`Å^3`)
  - **Monte Carlo Steps** (MC)


- ``CRYST1``:
  This header records the unit `cell dimension parameters <http://www.wwpdb.org/documentation/file-format-content/format33/sect8.html#CRYST1>`_.

  - **Lattice constant**: a,b,c (Å)
  - **Lattice angles**: :math:`\alpha, \beta, \gamma` (Degree)


- ``ATOM``:
  The `ATOM <http://www.wwpdb.org/documentation/file-format-content/format33/sect9.html#ATOM>`_ records present the atomic coordinates for standard amino acids 
  and nucleotides. They also present the occupancy and temperature factor for each atom.

  - **ATOM**: Record name
  - **serial**: Atom serial number.
  - **name**: Atom name.
  - **resName**: Residue name.
  - **chainID**: Chain identifier.
  - **resSeq**: Residue sequence number.
  - **x**: Coordinates for X (Å).
  - **y**: Coordinates for Y (Å).
  - **z**: Coordinates for Z (Å).
  - **occupancy**: GOMC uses to define which atoms belong to which box.
  - **beta**: Beta or Temperature factor. GOMC uses this value to define the mobility of the atoms. element: Element symbol.


- ``END``:
  A frame in the PDB file is terminated with the keyword.

Here are the PDB output of GOMC for the first molecule of isobutane:

.. code-block:: text

  REMARK    GOMC   122.790    3.14159     3439.817     1000000
  CRYST1  35.245    35.245    35.245    90.00   90.00   90.00
  ATOM    1     C1    ISB     1     0.911    -0.313    0.000    0.00    0.00    C
  ATOM    2     C1    ISB     1     1.424    -1.765    0.000    0.00    0.00    C
  ATOM    3     C1    ISB     1    -0.629    -0.313    0.000    0.00    0.00    C
  ATOM    4     C1    ISB     1     1.424     0.413   -1.257    0.00    0.00    C
  END

The fields seen here in order from left to right are the record type, atom ID, atom name, residue name, residue ID, x, y, and z coordinates, occupancy, temperature factor (called beta), and segment name.

The atom name is "C1" and residue name is "ISB". The PSF file (next section) contains a lookup table of atoms. These contain the atom name from the PDB and 
the name of the atom kind in the parameter file it corresponds to. As multiple different atom names will all correspond to the same parameter, 
these can be viewed "atom aliases" of sorts. The chain letter (in this case 'A') is sometimes used when packing a number of PDBs into a single PDB file.

.. Important::

  - VMD requires a constant number of ATOMs in a multi-frame PDB (multiple records terminated by "END" in a single file). To compensate for this, all atoms 
    from all boxes in the system are written to the output PDBs of this code.
  - For atoms not currently in a box, the coordinates are set to ``< 0.00, 0.00, 0.00 >``. The occupancy is commonly just set to "1.00" and is left unused by 
    many codes. We recycle this legacy parameter by using it to denote, in our output PDBs, the box a molecule is in (box 0 occupancy=0.00 ; box 1 occupancy=1.00)
  - The beta value in GOMC code is used to define the mobility of the molecule.

    - ``Beta = 0.00``: molecule can move and transfer within and between boxes.
    - ``Beta = 1.00``: molecule is fixed in its position.
    - ``Beta = 2.00``: molecule can move within the box but cannot be transferred between boxes.

Generating PDB file
^^^^^^^^^^^^^^^^^^^

With that overview of the format in mind, the following steps describe how a PDB file is typically built.

1. A single molecule PDB is obtained. In this example, the GaussView was used to draw the molecule, which was then edited by hand to adhere 
   to the PDB spec properly. There are many open-source software that can build a molecule for you, such as `Avagadro <https://avogadro.cc/docs/getting-started/drawing-molecules/>`__ ,
   `molefacture <http://www.ks.uiuc.edu/Research/vmd/plugins/molefacture/>`__ in VMD and more. The end result is a PDB for a single molecule:

.. code-block:: text

  REMARK   1 File created by GaussView 5.0.8
  ATOM     1  C1   ISB  1   0.911  -0.313    0.000  C
  ATOM     2  C1   ISB  1   1.424  -1.765    0.000  C
  ATOM     3  C1   ISB  1  -0.629  -0.313    0.000  C
  ATOM     4  C1   ISB  1   1.424   0.413   -1.257  C
  END

2. Next, packings are calculated to place the simulation in a region of vapor-liquid coexistence. There are a couple of ways to do this in Gibbs ensemble:

- Pack both boxes to a single middle density, which is an average of the liquid and vapor densities.

- Same as previous method, but add a modest amount to axis of one box (e.g. 10-30 A). This technique can be handy in the constant pressure Gibbs ensemble.

- Pack one box to the predicted liquid density and the other to the vapor density.

  A good reference for getting the information needed to estimate packing is the NIST Web Book database of pure compounds:

  http://webbook.nist.gov/chemistry/

3. After packing is determined, a basic pack can be performed with a Packmol script. Here is the example of packing 1000 isobutane in 70 A cubic box:

.. code-block:: text

  tolerance   3.0
  filetype    pdb
  output      STEP2_ISB_packed_BOX 0.pdb
  structure   isobutane.pdb
  number      1000
  inside cube 0.1   0.1   0.1   70.20
  end     structure

Copy the above text into "pack_isobutane.inp" file, save it and run the script by typing the following line into the terminal:

.. code-block:: bash

  $ ./packmol < pack_isobutane.inp

PSF File
--------

GOMC requires only one PSF file for NVT and NPT ensembles. However, GOMC requires two PSF files for GEMC and GCMC ensembles.

What is PSF file
^^^^^^^^^^^^^^^^

Protein structure file (PSF), contains all of the molecule-specific information needed to apply a particular force field to a molecular system. 
The CHARMM force field is divided into a topology file, which is needed to generate the PSF file, and a parameter file, which supplies specific numerical 
values for the generic CHARMM potential function. The topology file defines the atom types used in the force field; the atom names, types, bonds, and partial 
charges of each residue type; and any patches necessary to link or otherwise mutate these basic residues. The parameter file provides a mapping between bonded 
and nonbonded interactions involving the various combinations of atom types found in the topology file and specific spring constants and similar parameters for 
all of the bond, angle, dihedral, improper, and van der Waals terms in the CHARMM potential function. PSF file widely used by by NAMD, CHARMM, and X-PLOR.

The PSF file contains six main sections: ``remarks``, ``atoms``, ``bonds``, ``angles``, ``dihedrals``, and ``impropers`` (dihedral force terms used to maintain 
planarity). Each section starts with a specific header described bellow:

- ``NTITLE``: remarks on the file.
  The following is taken from a PSF file for isobutane:

  .. code-block:: text

    PSF
          3  !NTITLE
    REMARKS  original generated structure x-plor psf file
    REMARKS  topology ./Top_Branched_Alkanes.inp
    REMARKS  segment ISB { first NONE; last NONE; auto angles dihedrals }

- ``NATOM``: Defines the atom names, types, and partial charges of each residue type.

  .. code-block:: text

    atom    ID
    segment name
    residue ID
    residue name
    atom    name
    atom    type
    atom    charge
    atom    mass

  The following is taken from a PSF file for isobutane:

  .. code-block:: text

    4000 !NATOM
    1    ISB  1  ISB    C1    CH1    0.000000   13.0190  0
    2    ISB  1  ISB    C2    CH3    0.000000   15.0350  0
    3    ISB  1  ISB    C3    CH3    0.000000   15.0350  0
    4    ISB  1  ISB    C4    CH3    0.000000   15.0350  0
    5    ISB  2  ISB    C1    CH1    0.000000   13.0190  0
    6    ISB  2  ISB    C2    CH3    0.000000   15.0350  0
    7    ISB  2  ISB    C3    CH3    0.000000   15.0350  0
    8    ISB  2  ISB    C4    CH3    0.000000   15.0350  0

  The fields in the atom section, from left to right are atom ID, segment name, residue ID, residue name, atom name, atom type, charge, mass, and an unused 0.

- ``NBOND``: The covalent bond section lists four pairs of atoms per line. The following is taken from a PSF file for isobutane:

  .. code-block:: text

    3000   !BOND:     bonds
    1   2   1   3   1   4   5   6
    5   7   5   8

- ``NTHETA``: The angle section lists three triples of atoms per line. The following is taken from a PSF file for isobutane:

  .. code-block:: text

    3000   !NTHETA:   angles
    2   1   4   2   1   3   3   1   4
    6   5   8   6   5   7   7   5   8

- ``NPHI``: The dihedral sections list two quadruples of atoms per line.

- ``NIMPHI``: The improper sections list two quadruples of atoms per line. GOMC currently does not support improper. For the molecules without dihedral or improper, PDF file look like the following:

  .. code-block:: text

    0   !NPHI: dihedrals
    0   !NIMPHI: impropers

- (other sections such as cross terms)

.. Important::

  - The PSF file format is a highly redundant file format. It repeats identical topology of thousands of molecules of a common kind in some cases. GOMC follows the same approach as NAMD, allowing this excess information externally and compiling it in the code.
  - Other sections (e.g. cross terms) contain unsupported or legacy parameters and are ignored.
  - Following the restriction of VMD, the order of the atoms in PSF file must match the order of the atoms in the PDB file.
  - Improper entries are read and stored, but are not currently used. Support will eventually be added for this.

Generating PSF file
^^^^^^^^^^^^^^^^^^^

The PSF file is typically generated using PSFGen. It is convenient to make a script, such as the example below, to do this:

.. code-block:: text

  package require psfgen
  topology  ./Top_branched_Alaknes.inp 
  segment ISB {
    pdb   ./STEP2_ISB_packed_BOX 0.pdb
    first   none
    last  none
  }

  coordpdb ./STEP2_ISB_packed_BOX 0.pdb ISB

  writepsf ./STEP3_START_ISB_sys_BOX_0.psf
  writepdb ./STEP3_START_ISB_sys_BOX_0.pdb

Typically, one script is run per box to generate a finalized PDB/PSF for that box. The script requires one additional file, the NAMD-style topology file. While GOMC does not directly read or interact with this file, it's typically used to generate the PSF and, hence, is considered one of the integral file types. It will be briefly discussed in the following section.

Topology File
-------------
A CHARMM forcefield topology file contains all of the information needed to convert a list of residue names into a complete PSF structure file. The topology is a whitespace separated file format, which contains a list of atoms and their corresponding masses, and a list of residue information (charges, composition, and topology). Essentially, it is a non-redundant lookup table equivalent to the PSF file.

This is followed by a series of residues, which tell PSFGen what atoms are bonded to a given atom. Each residue is comprised of four key elements:

- A header beginning with the keyword RESI with the residue name and net charge
- A body with multiple ATOM entries (not to be confused with the PDB-style entries of the same name), which list the partial charge on the particle and what kind of atom each named atom in a specific molecule/residue is.
- A section of lines starting with the word BOND contains pairs of bonded atoms (typically 3 per line)
- A closing section with instructions for PSFGen.

Here's an example of topology file for isobutane:

.. code-block:: text

  * Custom top file -- branched alkanes *
  11
  !
  MASS 1 CH3 15.035 C !
  MASS 2 CH1 13.019 C !

  AUTOGENERATE ANGLES DIHEDRALS

  RESI ISB    0.00 !  isobutane - TraPPE
  GROUP
  ATOM  C1  CH1   0.00 !  C3\
  ATOM  C2  CH3   0.00 !     C1-C2
  ATOM  C3  CH3   0.00 !  C4/
  ATOM  C4  CH3   0.00 !
  BOND  C1  C2  C1  C3  C1  C4
  PATCHING FIRS NONE LAST NONE

  END

.. Note:: The keyword END must be used to terminate this file and keywords related to the auto-generation process must be placed near the top of the file, after the MASS definitions.

.. Tip::

  More in-depth information can be found in the following links:

  - `Topology Tutorial`_

  .. _Topology Tutorial: http://www.ks.uiuc.edu/Training/Tutorials/science/topology/topology-tutorial.pdf

  - `NAMD Tutorial: Examining the Topology File`_

  .. _`NAMD Tutorial: Examining the Topology File`: http://www.ks.uiuc.edu/Training/Tutorials/science/topology/topology-html/node4.html

  - `Developing Topology and Parameter Files`_

  .. _Developing Topology and Parameter Files: http://www.ks.uiuc.edu/Training/Tutorials/science/forcefield-tutorial/forcefield-html/node6.html

  - `NAMD Tutorial: Topology Files`_

  .. _`NAMD Tutorial: Topology Files`: http://www.ks.uiuc.edu/Training/Tutorials/namd/namd-tutorial-win-html/node25.html

Parameter File
---------------

Currently, GOMC uses a single parameter file and the user has the two kinds of parameter file choices:

- ``CHARMM`` (Chemistry at Harvard Molecular Mechanics) compatible parameter file
- ``EXOTIC`` or ``Mie`` parameter file

If the parameter file type is not specified or if the chosen file is missing, an error will result.

Both force field file options are whitespace separated files with sections preceded by a tag. When a known tag (representing a molecular interaction in the model) is encountered, reading of that section of the force field begins. Comments (anything after a ``*`` or ``!``) and whitespace are ignored. Reading concludes when the end of the file is reached or another section tag is encountered.

CHARMM format parameter file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
CHARMM contains a widely used model for describing energies in Monte Carlo and molecular dynamics simulations. It is intended to be compatible with other codes that use such a format, such as NAMD. See `here`_ for a general overview of the CHARMM force field.

.. _here: http://www.charmmtutorial.org/index.php/The_Energy_Function

Here's the basic CHARMM contributions that are supported in GOMC:

.. math::

  U_{\texttt{bond}}&=\sum_{\texttt{bonds}} K_b(b-b_0)^2\\
  U_{\texttt{angle}}&=\sum_{\texttt{angles}} K_{\theta}(\theta-\theta_0)^2\\
  U_{\texttt{dihedral}}&=\sum_{\texttt{dihedrals}} K_{\phi} [1+\cos(n\phi - \delta)]\\
  U_{\texttt{LJ}}&=\sum_{\texttt{nonbonded}} \epsilon_{ij}\left[\left(\frac{R_{min_{ij}}}{r_{ij}}\right)^{12}-2\left(\frac{R_{min_{ij}}}{r_{ij}}\right)^6\right]+ \frac{q_i q_j}{\epsilon r_{ij}}

As seen above, the following are recognized, read and used:

- ``BONDS``
  - Quadratic expression describing bond stretching based on bond length (b) in Angstrom
  – Typically, it is ignored as bonds are rigid for Monte Carlo simulations.

  .. Note:: GOMC does not sample bond stretch. To ignore the relative bond energy, set the :math:`K_b` to a large value i.e. "999999999999". 

  .. figure:: static/bonds.png

    Oscillations about the equilibrium bond length

- ``ANGLES``
  - Describe the conformational lbehavior of an angle (:math:`\delta`) between three atoms, one of which is shared branch point to the other two. 
  
  .. Note:: To fix any angle and ignore the related angle energy, set the :math:`K_\theta` to a large value i.e. "999999999999".

  .. figure:: static/angle.png

    Oscillations of 3 atoms about an equilibrium bond angle

- ``DIHEDRALS``
  - Describes crankshaft-like rotation behavior about a central bond in a series of three consecutive bonds (rotation is given as :math:`\phi`).

  .. figure:: static/dihedrals.png

    Torsional rotation of 4 atoms about a central bond

- ``NONBONDED``
  - This tag name only should be used if CHARMM force files are being used. This section describes 12-6 (Lennard-Jones) non-bonded interactions. Non-bonded parameters are assigned by specifying atom type name followed by polarizabilities (which will be ignored), minimum energy, and (minimum radius)/2. In order to modify 1-4 interaction, a second polarizability (again, will be ignored), minimum energy, and (minimum radius)/2 need to be defined; otherwise, the same parameter will be considered for 1-4 interaction.

  .. figure:: static/nonbonded.png

    Non-bonded energy terms (electrostatics and Lennard-Jones)

- ``NBFIX``
  - This tag name only should be used if CHARMM force field is being used. This section allows in- teraction between two pairs of atoms to be modified, done by specifying two atom type names followed by minimum energy and minimum radius. In order to modify 1-4 interaction, a second minimum energy and minimum radius need to be defined; otherwise, the same parameter will be considered for 1-4 interaction.

  .. Note:: Please pay attention that in this section we define minimum radius, not (minimum radius)/2 as it is defined in the NONBONDED section.

  Currently, supported sections of the ``CHARMM`` compliant file include ``BONDS``, ``ANGLES``, ``DIHEDRALS``, ``NONBONDED``, ``NBFIX``. Other sections such as ``CMAP`` are not currently read or supported.

BONDS
^^^^^

("bond stretching") is one key section of the CHARMM-compliant file. Units for the :math:`K_b` variable in this section are in kcal/mol; the :math:`b_0` section (which represents the equilibrium bond length for that kind of pair) is measured in Angstroms.

.. math::
  U_{\texttt{bond}}&=\sum_{\texttt{bonds}} K_b(b-b_0)^2\\

.. code-block:: text

  BONDS
  !V(bond) = Kb(b - b0)**2
  !
  !Kb:  kcal/mole/A**2
  !b0:  A
  !
  !Kb (kcal/mol) = Kb (K) * Boltz.  const.;
  !
  !atom type      Kb          b0     description
  CH3   CH1   9999999999    1.540 !  TraPPE 2 

.. note:: The :math:`K_b` value may appear odd, but this is because a larger value corresponds to a more rigid bond. As Monte Carlo force fields (e.g. TraPPE) typically treat molecules as rigid constructs, :math:`K_b` is set to a large value - 9999999999. Sampling bond stretch is not supported in GOMC.

ANGLES
^^^^^^

("bond bending"), where :math:`\theta` is the measured bond angle and :math:`\theta_0` is the equilibrium bond angle for that kind of pair, are commonly measured in degrees and :math:`K_\theta` is the force constant measured in kcal/mol/K. These values, in literature, are often expressed in Kelvin (K). 

To convert Kelvin to kcal/mol/K, multiply by the Boltzmann constant – :math:`K_\theta`, 0.0019872041 kcal/mol. In order to fix the angle, it requires to set a large value for :math:`K_\theta`. By assigning a large value like 9999999999, specified angle will be fixed and energy of that angle will considered to be zero.

.. math::
  U_{\texttt{angle}}&=\sum_{\texttt{angles}} K_{\theta}(\theta-\theta_0)^2\\

Here is an example of what is necessary for isobutane:

.. code-block:: text

  ANGLES
  !
  !V(angle) = Ktheta(Theta - Theta0)**2
  !
  !V(Urey-Bradley) = Kub(S - S0)**2
  !
  !Ktheta:  kcal/mole/rad**2
  !Theta0:  degrees
  !S0:  A
  !
  !Ktheta (kcal/mol) = Ktheta (K) * Boltz.  const.
  !
  !atom types         Ktheta        Theta0 
  CH3   CH1   CH3     62.100125     112.00 !  TraPPE 2

Some CHARMM ANGLES section entries include ``Urey-Bradley`` potentials (:math:`K_{ub}`, :math:`b_{ub}`), in addition to the standard quadratic angle potential. The constants related to this potential function are currently read, but the logic has not been added to calculate this potential function. Support for this potential function will be added in later versions of the code.

DIHEDRALS
^^^^^^^^^

The final major bonded interactions section of the CHARMM compliant parameter file are the DIHEDRALS. Dihedral energies were represented by a cosine series where :math:`\phi` is the dihedral angle, :math:`C_n` are dihedral force constants, :math:`n` is the multiplicity, and :math:`\delta_n` is the phase shift.
Often, there are 4 to 6 terms in a dihedral. Angles for the dihedrals' deltas are given in degrees.

.. math::
  U_{\texttt{dihedral}}&= C_0 + \sum_{\texttt{n = 1}} C_n [1+\cos(n\phi_i - \delta_n)]\\

Since isobutane has no dihedral, here are the parameters pertaining to 2,3-dimethylbutane:

.. code-block:: text

  DIHEDRALS
  !
  !V(dihedral) = Kchi(1 + cos(n(chi) - delta))
  !
  !Kchi:  kcal/mole
  !n:  multiplicity
  !delta:  degrees
  !
  !Kchi (kcal/mol) = Kchi (K) * Boltz.  const.
  !
  !atom types             Kchi    n     delta   description
  X   CH1   CH1   X    -0.498907  0     0.0   !  TraPPE 2
  X   CH1   CH1   X     0.851974  1     0.0   !  TraPPE 2
  X   CH1   CH1   X    -0.222269  2   180.0   !  TraPPE 2
  X   CH1   CH1   X     0.876894  3     0.0   !  TraPPE 2

.. note:: The code allows the use of 'X' to indicate ambiguous positions on the ends. This is useful because this kind is often determined solely by the two middle atoms in the middle of the dihedral, according to literature.

.. note:: If a dihedral parameter was defined with multiplicity value of zero (:math:`n` = 0), GOMC will automatically assign the phase shift value to 90 (:math:`\delta_n` = 90) to recover the above dihedral expresion.

IMPROPERS
^^^^^^^^^

Energy parameters used to describe out-of-plane rocking are currently read, but unused. The section is often blank. If it becomes necessary, algorithms to calculate the improper energy will need to be added.

NONBONDED
^^^^^^^^^

The next section of the CHARMM style parameter file is the NONBONDED. The nonbonded energy in CHARMM is presented as 12-6 potential
where, :math:`r_{ij}`, :math:`\epsilon_{ij}`, :math:`{R_{min}}_{ij}` are the separation, minimum potential, and minimum potential distance, respectively.
In order to use TraPPE this section of the CHARMM compliant file is critical.

.. math::
  U_{\texttt{LJ}}&=\sum_{\texttt{nonbonded}} \epsilon_{ij}\left[\left(\frac{R_{min_{ij}}}{r_{ij}}\right)^{12}-2\left(\frac{R_{min_{ij}}}{r_{ij}}\right)^6\right] \\

Here's an example with our isobutane potential model:

.. code-block:: text

  NONBONDED
  !
  !V(Lennard-Jones) = Eps,i,j[(Rmin,i,j/ri,j)**12 - 2(Rmin,i,j/ri,j)**6]
  !
  !atom ignored epsilon         Rmin/2        ignored   eps,1-4     Rmin/2,1-4
  CH3   0.0     -0.194745992  2.10461634058     0.0       0.0       0.0 !  TraPPE 1
  CH1   0.0     -0.019872040  2.62656119304     0.0       0.0       0.0 !  TraPPE 2
  End

.. note:: The :math:`R_{min}` is the potential well-depth, where the attraction is maximum. However, :math:`\sigma` is the particle diameter, where the interaction energy is zero. To convert :math:`\sigma` to :math:`R_{min}`, simply multiply :math:`\sigma` by 0.56123102415.

.. important:: If no parameter was defined for 1-4 interaction e.g (:math:`\epsilon_{1-4}, Rmin_{1-4}/2`), GOMC will use the  :math:`\epsilon, Rmin/2` for 1-4 interaction.

NBFIX
^^^^^

The last section of the CHARMM style parameter file is the NBFIX. In this section, individual pair interaction will be modified. First, pseudo non-bonded parameters have to be defined in NONBONDED and modified in NBFIX. Here iss an example if it is required to modify interaction between CH3 and CH1 atoms:

.. code-block:: text

  NBFIX
  !V(Lennard-Jones) = Eps,i,j[(Rmin,i,j/ri,j)**12 - 2(Rmin,i,j/ri,j)**6]
  !
  !atom atom  epsilon         Rmin          eps,1-4   Rmin,1-4
  CH3   CH1   -0.294745992    1.10461634058 !
  End

.. important:: If no parameter was defined for 1-4 interaction e.g (:math:`\epsilon_{1-4}, Rmin_{1-4}`), GOMC will use the  :math:`\epsilon, Rmin` for 1-4 interaction.

Exotic or Mie Parameter File
----------------------------

The Mie file is intended for use with nonstandard/specialty models of molecular interaction, which are not included in CHARMM standard. 

Mie Potential
^^^^^^^^^^^^^^
.. math:: 

  E_{ij} = C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]

where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`\sigma_{ij}` are, respectively, the separation, minimum potential, and collision diameter for the pair of interaction sites :math:`i` and :math:`j`. The constant :math:`C_n` is a normalization factor such that the minimum of the potential remains at :math:`-\epsilon_{ij}` for all :math:`n_{ij}`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

.. math:: 
  
  C_{n_{ij}} = \bigg(\frac{n_{ij}}{n_{ij} - 6} \bigg)\bigg(\frac{n_{ij}}{6} \bigg)^{6/(n_{ij} - 6)}

Buckingham Potential (Exp-6)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. math:: 

  E_{ij} = 
  \begin{cases}
    \frac{\alpha_{ij}\epsilon_{ij}}{\alpha_{ij}-6} \bigg[\frac{6}{\alpha_{ij}} exp\bigg(\alpha_{ij} \bigg[1-\frac{r_{ij}}{R_{min,ij}} \bigg]\bigg) - {\bigg(\frac{R_{min,ij}}{r_{ij}}\bigg)}^6 \bigg] &  r_{ij} \geq R_{max,ij} \\
    \infty & r_{ij} < R_{max,ij}
  \end{cases}

where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`R_{min,ij}` are, respectively, the separation, minimum potential, and minimum potential distance for the pair of interaction sites :math:`i` and :math:`j`. 
The constant :math:`\alpha_{ij}` is an  exponential-6 parameter. The cutoff distance :math:`R_{max,ij}` is the smallest positive value for which :math:`\frac{dE_{ij}}{dr_{ij}}=0`.

.. note::
  In order to use ``Mie`` or ``Exotice`` potential file format for ``Buckingham`` potential, instead of defining :math:`R_{min}`, we define :math:`\sigma` (collision diameter or the distance, where potential is zero) 
  and GOMC will calculate the :math:`R_{min}` and :math:`R_{max}` using ``Buckingham`` potential equation. 

Currently, two custom interaction are included:

- ``NONBODED_MIE`` This section describes n-6 (Lennard-Jones) or Exp-6 (Buckingham) non-bonded interactions. The Lennard-Jones potential (12-6) is a subset of Mie potential.
  Non-bonded parameters are assigned by specifying the following fields in order: 

  1. Atom type name
  2. Minimum energy (:math:`\epsilon`)
  3. Atom diameter (:math:`\sigma`)
  4. Repulsion exponent (:math:`n`) in ``Mie`` potential or :math:`\alpha` in ``Buckingham`` potential. 

  The 1-4 interaction can be modified by specifying the following fields in order:

  5. Minimum energy (:math:`\epsilon_{1-4}`)
  6. Atom diameter (:math:`\sigma_{1-4}`)
  7. Repulsion exponent (:math:`n_{1-4}`) in ``Mie`` potential or :math:`\alpha_{1-4}` in ``Buckingham`` potential. 
  
  .. note:: If no parameter is provided for 1-4 interaction, same parameters (item 2, 3, 4) would be considered for 1-4 interaction.

- ``NBFIX_MIE`` This section allows n-6 (Lennard-Jones) or Exp-6 (Buckingham) interaction between two pairs of atoms to be modified. 
  Interaction between two pairs of atoms can be modified by specifying the following fields in order: 

  1. Atom type 1 name
  2. Atom type 2 name 
  3. Minimum energy (:math:`\epsilon`)
  4. Atom diameter (:math:`\sigma`)
  5. Repulsion exponent (:math:`n`) in ``Mie`` potential or :math:`\alpha` in ``Buckingham`` potential. 

  The 1-4 interaction between two pairs of atoms can be modified by specifying the following fields in order:

  6. Minimum energy (:math:`\epsilon_{1-4}`)
  7. Atom diameter (:math:`\sigma_{1-4}`)
  8. Repulsion exponent (:math:`n_{1-4}`) in ``Mie`` potential or :math:`\alpha_{1-4}` in ``Buckingham`` potential. 
  
  .. note:: If no parameter is provided for 1-4 interaction, same parameters (item 3, 4, 5) would be considered for 1-4 interaction.
  
.. note:: In ``Mie`` or ``Buckingham`` potential, the definition of atom diameter(:math:`\sigma`) is same for both ``NONBONDED_MIE`` and ``NBFIX_MIE``.

.. important:: If no parameter was defined for 1-4 interaction e.g (:math:`\epsilon_{1-4}, \sigma_{1-4}, n_{1-4}`), GOMC will use the  :math:`\epsilon, \sigma, n` for 1-4 interaction.

Otherwise, the Mie file reuses the same geometry section headings - BONDS / ANGLES / DIHEDRALS / etc. The only difference in these sections versus in the CHARMM format force field file is that the energies are in Kelvin ('K'), 
the unit most commonly found for parameters in Monte Carlo chemical simulation literature. This precludes the need to convert to kcal/mol, the energy unit used in CHARMM.
The most frequently used section of the Mie files in the Mie potential section is NONBONDED_MIE. 

Here is the example of ``Mie`` or ``Exotic`` parameters file format that are used to simulate alkanes with ``Mie`` potential:

.. code-block:: text

  NONBONDED_MIE
  !
  !V(Mie) = const*eps*((sig/r)^n-(sig/r)^6)
  !
  !atom eps       sig     n     eps,1-4   sig,1-4   n,1-4
  CH4   161.00    3.740   14    0.0       0.0       0.0 ! Potoff, et al. '09
  CH3   121.25    3.783   16    0.0       0.0       0.0 ! Potoff, et al. '09
  CH2    61.00    3.990   16    0.0       0.0       0.0 ! Potoff, et al. '09

  NBFIX_MIE
  !V(Mie) = const*eps*((sig/r)^n-(sig/r)^6)
  !
  !atom atom  epsilon  sig     n     eps,1-4   sig,1-4   n,1-4
  CH3   CH2   100.00   3.8     16    0.0       0.0       0.0 !
  End

Here is the example of ``Mie`` or ``Exotic`` parameters file format that are used to simulate water with ``Buckingham`` potential:

.. code-block:: text

  NONBONDED_MIE
  !
  !V(exp-6) = ((eps-ij * alpha)/(alpha - 6)) * ((6 / alpha) * exp(alpha * [1 - (r / rmin)]) - (rmin / r)^6))
  !
  !atom eps       sig     alpha     eps,1-4   sig,1-4   n,1-4
  OT    159.78    3.195   12        0.0       0.0       0.0 ! Errington, et al. 1998
  HT      0.0     0.0      0        0.0       0.0       0.0 ! Errington, et al. 1998

  NBFIX_MIE
  !V(exp-6) = ((eps-ij * alpha)/(alpha - 6)) * ((6 / alpha) * exp(alpha * [1 - (r / rmin)]) - (rmin / r)^6))
  !
  !atom atom  epsilon  sig     alpha     eps,1-4   sig,1-4   n,1-4
  HT   OT      0.00    0.0     0         0.0       0.0       0.0 !
  End

.. note:: Although the units (Angstroms) are the same, the Mie file uses :math:`\sigma`, not the :math:`R_{min}` used by CHARMM. The energy in the exotic file are expressed in Kelvin (K), as this is the standard convention in the literature.

Control File (\*.conf)
----------------------
The control file is GOMC's proprietary input file. It contains key settings. The settings generally fall under three categories:

- Input/Simulation Setup
- System Settings for During Run
- Output Settings

.. note:: The control file is designed to recognize logic values, such as "yes/true/on" or "no/false/off". The keyword in control file is not case sensitive.

Input/Simulation Setup
^^^^^^^^^^^^^^^^^^^^^^

In this section, input file names are listed. In addition, if you want to restart your simulation or use integer seed for running your simulation, you need to modify this section according to your purpose.

``Restart``
  Determines whether to restart the simulation from restart file (`*_restart.pdb`) or not.

  - Value 1: Boolean - True if restart, false otherwise.

``ExpertMode``
  Determines whether to perform error checking of move selection to ensure correct ensemble is sampled.  This allows the user to run a simulation with no volume moves in NPT, NPT-GEMC; no molecule transfers in GCMC, GEMC.

  - Value 1: Boolean - True if enable expert mode; false otherwise.

``Checkpoint``
  Determines whether to restart the simulation from checkpoint file or not. Restarting the simulation with would result in
  an identitcal outcome, as if previous simulation was continued.  This is required for hybrid Monte-Carlo Molecular Dyanamics in open-ensembles (GCMC/GEMC) to concatenate trajectory files since the molecular transfers rearranges the order of the molecules.  Checkpointing will ensure the molecules are loaded in the same order each cycle.

  - Value 1: Boolean - True if restart with checkpoint file, false otherwise.
  - Value 2: String - Sets the name of the checkpoint file.

    .. code-block:: text

       Checkpoint   true	AR_KR_continued.chk

``PRNG``
  Dictates how to start the pseudo-random number generator (PRNG)

  - Value 1: String

    - RANDOM: Randomizes Mersenne Twister PRNG with random bits based on the system time.

    .. code-block:: text

       #################################
       # kind {RANDOM, INTSEED}
       #################################
       PRNG   RANDOM

    - INTSEED: This option "seeds" the Mersenne Twister PRNG with a standard integer. When the same integer is used, the generated PRNG stream should be the same every time, which is helpful in tracking down bugs.

``Random_Seed``
    Defines the seed number. If "INTSEED" is chosen, seed number needs to be specified; otherwise, the program will terminate.

    - Value 1: ULONG - If "INTSEED" option is selected for PRNG (See bellow example)

    .. code-block:: text

      #################################
      # kind {RANDOM, INTSEED}
      #################################
      PRNG          INTSEED
      Random_Seed    50

``ParaTypeCHARMM``
  Sets force field type to CHARMM style.

  - Value 1: Boolean - True if it is CHARMM forcefield, false otherwise.

  .. code-block:: text

    #################################
    # FORCE FIELD TYPE
    #################################
    ParaTypeCHARMM    true

``ParaTypeEXOTIC`` or ``ParaTypeMie``
  Sets force field type to Mie style.

  - Value 1: Boolean - True if it is Mie forcefield, false otherwise.

  .. code-block:: text

    #################################
    # FORCE FIELD TYPE
    #################################
    ParaTypeEXOTIC    true

``ParaTypeMARTINI``
  Sets force field type to MARTINI style.

  - Value 1: Boolean - True if it is MARTINI forcefield, false otherwise.

  .. code-block:: text

    #################################
    # FORCE FIELD TYPE
    #################################
    ParaTypeMARTINI     true

``Parameters``
  Provides the name and location of the parameter file to use for the simulation.

  - Value 1: String - Sets the name of the parameter file.

  .. code-block:: text

    #################################
    # FORCE FIELD TYPE
    #################################
    ParaTypeCHARMM    yes
    Parameters        ../../common/Par_TraPPE_Alkanes.inp

``Coordinates``
  Defines the PDB file names (coordinates) and location for each box in the system.

  - Value 1: Integer - Sets box number (starts from '0').

  - Value 2: String - Sets the name of PDB file.

  .. note:: NVT and NPT ensembles requires only one PDB file and GEMC/GCMC requires two PDB files. If the number of PDB files is not compatible with the simulation type, the program will terminate.

  Example of NVT or NPT ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - NVT or NPT ensemble
    #############################################
    Coordinates   0   STEP3_START_ISB_sys.pdb

  Example of Gibbs or GC ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - Gibbs or GCMC ensemble
    #############################################
    Coordinates   0   STEP3_START_ISB_sys_BOX_0.pdb
    Coordinates   1   STEP3_START_ISB_sys_BOX_1.pdb

  .. note:: In case of ``Restart`` true, the restart PDB output file from GOMC (``OutputName``\_BOX_N_restart.pdb) can be used for each box.

  Example of Gibbs ensemble when Restart mode is active:

  .. code-block:: text

    #################################
    # INPUT PDB FILES
    #################################
    Coordinates   0   ISB_T_270_k_BOX_0_restart.pdb
    Coordinates   1   ISB_T_270_k_BOX_1_restart.pdb

``Structures``
  Defines the PSF filenames (structures) for each box in the system.

  - Value 1: Integer - Sets box number (start from '0')

  - Value 2: String - Sets the name of PSF file.

  .. note:: NVT and NPT ensembles requires only one PSF file and GEMC/GCMC requires two PSF files. If the number of PSF files is not compatible with the simulation type, the program will terminate.

  Example of NVT or NPT ensemble: 

  .. code-block:: text

    #################################
    # INPUT PSF FILES
    #################################
    Structure   0   STEP3_START_ISB_sys.psf

  Example of Gibbs or GC ensemble:

  .. code-block:: text

    #################################
    # INPUT PSF FILES
    #################################
    Structure   0   STEP3_START_ISB_sys_BOX_0.psf
    Structure   1   STEP3_START_ISB_sys_BOX_1.psf

  .. note:: In case of ``Restart`` true, the PSF output file from GOMC (``OutputName``\_BOX_N_restart.psf) can be used for both boxes.

  Example of Gibbs ensemble when ``Restart`` mode is active:

  .. code-block:: text

    #################################
    # INPUT PSF FILES
    #################################
    Structure   0   ISB_T_270_k_BOX_0_restart.psf
    Structure   1   ISB_T_270_k_BOX_1_restart.psf

``binCoordinates``
  Defines the DCD file names (coordinates) and location for each box in the system.

  - Value 1: Integer - Sets box number (starts from '0').

  - Value 2: String - Sets the name of PDB file.

  .. note:: NVT and NPT ensembles requires only one DCD file and GEMC/GCMC requires only one PDB files, although loading two is supported. This is different from PDB files, for which two are required in GEMC/GCMC.  This allows the user to only load binary coordinates for one box.

  Example of NVT or NPT ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - NVT or NPT ensemble
    #############################################
    binCoordinates   0   STEP3_START_ISB_sys.coor

  Example of Gibbs or GC ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - Gibbs or GCMC ensemble
    #############################################
    binCoordinates   0   STEP3_START_ISB_sys_BOX_0.coor
    binCoordinates   1   STEP3_START_ISB_sys_BOX_1.coor

  .. note:: In case of ``Restart``, the restart DCD output file from GOMC (``OutputName``\_BOX_N_restart.coor) can be used for each box.

  Example of Gibbs ensemble when Restart mode is active:

  .. code-block:: text

    #################################
    # INPUT PDB FILES
    #################################
    binCoordinates   0   ISB_T_270_k_BOX_0_restart.coor
    binCoordinates   1   ISB_T_270_k_BOX_1_restart.coor

``binVelocities``
  Defines the VEL file names (velocities) and location for each box in the system.

  - Value 1: Integer - Sets box number (starts from '0').

  - Value 2: String - Sets the name of VEL file.

  .. note:: Originate from a Molecular Dynamics softwrae such as NAMD.  GOMC will only output a velocity restart file if it is provided one using this keyword.

  .. note:: In hybrid Monte-Carlo Molecular Dynamics, the velocities of the atoms should be preserved across cycles to increase accuracy.  These files are not used internally by GOMC, only maintained.  If a molecular transfer occurs, a new velocity is generated by Langevin dynamics.

  Example of NVT or NPT ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - NVT or NPT ensemble
    #############################################
    binVelocities   0   STEP3_START_ISB_sys.vel

  Example of Gibbs or GC ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - Gibbs or GCMC ensemble
    #############################################
    binVelocities   0   STEP3_START_ISB_sys_BOX_0.vel
    binVelocities   1   STEP3_START_ISB_sys_BOX_1.vel

  .. note:: In case of ``Restart``, the restart VEL output file from GOMC (``OutputName``\_BOX_N_restart.vel) can be used for each box.

  Example of Gibbs ensemble when Restart mode is active:

  .. code-block:: text

    #################################
    # INPUT PDB FILES
    #################################
    binVelocities   0   ISB_T_270_k_BOX_0_restart.vel
    binVelocities   1   ISB_T_270_k_BOX_1_restart.vel

``extendedSystem``
  Defines the XSC file names (box dimensions and origin) and location for each box in the system.

  - Value 1: Integer - Sets box number (starts from '0').

  - Value 2: String - Sets the name of XSC file.

  .. note:: Previously, this information was stored in plain-text format at the top of restart PDB files.  This will be deprecated in favor of binary XSC.

  Example of NVT or NPT ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - NVT or NPT ensemble
    #############################################
    extendedSystem   0   STEP3_START_ISB_sys.xsc

  Example of Gibbs or GC ensemble:

  .. code-block:: text

    #############################################
    # INPUT PDB FILES - Gibbs or GCMC ensemble
    #############################################
    extendedSystem   0   STEP3_START_ISB_sys_BOX_0.xsc
    extendedSystem   1   STEP3_START_ISB_sys_BOX_1.xsc

  .. note:: In case of ``Restart``, the restart XSC output file from GOMC (``OutputName``\_BOX_N_restart.xsc) can be used for each box.

  Example of Gibbs ensemble when Restart mode is active:

  .. code-block:: text

    #################################
    # INPUT PDB FILES
    #################################
    extendedSystem   0   ISB_T_270_k_BOX_0_restart.xsc
    extendedSystem   1   ISB_T_270_k_BOX_1_restart.xsc


``MultiSimFolderName``
  The name of the folder to be created which contains output from the multisim.

  - Value 1: String - Name of the folder to contain output

  .. code-block:: text

    MultiSimFolderName  outputFolderName


System Settings for During Run Setup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This section contains all the variables not involved in the output of data during the simulation, or in the reading of input files at the start of the simulation. In other words, it contains settings related to the moves, the thermodynamic constants (based on choice of ensemble), and the length of the simulation.
Note that some tags, or entries for tags, are only used in certain ensembles (e.g. Gibbs ensemble). These cases are denoted with colored text.

``GEMC``
  *(For Gibbs Ensemble runs only)* Defines the type of Gibbs Ensemble simulation you want to run. If neglected in Gibbs Ensemble, it simply defaults to const volume (NVT) Gibbs Ensemble.

  - Value 1: String - Allows you to pick between isovolumetric ("NVT") and isobaric ("NPT") Gibbs ensemble simulations.

  .. Note:: The default value for ``GEMC`` is NVT.

  .. code-block:: text

    #################################
    # GEMC TYPE (DEFAULT IS NVT GEMC) 
    #################################
    GEMC    NVT

``Pressure``
  For ``NPT`` or ``NPT-GEMC`` simulation, imposed pressure (in bar) needs to be specified; otherwise, the program will terminate.
  
  - Value 1: Double - Constant pressure in bar.

  .. code-block:: text

    #################################
    # GEMC TYPE (DEFAULT IS NVT GEMC) 
    #################################
    GEMC        NPT
    Pressure    5.76

``Temperature``
  Sets the temperature at which the system will run.

  - Value 1: Double - Constant temperature of simulation in degrees Kelvin.

  .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature   270.00 

  (MPI-GOMC Only)
  
  - Value 1: List of Doubles - A list of constant temperatures for simulations in degrees Kelvin.
  
  .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature   270.00    280.00    290.00    300.00 

.. Note:: To use more than one temperature, GOMC must be compiled in MPI mode.  Also, if GOMC is compiled in MPI mode, more than one temperature is required.  To use only one temperature, use standard GOMC.
  
``Rcut``
  Sets a specific radius that non-bonded interaction energy and force will be considered and calculated using defined potential function.

  - Value 1: Double - The distance to truncate the Lennard-Jones potential at.

``RcutLow``
  Sets a specific minimum possible in angstrom that reject any move that places any atom closer than specified distance.

  - Value 1: Double - The minimum possible distance between any atoms.

``RcutCoulomb``
  Sets a specific radius for each box in the system that short range electrostatic energy will be calculated.

  - Value 1: Integer - Sets box number (start from '0')

  - Value 2: Double - The distance to truncate the short rage electrostatic energy at.

  .. note:: The default value for ``RcutCoulomb`` is the value of ``Rcut``

  .. important::
    - In Ewald Summation method, at constant ``Tolerance`` and box volume, increasing ``RcutCoulomb`` would result is decreasing reciprocal vector [`Fincham 1993 <https://www.tandfonline.com/doi/abs/10.1080/08927029408022180>`_].
      Decreasing the reciprocal vector decreases the computation time in long range electrostatic calculation.

    - Increasing the ``RcutCoulomb`` results in increasing the computation time in short range electrostatic calculation.

    - Parallelization of Ewald summation method is done on reciprocal vector loop, rather than molecule loop. 
      So, in case of running on multiple CPU threads or GPU, it is better to use the lower value for ``RcutCoulomb``, to maximize the parallelization efficiency.
    
    - There is an optimum value for ``RcutCoulomb``, where result in maximum effeciency of the method. We encourage to run a short simulation with various ``RcutCoulomb`` to find the optimum value.


``LRC``
  Defines whether or not long range corrections are used.
  
  - Value 1: Boolean - True to consider long range correction. 

  .. note:: In case of using ``SHIFT`` or ``SWITCH`` potential functions, ``LRC`` will be ignored.

``Exclude``
  Defines which pairs of bonded atoms should be excluded from non-bonded interactions.

  - Value 1: String - Allows you to choose between "1-2", "1-3", and "1-4".
  
    - 1-2: All interactions pairs of bonded atoms, except the ones that separated with one bond, will be considered and modified using 1-4 parameters defined in parameter file.
    
    - 1-3: All interaction pairs of bonded atoms, except the ones that separated with one or two bonds, will be considered and modified using 1-4 parameters defined in parameter file.
    
    - 1-4: All interaction pairs of bonded atoms, except the ones that separated with one, two or three bonds, will be considered using non-bonded parameters defined in parameter file.
      
    .. note:: The default value for ``Exclude`` is "1-4".

    .. note:: In CHARMM force field, the 1-4 interaction needs to be considered. Choosing "``Exclude`` 1-3" will modify 1-4 interaction based on 1-4 parameters in parameter file. If a kind force field is used, where 1-4 interaction needs to be ignored, such as TraPPE, either "``Exclude`` 1-4" needs to be chosen or 1-4 parameter needs to be assigned to zero in the parameter file.

``Potential``
  Defines the potential function type to calculate non-bonded interaction energy and force between atoms.

  - Value 1: String - Allows you to pick between "VDW", "EXP6", "SHIFT" and "SWITCH".
    
    - VDW: Nonbonded interaction energy and force calculated based on n-6 (Lennard-Johns) equation. This function will be discussed further in the Intermolecular energy and Virial calculation section.

      .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature   270.00
        Potential     VDW
        LRC           true
        Rcut          10
        Exclude       1-4

    - EXP6: Nonbonded interaction energy and force calculated based on exp-6 (Buckingham potential) equation. This function will be discussed further in the Intermolecular energy and Virial calculation section.

      .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature   270.00
        Potential     EXP6
        LRC           true
        Rcut          10
        Exclude       1-4

    - SHIFT: This option forces the potential energy to be zero at ``Rcut`` distance. This function will be discussed further in the Intermolecular energy and Virial calculation section.

      .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature     270.00
        Potential       SHIFT
        LRC             false
        Rcut            10
        Exclude         1-4
        RcutCoulomb  0  12.0
        RcutCoulomb  1  20.0

    - SWITCH: This option smoothly forces the potential energy to be zero at ``Rcut`` distance and starts modifying the potential at ``Rswitch`` distance. Depending on force field type, specific potential function will be applied. These functions will be discussed further in the Intermolecular energy and Virial calculation section.

    ``Rswitch``
      In the case of choosing "SWITCH" as potential function, a distance is set in which non-bonded interaction energy is truncated smoothly at ``Rcut`` distance.

      - Value 1: Double - Define switch distance in angstrom. If the "SWITCH" function is chosen, ``Rswitch`` needs to be defined; otherwise, the program will be terminated.

      .. code-block:: text

        #################################
        # SIMULATION CONDITION
        #################################
        Temperature   270.00
        Potential     SWITCH
        LRC           false
        Rcut          12
        Rswitch       9
        Exclude       1-4

``VDWGeometricSigma``
  Use geometric mean, as required by OPLS force field, to combining Lennard-Jones sigma parameters for different atom types.

  - Value 1: Boolean - True, uses geometric mean to combine L-J sigmas

    .. note:: The default setting of ``VDWGeometricSigma`` is false to use arithmetic mean when combining Lennard-Jones sigma parameters for different atom types.

``ElectroStatic``
  Considers coulomb interaction or not. This function will be discussed further in the Inter- molecular energy and Virial calculation section.

  - Value 1: Boolean - True if coulomb interaction needs to be considered and false if not.

    .. note:: To simulate the polar molecule in MARTINI force field, ``ElectroStatic`` needs to be turn on. MARTINI force field uses short range coulomb interaction with constant ``Dielectric`` 15.0.

``Ewald``
  Considers standard Ewald summation method for electrostatic calculation. This function will be discussed further in the Intermolecular energy and Virial calculation section.

  - Value 1: Double - True if Ewald summation calculation needs to be considered and false if not.

    .. note:: By default, ``ElectroStatic`` will be set to true if Ewald summation method was used to calculate coulomb interaction.

``CachedFourier``
  Considers storing the reciprocal terms for Ewald summation calculation in order to improve the code performance. This option would increase the code performance with the cost of memory usage.

  - Value 1: Boolean - True to store reciprocal terms of Ewald summation calculation and false if not.

    .. note:: By default, ``CachedFourier`` will be set to true if not value was set.

    .. warning:: Monte Carlo moves, such as ``MEMC-1``, ``MEMC-2``, ``MEMC-3``, ``IntraMEMC-1``, ``IntraMEMC-2``, ``IntraMEMC-3`` does not support ``CachedFourier``.

``Tolerance``
  Specifies the accuracy of the Ewald summation calculation. Ewald separation parameter and number of reciprocal vectors for the Ewald summation are determined based on the accuracy parameter.

  - Value 1: Double - Sets the accuracy in Ewald summation calculation. 

    .. note:: 
      - A reasonable value for te accuracy is 0.00001. 
      - If "Ewald" was chosen and no value was set for Tolerance, the program will be terminated.
    
``Dielectric``
  Defines dielectric constant for coulomb interaction in MARTINI force field.

  - Value 1: Double - Sets dielectric value used in coulomb interaction.

    .. note:: 
      - In MARTINI force field, ``Dielectric`` needs to be set to 15.0. 
      - If MARTINI force field was chosen and ``Dielectric`` was not specified, a default value of 15.0 will be assigned.

``PressureCalc``
  Considers to calculate the pressure or not. If it is set to true, the frequency of pressure calculation need to be set.

  - Value 1: Boolean - True enabling pressure calculation during the simulation, false disabling pressure calculation.

  - Value 2: Ulong - The frequency of calculating the pressure.
  
``1-4scaling``
  Defines constant factor to modify intra-molecule coulomb interaction.

  - Value 1: Double - A fraction number between 0.0 and 1.0.
  
    .. note:: CHARMM force field uses a value between 0.0 and 1.0. In MARTINI force field, it needs to be set to 1.0 because 1-4 interaction will not be modified in this force field.

    .. code-block:: text

      #################################
      # SIMULATION CONDITION
      #################################
      ElectroStatic   true
      Ewald           true
      Tolerance       0.00001
      CachedFourier   false
      1-4scaling      0.0

``RunSteps``
  Sets the total number of steps to run (one move is performed for each step) (cycles = this value / number of molecules in the system)
  
  - Value 1: Ulong - Total run steps

  .. Note:: RunSteps is a delta.
  .. important:: Seting the ``RunSteps`` to zero, and activating ``Restart`` simulation, will recalculate the energy of stored simulation's snapshots.

``EqSteps``
  Sets the number of steps necessary to equilibrate the system; averaging will begin at this step.

  - Value 1: Ulong - Equilibration steps

  .. Note:: EqSteps is not a delta.  If restarting a simulation with a start step greater than EqSteps, no equilibration is performed.
  .. note:: In GCMC simulation, the ``Histogram`` files will be outputed at ``EqSteps``.

``AdjSteps``
  Sets the number of steps per adjustment of the parameter associated with each move (e.g. maximum translate distance, maximum rotation, maximum volume exchange, etc.)
  
  - Value 1: Ulong - Number of steps per move adjustment

``InitStep``
  Sets the first step of the simulation.
  
  - Value 1: Ulong - Number of first step of simulation.

  .. Note::  Hybrid Monte-Carlo Molecular Dynamics (py-MCMD) requires resetting start step to 0 for combination of NAMD and GOMC data.

    .. code-block:: text

      #################################
      # STEPS
      #################################
      RunSteps    25000000
      EqSteps     5000000
      AdjSteps    1000
      InitStep    0

``ChemPot``
  For Grand Canonical (GC) ensemble runs only: Chemical potential at which simulation is run.

  - Value 1: String - The residue name to apply this chemical potential.
  - Value 2: Double - The chemical potential value in degrees Kelvin (should be negative).

  .. note:: 
    - For binary systems, include multiple copies of the tag (one per residue kind).
    - If there is a molecule kind that cannot be transfer between boxes (in PDB file the beta value is set to 1.00 or 2.00), an arbitrary value (e.g. 0.00) can be assigned to the residue name.

  .. code-block:: text

    #################################
    # Mol.  Name Chem.  Pot.  (K)
    #################################
    ChemPot   ISB     -968

``Fugacity``
  For Grand Canonical (GC) ensemble runs only: Fugacity at which simulation is run.
  
  - Value 1: String - The residue to apply this fugacity.
  - Value 2: Double - The fugacity value in bar.

  .. note:: 
    - For binary systems, include multiple copies of the tag (one per residue kind).
    - If there is a molecule kind that cannot be transfer between boxes (in PDB file the beta value is set to 1.00 or 2.00) an arbitrary value e.g. 0.00 can be assigned to the residue name.

  .. code-block:: text

    #################################
    # Mol.  Name Fugacity (bar)
    #################################
    Fugacity  ISB   10.0
    Fugacity  Si     0.0
    Fugacity  O      0.0

``DisFreq``
  Fractional percentage at which displacement move will occur.
  
  - Value 1: Double - % Displacement

``RotFreq``
  Fractional percentage at which rigid rotation move will occur.
  
  - Value 1: Double - % Rotatation

``IntraSwapFreq``
  Fractional percentage at which molecule will be removed from a box and inserted into the same box using coupled-decoupled configurational-bias algorithm.

  - Value 1: Double - % Intra molecule swap

  .. note:: The default value for ``IntraSwapFreq`` is 0.000

``IntraTargetedSwapFreq``
  Fractional percentage at which molecule will be removed from a box and inserted into a subvolume in the same box using coupled-decoupled configurational-bias algorithm.

  - Value 1: Double - % Intra molecule swap

  .. note:: The default value for ``IntraTargetedSwapFreq`` is 0.000

``RegrowthFreq``
  Fractional percentage at which part of the molecule will be deleted and then regrown using coupled-decoupled configurational-bias algorithm.

  - Value 1: Double - % Molecular growth

  .. note:: The default value for ``RegrowthFreq`` is 0.000

``CrankShaftFreq``
  Fractional percentage at which crankshaft move will occur. In this move, two atoms that are forming angle or dihedral are selected randomely and form a shaft. 
  Then any atoms or group that are within these two selected atoms, will rotate around the shaft to sample intramolecular degree of freedom.

  - Value 1: Double - % Crankshaft

  .. note:: The default value for ``CrankShaftFreq`` is 0.000

``MultiParticleFreq``
  Fractional percentage at which multi-particle move will occur. In this move, all molecules in the selected simulation box will be rigidly rotated or displaced 
  simultaneously, along the calculated torque or force, respectively. 

  - Value 1: Double - % Multiparticle

  .. note:: The default value for ``MultiParticleFreq`` is 0.000

``MultiParticleBrownianFreq``
  Fractional percentage at which multi-particle brownian move will occur. In this move, all molecules in the selected simulation box will be rigidly rotated or displaced 
  simultaneously, along the calculated torque or force, respectively. 

  - Value 1: Double - % Multiparticle

  .. note:: The default value for ``MultiParticleBrownianFreq`` is 0.000

``NeMTMCFreq``
  Fractional percentage at which non-equilibrium molecule transfer move will occur. In this move, a molecule is gradually transferred from the selected simulation box to the destination box, with the multi-particle move or multi-particle brownian move used to relax the system.

  - Value 1: Double - % Non-equilibrium molecule transfer

  .. note:: The default value for ``NeMTMCFreq`` is 0.000
  .. note:: The number of RelaxingSteps per NeMTMC move must be defined.
  .. note:: Either MultiParticleRelaxing or MultiParticleBrownianRelaxing must be enabled if NeMTMC move is to be used.
  .. note:: ScalePower, ScaleAlpha, MinSigma, ScaleCoulomb parameters discussed in Free Energy section are used by NeMTMC moves.

``RelaxingSteps``
  Sets the total number of relaxing steps to run (one MP or BMP is performed for each step) to relax the system.
  
  - Value 1: Ulong - Total relaxing steps per NeMTMC move

  .. Note:: 

``MultiParticleRelaxing``
  Relax NeMTMC using force-biased Monte Carlo algorithm.

  - Value 1: Boolean

  .. note:: MultiParticleFreq must be non-zero if NeMTMC with MultiParticleRelaxing is to be used.

``MultiParticleBrownianRelaxing``
  Relax NeMTMC using brownian motion.

  - Value 1: Boolean

  .. note:: MultiParticleBrownianFreq must be non-zero if NeMTMC with MultiParticleBrownianRelaxing is to be used.

``SampleConfFreq``
  Intra-Swap/Regrowth Frequency in NeMTMC Relaxing Steps

  - Value 1: Double

``LambdaVDWLimit``
  Lambda VDW limit for Intra-Swap move in NeMTMC Relaxing Steps

``IntraMEMC-1Freq``
  Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume within same simulation box.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``IntraMEMC-1Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, and ``ExchangeLargeKind``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.

  ``IntraMEMC-2Freq``
    Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume within same simulation box. Backbone of small and large molecule kind will be used to insert the large molecule more efficiently.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``IntraMEMC-2Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, ``ExchangeLargeKind``, ``SmallKindBackBone``, and ``LargeKindBackBone``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.

  ``IntraMEMC-3Freq``
    Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume within same simulation box. Specified atom of the large molecule kind will be used to insert the large molecule using coupled-decoupled configurational-bias.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``IntraMEMC-3Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, ``ExchangeLargeKind``, and ``LargeKindBackBone``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.


``MEMC-1Freq``
  For Gibbs and Grand Canonical (GC) ensemble runs only: Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume in dense simulation box.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``MEMC-1Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, and ``ExchangeLargeKind``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.

  ``MEMC-2Freq``
    For Gibbs and Grand Canonical (GC) ensemble runs only: Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume in dense simulation box. Backbone of small and large molecule kind will be used to insert the large molecule more efficiently.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``MEMC-2Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, ``ExchangeLargeKind``, ``SmallKindBackBone``, and ``LargeKindBackBone``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.

  ``MEMC-3Freq``
    For Gibbs and Grand Canonical (GC) ensemble runs only: Fractional percentage at which specified number of small molecule kind will be exchanged with a specified large molecule kind in defined sub-volume in dense simulation box. Specified atom of the large molecule kind will be used to insert the large molecule using coupled-decoupled configurational-bias.
  
  - Value 1: Double - % Molecular exchange

  .. note:: 
    - The default value for ``MEMC-3Freq`` is 0.000
    - This move need additional information such as ``ExchangeVolumeDim``, ``ExchangeRatio``, ``ExchangeSmallKind``, ``ExchangeLargeKind``, and ``LargeKindBackBone``, which will be explained later.
    - For more information about this move, please refere to `MEMC-GCMC <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__ and `MEMC-GEMC <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ papers.

``SwapFreq``
  For Gibbs and Grand Canonical (GC) ensemble runs only: Fractional percentage at which molecule swap move will occur using coupled-decoupled configurational-bias.

  - Value 1: Double - % Molecule swaps

``TargetedSwapFreq``
  For Gibbs and Grand Canonical (GC) ensemble runs only: Fractional percentage at which targeted molecule swap move will occur using coupled-decoupled configurational-bias in the sub-volumes specified.

  - Value 1: Double - % Molecule targeted swaps

``VolFreq``
  For isobaric-isothermal ensemble and Gibbs ensemble runs only: Fractional percentage at which molecule will be removed from one box and inserted into the other box using configurational bias algorithm.

  - Value 1: Double - % Volume swaps

.. code-block:: text

  #################################
  # MOVE FREQEUNCY
  #################################
  DisFreq         0.39
  RotFreq         0.10
  IntraSwapFreq   0.10
  RegrowthFreq    0.10
  CrankShaftFreq  0.10
  SwapFreq        0.20
  VolFreq         0.01


.. warning:: All move percentages should add up to 1.0; otherwise, the program will terminate.


``ExchangeVolumeDim``
  To use all variation of ``MEMC`` and ``IntraMEMC`` Monte Carlo moves, the exchange sub-volume must be defined. The exchange sub-volume is defined as an orthogonal box with x-, y-, and z-dimensions, where small molecule/molecules kind will be selected from to be exchanged with a large molecule kind.

  - Value 1: Double - X dimension in :math:`Å`
  - Value 2: Double - Y dimension in :math:`Å`
  - Value 3: Double - Z dimension in :math:`Å`

  .. note::
    - Currently, the X and Y dimension cannot be set independently (X = Y = max(X, Y))
    - A heuristic for setting good values of the x-, y-, and z-dimensions is to use the geometric size of the large molecule plus 1-2 Å in each dimension.
    - In case of exchanging 1 small molecule kind with 1 large molecule kind in ``IntraMEMC-2``, ``IntraMEMC-3``, ``MEMC-2``, ``MEMC-3`` Monte Carlo moves, the sub-volume dimension has no effect on acceptance rate.

``ExchangeSmallKind``
  To use all variation of ``MEMC`` and ``IntraMEMC`` Monte Carlo moves, the small molecule kind to be exchanged with a large molecule kind must be defined. Multiple small molecule kind can be specified.

  - Value 1: String - Small molecule kind (resname) to be exchanged.

``ExchangeLargeKind``
  To use all variation of ``MEMC`` and ``IntraMEMC`` Monte Carlo moves, the large molecule kind to be exchanged with small molecule kind must be defined. Multiple large molecule kind can be specified.

  - Value 1: String - Large molecule kind (resname) to be exchanged.

``ExchangeRatio``
  To use all variation of ``MEMC`` and ``IntraMEMC`` Monte Carlo moves, the exchange ratio must be defined. The exchange ratio defines how many small molecule will be exchanged with 1 large molecule. For each large-small molecule pairs, one exchange ratio must be defined.

  - Value 1: Integer - Ratio of exchanging small molecule/molecules with 1 large molecule.

``LargeKindBackBone``
  To use ``MEMC-2``, ``MEMC-3``, ``IntraMEMC-2``, and ``IntraMEMC-3`` Monte Carlo moves, the large molecule backbone must be defined. The backbone of the molecule is defined as a vector that connects two atoms belong to the large molecule. 
  The large molecule backbone will be used to align the sub-volume in ``MEMC-2`` and ``IntraMEMC-2`` moves, while in ``MEMC-3`` and ``IntraMEMC-3`` moves, it uses the atom name to start growing the large molecule using coupled-decoupled configurational-bias. 
  For each large-small molecule pairs, two atom names must be defined.

  - Value 1: String - Atom name 1 belong to the large molecule's backbone

  - Value 2: String - Atom name 2 belong to the large molecule's backbone

  .. important:: 
    - In ``MEMC-3`` and ``IntraMEMC-3`` Monte Carlo moves, both atom names must be same, otherwise program will be terminated.
    - If large molecule has only one atom (mono atomic molecules), same atom name must be used for ``Value 1`` and ``Value 2`` of the ``LargeKindBackBone``.

``SmallKindBackBone``
  To use ``MEMC-2``, and ``IntraMEMC-2`` Monte Carlo moves, the small molecule backbone must be defined. The backbone of the molecule is defined as a vector that connects two atoms belong to the small molecule and will be used to align the sub-volume. 
  For each large-small molecule pairs, two atom names must be defined.

  - Value 1: String - Atom name 1 belong to the small molecule's backbone

  - Value 2: String - Atom name 2 belong to the small molecule's backbone

  .. important:: 
    - If small molecule has only one atom (mono atomic molecules), same atom name must be used for ``Value 1`` and ``Value 2`` of the ``SmallKindBackBone``.


Here is the example of ``MEMC-2`` Monte Carlo moves, where 7 large-small molecule pairs are defined with an exchange ratio of 1:1: (ethane, methane), (propane, ethane), (n-butane, propane), (n-pentane, nbutane), (n-hexane, n-pentane), (n-heptane, n-hexane), and (noctane, n-heptane).

.. code-block:: text

  ######################################################################
  # MEMC PARAMETER
  ######################################################################
  ExchangeVolumeDim   1.0   1.0   1.0
  ExchangeRatio       1	      1	      1      1      1      1      1
  ExchangeLargeKind   C8P    C7P    C6P    C5P    C4P    C3P    C2P
  ExchangeSmallKind   C7P    C6P    C5P    C4P    C3P    C2P    C1P
  LargeKindBackBone   C1 C8  C1 C7  C1 C6  C1 C5  C1 C4  C1 C3  C1 C2
  SmallKindBackBone   C1 C7  C1 C6  C1 C5  C1 C4  C1 C3  C1 C2  C1 C1


Here is the example of ``MEMC-3`` Monte Carlo moves, where 7 large-small molecule pairs are defined with an exchange ratio of 1:1: (ethane, methane), (propane, ethane), (n-butane, propane), (n-pentane, nbutane), (n-hexane, n-pentane), (n-heptane, n-hexane), and (noctane, n-heptane).

.. code-block:: text

  ######################################################################
  # MEMC PARAMETER
  ######################################################################
  ExchangeVolumeDim   1.0   1.0   1.0
  ExchangeRatio       1	      1	      1      1      1      1      1
  ExchangeLargeKind   C8P    C7P    C6P    C5P    C4P    C3P    C2P
  ExchangeSmallKind   C7P    C6P    C5P    C4P    C3P    C2P    C1P
  LargeKindBackBone   C4 C4  C4 C4  C3 C3  C3 C3  C2 C2  C2 C2  C1 C1
  SmallKindBackBone   C1 C7  C1 C6  C1 C5  C1 C4  C1 C3  C1 C2  C1 C1


Here is the example of ``MEMC-2`` Monte Carlo moves, where 1 large-small molecule pair is defined with an exchange ratio of 1:2: (xenon, methane).

.. code-block:: text

  ######################################################################
  # MEMC PARAMETER
  ######################################################################
  ExchangeVolumeDim   5.0   5.0   5.0
  ExchangeRatio       2	    
  ExchangeLargeKind   XE
  ExchangeSmallKind   C1P
  LargeKindBackBone   Xe Xe
  SmallKindBackBone   C1 C1


``SubVolumeBox``
Define which box the dynamic subvolume occupies.
  - Value 1: Integer - Sub-volume id.
  - Value 2: Integer - Sets box number (first box is box '0'). 

``SubVolumeCenter``
Define which box the dynamic subvolume occupies.
  - Value 1: Integer - Sub-volume id.
  - Value 2: Double - x value of SubVolumeCenter :math:`Å`.
  - Value 3: Double - y value of SubVolumeCenter :math:`Å`.
  - Value 4: Double - z value of SubVolumeCenter :math:`Å`.

``SubVolumePBC``
Define which dimensions periodic box wrapping is applied in the subvolume.
  - Value 1: Integer - Sub-volume id.
  - Value 2: String - X (optional)
  - Value 3: String - Y (optional)
  - Value 4: String - Z (optional)

``SubVolumeCenterList``
Define the center of the subvolume by defining the atoms to use for the geometric mean calculation.
  - Value 1: Integer - Sub-volume id.
  - Value 2: Integer Range - Atom indices used to calculate geometric center of subvolume.

``SubVolumeDim``
Define the dimensions of the subvolume.
  - Value 1: Integer - Sub-volume id.
  - Value 2: Double - x value of SubVolumeDim :math:`Å`.
  - Value 3: Double - y value of SubVolumeDim :math:`Å`.
  - Value 4: Double - z value of SubVolumeDim :math:`Å`.

``SubVolumeResidueKind``
Define which residue kinds can be inserted or deleted from the subvolume.
  - Value 1: Integer - Sub-volume id.
  - Value 2: String - Residue kind inserted/deleted from subvolume
  - Value .: String - Residue kind inserted/deleted from subvolume
  - Value .: String - Residue kind inserted/deleted from subvolume
  - Value N: String - Residue kind inserted/deleted from subvolume

``SubVolumeRigidSwap``
Define whether molecules are held rigid or the geometry is sampled per the coupled-decoupled CBMC scheme.
  - Value 1: Integer - Sub-volume id.
  - Value 2: Boolean - If true the molecule is held rigid.  If false, geometry is sampled when inserting in the subvolume.

``SubVolumeChemPot``
Define the chemical potential of a residue kind in the subvolume.
  - Value 1: Integer - Sub-volume id.
  - Value 2: String - Residue kind
  - Value 3: Double - Chemical potential

``SubVolumeFugacity``
Define the fugacity of a residue kind in the subvolume.
  - Value 1: Integer - Sub-volume id.
  - Value 2: String - Residue kind
  - Value 3: Double - Chemical potential

.. code-block:: text

  ######################################################################
  # TARGETED SWAP (Dynamic subVolume)
  ######################################################################
  SubVolumeBox     		1       0         
  SubVolumeCenterList  		1   	1-402
  SubVolumeDim     		1       35 35 5
  SubVolumeResidueKind 		1   	TIP3       
  SubVolumeRigidSwap   		1   	false 


``useConstantArea``
  For Isobaric-Isothermal ensemble and Gibbs ensemble runs only: Considers to change the volume of the simulation box by fixing the cross-sectional area (x-y plane).

  - Value 1: Boolean - If true volume will change only in z axis, If false volume will change with constant axis ratio.

  .. note:: By default, ``useConstantArea`` will be set to false if no value was set. It means, the volume of the box will change in a way to maintain the constant axis ratio.

``FixVolBox0``
  For adsorption simulation in NPT Gibbs ensemble runs only: Changing the volume of fluid phase (Box 1) to maintain the constant imposed pressure and temperature, while keeping the volume of adsorbed phase (Box 0) fix.

  - Value 1: Boolean - If true volume of adsorbed phase will remain constant, If false volume of adsorbed phase will change.

``CellBasisVector``
  Defines the shape and size of the simulation periodic cell. ``CellBasisVector1``, ``CellBasisVector2``, ``CellBasisVector3`` represent the cell basis vector :math:`a,b,c`, respectively. This tag may occur multiple times. It occurs once for NVT and NPT, but twice for Gibbs ensemble or GC ensemble.

  - Value 1: Integer - Sets box number (first box is box '0'). 
  - Value 2: Double - x value of cell basis vector :math:`Å`.
  - Value 3: Double - y value of cell basis vector :math:`Å`.
  - Value 4: Double - z value of cell basis vector :math:`Å`.

  .. note:: If the number of defined boxes were not compatible to simulation type, the program will be terminated.

  Example for NVT and NPT ensemble. In this example, each vector is perpendicular to the other two (:math:`\alpha = 90, \beta = 90, \gamma = 90`), as indicated by a single x, y, or z value being specified by each and making a rectangular 3-D box:

  .. code-block:: text

    ############################################
    # BOX DIMENSION #, X, Y, Z
    ############################################
    CellBasisVector1  0   40.00   00.00   00.00
    CellBasisVector2  0   00.00   40.00   00.00
    CellBasisVector3  0   00.00   00.00   80.00

  Example for Gibbs ensemble and GC ensemble ensemble. In this example, In the first box, only vector :math:`a` and :math:`c` are perpendicular to each other (:math:`\alpha = 90, \beta = 90, \gamma = 120`), and making a non-orthogonal simulation cell with the cell length :math:`a = 39.91 Å, b = 39.91 Å, c = 76.98 Å`. In the second box, each vector is perpendicular to the other two (:math:`\alpha = 90, \beta = 90, \gamma = 90`), as indicated by a single x, y, or z value being specified by each and making a cubic box:

  .. code-block:: text
  
    ############################################
    # BOX DIMENSION #, X, Y, Z
    ############################################
    CellBasisVector1  0   36.91   00.00   00.00
    CellBasisVector2  0   -18.45  31.96   00.00
    CellBasisVector3  0   00.00   00.00   76.98
    
    CellBasisVector1  1   60.00   00.00   00.00
    CellBasisVector2  1   00.00   60.00   00.00
    CellBasisVector3  1   00.00   00.00   60.00

  .. warning:: If ``Restart`` was activated, box dimension does not need to be specified. If it is specified, program will read it but it will be ignored and replaced by the printed cell dimensions and angles in the restart PDB output file from GOMC (``OutputName``\_BOX_0_restart.pdb and ``OutputName``\_BOX_1_restart.pdb).

``CBMC_First``
  Number of CD-CBMC trials to choose the first atom position (Lennard-Jones trials for first seed growth).

  - Value 1: Integer - Number of initial insertion sites to try.

``CBMC_Nth``
  Number of CD-CBMC trials to choose the later atom positions (Lennard-Jones trials for first seed growth).

  - Value 1: Integer - Number of LJ trials for growing later atom positions.

``CBMC_Ang``
  Number of CD-CBMC bending angle trials to perform for geometry (per the coupled-decoupled CBMC scheme).

  - Value 1: Integer - Number of trials per angle.

``CBMC_Dih``
  Number of CD-CBMC dihedral angle trials to perform for geometry (per the coupled-decoupled CBMC scheme).

  - Value 1: Integer - Number of trials per dihedral.

  .. code-block:: text

    #################################
    # CBMC TRIALS
    #################################
    CBMC_First  10
    CBMC_Nth    4
    CBMC_Ang    100
    CBMC_Dih    30

  
  **Next section specifies the parameters that will be used for free energy calculation in NVT and NPT ensembles.**
  
  ``FreeEnergyCalc``
    For NVT and NPT ensemble only: Considers to calculate the free energy data (the energy different between current lambda 
    state and all other neighboring lambda states, and calculate the derivative of energy with respective to current lambda) or not. 
    If it is set to true, the frequency of free energy calculation need to be set. The free energy data will be printed into
    Free_Energy_BOX_0\_ ``OutputName``.dat.

    - Value 1: Boolean - True enabling free energy calculation during the simulation, false disabling the calculation.
    
    - Value 2: Ulong - The frequency of calculating the free energy.
  
  ``MoleculeType``
    Sets the solute molecule kind (residue name) and molecule number (residue ID), which absolute solvation free will be calculated for.

    - Value 1: String - The solute name (residue name).
    
    - Value 2: Integer - The solute molecule number (residue ID).
  
  ``InitialState``
    Sets the index of the ``LambdaCoulomb`` and ``LambdaVDW`` vectors, to determine the simulation lambda value for VDW and Coulomb interactions.

    - Value 1: Integer - The index of ``LambdaCoulomb`` and ``LambdaVDW`` vectors.

  ``LambdaVDW``
    Sets the intermediate lambda states to which solute-solvent VDW interaction to be scaled.

    -  Value 1: Double - Lambda values for VDW interaction in ascending order.

    .. warning:: All lambda values must be stated in the ascending order, otherwise the program will terminate.

  ``LambdaCoulomb``
    Sets the intermediate lambda states to which solute-solvent Coulombic interaction to be scaled.

    -  Value 1: Double - Lambda values for Coulombic interaction in ascending order.

    .. warning:: All lambda values must be stated in the ascending order, otherwise the program will terminate.

    .. note::

      - By default, the lambda values for Coulombic interaction will be set to zero if ``ElectroStatic`` or ``Ewald`` is **deactivated**.
      
      - By default, the lambda values for Coulombic interaction will be set to Lambda values for VDW interaction if ``ElectroStatic`` or ``Ewald`` is **activated**.

  ``ScaleCoulomb``
    Determines to scale the Coulombic interaction non-linearly (soft-core scheme) or not.  

    - Value 1: Boolean - True if coulombic interaction needs to be scaled non-linearly, False if coulombic interaction needs to be scaled linearly.

    .. note:: By default, the ``ScaleCoulomb`` will be set to false.

  ``ScalePower``
    Sets the :math:`p` value in soft-core scaling scheme, where the distance between solute and solvent is scaled non-linearly.

    - Value 1: Integer - The :math:`p` value in the soft-core scaling scheme.

    .. note:: By default, the ``ScalePower`` will be set to 2.

  ``ScaleAlpha``
    Sets the :math:`\alpha` value in soft-core scaling scheme, where the distance between solute and solvent is scaled non-linearly.

    - Value 1: Double - :math:`\alpha` value in the soft-core scaling scheme.

    .. note:: By default, the ``ScaleAlpha`` will be set to 0.5.

  ``MinSigma``
    Sets the minimum :math:`\sigma` value in soft-core scaling scheme, where the distance between solute and solvent is scaled non-linearly.

    - Value 1: Double - Minimum :math:`\sigma` value in the soft-core scaling scheme.

    .. note:: By default, the ``MinSigma`` will be set to 3.0.

  .. note::

    Scaling the distance between solute and solvent using soft-core scheme:

    .. math::

      r_{sc} = \bigg[\alpha {\big(1 - \lambda \big)}^{p}{\sigma}^6 + {r}^6 \bigg]^{\frac{1}{6}}


  Here is the example of solvation free energy of CO2, in intermediate state 3.

.. code-block:: text

  #################################
  # FREE ENERGY PARAMETERS
  #################################
  FreeEnergyCalc true   1000
  MoleculeType   CO2   1
  InitialState   3 
  ScalePower     2
  ScaleAlpha     0.5
  MinSigma       3.0
  ScaleCoulomb   false     
  #states        0    1    2    3    4
  LambdaVDW      0.00 0.50 1.00 1.00 1.00
  LambdaCoulomb  0.00 0.00 0.00 0.50 1.00


Output Controls
^^^^^^^^^^^^^^^

This section contains all the values that control output in the control file. For example, certain variables control the naming of files outputed of the block-averaged thermodynamic variables of interest, the PDB files, etc.

``OutputName``
  Unique name with no space for simulation used to name the block average, PDB, and PSF output files.
  
  - Value 1: String - Unique phrase to identify this system.

  .. code-block:: text

    #################################
    # OUTPUT FILE NAME
    #################################
    OutputName  ISB_T_270_K

``CoordinatesFreq``
  Controls output of PDB file (coordinates). If PDB outputing was enabled, one file for NVT or NPT and 
  two files for Gibbs ensemble or GC ensemble will be outputed into ``OutputName``\_BOX_n.pdb, where n defines the box number.

  - Value 1: Boolean - "true" enables outputing these files; "false" disables outputing.

  - Value 2: Ulong - Steps per dump PDB frame. It should be less than or equal to RunSteps. If this 
    keyword could not be found in configuration file, its value will be assigned a default value to dump 10 frames.

  .. note:: 
    - DCDFreq should be used unless the low precision and slower PDB trajectory is needed, 
      perhaps beta and occupancy values are desired.
    - The PDB file contains an entry for every ATOM, in all boxes read. This allows VMD (which requires a 
      constant number of atoms) to properly parse frames, with a bit of help. Atoms that are not currently 
      in a specific box are given the coordinate (0.00, 0.00, 0.00). The occupancy value corresponds to the 
      box a molecule is currently in (e.g. 0.00 for box 0; 1.00 for box 1).
    - At the beginning of simulation, a merged PSF file will be outputed into ``OutputName``\_merged.psf, 
      in which all boxes will be outputed. It also contains the topology for every molecule in both boxes, 
      corresponding to the merged PDB format. Loading PDB files into merged PSF file in VMD allows the user 
      to visualize and analyze the results. 

``DCDFreq``
  Controls output of DCD file (binary coordinates). If DCD outputing was enabled, one file for NVT or NPT and 
  two files for Gibbs ensemble or GC ensemble will be outputed into ``OutputName``\_BOX_n.dcd, where n defines the box number.

  - Value 1: Boolean - "true" enables outputing these files; "false" disables outputing.

  - Value 2: Ulong - Steps per dump PDB frame. It should be less than or equal to RunSteps. If this 
    keyword could not be found in configuration file, its value will be assigned a default value to dump 10 frames.

  .. note:: 
    - The DCD file contains an entry for every ATOM, in all boxes read. This allows VMD (which requires a 
      constant number of atoms) to properly parse frames, with a bit of help. Atoms that are not currently 
      in a specific box are given the coordinate (0.00, 0.00, 0.00). The occupancy value corresponds to the 
      box a molecule is currently in (e.g. 0.00 for box 0; 1.00 for box 1).
    - At the beginning of simulation, a merged PSF file will be outputed into ``OutputName``\_merged.psf, 
      in which all boxes will be outputed. It also contains the topology for every molecule in both boxes, 
      corresponding to the merged PDB format. Loading DCD files into merged PSF file in VMD allows the user 
      to visualize and analyze the results. 
    

``RestartFreq``
  Controls the output of the last state of simulation at a specified step in 

	PDB files (coordinates)
	PSF files (structure)
	XSC files (box dimensions)
	COOR files (binary coordinates)
	CHK files (checkpoint)
	If provided as input:
		VEL files (velocity)

  ``OutputName``\_BOX_n_restart.*, where n defines the box number. Header part of this file contains 
  important information and will be needed to restart the simulation:


  Restart PDB files, one file for NVT or NPT and two files for Gibbs ensemble or GC ensemble, will be outputed with the following information.
  - Simulation cell dimensions and angles.
  - Maximum amount of displacement (Å), rotation (:math:`\delta`), and volume (:math:`Å^3`) that used in Displacement, Rotation, and Volume move.
 
  .. note:: 
    - The restart PDB/PSF/COOR/VEL files contains only ATOM that exist in each boxes at specified steps.  This allows the user to load a box into NAMD and run molecular dynamics in Hybrid Monte-Carlo Molecular Dynamics (py-MCMD).
    - Only restart files must be used to begin a GOMC simulation with ``Restart`` simulation active.  The merged psf is NOT a restart file.
    - CoordinatesFreq must be a common multiple of RestartFreq or vice versa.

Checkpoint file contents:

  - Last simulation step that saved into checkpoint file (Start step can be overriden).
  - True number of simulation steps that have been run.
  - Maximum amount of displacement (Å), rotation (:math:`\delta`), and volume (:math:`Å^3`) that used in Displacement, Rotation, MultiParticle, and Volume move.
  - Number of Monte Carlo move trial and acceptance.
  - Random number sequence.
  - Molecule lookup object.
  - Original pdb atoms object to reload new positions into.
  - Original molecule setup object generated from parsing first PSF files.
  - Accessory data for coordinating loading the restart coordinates into the original ordering.
  If built with MPI and parallel tempering was enabled:
  - Random number sequence for parallel tempering.

``ConsoleFreq``
  Controls the output to STDIO ("the console") of messages such as acceptance statistics, and run timing info. In addition, instantaneously-selected thermodynamic properties will be output to this file.

  - Value 1: Boolean - "true" enables message printing; "false" disables outputing.
  - Value 2: Ulong - Number of steps per print. If this keyword could not be found in the configuration file, the value will be assigned by default to dump 1000 output for RunSteps greater than 1000 steps and 100 output for RunSteps less than 1000 steps.

``BlockAverageFreq``
  Controls the block averages output of selected thermodynamic properties. Block averages are averages of thermodynamic values of interest for chunks of the simulation (for post-processing of averages or std. dev. in those values).

  - Value 1: Boolean - "true" enables printing block average; "false" disables it.
  - Value 2: Ulong - Number of steps per block-average output file. If this keyword cannot be found in the configuration file, its value will be assigned a default to dump 100 output.

``HistogramFreq``
  Controls the histograms. Histograms are a binned listing of observation frequency for a specific thermodynamic variable. In this code, they also control the output of a file containing energy/molecule samples; it only will be used in GC ensemble simulations for histogram reweighting purposes.

  - Value 1: Boolean - "true" enables printing histogram; "false" disables it.
  - Value 2: Ulong - Number of steps per histogram output file. If this keyword cannot be found in the configuration file, a value will be assigned by default to dump 1000 output for RunSteps greater than 1000 steps and 100 output for RunSteps less than 1000 steps.

  .. code-block:: text

    #################################
    # STATISTICS Enable, Freq.
    #################################
    CoordinatesFreq   true 10000000
    RestartFreq       true 1000000
    CheckpointFreq    true 1000000
    ConsoleFreq       true 100000
    BlockAverageFreq  true 100000
    HistogramFreq     true 10000

The next section controls the output of the energy/molecule sample file and the distribution file f
or molecule counts, commonly referred to as the "histogram" output. This section is only required 
if Grand Canonical ensemble simulation was used.

``DistName``
  Sets short phrase to naming molecule distribution file.

  - Value 1: String - Short phrase which will be combined with *RunNumber* and *RunLetter* to use in the name of the binned histogram for molecule distribution.
  
``HistName``
  Sets short phrase to naming energy sample file.

  - Value 1: String - Short phrase, which will be combined with *RunNumber* and *RunLetter*, to use in the name of the energy/molecule count sample file.

``RunNumber``
  Sets a number, which is a part of *DistName* and *HistName* file name.
  
  - Value 1: Uint – Run number to be used in the above file names.

``RunLetter``
  Sets a letter, which is a part of *DistName* and *HistName* file name.
  
  - Value 1: Character – Run letter to be used in above file names.

``SampleFreq``
  Controls histogram sampling frequency.

  - Value 1: Uint – the number of steps per histogram sample.

  .. code-block:: text

    #################################
    # OutHistSettings
    #################################
    DistName   dis
    HistName   his
    RunNumber  5
    RunLetter  a
    SampleFreq 200
    
``OutEnergy, OutPressure, OutMolNumber, OutDensity, OutVolume, OutSurfaceTension``
  Enables/Disables for specific kinds of file output for tracked thermodynamic quantities

  - Value 1: Boolean – "true" enables message output of block averages via this tracked parameter (and in some cases such as entry, components); "false" disables it.
  - Value 2: Boolean – "true" enables message output of a fluctuation into the console file via this tracked parameter (and in some cases, such as entry, components); "false" disables it.

  The keywords are available for the following ensembles

  ====================  ====================  ====================  ====================
  Keyword               NVT                   NPT & Gibbs           GC
  ====================  ====================  ====================  ====================
  OutEnergy             :math:`\checkmark`    :math:`\checkmark`    :math:`\checkmark`
  OutPressure           :math:`\checkmark`    :math:`\checkmark`    :math:`\checkmark`
  OutMolNumber                                :math:`\checkmark`    :math:`\checkmark`
  OutDensity                                  :math:`\checkmark`    :math:`\checkmark`
  OutVolume                                   :math:`\checkmark`    :math:`\checkmark`
  OutSurfaceTension     :math:`\checkmark`                                            
  ====================  ====================  ====================  ====================

  Here is an example:
  
  .. code-block:: text

    #################################
    # ENABLE: BLK AVE., FLUC.
    #################################
    OutEnergy         true true
    OutPressure       true true
    OutMolNum         true true
    OutDensity        true true
    OutVolume         true true
    OutSurfaceTention false false
