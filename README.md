# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx (it is included in anaconda) You can install it through pip:
   ```bash
   $ pip install -U Sphinx
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
   
4. To build PDF first execute the following command in your terminal:
   ```bash
    $ sphinx-build  -b latex  src  build
   ```
   Then add `\DeclareUnicodeCharacter{2212}{-}` before `\begin{document}` in `build/GOMC.tex` file:
   Then run:
   ```bash
    $ cd build
    $ make
   ```
