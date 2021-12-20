{
  mkDerivation, lib,
  extra-cmake-modules,
  kguiaddons,
  knotifications,
  ki18n,
  kio,
  kdoctools,
  kxmlgui,
  kiconthemes,
  karchive,
  kwidgetsaddons,
  shared-mime-info
}:

mkDerivation {
  pname = "kbackup";
  meta = {
    homepage = "https://apps.kde.org/kbackup/";
    description = "Backup tool";
    license = with lib.licenses; [ gpl2 ];
    maintainers = [ lib.maintainers.pwoelfel ];
  };
  nativeBuildInputs = [
    extra-cmake-modules
    kdoctools
    shared-mime-info
    ];
  buildInputs = [
    kguiaddons
    knotifications
    ki18n
    kio
    kdoctools
    kxmlgui
    kiconthemes
    karchive
    kwidgetsaddons
  ];
}
