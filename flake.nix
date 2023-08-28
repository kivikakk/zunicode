{
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
    in rec {
      checks.default = pkgs.stdenv.mkDerivation {
        name = "zunicode-build";

        src = ./.;

        nativeBuildInputs = [pkgs.zig];

        buildPhase = ''
          export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig"
          zig build test
          touch $out
        '';
      };

      formatter = pkgs.alejandra;

      devShells.default = checks.default;
    });
}
