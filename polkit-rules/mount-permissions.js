// Allow user jonas to mount/unmount filesystems without authentication
polkit.addRule(function(action, subject) {
  if (subject.user == "jonas") {
    // External drive mounting (USB, SD cards, external drives)
    if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
        action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
        action.id == "org.freedesktop.udisks2.filesystem-unmount") {
      return polkit.Result.YES;
    }
    
    // Allow ejecting and powering off drives
    if (action.id == "org.freedesktop.udisks2.eject-media" ||
        action.id == "org.freedesktop.udisks2.power-off-drive") {
      return polkit.Result.YES;
    }
    
    // Allow unlocking/locking LUKS encrypted devices
    if (action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
        action.id == "org.freedesktop.udisks2.encrypted-lock") {
      return polkit.Result.YES;
    }
    
    // Allow loop device setup (for mounting ISO images, etc.)
    if (action.id == "org.freedesktop.udisks2.loop-setup" ||
        action.id == "org.freedesktop.udisks2.loop-delete") {
      return polkit.Result.YES;
    }
  }
});
