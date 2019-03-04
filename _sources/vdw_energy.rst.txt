Intermolecular Energy and Virial Function (Van der Waals)
=========================================================

In this section, the virial and energy equation of Van der Waals interaction for different potential function are discussed in details.

VDW
---

This option calculates potential energy without any truncation.

``Potential Calculation``
  Interactions between atoms can be modeled with an n−6 potential, a Mie potential in which the attractive exponent is fixed. The Mie potential can be viewed as a generalized version of the 12-6 Lennard-Jones potential,

  .. math:: 

    E_{ij} = C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]

  where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`\sigma_{ij}` are, respectively, the separation, well depth, and collision diameter for the pair of interaction sites :math:`i` and :math:`j`. The constant :math:`C_n` is a normalization factor such that the minimum of the potential remains at :math:`−\epsilon_{ij}` for all :math:`n_{ij}`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

  .. math:: 
    
    C_{n_{ij}} = \bigg(\frac{n_{ij}}{n_{ij} - 6} \bigg)\bigg(\frac{n_{ij}}{6} \bigg)^{6/(n_{ij} - 6)}

``Virial Calculation``
  Virial is basically the negative derivative of energy with respect to distance, multiplied by distance.

  .. math:: 

    W_{ij} = -\frac{dE_{ij}}{dr}\times \frac{\overrightarrow{r_{ij}}}{{r_{ij}}}

  Using n−6 LJ potential defined above:

  .. math::

    W_{ij} = 6C_{n_{ij}} \epsilon_{ij} \bigg[\frac{n_{ij}}{6} \times \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]\times \frac{\overrightarrow{r_{ij}}}{{r_{ij}}^2}

.. note:: This option only evaluates the energy up to specified ``Rcut`` distance. Tail correction to energy and pressure can be specified to account for infinite cutoff distance.

SHIFT
-----
This option forces the potential energy to be zero at ``Rcut`` distance.

``Potential Calculation``
  Interactions between atoms can be modeled with an n−6 potential,
  
  .. math:: 

    E_{ij}(\texttt{shift}) = C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg] - C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{cut}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{cut}}\bigg)^6\bigg]

  where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`\sigma_{ij}` are, respectively, the separation, well depth, and collision diameter for the pair of interaction sites :math:`i` and :math:`j`. The constant :math:`C_n` is a normalization factor according to Eq. 3, such that the minimum of the potential remains at :math:`−\epsilon_{ij}` for all :math:`n_{ij}`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

``Virial Calculation``
  Virial is basically the negative derivative of energy with respect to distance, multiplied by distance, Eq. 4.

  Using ``SHIFT`` potential function defined above:

  .. math::

    W_{ij}(\texttt{shift}) = 6C_{n_{ij}} \epsilon_{ij} \bigg[\frac{n_{ij}}{6} \times \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]\times \frac{\overrightarrow{r_{ij}}}{{r_{ij}}^2}

  .. figure:: _static/VDW_SHIFT.png

    Graph of Van der Waals potential with and without the application of the ``SHIFT`` function. With the ``SHIFT`` function active, the potential by force was reduced to 0.0 at the ``Rcut`` distance. With the ``SHIFT`` function, there is a discontinuity where the potential is truncated.

SWITCH
------
This option in ``CHARMM`` or ``EXOTIC`` force field smoothly forces the potential energy to be zero at Rcut distance and starts modifying the potential at Rswitch distance.

``Potential Calculation``
  Interactions between atoms can be modeled with an n−6 potential,

  .. math::
  
    E_{ij}(\texttt{switch}) = C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]\times F_E

  where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`\sigma_{ij}` are, respectively, the separation, well depth, and collision diameter for the pair of interaction sites :math:`i` and :math:`j`. The constant :math:`C_n` is a normalization factor according to Eq. 3, such that the minimum of the potential remains at :math:`−\epsilon_{ij}` for all :math:`n_{ij}`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

  The factor :math:`F_E` is defined as:

  .. math::

    F_E = 
    \begin{cases}
      1 & r_{ij} \leq r_{switch} \\
      \frac{\big({r_{cut}}^2 - {r_{ij}}^2 \big)^2 \times \big({r_{cut}}^2 - 3{r_{switch}}^2 + 2{r_{ij}}^2 \big)}{\big({r_{cut}}^2 - {r_{switch}}^2 \big)^3} & r_{switch} < r_{ij} < r_{cut} \\
      0 & r_{ij} \geq r_{cut}
    \end{cases}

