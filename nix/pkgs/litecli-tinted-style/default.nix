{ python3Packages }:
python3Packages.buildPythonPackage {
  pname = "litecli-tinted-style";
  version = "1.0";
  format = "setuptools";
  src = ../../../assets/litecli;
  propagatedBuildInputs = [ python3Packages.pygments ];
}
