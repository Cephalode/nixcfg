{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "notesmd-cli";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "Yakitrak";
    repo = "notesmd-cli";
    rev = "v${version}";
    hash = "sha256-TubUNSpLvv3Q8dixeCf7otG6CSlb8haIGqkMFXAsqYI=";
  };

  vendorHash = null; # deps are vendored in the repo

  meta = with lib; {
    description = "Obsidian CLI — interact with Obsidian in the terminal";
    homepage = "https://github.com/Yakitrak/notesmd-cli";
    license = licenses.mit;
    mainProgram = "obsidian";
  };
}
