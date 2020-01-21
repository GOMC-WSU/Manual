rm -r docs
sphinx-build src docs
cd docs
mv _images images
mv _sources sources
mv _static static
grep -rli '_images' * | xargs -n 1 sed -i '' -e "s/_images/images/g"
grep -rli '_sources' * | xargs -n 1 sed -i '' -e "s/_sources/sources/g"
grep -rli '_static' * | xargs -n 1 sed -i '' -e "s/_static/static/g"