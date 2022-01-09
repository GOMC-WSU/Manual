# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx, the tempelate (it is included in anaconda), and latex writer.
   You can install it through pip and apt-get:
   ```bash
   $ pip install -U Sphinx
   $ pip install sphinx-bootstrap-theme
   $ sudo apt-get install latexmk
   ```

3. To build the HTML files execute the following command in your terminal: 
   ```bash
   $ rm -r docs
   $ sphinx-build src docs
   ```
   After the process is complete go to `docs` directory.
   ```bash
   $ cd docs
   ```
   Then rename all three directories.
   ```bash
   $ mv _images images
   $ mv _sources sources
   $ mv _static static
   ```
   Then for each file inside docs, replace the same strings. `_images`, `_sources`, and `_static` to `images`, `sources`, `static`.
   $ find . -name \* -exec sed -i "s/_images/images/g" {} \;
   $ find . -name \* -exec sed -i "s/_sources/sources/g" {} \;
   $ find . -name \* -exec sed -i "s/_static/static/g" {} \;
   


4. To build PDF first execute the following command in your terminal:
   ```bash
    $ sphinx-build  -b latex  src  build
   ```
   Then run:
   ```bash
    $ cd build
    $ make
   ```
