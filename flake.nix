{
  inputs = {
    zig = {
      url = github:mitchellh/zig-overlay;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zig,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
    in rec {
      checks.default = pkgs.stdenv.mkDerivation {
        name = "zunicode-build";

        src = ./.;

        nativeBuildInputs = [zig.packages.${system}."0.12.0"];

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
