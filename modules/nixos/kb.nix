{ config, pkgs, lib, ... }: {

  boot.kernelModules = [ "uninput" ];

  hardware.uinput.enable = true;

  environment.systemPackages = with pkgs; [
	wl-clipboard
  ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  users.groups.uinput = { };

  systemd.services.kanata-internalKeyboard.serviceConfig = {
	SupplementaryGroups = [
	  "input"
	  "uinput"
	];
  };

  services.kanata = {
	enable = true;
	keyboards = {
	  internalKeyboard = {
		devices = [
		  "platform-i8042-serio-0-event-kbd"
		];
		extraDefCfg = "process-unmapped-keys yes";
		config = ''
		  (defsrc
            caps grv
            h    j    k    l
            lsft rsft
		  )
		  (deflayer default
            @cap @grv        
            _    _    _    _
            _    _
		  )
          (deflayer arrows
            _    _ 
            left down up   rght
            _    _
		  )
		  (defalias
            cap (tap-hold-press 200 200 esc (multi lctl lmet lalt))
            grv (tap-hold-press 200 200 grv (layer-toggle arrows))
		  )
		'';
	  };
	};
  };
}
