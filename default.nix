{ stdenv
, unicode-version ? "13.0.0"
, fetchurl
, fzf ? null
, bash
, python3
}:

let symbols_file =
  stdenv.mkDerivation rec {
    pname = "ucd-${unicode-version}-symbols";
    version = unicode-version;

    Blocks_txt = fetchurl {
      url = "https://unicode.org/Public/${unicode-version}/ucd/Blocks.txt";
      sha256 = "17y1sr17jvjpgvmv15dc9kfazabkrpga3mw8yl99q6ngkxm2pa41"; };

    phases = "installPhase";
    installPhase = ''
      source $stdenv/setup

      substitute ${./generate-symbols.py} ./generate-symbols.py \
        --subst-var "Blocks_txt"

      ${python3}/bin/python3 ./generate-symbols.py > symbols

      sed < symbols > $out 's/[Ll][Aa][Mm][Dd][Aa]/& lambda/'
    '';
  };
in stdenv.mkDerivation {
  pname = "unipicker-ucd-${unicode-version}";
  version = "unstable-2018-07-10";

  phases = "installPhase";

  inherit symbols_file fzf bash;

  installPhase = ''
    source $stdenv/setup

    mkdir -p $out/bin

    substitute ${./unipicker} $out/bin/unipicker \
      --subst-var 'bash' \
      --subst-var 'symbols_file' \
      --subst-var 'fzf' \

    chmod +x $out/bin/unipicker
  '';
}
