{
  description = "Sudoku solver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        stdenv = pkgs.stdenv;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.odin.overrideAttrs (finalAttr: prevAttr: {
                postPatch = prevAttr.postPatch + pkgs.lib.optionalString (stdenv.hostPlatform.system == "aarch64-darwin") ''
                  substituteInPlace src/build_settings.cpp \
                    --replace-fail "arm64-apple-macosx" "arm64-apple-darwin"
                '';
            }))
          ];
        };
      }
    );
}
