rm -r docs
sphinx-build src docs
cd docs
mv images images
mv sources sources
mv static static
grep -rli 'images' * | xargs -n 1 sed -i '' -e "s/images/images/g"
grep -rli 'sources' * | xargs -n 1 sed -i '' -e "s/sources/sources/g"
grep -rli 'static' * | xargs -n 1 sed -i '' -e "s/static/static/g"
