{ pkgs, ... }:
{
  security.rtkit.enable = true;   # ← ADD THIS

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };


  extraConfig.pipewire = {
    "10-resolve-fix" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 48000 44100 ];
      };
    };
};

    };
  };

  hardware.alsa.enablePersistence = true;
  environment.systemPackages = with pkgs; [ alsa-utils ];
}
