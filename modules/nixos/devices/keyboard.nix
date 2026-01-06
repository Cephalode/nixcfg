{
  pkgs,
  ...
}:
{
  # Enable the uinput module
  boot.kernelModules = [ "uinput" ];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = { };

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  environment.systemPackages = with pkgs; [ wl-clipboard ];

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.2:1.0-event-kbd" # Main keyboard (event0)
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.3:1.1-event-kbd" # Numpad? (event6)
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
                 1    2
            caps a    s    d    f    j    k    l    ;    ret  \
          )
          (deflayer main
                 _    _
            @hyc @aC  @sA  @dS  @fM  @jM  @kS  @lA  @;C  @hyr @lay
          )
          (deflayer base
                 _    _
            _    _    _    _    _    _    _    _    _    _    _
          )
          (deflayer switch
                 @l1  @l2
            _    _    _    _    _    _    _    _    _    _    _
          )
          (defalias
            hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
            hyr (tap-hold-press 200 200 ret (multi lctl lalt lmet))
            ;C  (tap-hold       200 200 ;   rctl)
            lA  (tap-hold       200 200 l   ralt)
            kS  (tap-hold       200 200 k   rsft)
            jM  (tap-hold       200 200 j   rmet)
            aC  (tap-hold       200 200 a   lctl)
            sA  (tap-hold       200 200 s   lalt)
            dS  (tap-hold       200 200 d   lsft)
            fM  (tap-hold       200 200 f   lmet)

            lay (layer-while-held switch)
            l1  (layer-switch main)
            l2  (layer-switch base)
          )
        '';
      };
    };
  };
}
