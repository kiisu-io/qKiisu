{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, zlib
, libusb1
, libGL
, qmake
, wrapQtAppsHook
, mkDerivation

, qttools
, qtbase
, qt3d
, qtsvg
, qtserialport
, qtdeclarative
, qtquickcontrols
, qtquickcontrols2
, qtgraphicaleffects
, qtwayland
}:
let
  version = "0.8.2";
  timestamp = "99999999999";
  commit = "nix-${version}";
  udev_rules = ''
    #Kiisu serial port
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", ATTRS{manufacturer}=="RainWalker OÜ", TAG+="uaccess"
    #Kiisu DFU
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", ATTRS{manufacturer}=="STMicroelectronics", TAG+="uaccess"
  '';
in
mkDerivation {
  name = "qKiisu";
  inherit version;

  src = ../..;

  nativeBuildInputs = [
    pkg-config
    qmake
    qttools
  ];

  buildInputs = [
    zlib
    libusb1
    libGL
    wrapQtAppsHook

    qtbase
    qt3d
    qtsvg
    qtserialport
    qtdeclarative
    qtquickcontrols
    qtquickcontrols2
    qtgraphicaleffects
  ] ++ lib.optionals (stdenv.isLinux) [
    qtwayland
  ];

  qmakeFlags = [
    "DEFINES+=DISABLE_APPLICATION_UPDATES"
  ];

  preBuild = ''
    substituteInPlace qkiisu_common.pri \
        --replace 'GIT_VERSION = unknown' 'GIT_VERSION = "${version}"' \
        --replace 'GIT_TIMESTAMP = 0' 'GIT_TIMESTAMP = ${timestamp}' \
        --replace 'GIT_COMMIT = unknown' 'GIT_COMMIT = "${commit}"'
  '';

  installPhase = ''
    mkdir -p $out/bin
  '' + (
    if stdenv.isLinux then ''
      cp qKiisu $out/bin
    '' else ''
      cp qKiisu.app/Contents/MacOS/qKiisu $out/bin
    ''
  ) + ''
    cp qKiisuTool $out/bin

    mkdir -p $out/share/applications
    cp installer-assets/appimage/qKiisu.desktop $out/share/applications

    mkdir -p $out/share/icons
    cp application/assets/icons/qKiisu.png $out/share/icons

    mkdir -p $out/etc/udev/rules.d
    tee $out/etc/udev/rules.d/42-kiisu.rules << EOF
    ${udev_rules}
    EOF

  '';

  meta = with lib; {
    description = "Cross-platform desktop tool to manage your Kiisu device";
    homepage = "https://kiisu.io/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ cab404 ];
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" ]; # qtbase doesn't build yet on aarch64-darwin
  };

}
