Introduction
============

GPU Optimized Monte Carlo (GOMC) is open-source software for simulating many-body molecular systems using the Metropolis Monte Carlo algorithm. GOMC is written in object oriented C++, which was chosen since it offers a good balance between code development time, interoperability with existing software elements, and code performance. The software may be compiled as a single-threaded application, a multi-threaded application using OpenMP, or to use many-core heterogeneous CPU-GPU architectures using OpenMP and CUDA. GOMC officially supports Windows 7 or newer and most modern distribution of GNU/Linux. This software has the ability to compile on recent versions of macOS (x64 & ARM); however, such a platform is not officially supported.

GOMC employs widely-used simulation file types (PDB, PSF, CHARMM-style parameter file) and supports polar and non-polar linear and branched molecules. GOMC can be used to study vapor-liquid and liquid-liquid equilibria, adsorption in porous materials, surfactant self-assembly, and condensed phase structure for complex molecules.

To cite GOMC software, please refer to `GOMC paper <https://www.sciencedirect.com/science/article/pii/S2352711018301171>`_.

GOMC supported ensembles:
-------------------------

- Canonical (NVT)
- Isobaric-isothermal (NPT)
- Grand canonical (:math:`\mu` VT)
- Constant volume Gibbs (NVT-Gibbs) 
- Constant pressure Gibbs (NPT-Gibbs)

GOMC supported Monte Carlo moves:
---------------------------------
- Rigid-body displacement
- Rigid-body rotation
- `Force-biased Multiparticle <https://www.tandfonline.com/doi/abs/10.1080/08927022.2013.804183?journalCode=gmos20>`__ move (Rigid-body displacement or rotation of all molecules)
- `Brownian Motion Multiparticle <https://www.tandfonline.com/doi/abs/10.1080/08927022.2013.804183?journalCode=gmos20>`__ move (Rigid-body displacement or rotation of all molecules)
- Regrowth using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Crankshaft using combination of `crankshaft <https://aip.scitation.org/doi/abs/10.1063/1.438608>`_ and `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Intra-box swap using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Intra-box `molecular exchange Monte Carlo <https://aip.scitation.org/doi/abs/10.1063/1.5025184>`__
- Intra-box targeted swap using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Inter-box swap using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Inter-box targeted swap using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__
- Inter-box `molecular exchange monter carlo <https://www.sciencedirect.com/science/article/pii/S0378381218305351>`__ 

  ..
    - Non-Equilibrium Molecule Transfer <https://journals.aps.org/pre/abstract/10.1103/PhysRevE.66.046705>`__

- Volume exchange (both isotropic and anisotropic)

GOMC supported force fields:
----------------------------
- OPLS
- CHARMM 
- TraPPE
- Mie
- Martini

GOMC supported molecules:
----------------------------
- Polar molecules (using Ewald summation)
- Non-polar molecules (standard LJ and Mie potential) 
- Linear molecules (using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`_)
- Branched molecules (using `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`_)
- Cyclic molecules (using combination of `coupled-decoupled configurational-bias <https://pubs.acs.org/doi/abs/10.1021/jp984742e>`__ and `crankshaft <https://aip.scitation.org/doi/abs/10.1063/1.3644939>`__ to sample intramolecular degrees of freedom of cyclic molecules)
- Large biomolecules can be loaded into GOMC (although current sampling is limited to `crankshaft <https://aip.scitation.org/doi/abs/10.1063/1.3644939>`__ to sample intramolecular degrees of freedom)

.. Note:: 
    - Biomolecules often have defined secondary structure which is maintained through improper terms, CMAP, and missing angles and dihedrals.
    - These complexities make sampling incorrect (improper, CMAP) or impossible (missing angles and dihedrals) in GOMC and these molecules should be held fixed.

.. Note:: 
    - It is important to start the simulation with correct molecular geometry such as correct bond length, angles, and dihedral.
    - In GOMC if the defined bond length in ``Parameter`` file is different from calculated bond length in ``PDB`` files by more than 0.02 :math:`Å`, you will receive a warning message with detailed information (box, residue id, specified bond length, and calculated bond length)

.. important:: 
    - Molecular geometry of ``Linear`` and ``Branched`` molecules will be corrected during the simulation by using the Monte Carlo moves that uses coupled-decoupled configurational-bias method, such as ``Regrowth``, ``Intra-box swap``, and ``Inter-box swap``.

.. warning::
    - Bond length of the ``Cyclic`` molecules that belong to the body of rings will never be changed. Incorrect bond length may result in incorrect simulation results.
    - To sample the angles and dihedrals of a ``Cyclic`` molecule that belongs to the body of the ring, ``Regrowth`` or ``Crankshaft`` Monte Carlo move must be used.
    - Any atom or group attached to the body of the ring, will uses coupled-decoupled configurational-bias to sample the molecular geometry.
    - Flexible ``Cyclic`` molecules with multiple rings (3 or more) that share edges (e.g. tricyclic), are not supported in GOMC. This is due the fact that no ``Crankshaft`` move can alter the angle or dihedral of this atom, without changing the bond length.
