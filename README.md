# How to build the manual
1. Install anaconda 3 or python 3.
2. Install sphinx, the template (it is included in anaconda), and latex writer.
   You can install it through pip and apt-get:
   ```bash
   $ sudo apt-get install Sphinx
   $ pip install sphinx_materialdesign_theme
   $ sudo apt-get install latexmk
   ```

3. To build the HTML files and PDF Manual execute the following command in your terminal: 
   ```bash
   $ bash ./compile.sh  
   ```
