# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx and the template (it is included in anaconda) You can install it through pip:
   ```bash
   $ pip install -U Sphinx
   $ pip install sphinx_materialdesign_theme
   ```

3. To build the HTML files execute the following command in your terminal: 
   ```bash
   $ ./compile.sh
   
4. To build PDF first execute the following command in your terminal:
   ```bash
    $ sphinx-build  -b latex  src  build
   ```
   Then run:
   ```bash
    $ cd build
    $ make
   ```
