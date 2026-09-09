{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    amberol # music player
    audacity
    gimp
    media-downloader
    obs-studio
    pavucontrol
    soundwireserver
    video-trimmer
    vlc

    ## Office
    libreoffice

    ## spell checking for libreoffice
    hunspell
    hunspellDicts.ru-ru

    gnome-calculator
    gnome-control-center
    gnome-calendar

    ## Utility
    dconf-editor
    gnome-disk-utility
    popsicle
    mission-center # GUI resources monitor
    zenity
  ];
}
