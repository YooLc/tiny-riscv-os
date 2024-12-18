{
  description = "Cross compile environment for RISC-V Linux kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
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
          pkgs.pkgsCross.riscv64.gcc13
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
