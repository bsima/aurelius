.PHONY: clean

out/main.js:
	mkdir -p out
	elm make src/Main.elm --warn --output out/main.js

clean:
	rm -rf out
