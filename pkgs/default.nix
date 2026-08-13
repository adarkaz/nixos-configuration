{
  inputs,
  pkgs,
  ...
}:
{
  maple-mono-custom = pkgs.callPackage ./maple-mono { inherit inputs; };
  manhattan-cafe-cursor = pkgs.callPackage ./manhattan-cafe-cursor { }; 
}
