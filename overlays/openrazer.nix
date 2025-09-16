final: prev: 
let
  src = prev.fetchFromGitHub {
    owner = "openrazer";
    repo = "openrazer";
    rev = "6e2daa75e201f0b67e86e3a195e884b68adb71d9";
    hash = "sha256-8zF8gwF/+2QtQk52t+yP3453Ao3TY6/0xhJKaM5NMqk=";
  };
  v = "git-6e2daa7";
in {
  openrazer-daemon = prev.python3Packages.openrazer-daemon.overrideAttrs (_: {
    inherit src;
    version = v;
  });

  openrazer = prev.openrazer.overrideAttrs (_: {
    inherit src;
    version = v;
  });

  linuxPackages = prev.linuxPackages.extend (lFinal: lPrev: {
    openrazer = lPrev.openrazer.overrideAttrs (_: {
      inherit src;
      version = v;
    });
  });
}