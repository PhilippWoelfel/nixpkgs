{ fetchFromGitHub }:
rec {
  pname = "authelia";
  version = "4.38.7";

  src = fetchFromGitHub {
    owner = "authelia";
    repo = "authelia";
    rev = "v${version}";
    hash = "sha256-VbAF2uIFL1jN469KGpnkm5erwryLoatZukZgiea+RQA=";
  };
  vendorHash = "sha256-gyBCpNH85LwPLpENZPMuk98YoFsNWbudsw59W35cUKY=";
  npmDepsHash = "sha256-UfkvjkmjXM8SzpSvHY7fkGP3qCRUDgF8WJUAlS2c1WM=";
}
