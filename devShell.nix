{
    mkShell,
    zig,
    system,
    pkgs,
}: let

  in
    mkShell {
      name = "hello";
      packages =
        [
          zig
        ];
    }
