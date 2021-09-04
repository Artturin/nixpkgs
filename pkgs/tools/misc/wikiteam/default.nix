{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "wikiteam";
  version = "0.0.1";

  format = "other";

  src = fetchFromGitHub {
    owner = "wikiTeam";
    repo = "wikiteam";
    rev = "ec62f3456beac488c4598415ff244019ab8a9fbc";
    sha256 = "sha256-f9H7801rlfLgdCa0+7fQPVzbXS9kiQjCfmN+sJpPtLM=";
  };

  propagatedBuildInputs = with python3Packages; [
    wikitools3
    configargparse
    kitchen
    requests
    mwclient
    lxml
    urllib3
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp dumpgenerator.py $out/bin
  '';

  #pythonImportsCheck = [ "wikiteam" ];

  meta = with lib; {
    description = "Tools for downloading and preserving wikis. We archive wikis, from Wikipedia to tiniest wikis. As of 2020, WikiTeam has preserved more than 250,000 wikis.";
    homepage = "github.com/WikiTeam/wikiteam";
    license = licenses.gpl3;
    maintainers = with maintainers; [ artturin ];
  };
}
