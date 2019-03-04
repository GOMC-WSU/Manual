# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx (it is included in anaconda) You can install it through pip:
   ```bash
   $ pip install -U Sphinx
   ```

3. To build simply execute the following command in your terminal:
   ```bash
    $ sphinx-build <sourcedir> <outputdir>
   ```
4. To build the HTML files execute the following command in your terminal: 
   ```bash
   $ sphinx-build  -b  html  src  build
   ```
5. To build PDF first execute the following command in your terminal:
   ```bash
    $ sphinx-build  -b latex  src  build
   ```
   Then change directory to `build` and add `\DeclareUnicodeCharacter{2212}{-}` before `\begin{document}` in `GOMC.tex` file:
   Then run:
   ```bash
    $ cd build
    $ make
   ```