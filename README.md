# BepInEx Pack for Survival Log

Most mods for the Steam game [Survival Log](https://store.steampowered.com/app/4164790/Survival_Log/) need the mod loader [BepInEx](https://github.com/BepInEx/BepInEx). This pack is the official BepInEx 6 build that works with the game, in one zip that you extract into the game folder. Install it once, then install any mod that lists it as a requirement.

- The files are the official BepInEx build `6.0.0-be.788` (IL2CPP, win-x64), not changed in any way.
- BepInEx is made by the BepInEx team. This pack is not made or endorsed by them.
- This repo holds the recipe, not the binaries: the pinned build with its hash, and the scripts that build and check the zip.

**This is unofficial.** BepInEx and the mods that use it are not made or supported by the developer of Survival Log. The developer's roadmap on the Steam store page lists Steam Workshop support as planned for Q1 2027, so the game may get its own mod system later. Plans can change, so check the roadmap for the current state. If you find a bug in the game, remove your mods and check that the bug still happens before you report it to the developer.

## Install

Close the game. Download `BepInExPack_SurvivalLog-6.0.0-be.788.zip` from [Releases](https://github.com/ivmakk-sl/sl-bepinex-pack/releases).

1. Extract the zip into `C:\Program Files (x86)\Steam\steamapps\common\Survival Log` *(if you installed Steam or the game elsewhere, find the folder in your Steam Library: right-click Survival Log > Manage > Browse local files)*.
2. Start the game from Steam. Wait for the main menu, then quit before installing mods.

Example after extraction (other game files omitted):

```text
C:\Program Files (x86)\Steam\steamapps\common\Survival Log\
├── BepInEx\
├── dotnet\
├── SurvivalLog.exe
├── doorstop_config.ini
└── winhttp.dll
```

## The first start

- The BepInEx console window opens with the game. This is normal. Do not close the console window, because that also closes the game.
- The first start takes longer than normal (about 40 seconds longer on the test PC). BepInEx reads the game and prepares files for mods. Wait for the main menu.
- The first start needs an internet connection. BepInEx downloads a small file (about 2.4 MB) from the BepInEx site.

It works when the first line of the console window says `BepInEx 6.0.0-be.788 - SurvivalLog`, and the `BepInEx` folder holds new `config` and `interop` folders. Mods go into `BepInEx\plugins`.

## Problems

- **No console window opens.** Check the file location. `winhttp.dll` must be in the same folder as `SurvivalLog.exe`.
- **BepInEx is already installed.** If the console shows `6.0.0-be.788`, you do not need this pack. For a different build, follow the [replacement instructions](#replace-an-existing-installation).
- **The antivirus warns about `winhttp.dll`.** This file is how BepInEx starts: the game loads it because of its name, and it then loads BepInEx. Some antivirus programs flag this method. The file is the same as in the official download. To check, download `BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.788+5b766a3.zip` (build #788) from [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be) and compare. The SHA-256 of that official zip is `F4CC496BD098A0DF4164B81E3737297707F13A47C2478DBA2F60EEFAB784817A`, and `verify.ps1` in this repo does the full comparison.
- **Mods stopped after a game update.** A game update can break BepInEx or a mod. Check here and on the pages of your mods for an update. To play in the meantime, uninstall. Saves are not touched.
- **The game does not start at all.** Uninstall, then in Steam use Properties, Installed Files, Verify integrity of game files.

BepInEx bugs that are not about this pack belong to the [BepInEx project](https://github.com/BepInEx/BepInEx/issues).

## Uninstall

Close the game. To keep your mods and settings, copy `BepInEx\plugins` and `BepInEx\config` somewhere outside the game folder.

Delete these files and folders from your Survival Log game folder:

```text
BepInEx/
dotnet/
.doorstop_version
changelog.txt
doorstop_config.ini
winhttp.dll
```

Delete the entire `BepInEx` and `dotnet` folders. Deleting `BepInEx` also removes all installed mods and their settings.

Keep the `Survival Log` folder and all other files. The game then runs without mods. These uninstall steps do not delete your save files.

## Replace an existing installation

Close the game before replacing BepInEx.

1. Copy `BepInEx\plugins` and `BepInEx\config` somewhere outside the game folder.
2. Delete the files and folders listed under [Uninstall](#uninstall).
3. Follow the [installation steps](#install).
4. Copy your saved plugins and configuration files back into their original folders.

## Verify the download

Download the official archive using the [manual installation instructions](#manual-install-advanced). Its SHA-256 is `F4CC496BD098A0DF4164B81E3737297707F13A47C2478DBA2F60EEFAB784817A`. This is the official archive's hash, not the pack zip's hash.

Download this repository and install PowerShell 7. Open PowerShell in the repository folder. Replace the example paths below with the paths to your downloaded files:

```powershell
Get-FileHash -Algorithm SHA256 "C:\Downloads\BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.788+5b766a3.zip"
pwsh ./verify.ps1 "C:\Downloads\BepInExPack_SurvivalLog-6.0.0-be.788.zip" "C:\Downloads\BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.788+5b766a3.zip"
```

Check that the first command reports the hash above. The second command must report `verify: PASSED`. It compares the official file contents and archive entries, checks that the notice exists, and rejects unexpected additions.

## Manual install (advanced)

You do not need this pack to use BepInEx. Open [builds.bepinex.dev/projects/bepinex_be](https://builds.bepinex.dev/projects/bepinex_be), find build #788, download `BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.788+5b766a3.zip` (the `Unity.IL2CPP-win-x64` file, the Mono files do not work with this game), extract it into the game folder, and start the game once.

## Why this build

Survival Log runs on Unity 6000.2 with IL2CPP metadata version 31. The GitHub release `6.0.0-pre.2` does not work with it (see the test record below). Build 788 passed the recorded clean-install test on Survival Log 1.0.16756 (Steam build 25366138).

All official BepInEx builds, this one (#788) and newer ones, are listed at [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be). A newer build is not tested with this game until this pack moves to it.

## For maintainers

Requirements: PowerShell 7 (`pwsh`). Nothing else.

- `pack.json` - the pin: build number, source commit, official archive name, URL, SHA-256.
- `pwsh ./pack.ps1` - downloads the pinned archive into `cache/` when it is absent, checks the SHA-256 (a mismatch fails and makes no zip), copies the archive to `dist/BepInExPack_SurvivalLog-<build>.zip`, and appends `BepInEx/NOTICE-BepInExPack.txt` (credits from `credits.template.txt` and `pack.json`, followed by the full text of `LICENSE`). The official zip is copied and appended to, never extracted and zipped again, so every entry stays as it is, the empty `BepInEx/plugins/` folder included.
- `pwsh ./verify.ps1` - compares the zip in `dist/` with the archive in `cache/`, one named rule each. It also takes `verify.ps1 <pack zip> <official archive>`.
- `pwsh ./tests/run.ps1` - the tests of the two scripts. It builds good and bad zips from the cached archive and expects each bad zip to fail on its rule.

The zip hash changes with each run of `pack.ps1` because of zip timestamps, so the hash in the release notes belongs to that release asset only.

### Update the pin

The pin is the bleeding edge build that the mods are built and tested against. It moves when that build stops working with the game, or when the mods move to a newer build.

1. Pick the build on [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be). Put its number, commit, `Unity.IL2CPP-win-x64` file name, URL, and SHA-256 into `pack.json`.
2. Run `pack.ps1`, `verify.ps1`, and `tests/run.ps1`.
3. Test on a clean install: move the loader entries (the Uninstall list) out of the game folder, extract the new zip, start the game, and read `BepInEx\LogOutput.log` for the build line, "Chainloader startup complete", and no error. Put a known plugin into `BepInEx\plugins` and check its load line. Then restore the old entries or keep the new ones.
4. Update the build values in this README, `nexus/`, and `CHANGELOG.md` with the tested game version, then release with the tag `v<build>`. A repack of the same build gets `-r2`, `-r3`.

If builds.bepinex.dev no longer serves the pinned build, put a copy of the official archive from any source into `cache/` under the name in `pack.json`. `pack.ps1` accepts it only when the SHA-256 matches. The GitHub Release of this repo keeps the built zip.

### Test record

The in-game tests below used the original packaging with separate root-level license and credit files. The packaging revision combines them in `BepInEx/NOTICE-BepInExPack.txt`. Archive verification confirms that all official files are unchanged. The revised packaging passes the script tests, including the notice contents and root-entry checks; the in-game test was not repeated for this text-only change.

- 2026-09-20, game 1.0.16756 (Steam build 25366138), Unity 6000.2.0a1: the pack zip with `6.0.0-be.788` on a clean install. BepInEx loads, the interop generation takes about 35 seconds, the game reaches the main menu, a plugin placed in `BepInEx\plugins` loads, and deleting the Uninstall list leaves exactly the files that the game shipped.
- 2026-09-20, same game version: the GitHub release `6.0.0-pre.2` (`BepInEx-Unity.IL2CPP-win-x64-6.0.0-pre.2.zip`, SHA-256 `616EC7EB06CF11B2A0000E8FCEF04D1B12BB58E84A2E0BDAC9523234FC193CEB`, its log says `6.0.0-be.697`) fails. `LogOutput.log`: "Failed to generate Il2Cpp interop assemblies ... Unsupported metadata version found! We support 23-29, got 31". The game process then exits about 10 seconds after the start.

## Credits and license

BepInEx is the work of the [BepInEx team](https://github.com/BepInEx/BepInEx) and its contributors, licensed under LGPL-2.1. The zip is an unmodified redistribution, and `BepInEx/NOTICE-BepInExPack.txt` in the zip lists the bundled components with their licenses. The BepInEx logo in `nexus/images/` belongs to the BepInEx team.

This repo is licensed under LGPL-2.1, the same license as BepInEx. See `LICENSE`.
