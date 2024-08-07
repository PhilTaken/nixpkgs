{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "visitor";
  version = "0.1.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02j87v93c50gz68gbgclmbqjcwcr7g7zgvk7c6y4x1mnn81pjwrc";
  };

  meta = with lib; {
    homepage = "https://github.com/mbr/visitor";
    description = "Tiny pythonic visitor implementation";
    license = licenses.mit;
    maintainers = [ ];
  };
}
