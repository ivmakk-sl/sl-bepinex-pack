# BepInEx Pack for Survival Log

Most mods for the Steam game [Survival Log](https://store.steampowered.com/app/4164790/Survival_Log/) need the mod loader [BepInEx](https://github.com/BepInEx/BepInEx). This pack is the official BepInEx 6 build that works with the game, in one zip that you extract into the game folder. Install it once, then install any mod that lists it as a requirement.

- The files are the official BepInEx build `6.0.0-be.788` (IL2CPP, win-x64), not changed in any way.
- BepInEx is made by the BepInEx team. This pack is not made or endorsed by them.
- This repo holds the recipe, not the binaries: the pinned build with its hash, and the scripts that build and check the zip.

**This is unofficial.** BepInEx and the mods that use it are not made or supported by the developer of Survival Log. The developer's roadmap on the Steam store page lists Steam Workshop support as planned for Q1 2027, so the game may get its own mod system later. Plans can change, so check the roadmap for the current state. If you find a bug in the game, remove your mods and check that the bug still happens before you report it to the developer.

## Install

Close the game. Download `BepInExPack_SurvivalLog-6.0.0-be.788.zip` from [Releases](https://github.com/ivmakk-sl/sl-bepinex-pack/releases) or from [Nexus Mods](https://www.nexusmods.com/survivallog/mods/12). The two files are the same.

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
- The first start needs an internet connection. BepInEx downloads a small file (about 2.4 MB) from the BepInEx site. If the site does not open where you live, see [The Unity libraries file](#the-unity-libraries-file-optional).

It works when the first line of the console window says `BepInEx 6.0.0-be.788 - SurvivalLog`, and the `BepInEx` folder holds new `config` and `interop` folders. Mods go into `BepInEx\plugins`.

## Problems

- **No console window opens.** Check the file location. `winhttp.dll` must be in the same folder as `SurvivalLog.exe`.
- **The first start stays at `Downloading unity base libraries`, or the console shows `End of Central Directory record could not be found`.** The game could not download the Unity libraries from the BepInEx site, and no mod loads. Starting the game again does not fix it: BepInEx keeps the broken download and tries it again at each start. Close the game and follow [The Unity libraries file](#the-unity-libraries-file-optional).
- **BepInEx is already installed.** If the console shows `6.0.0-be.788`, you do not need this pack. For a different build, follow the [replacement instructions](#replace-an-existing-installation).
- **The antivirus warns about `winhttp.dll`.** This file is how BepInEx starts: the game loads it because of its name, and it then loads BepInEx. Some antivirus programs flag this method. The file is the same as in the official download. To check, download `BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.788+5b766a3.zip` (build #788) from [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be) and compare. The SHA-256 of that official zip is `F4CC496BD098A0DF4164B81E3737297707F13A47C2478DBA2F60EEFAB784817A`, and `verify.ps1` in this repo does the full comparison.
- **Mods stopped after a game update.** A game update can break BepInEx or a mod. Check here and on the pages of your mods for an update. To play in the meantime, uninstall. Saves are not touched.
- **The game does not start at all.** Uninstall, then in Steam use Properties, Installed Files, Verify integrity of game files.

BepInEx bugs that are not about this pack belong to the [BepInEx project](https://github.com/BepInEx/BepInEx/issues).

## The Unity libraries file (optional)

On the first start, BepInEx downloads the Unity libraries of the game, `6000.2.7.zip` (about 2.5 MB), from `unity.bepinex.dev`. If that site is blocked or very slow where you live, get the same file from another place. You need this only when the first start fails at that download.

1. Close the game.
2. Download `6000.2.7.zip` from one of these places:
   - the optional files in the [Files tab of the Nexus page](https://www.nexusmods.com/survivallog/mods/12?tab=files)
   - the BepInEx site: `https://unity.bepinex.dev/libraries/6000.2.7.zip`
   - the mirror on GitHub, an asset of the latest release of this pack: `https://github.com/ivmakk-sl/sl-bepinex-pack/releases/latest/download/6000.2.7.zip`. GitHub shows its SHA-256 on the release page.
3. If the downloaded file has another name (Nexus can add numbers to it), rename it to exactly `6000.2.7.zip`.
4. Do not extract it. Put the zip itself into `BepInEx\unity-libs\` in the game folder (create the folder if it is missing). When asked, replace the existing file. With the default Steam folder, the result is `C:\Program Files (x86)\Steam\steamapps\common\Survival Log\BepInEx\unity-libs\6000.2.7.zip`.
5. Start the game. BepInEx now uses the file and downloads nothing.

The file belongs to one Unity version of the game. When a game update moves the game to a new Unity version, BepInEx looks for a new file name and downloads again, and the Nexus page and the latest release get the new file.

The zip holds the Unity engine libraries (`UnityEngine.*.dll`) of Unity Technologies, unchanged. Each place serves byte for byte the file that BepInEx downloads from `unity.bepinex.dev`, with the SHA-256 `21DA939863D73D8530985A5573FF171821B045D9D1094B04547CC2CC4B9EDFCF`. Neither the pack author nor the BepInEx team made these files.

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

Survival Log runs on Unity 6000.2 with IL2CPP metadata version 31. The GitHub release `6.0.0-pre.2` does not work with it (see the test record below). Build 788 passed the recorded clean-install test on Survival Log 1.0.16756 (Steam build 25366138) and on Survival Log 1.1.18902 (Steam build 25984240).

All official BepInEx builds, this one (#788) and newer ones, are listed at [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be). A newer build is not tested with this game until this pack moves to it.

## For maintainers

Requirements: PowerShell 7 (`pwsh`). Nothing else.

- `pack.json` - the pin: build number, source commit, official archive name, URL, SHA-256. Its `unityLibs` object pins the Unity libraries zip of the optional file: the Unity version in the short form of BepInEx (`6000.2.7`), the URL, and the SHA-256.
- `pwsh ./pack.ps1` - downloads the pinned archive into `cache/` and the Unity libraries zip into `cache/unity-libs/` when they are absent, and checks both SHA-256 values before it writes anything (a mismatch fails and makes no zip). It copies the archive to `dist/BepInExPack_SurvivalLog-<build>.zip` and appends `BepInEx/NOTICE-BepInExPack.txt` (credits from `credits.template.txt` and `pack.json`, followed by the full text of `LICENSE`). The official zip is copied and appended to, never extracted and zipped again, so every entry stays as it is, the empty `BepInEx/plugins/` folder included. It then copies the checked Unity libraries zip to `dist/<Unity version>.zip`, the optional file for Nexus and the mirror for GitHub. That file is the raw zip of the site, not wrapped in another zip: Nexus quarantines an archive inside an archive.
- `pwsh ./verify.ps1` - compares the zip in `dist/` with the archive in `cache/`, one named rule each. It also takes `verify.ps1 <pack zip> <official archive>`.
- `pwsh ./tests/run.ps1` - the tests of the two scripts. It builds good and bad zips from the cached archive and expects each bad zip to fail on its rule, and checks the hash of the Unity libraries zip that `pack.ps1` writes.

The zip hash changes with each run of `pack.ps1` because of zip timestamps, so the hash in the release notes belongs to that release asset only.

### Update the pin

The pin is the bleeding edge build that the mods are built and tested against. It moves when that build stops working with the game, or when the mods move to a newer build.

1. Pick the build on [builds.bepinex.dev](https://builds.bepinex.dev/projects/bepinex_be). Put its number, commit, `Unity.IL2CPP-win-x64` file name, URL, and SHA-256 into `pack.json`.
2. Run `pack.ps1`, `verify.ps1`, and `tests/run.ps1`.
3. Test on a clean install: move the loader entries (the Uninstall list) out of the game folder, extract the new zip, start the game, and read `BepInEx\LogOutput.log` for the build line, "Chainloader startup complete", and no error. Put a known plugin into `BepInEx\plugins` and check its load line. Then restore the old entries or keep the new ones.
4. Update the build values in this README, `nexus/`, and `CHANGELOG.md` with the tested game version, then release with the tag `v<build>`. Attach the pack zip and the current `cache/unity-libs/<Unity version>.zip`, so the mirror link `releases/latest/download/<Unity version>.zip` keeps working. A repack of the same build gets `.2`, `.3` (for example `6.0.0-be.788.2`, which semver sorts between `be.788` and the next build).

### A new Unity version of the game

The optional file belongs to one Unity version. The Unity version of the game is the ProductVersion of `UnityPlayer.dll` without its suffix (`6000.2.7f2` is `6000.2.7`), and BepInEx logs the URL with that version in its `Downloading unity base libraries` line.

1. Put the new version, its URL `https://unity.bepinex.dev/libraries/<version>.zip`, and the SHA-256 of the downloaded file into `unityLibs` of `pack.json`.
2. Run `pack.ps1`, `verify.ps1`, and `tests/run.ps1`.
3. Test the optional file on a clean install: a broken `BepInEx\unity-libs\<version>.zip` and `UnityBaseLibrariesSource = http://127.0.0.1:9/libraries/{VERSION}.zip` in `BepInEx\config\BepInEx.cfg` give the error of a failed download; then copy `dist/<version>.zip` over it and start again, with no `Downloading unity base libraries` line, no interop error, and the title screen.
4. Update the version and the hash in this README and in `nexus/`. On Nexus, upload `dist/<version>.zip` as the new optional file and remove the old one. On GitHub, upload the same file to the latest release: `gh release upload <tag> dist/<version>.zip`, and check that its digest equals `unityLibs.sha256`.

If builds.bepinex.dev no longer serves the pinned build, put a copy of the official archive from any source into `cache/` under the name in `pack.json`. `pack.ps1` accepts it only when the SHA-256 matches. The GitHub Release of this repo keeps the built zip.

### Test record

The in-game tests below used the original packaging with separate root-level license and credit files. The packaging revision combines them in `BepInEx/NOTICE-BepInExPack.txt`. Archive verification confirms that all official files are unchanged. The revised packaging passes the script tests, including the notice contents and root-entry checks; the in-game test was not repeated for this text-only change.

- 2026-10-17, game 1.1.18902 (Steam build 25984240), Unity 6000.2.7f2: the pack zip with `6.0.0-be.788` on a clean install, with the default config and internet. BepInEx downloads `6000.2.7.zip`, `Chainloader startup complete` comes about 40 seconds after the start, the game reaches the main menu, a plugin placed in `BepInEx\plugins` loads, and deleting the Uninstall list leaves exactly the files that the game shipped. The start of the unmodded game after the delete was not repeated.
- 2026-10-17, same game version: the failed download of a player report. With a broken `BepInEx\unity-libs\6000.2.7.zip` and an unreachable `UnityBaseLibrariesSource`, each start logs "Failed to generate Il2Cpp interop assemblies: System.IO.InvalidDataException: End of Central Directory record could not be found" and "Unable to execute IL2CPP chainloader, no plugins will be loaded", with no new download. After the pinned `6000.2.7.zip` replaced it (the test put it in place with the extract of a zip that wrapped it, which Nexus later quarantined; the file that BepInEx reads is the same), the next start makes no download, generates the interop assemblies with no error, loads the plugins, and reaches the main menu about 70 seconds after the start.
- 2026-09-20, game 1.0.16756 (Steam build 25366138), Unity 6000.2.0a1: the pack zip with `6.0.0-be.788` on a clean install. BepInEx loads, the interop generation takes about 35 seconds, the game reaches the main menu, a plugin placed in `BepInEx\plugins` loads, and deleting the Uninstall list leaves exactly the files that the game shipped.
- 2026-09-20, same game version: the GitHub release `6.0.0-pre.2` (`BepInEx-Unity.IL2CPP-win-x64-6.0.0-pre.2.zip`, SHA-256 `616EC7EB06CF11B2A0000E8FCEF04D1B12BB58E84A2E0BDAC9523234FC193CEB`, its log says `6.0.0-be.697`) fails. `LogOutput.log`: "Failed to generate Il2Cpp interop assemblies ... Unsupported metadata version found! We support 23-29, got 31". The game process then exits about 10 seconds after the start.

## Credits and license

BepInEx is the work of the [BepInEx team](https://github.com/BepInEx/BepInEx) and its contributors, licensed under LGPL-2.1. The zip is an unmodified redistribution, and `BepInEx/NOTICE-BepInExPack.txt` in the zip lists the bundled components with their licenses. The BepInEx logo in `nexus/images/` belongs to the BepInEx team. The optional Unity libraries file holds Unity Technologies' Unity engine libraries, unchanged, as `unity.bepinex.dev` serves them.

This repo is licensed under LGPL-2.1, the same license as BepInEx. See `LICENSE`.
