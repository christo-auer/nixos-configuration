{ lib, pkgs, config, ...}: {

  services.rpcbind.enable = true; 
  systemd.mounts = let commonMountOptions = {
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
  };
  in
  [
    (commonMountOptions // {
      what = "10.0.64.2:/storage";
      where = "/mnt/nagi/storage";
    })

    (commonMountOptions // {
      what = "10.0.64.2:/home";
      where = "/mnt/nagi/home";
    })
  ];

  systemd.automounts = let commonAutoMountOptions = {
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
  };

  in

  [
    (commonAutoMountOptions // { where = "/mnt/nagi/storage"; })
    (commonAutoMountOptions // { where = "/mnt/nagi/home"; })
  ];

}
