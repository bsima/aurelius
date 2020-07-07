.PHONY: clean

build: out/main.js

out/main.js:
	mkdir -p out
	elm make Main.elm --debug --output out/main.js

clean:
	rm -rf out/main.js


dev:
	make clean && make && python -m http.server
