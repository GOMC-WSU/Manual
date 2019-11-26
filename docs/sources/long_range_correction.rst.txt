Long-range Correction (Energy and Virial)
==========================================
To accelerate the simulation performance, the nonbonded potential is usually truncated at specific cut-off (``Rcut``) distance. 
To compensate the missing potential energy and force, beyond the ``Rcut`` distance, the long-range correction (``LRC``) or tail correction to energy and virial must be 
calculated and added to total energy and virial of the system, to account for infinite cutoff distance.

The ``VDW`` and ``EXP6`` energy functions, evaluates the energy up to specified ``Rcut`` distance. In this section, the ``LRC`` equations for virial and energy term 
for Van der Waals interaction are discussed in details.

VDW
---

This option calculates potential energy using standard Lennard Jones (12-6) or Mie (n-6) potentials, up to specific ``Rcut`` distance.

``Energy``
  For homogeneous system, the long-range correction energy can be analytically calculated:

  .. math:: 

    E_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \int_{r=r_{cut}}^{\infty} r^2 E_{\texttt{VDW}}(r) dr

  .. math::

    E_{\texttt{VDW}}(r) = C_{n} \epsilon \bigg[\bigg(\frac{\sigma}{r}\bigg)^{n} - \bigg(\frac{\sigma}{r}\bigg)^6\bigg]

  where :math:`N`, :math:`V`, :math:`r`, :math:`\epsilon`, and :math:`\sigma` are the number of molecule, volume of the system, separation, minimum potential, and collision diameter, respectively. 
  The constant :math:`C_n` is a normalization factor such that the minimum of the potential remains at :math:`−\epsilon` for all :math:`n`. In the 12-6 potential, :math:`C_n` reduces to the familiar value of 4.

  .. math:: 
    
    C_{n} = \bigg(\frac{n}{n - 6} \bigg)\bigg(\frac{n}{6} \bigg)^{6/(n - 6)}

  Substituting the general Lennard Jones energy equation into the integral, the long-range correction energy term is defined by:

  .. math:: 

    E_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} C_{n} \epsilon {\sigma}^3 \bigg[\frac{1}{n-3}\bigg(\frac{\sigma}{r_{cut}}\bigg)^{(n-3)} - \frac{1}{3} \bigg(\frac{\sigma}{r_{cut}}\bigg)^3\bigg]

``Virial``
  For homogeneous system, the long-range correction virial can be analytically calculated:

  .. math:: 

    W_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \int_{r=r_{cut}}^{\infty} r^3 F_{\texttt{VDW}}(r) dr

  .. math::

    F_{\texttt{VDW}}(r) = \frac{6C_{n} \epsilon}{r} \bigg[\frac{n}{6} \times \bigg(\frac{\sigma}{r}\bigg)^{n} - \bigg(\frac{\sigma}{r}\bigg)^6\bigg]

  Substituting the general Lennard Jones force equation into the integral, the long-range correction virial term is defined by:

  .. math:: 

    W_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} C_{n} \epsilon {\sigma}^3 \bigg[\frac{n}{n-3}\bigg(\frac{\sigma}{r_{cut}}\bigg)^{(n-3)} - 2 \bigg(\frac{\sigma}{r_{cut}}\bigg)^3\bigg]


EXP6
----

This option calculates potential energy using Buckingham potentials, up to specific ``Rcut`` distance.

``Energy``
  For homogeneous system, the long-range correction energy can be analytically calculated:

  .. math:: 

    E_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \int_{r=r_{cut}}^{\infty} r^2 E_{\texttt{VDW}}(r) dr

  .. math:: 

    E_{\texttt{VDW}}(r) =
    \begin{cases}
      \frac{\alpha\epsilon}{\alpha-6} \bigg[\frac{6}{\alpha} \exp\bigg(\alpha \bigg[1-\frac{r}{R_{min}} \bigg]\bigg) - {\bigg(\frac{R_{min}}{r}\bigg)}^6 \bigg] &  r \geq R_{max} \\
      \infty & r < R_{max}
    \end{cases}

  where :math:`r`, :math:`\epsilon`, and :math:`R_{min}` are, respectively, the separation, minimum potential, and minimum potential distance. 
  The constant :math:`\alpha` is an  exponential-6 parameter. The cutoff distance :math:`R_{max}` is the smallest positive value for which :math:`\frac{dE_{\texttt{VDW}}(r)}{dr}=0`.

  Substituting the Buckingham potential into the integral, the long-range correction energy term is defined by:

  .. math::

    E_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \bigg[AB \exp\big(\frac{-r_{cut}}{B}\big) \bigg(2 B^2 + 2 B r_{cut} + {r_{cut}}^2 \bigg) - \frac{C}{3 {r_{cut}}^3}   \bigg]

  .. math::

    A = \frac{6 \epsilon \exp(\alpha)}{\alpha - 6}

  .. math::

    B = \frac{R_{min}}{\alpha}

  .. math::

    C = \frac{\epsilon \alpha {R_{min}}^6}{\alpha - 6}

``Virial``
  For homogeneous system, the long-range correction virial can be analytically calculated:

  .. math:: 

    W_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \int_{r=r_{cut}}^{\infty} r^3 F_{\texttt{VDW}}(r) dr

  .. math::
    F_{\texttt{VDW}}(r) =
    \begin{cases}
      \frac{6 \alpha\epsilon}{r\big(\alpha-6\big)} \bigg[\frac{r}{R{min}} \exp\bigg(\alpha \bigg[1-\frac{r}{R_{min}} \bigg]\bigg) - {\bigg(\frac{R_{min}}{r}\bigg)}^6 \bigg] &  r \geq R_{max} \\
      \infty & r < R_{max}
    \end{cases}

  Substituting the Buckingham potential into the integral, the long-range correction virial term is defined by:

  .. math::

    W_{\texttt{LRC(VDW)}} = \frac{2\pi N^2}{V} \bigg[A \exp\big(\frac{-r_{cut}}{B}\big) \bigg(6 B^3 + 6 B^2 r_{cut} + 3 B {r_{cut}}^2 + {r_{cut}}^3 \bigg) - \frac{2C}{3 {r_{cut}}^3}   \bigg]
