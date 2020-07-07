.PHONY: clean

build: out/main.js

out/main.js:
	mkdir -p out
	elm make Main.elm --debug --output out/main.js

clean:
	rm -rf out/main.js


shell:
	nix-shell -p elmPackages.elm -p elmPackages.elm-format -p python37

dev:
	make clean && make && python -m http.server