``Virial Calculation``
  Virial is basically the negative derivative of energy with respect to distance, multiplied by distance, Eq. 4.
  
  Using SWITCH potential function defined above:

  .. math::

    W_{ij}(\texttt{switch}) = \Bigg[6 C_{n_{ij}} \epsilon_{ij} \bigg[\frac{n_{ij}}{6} \times \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg]\times \frac{F_E}{{r_{ij}}^2}  - 
    
    C_{n_{ij}} \epsilon_{ij} \bigg[\bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^{n_{ij}} - \bigg(\frac{\sigma_{ij}}{r_{ij}}\bigg)^6\bigg] \times F_W \Bigg] \times \overrightarrow{r_{ij}}

  The factor :math:`F_W` is defined as:

  .. math::

    F_W = 
    \begin{cases}
      1 & r_{ij} \leq r_{switch} \\
      \frac{12\big({r_{cut}}^2 - {r_{ij}}^2 \big) \times \big({r_{switch}}^2 - {r_{ij}}^2 \big)}{\big({r_{cut}}^2 - {r_{switch}}^2 \big)^3} & r_{switch} < r_{ij} < r_{cut} \\
      0 & r_{ij} \geq r_{cut}
    \end{cases}

  .. figure:: _static/SWITCH.png

    Graph of Van der Waals potential with and without the application of the ``SWITCH`` function. With the ``SWITCH`` function active, the potential is smoothly reduced to 0.0 at the ``Rcut`` distance.

SWITCH (MARTINI)
----------------

This option in ``MARTINI`` force field smoothly forces the potential energy to be zero at Rcut distance and starts modifying the potential at ``Rswitch`` distance.

``Potential Calculation``
  Potential Calculation: Interactions between atoms can be modeled with an n−6 potential. In standard MARTINI, :math:`n` is equal to 12,

  .. math:: 

    E_{ij}(\texttt{switch}) = C_{n_{ij}}\epsilon_{ij} \Bigg[ {\sigma_{ij}}^{n} \bigg(\frac{1}{{r_{ij}}^{n}} + \varphi_{n} (r_{ij}) \bigg) - {\sigma_{ij}}^{6} \bigg(\frac{1}{{r_{ij}}^{6}} + \varphi_{6} (r_{ij}) \bigg) \Bigg]
	
  where :math:`r_{ij}`, :math:`\epsilon_{ij}`, and :math:`\sigma_{ij}` are, respectively, the separation, well depth, and collision diameter for the pair of interaction sites :math:`i` and :math:`j`. The constant :math:`C_n` is a normalization factor according to Eq. 3, such that the minimum of the potential remains at :math:`−\epsilon_{ij}` for all :math:`n_{ij}`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

  The factor :math:`\varphi_{\alpha}` and constants are defined as:

  .. math::

    \varphi_{\alpha}(r_{ij}) = 
    \begin{cases}
      -C_{\alpha} & r_{ij} \leq r_{switch} \\
      -\frac{A_{\alpha}}{3} (r_{ij} - r_{switch})^3 -\frac{B_{\alpha}}{4} (r_{ij} - r_{switch})^4 - C_{\alpha} & r_{switch} < r_{ij} < r_{cut} \\
      0 & r_{ij} \geq r_{cut}
    \end{cases}

  .. math::

    A_{\alpha} = \alpha \frac{(\alpha + 1) r_{switch} - (\alpha +4) r_{cut}} {{r_{cut}}^{(\alpha + 2)} {(r_{cut} - r_{switch})}^2}

  .. math::

    B_{\alpha} = \alpha \frac{(\alpha + 1) r_{switch} - (\alpha +3) r_{cut}} {{r_{cut}}^{(\alpha + 2)} {(r_{cut} - r_{switch})}^3}

  .. math::

    C_{\alpha} =  \frac{1}{{r_{cut}}^{\alpha}} -\frac{A_{\alpha}}{3} (r_{cut} - r_{switch})^3 -\frac{B_{\alpha}}{4} (r_{cut} - r_{switch})^4

``Virial Calculation``
  Virial is basically the negative derivative of energy with respect to distance, mul- tiplied by distance, Eq. 4.

  Using the ``SWITCH`` potential function defined for ``MARTINI`` force field:

  .. math::

    W_{ij}(\texttt{switch}) = C_{n_{ij}}\epsilon_{ij} \Bigg[ {\sigma_{ij}}^{n} \bigg(\frac{n}{{r_{ij}}^{(n+1)}} + d\varphi_{n} (r_{ij}) \bigg) - {\sigma_{ij}}^{6} \bigg(\frac{6}{{r_{ij}}^{(6+1)}} +d \varphi_{6} (r_{ij}) \bigg) \Bigg]\times \frac{\overrightarrow{r_{ij}}}{r_{ij}}
	
  The constants defined in Eq. 14-16 and the factor :math:`d\varphi_{\alpha}` defined as:

  .. math::

    d\varphi_{\alpha}(r_{ij}) = 
    \begin{cases}
      0 & r_{ij} \leq r_{switch} \\
      A_{\alpha} (r_{ij} - r_{switch})^2 + B_{\alpha} (r_{ij} - r_{switch})^3 & r_{switch} < r_{ij} < r_{cut} \\
      0 & r_{ij} \geq r_{cut}
    \end{cases}

  .. figure:: _static/MARTINI.png

    Graph of Van der Waals potential with and without the application of the ``SWITCH`` function in ``MARTINI`` force field. With the ``SWITCH`` function active, the potential is smoothly reduced to 0.0 at the ``Rcut`` distance.
