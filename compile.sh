#!/usr/bin/bash
rm -r docs
sphinx-build src docs
cd docs
mv _images images
mv _sources sources
mv _static static
find . -name \* -exec sed -i "s/_images/images/g" {} \;
find . -name \* -exec sed -i "s/_sources/sources/g" {} \;
find . -name \* -exec sed -i "s/_static/static/g" {} \;
cd ..
sphinx-build  -b latex  src  build
cd build
make
mv GOMC.pdf ..
