{
  stdenv,
  lib,
  fetchFromGitHub,
  autoreconfHook,
  cxxtest,
}:

stdenv.mkDerivation {
  pname = "sta";
  version = "0-unstable-2021-11-30";

  src = fetchFromGitHub {
    owner = "simonccarter";
    repo = "sta";
    rev = "94559e3dfa97d415e3f37b1180b57c17c7222b4f";
    sha256 = "sha256-AiygCfBze7J1Emy6mc27Dim34eLR7VId9wodUZapIL4=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];

  doCheck = true;
  nativeCheckInputs = [ cxxtest ];
  checkInputs = [ cxxtest ];

  checkPhase = ''
    runHook preCheck

    pushd test

    cxxtestgen --error-printer --have-std -o tests.cpp sta_test_1.h sta_test_2.h
    ${stdenv.cc.targetPrefix}c++ -o tester tests.cpp
    ./tester

    popd

    runHook postCheck
  '';

  meta = with lib; {
    description = "Simple statistics from the command line interface (CLI), fast";
    longDescription = ''
      This is a lightweight, fast tool for calculating basic descriptive
      statistics from the command line. Inspired by
      https://github.com/nferraz/st, this project differs in that it is written
      in C++, allowing for faster computation of statistics given larger
      non-trivial data sets.
    '';
    license = licenses.mit;
    homepage = "https://github.com/simonccarter/sta";
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "sta";
  };
}
