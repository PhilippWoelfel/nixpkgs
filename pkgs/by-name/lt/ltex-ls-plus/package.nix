{ lib
, stdenvNoCC
, fetchurl
# , fetchFromGitHub
, makeBinaryWrapper
, jre_headless
}:

stdenvNoCC.mkDerivation rec {
  pname = "ltex-ls-plus";
  version = "18.0.0";

  src = fetchurl {
    url = "https://github.com/ltex-plus/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-x3kaxMclxUXHLKm09H+HWHAwfRk5dCYwO1wJijnC6sc=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -rfv bin/ lib/ $out
    rm -fv $out/bin/.lsp-cli.json $out/bin/*.bat
    for file in $out/bin/{ltex-ls,ltex-cli}; do
      wrapProgram "$file"-plus --set JAVA_HOME "${jre_headless}"
      ln -s "$file"-plus "$file"
    done

    runHook postInstall
  '';

  # meta = with lib; {
  #   homepage = "https://valentjn.github.io/ltex/";
  #   description = "LSP language server for LanguageTool";
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ vinnymeller ];
  #   platforms = jre_headless.meta.platforms;
  # };
}
