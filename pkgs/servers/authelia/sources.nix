{ fetchFromGitHub }:
rec {
  pname = "authelia";
  version = "4.38.8";

  src = fetchFromGitHub {
    owner = "authelia";
    repo = "authelia";
    rev = "v${version}";
    hash = "sha256-wuGA3nxzMhpaJKPQeMgVv27zmLyUL5o3MVY+BM6SbAI=";
  };
  vendorHash = "sha256-k+VzAxV9ctvOMxAM6j9qFNOMERxm5Rgcni18dhh3Rfs=";
  npmDepsHash = "sha256-V8C1K7V7rerzogCXscePsIY01JOac5E+j3VM78qtRtI=";
}
