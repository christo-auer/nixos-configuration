{ config, lib, pkgs, ... }: {

  fileSystems."/mnt/btrfs-root" = {
    device = "/dev/disk/by-uuid/b0d35c1a-b107-4995-957b-2ee4c419c6d3";
    fsType = "btrfs";
    options = [ "subvolid=5" "noatime" ];
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "btrfs";
    options = [ "noauto" "noatime" ];
  };

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-label/Storage";
    fsType = "vfat";
    options = [ "noauto" "noatime" ];
  };

  services.btrbk.instances.home = {
    snapshotOnly = true;
    onCalendar = "hourly";

    settings = {
      snapshot_dir = "btrbk_snapshots";
      snapshot_preserve_min = "24h";
      snapshot_preserve = "48h";

      volume."/mnt/btrfs-root" = {
        subvolume."@home" = {};
        target = "/mnt/backup/home";
      };

    };
  };

  services.btrbk.instances.storage = {
    snapshotOnly = true;
    onCalendar = "hourly";

    settings = {
      snapshot_dir = "btrbk_snapshots";
      snapshot_preserve_min = "24h";
      snapshot_preserve = "48h";

      volume."/mnt/backup" = {
        subvolume = {
          "@backup_Storage" = {};
        };
        target = "/mnt/backup/storage";
      };

    };
  };
}
