{
  isDevelopmentShell ? true
}:

let
  nixpkgs = import <nixpkgs> {}; # TODO: pin nixpkgs version
  devpkgs = with nixpkgs; [
    elmPackages.elm
    elmPackages.elm-format
    python37
  ];
in nixpkgs.mkShell ({
  name = "aurelius-dev";
  buildInputs = devpkgs;
  shellHook = ''
    echo "marcus" | ${nixpkgs.figlet}/bin/figlet | ${nixpkgs.lolcat}/bin/lolcat
  '';
})
