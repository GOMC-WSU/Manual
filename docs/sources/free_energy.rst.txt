Coupling Interaction with :math:`\lambda`
==========================================

In this section, the scaling nonbonded and long-range correction energies with :math:`\lambda` is discussed in detailed.

.. math::

  E_{\lambda} = E_{\lambda}(\texttt{VDW}) + E_{\lambda}(\texttt{Elect}) + E_{\lambda}(\texttt{LRC-VDW}) + E_{\lambda}(\texttt{LRC-Elect})

VDW
^^^

Soft-core
----------
In free energy calculation, the ``VDW`` interaction between solute and solvent is scaled with :math:`\lambda`, non-linearly (soft-core scheme), to avoid
end-point catastrophe and numerical issue

.. math::

  E_{\lambda}(\texttt{VDW}) = \lambda_{\texttt{VDW}} E_{\texttt{VDW}}(r_{sc})

the scaled solute-solvent distance, :math:`r_{sc}` is defined as:

.. math::

  r_{sc} = \bigg[\alpha {\big(1 - \lambda_{\texttt{VDW}} \big)}^{p}{\sigma}^6 + {r}^6 \bigg]^{\frac{1}{6}}

where, :math:`\alpha` and :math:`p` are the soft-core parameters defined by user (``ScaleAlpha``, ``ScalePower``) and :math:`\sigma` is the diameter of atom.
To improve numerical convergence of the calculation, a minimum interaction diameter :math:`\sigma_{min}` should be defined by user (``MinSigma``) for any atom with a diameter 
less than :math:`\sigma_{min}`, e.g. hydrogen atoms attached to oxygen in water or alcohols.


To calculate the solvation free energy with thermodynamic integration (TI) method, the derivative of energy with 
respect to lambda (:math:`\frac{dE_{\lambda}(\texttt{VDW})}{d\lambda_{\texttt{VDW}}}`) is required:

.. math::

  \frac{dE_{\lambda}(\texttt{VDW})}{d\lambda_{\texttt{VDW}}} = E_{\texttt{VDW}}(r_{sc}) + \frac{p \alpha \lambda_{\texttt{VDW}}}{6} \bigg(1 - \lambda_{\texttt{VDW}}\bigg)^{p-1} \bigg(\frac{{\sigma}^6}{{r_{sc}}^5} \bigg) F_{\texttt{VDW}}(r_{sc})

Electrostatic
^^^^^^^^^^^^^

Hard-core
----------
In free energy calculation, the ``Coulombic`` interaction between solute and solvent can be scaled with :math:`\lambda`, **linearly** (hard-core scheme), 
by setting the ``ScaleCoulomb`` to false.

.. math::

  E_{\lambda}(\texttt{Elect}) = \lambda_{\texttt{Elect}} E_{\texttt{Elect}}(r)

where, :math:`r` is the distance between solute and solvent, without any modification.

To calculate the solvation free energy with thermodynamic integration (TI) method, the derivative of energy with 
respect to lambda (:math:`\frac{dE_{\lambda}(\texttt{Elect})}{d\lambda_{\texttt{Elect}}}`) is required:

.. math::

  \frac{dE_{\lambda}(\texttt{Elect})}{d\lambda_{\texttt{Elect}}} = E_{\texttt{Elect}}(r)

.. warning::

  To avoid end-point catastrophe and numerical issue, it's suggested to turn on the ``VDW`` interaction completely, before turning
  on the ``Coulombic`` interaction.


Soft-core
----------
In free energy calculation, the ``Coulombic`` interaction between solute and solvent can be scaled with :math:`\lambda`, **non-linearly** (soft-core scheme), to avoid
end-point catastrophe and numerical issue. This option can be activated by setting the ``ScaleCoulomb`` to true.

.. math::

  E_{\lambda}(\texttt{Elect}) = \lambda_{\texttt{Elect}} E_{\texttt{Elect}}(r_{sc})

