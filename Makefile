.PHONY: elm.js page

bundle.js: Main.elm StyledHtml.elm src/main.js
	npm install
	npm run install
	npm run build
	npm run bundle

publish: index.html bundle.js
	rm -rf out
	mkdir out
	cd out; make -f ../Makefile page

page:
	cp -r ../index.html ../bundle.js ../src ./
	git init
	git config user.name "CircleCI"
	git config user.email "2sm@csc.jp"
	git add .
	git commit -m "Deploy to GitHub pages"
	git push -v --force --quiet "git@github.com:tshm/pkmap.git" master:gh-pages > /dev/null 2>&1

