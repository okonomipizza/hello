{
  lib,
  stdenv,
  zig,
  revision ? "dirty",
  optimize ? "Debug",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    zig
  ];

  configurePhase = ''
    runHook preConfigure
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    zig build --prefix $out -Doptimize=${optimize}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    # zig build with --prefix should handle installation
    runHook postInstall
  '';

  meta = {
    description = "A JSON with Comments formatter written in Zig";
    homepage = "https://github.com/example/jsonc-fmt";  # 実際のURLに変更してください
    license = lib.licenses.mit;  # 実際のライセンスに変更してください
    platforms = lib.platforms.unix;
    mainProgram = "hello";
  };
})
