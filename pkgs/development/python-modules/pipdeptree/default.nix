{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  diff-cover,
  graphviz,
  hatchling,
  hatch-vcs,
  packaging,
  pytest-mock,
  pytestCheckHook,
  pip,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "pipdeptree";
  version = "2.28.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "pipdeptree";
    tag = version;
    hash = "sha256-PYlNMAomqN9T60b8bRqb8mnLjFRn3JnI79Tynncxje8=";
  };

  postPatch = ''
    # only set to ensure py3.13 compat
    # https://github.com/tox-dev/pipdeptree/pull/406
    substituteInPlace pyproject.toml \
      --replace-fail '"pip>=24.2"' '"pip"'
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    pip
    packaging
  ];

  optional-dependencies = {
    graphviz = [ graphviz ];
  };

  nativeCheckInputs = [
    diff-cover
    pytest-mock
    pytestCheckHook
    virtualenv
  ]
  ++ lib.flatten (builtins.attrValues optional-dependencies);

  pythonImportsCheck = [ "pipdeptree" ];

  disabledTests = [
    # Don't run console tests
    "test_console"
  ];

  meta = with lib; {
    description = "Command line utility to show dependency tree of packages";
    homepage = "https://github.com/tox-dev/pipdeptree";
    changelog = "https://github.com/tox-dev/pipdeptree/releases/tag/${src.tag}";
    license = licenses.mit;
    maintainers = with maintainers; [
      charlesbaynham
      mdaniels5757
    ];
    mainProgram = "pipdeptree";
  };
}
