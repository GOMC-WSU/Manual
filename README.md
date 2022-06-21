# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx, the template (it is included in anaconda), and latex writer.
   You can install it through pip and apt-get:
   ```bash
   $ sudo apt-get install Sphinx
   $ pip install sphinx-bootstrap-theme
   $ sudo apt-get install latexmk
   ```

3. To build the HTML files execute the following command in your terminal: 
   ```bash
   $ bash ./compile.sh  


4. To build PDF first execute the following command in your terminal:
   ```bash
    $ cd ..
    $ sphinx-build  -b latex  src  build
   ```
   Then run:
   ```bash
    $ cd build
    $ make
   ```
