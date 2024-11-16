{
  description = "Cross compile environment for RISC-V Linux kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      overlays = [
        (final: prev:
          {
            gcc_latest = final.gcc14;
            gcc14 = prev.wrapCC ((prev.gcc13.cc.override (self: {
              stdenv =
                if self.stdenv.buildPlatform == self.stdenv.hostPlatform
                then self.stdenv
                else prev.overrideCC self.stdenv final.buildPackages.gcc14;
            })).overrideAttrs (oldAttrs:
              let snapshot = "20241026"; in
              rec {
                name = "gcc-${version}";
                version = "14.0.0-dev.${snapshot}";
                passthru = oldAttrs.passthru // { inherit version; };
                src = prev.stdenv.fetchurlBoot {
                  url = "https://gcc.gnu.org/pub/gcc/snapshots/LATEST-14/gcc-14-${snapshot}.tar.xz";
                  hash = "sha256-7tIJJkdrDHDUjTsXXGiVvwVH3IvVrZMP3PiuBRN0HE8=";
                };
                nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.buildPackages.flex ];
                patches = prev.lib.filter
                  (patch: !prev.lib.hasSuffix "ICE-PR110280.patch" (builtins.baseNameOf patch))
                  oldAttrs.patches;
              }));
            gcc14Stdenv = prev.overrideCC final.gccStdenv final.gcc14;
          })
      ];

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = overlays; # Add the overlays here
      };
    in
    {
      devShell.x86_64-linux = pkgs.pkgsCross.riscv64.mkShell {
        nativeBuildInputs = with pkgs; [
          flex
          bison
          bc
          ncurses
          ncurses.dev
          pkgsCross.riscv64.riscv-pk
          spike
          openocd
          pkgs.pkgsCross.riscv64.gcc14 # This will now refer to the overridden version
        ];

        shellHook = ''
          export CROSS_COMPILE=riscv64-unknown-linux-gnu-
          export ARCH=riscv
          export C_INCLUDE_PATH="${pkgs.ncurses.dev}/include":$C_INCLUDE_PATH
          export LIBRARY_PATH="${pkgs.ncurses}/lib":$LIBRARY_PATH
        '';
      };
    };
}
