{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./cli
    ./development
    ./security
    inputs.zen-spaces.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    discord
    discordo
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];

  programs.zen-spaces = {
    enable = true;
    user = "sqibo";
    profileName = "0vkp3u7b.Default Profile";
    spacesForce = true;
    spaces = {
      "Personal" = {
        id = "7a51bd40-5e5b-49d9-b29f-b2ba57b4f1a8";
        position = 1000;
        icon = "🏠";
      };
      "Dev" = {
        id = "538dc38e-ee09-4dc6-bad9-477f7fcb2b3c";
        position = 2000;
        icon = "💻";
      };
      "Work A" = {
        id = "e5169fcc-316c-4202-b722-5a7d7b4d2228";
        position = 3000;
        icon = "💼";
      };
      "Work B" = {
        id = "2d83f9c1-1de4-4029-8f77-4020997ceb44";
        position = 4000;
        icon = "📁";
      };
      "School" = {
        id = "0fe237b8-9337-4353-a107-51b1a465d936";
        position = 5000;
        icon = "🎓";
      };
    };
  };
}
