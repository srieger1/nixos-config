{ config, pkgs, ... }:
let
  mytexlive = pkgs.texliveSmall.withPackages (ps: with ps; [
    scheme-basic
    dvisvgm dvipng # for preview and export as html
    wrapfig amsmath ulem hyperref capt-of # default from example in nixos wiki
    wasy biblatex adjustbox arydshln lstaddons pict2e diagbox wasysym babel babel-german german beamer sttools caption times metafont csquotes float cite amsfonts algorithms algorithmicx graphics listings xcolor enumitem multirow subfig bytefield chngcntr siunitx cleveref
    xurl # for p4 intro acn
    parskip eurosym comment titlesec mathtools xifthen mdframed ifmtarg zref needspace helvetic microtype pgfgantt fontawesome5 # dfg sachbeihilfe, sach par local ai
    subfiles setspace soul
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  ])
in:
  home.packages = [ mytexlive ];
