.PHONY: clean

build: out/main.js

out/main.js:
	mkdir -p out
	elm make --yes src/Main.elm --warn --output out/main.js

clean:
	rm -f out/main.js