the scaled solute-solvent distance, :math:`r_{sc}` is defined as:

.. math::

  r_{sc} = \bigg[\alpha {\big(1 - \lambda_{\texttt{Elect}} \big)}^{p}{\sigma}^6 + {r}^6 \bigg]^{\frac{1}{6}}

where, :math:`\alpha` and :math:`p` are the soft-core parameters defined by user (``ScaleAlpha``, ``ScalePower``) and :math:`\sigma` is the diameter of atom.
To improve numerical convergence of the calculation, a minimum interaction diameter :math:`\sigma_{min}` should be defined by user (``MinSigma``) for any atom with a diameter 
less than :math:`\sigma_{min}`, e.g. hydrogen atoms attached to oxygen in water or alcohols.


To calculate the solvation free energy with thermodynamic integration (TI) method, the derivative of energy with 
respect to lambda (:math:`\frac{dE_{\lambda}(\texttt{Elect})}{d\lambda_{\texttt{Elect}}}`) is required:

.. math::

  \frac{dE_{\lambda}(\texttt{Elect})}{d\lambda_{\texttt{Elect}}} = E_{\texttt{Elect}}(r_{sc}) + \frac{p \alpha \lambda_{\texttt{Elect}}}{6} \bigg(1 - \lambda_{\texttt{Elect}}\bigg)^{p-1} \bigg(\frac{{\sigma}^6}{{r_{sc}}^5} \bigg) F_{\texttt{Elect}}(r_{sc})

.. warning::

  Using soft-core scheme to scale the coulombic interaction non-linearly, would result in **inaccurate** results if ``Ewald`` method is activated. 

  Using *Ewald Summation Method*, we suggest to use hard-core scheme, to scale the coulombic interaction linearly with :math:`\lambda`.


Long-range Correction (VDW)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The effect of long-range corrections on predicted free energies were determined for ``VDW`` interactions via a linear coupling with :math:`\lambda`.


.. math::

  E_{\lambda}(\texttt{LRC-VDW}) = \lambda_{\texttt{VDW}} \Delta E_{\texttt{LRC(VDW)}}

where, :math:`\Delta E_{\texttt{LRC(VDW)}}` is the the change in the long-range correction energy, due to adding a fully interacting solute 
to the solvent for ``VDW`` interaction.

To calculate the solvation free energy with thermodynamic integration (TI) method, the derivative of energy with 
respect to lambda (:math:`\frac{dE_{\lambda}(\texttt{LRC-VDW})}{\lambda_{\texttt{VDW}}}`) is required:

.. math::

  \frac{dE_{\lambda}(\texttt{LRC-VDW})}{d\lambda_{\texttt{VDW}}} = \Delta E_{\texttt{LRC(VDW)}}


Long-range Correction (Electrostatic)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Using *Ewald Summation Method*, the effect of long-range corrections on predicted free energies were determined for ``Coulombic`` interactions 
via a linear coupling with :math:`\lambda`.


.. math::

  E_{\lambda}(\texttt{LRC-Elect}) = \lambda_{\texttt{Elect}} \bigg[\Delta E_{reciprocal} + \Delta E_{self} + \Delta E_{correction} \bigg]

where, :math:`\Delta E_{reciprocal}`, :math:`\Delta E_{self}`, and :math:`\Delta E_{correction}` are the the change in the reciprocal, self, 
and correction energy term in ``Ewald`` method, due to adding a fully interacting solute to the solvent.

To calculate the solvation free energy with thermodynamic integration (TI) method, the derivative of energy with 
respect to lambda (:math:`\frac{dE_{\lambda}(\texttt{LRC-Elect})}{\lambda_{\texttt{Elect}}}`) is required:

.. math::

  \frac{dE_{\lambda}(\texttt{LRC-Elect})}{d\lambda_{\texttt{Elect}}} = \Delta E_{reciprocal} + \Delta E_{self} + \Delta E_{correction}

