hexo generate
cp -R public/* .deploy/romantiskt.github.io
cd .deploy/romantiskt.github.io
git add .
git commit -m “update”
git push origin master