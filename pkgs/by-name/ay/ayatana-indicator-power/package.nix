{
  stdenv,
  lib,
  gitUpdater,
  fetchFromGitHub,
  nixosTests,
  cmake,
  dbus,
  dbus-test-runner,
  glib,
  gtest,
  intltool,
  libayatana-common,
  libnotify,
  librda,
  lomiri,
  pkg-config,
  python3,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ayatana-indicator-power";
  version = "24.5.2";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = "ayatana-indicator-power";
    tag = finalAttrs.version;
    hash = "sha256-A9Kbs+qH01rkuLt8GINdPI2vCu0bCO+/g4kZhDj8GsY=";
  };

  postPatch = ''
    # Replace systemd prefix in pkg-config query, use GNUInstallDirs location for /etc
    substituteInPlace data/CMakeLists.txt \
      --replace-fail 'pkg_get_variable(SYSTEMD_USER_DIR systemd systemduserunitdir)' 'pkg_get_variable(SYSTEMD_USER_DIR systemd systemduserunitdir DEFINE_VARIABLES prefix=''${CMAKE_INSTALL_PREFIX})' \
      --replace-fail 'XDG_AUTOSTART_DIR "/etc' 'XDG_AUTOSTART_DIR "''${CMAKE_INSTALL_FULL_SYSCONFDIR}'

    # Path needed for build-time codegen
    substituteInPlace src/CMakeLists.txt \
      --replace-fail '/usr/share/accountsservice/interfaces/com.lomiri.touch.AccountsService.Sound.xml' '${lomiri.lomiri-schemas}/share/accountsservice/interfaces/com.lomiri.touch.AccountsService.Sound.xml'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    intltool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    libayatana-common
    libnotify
    librda
    systemd
  ]
  ++ (with lomiri; [
    cmake-extras
    deviceinfo
    lomiri-schemas
    lomiri-sounds
  ]);

  nativeCheckInputs = [
    dbus
    (python3.withPackages (ps: with ps; [ python-dbusmock ]))
  ];

  checkInputs = [
    dbus-test-runner
    gtest
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "ENABLE_LOMIRI_FEATURES" true)
    (lib.cmakeBool "ENABLE_DEVICEINFO" true)
    (lib.cmakeBool "ENABLE_RDA" true)
    (lib.cmakeBool "GSETTINGS_LOCALINSTALL" true)
    (lib.cmakeBool "GSETTINGS_COMPILE" true)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  passthru = {
    ayatana-indicators = {
      ayatana-indicator-power = [
        "ayatana"
        "lomiri"
      ];
    };
    tests = {
      startup = nixosTests.ayatana-indicators;
      lomiri = nixosTests.lomiri.desktop-ayatana-indicator-power;
    };
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Ayatana Indicator showing power state";
    longDescription = ''
      This Ayatana Indicator displays current power management information and
      gives the user a way to access power management preferences.
    '';
    homepage = "https://github.com/AyatanaIndicators/ayatana-indicator-power";
    changelog = "https://github.com/AyatanaIndicators/ayatana-indicator-power/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.linux;
  };
})
