{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, requests
, beautifulsoup4
, colorama
, poetry-core
}:

buildPythonPackage rec {
  pname = "hydra-check";
  version = "1.3.1";
  disabled = pythonOlder "3.10";

  format = "pyproject";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-na2mWkJQWrBGeOF0q77Wzlx/IO22wI3eWChHdTRS2uQ=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [
    requests
    beautifulsoup4
    colorama
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    (
      unset PATH
      unset PYTHONPATH
      $out/bin/hydra-check --help > /dev/null
    )
    runHook postInstallCheck
  '';


  meta = with lib; {
    description = "check hydra for the build status of a package";
    homepage = "https://github.com/nix-community/hydra-check";
    license = licenses.mit;
    maintainers = with maintainers; [ makefu artturin ];
  };
}
