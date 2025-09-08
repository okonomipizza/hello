{
  lib,
  stdenv,
  zig,
  fetchFromGitHub,
  revision ? "dirty",
  optimize ? "Debug",
}:
let
  zig-deps = fetchFromGitHub {
    owner = "Hejsil";
    repo = "zig-clap";
    rev = "5289e0753cd274d65344bef1c114284c633536ea";
    sha256 = "sha256-XytqwtoE0xaR43YustgK68sAQPVfC0Dt+uCs8UTfkbU="; # 偽のハッシュ
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    zig
  ];

  configurePhase = ''
    runHook preConfigure
    
    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
    mkdir -p $ZIG_GLOBAL_CACHE_DIR
    
    # 元のbuild.zig.zonをバックアップ
    cp build.zig.zon build.zig.zon.backup
    
    # 依存関係をローカルディレクトリにコピー
    mkdir -p ./deps/clap
    cp -r ${zig-deps}/* ./deps/clap/
    chmod -R +w ./deps/clap
    
    # build.zig.zonを一時的に修正（相対パスを使用）
    cat > build.zig.zon << 'EOF'
.{
    .name = .hello,
    .version = "0.0.0",
    .fingerprint = 0x3610a6862caccc13,
    .minimum_zig_version = "0.15.1",
    .dependencies = .{
        .clap = .{
            .path = "./deps/clap",
        },
    },
    .paths = .{
        "build.zig",
        "build.zig.zon", 
        "src",
    },
}
EOF
    
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    zig build --prefix $out -Doptimize=${optimize} --verbose
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
