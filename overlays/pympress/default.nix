    (final: prev: {
      pympress = prev.pympress.overrideAttrs (prevPkg: {
        version = "1.8.5+e5da914";
        src = prev.fetchFromGitHub {
          owner = "Cimbali";
          repo = "pympress";
          rev = "e5da914ecb2f5beb6298225cde510e5ff07d02bc";
          sha256 = "sha256-9n/xfKwN85zqP/5wGjkRbjYo4q40yJE1ABmi40Fz9dk=";
        };
        buildInputs = prevPkg.buildInputs ++ [prev.python3Packages.babel];
      });
    })
