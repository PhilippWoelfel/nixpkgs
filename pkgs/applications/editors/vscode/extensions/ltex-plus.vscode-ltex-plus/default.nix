{
  # alejandra,
  # jq,
  lib
, # moreutils,
  fetchurl
, vscode-utils
,
}:
let
  version = "14.0.2";
  publisher = "ltex-plus";
  extName = "vscode-ltex-plus";
in
vscode-utils.buildVscodeExtension rec {
  name = "${publisher}-${extName}-offline-${version}";
  vscodeExtPublisher = publisher;
  vscodeExtName = extName;
  vscodeExtUniqueId = "${publisher}.${extName}";
  src = fetchurl {
    url = "https://github.com/${publisher}/${extName}/releases/download/${version}/${extName}-${version}-offline-linux-x64.vsix";
    sha256 = "sha256-lW1TfTdrshCmhjcvduISY9qAdKPM/0cobxbIrCq5JkQ=";
  };
  # mktplcRef = {
  #   name = "alejandra";
  #   publisher = "kamadorueda";
  #   version = "1.0.0";
  #   hash = "sha256-COlEjKhm8tK5XfOjrpVUDQ7x3JaOLiYoZ4MdwTL8ktk=";
  # };
  # nativeBuildInputs = [
  #   jq
  #   moreutils
  # ];
  # postInstall = ''
  #   cd "$out/$installPrefix"

  #   jq -e '
  #     .contributes.configuration.properties."alejandra.program".default =
  #       "${alejandra}/bin/alejandra" |
  #     .contributes.configurationDefaults."alejandra.program" =
  #       "${alejandra}/bin/alejandra"
  #   ' \
  #   < package.json \
  #   | sponge package.json
  # '';
  # meta = {
  #   description = "Uncompromising Nix Code Formatter";
  #   homepage = "https://github.com/kamadorueda/alejandra";
  #   license = lib.licenses.unlicense;
  #   maintainers = [ lib.maintainers.kamadorueda ];
  # };
}
