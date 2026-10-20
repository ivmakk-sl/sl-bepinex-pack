# Nexus page

- Title: BepInEx Pack for Survival Log
- Game domain: `survivallog` (add-mod page: https://www.nexusmods.com/survivallog/mods/add)
- Mod id and URL: 12, https://www.nexusmods.com/survivallog/mods/12 (published 2026-09-20)
- Category: Utilities (or the closest category the game offers for tools and frameworks)
- Version: `6.0.0-be.788` (the BepInEx build identifier, with `.2`, `.3` for a repack of the same build, for example `6.0.0-be.788.2`)
- File name under Manage Files: `BepInEx Pack 6.0.0-be.788`, the zip `BepInExPack_SurvivalLog-6.0.0-be.788.zip`, marked as the main file. It is the same zip as the GitHub Release asset. Also mark it with "Set as primary file for download": the top Vortex and Manual download buttons of the page give the primary file. Keep "Allow mod manager download" on: the Vortex extension installs this zip as the pack mod.
- Optional file under Manage Files: `Unity libraries 6000.2.7`, the raw zip `dist/6000.2.7.zip` (the file of `unity.bepinex.dev`, the same as the GitHub mirror), category Optional files, version `6000.2.7`, with "Allow mod manager download" off (it is not a mod, and the Vortex extension refuses it from 1.0.2). Never a zip that holds another zip: Nexus quarantined the first upload of 2026-10-17, `UnityLibs_SurvivalLog-6000.2.7.zip`, for that. When the game moves to a new Unity version, upload the new file and remove the old one (README, "A new Unity version of the game"). File description (plain text, at most 255 characters):

```
Fix for a first start that hangs at "Downloading unity base libraries" or shows "End of Central Directory record could not be found". Close the game. Do not extract: rename to 6000.2.7.zip, put into BepInEx\unity-libs. Unity's files, unchanged.
```
- Requirements: none.
- Do not post the page in the game's Steam forum or Discord. The developer asked players not to share mod tools there.

## Permissions

The main file is the BepInEx team's work under LGPL-2.1, so the page does not claim it. The optional Unity libraries file is Unity Technologies' work with no stated licence, so the page grants no permission for it: each permission below covers the BepInEx files only.

- Other users' assets: yes, all the loader files belong to the BepInEx team, and the files in the optional Unity libraries file belong to Unity Technologies. Credit both in the credits field.
- Upload to other sites: allowed for the BepInEx files, with credit to the BepInEx team. Not for the optional Unity libraries file.
- Modification and reuse: allowed for the BepInEx files under LGPL-2.1, with credit and with the same license. Not for the optional Unity libraries file.
- Conversion to other games: allowed for the BepInEx files. Not for the optional Unity libraries file.
- Use in paid mods or for donation points: not allowed. Keep donation points off for this page.
- Credits field (plain text, no BBCode):

```
BepInEx is made by the BepInEx team and contributors: https://github.com/BepInEx/BepInEx
It is licensed under LGPL-2.1, which permits this unmodified redistribution. The license text and the credits are in the pack (BepInEx/NOTICE-BepInExPack.txt).

All files in this pack are the official BepInEx build 6.0.0-be.788 from https://builds.bepinex.dev/projects/bepinex_be, unchanged. I made none of them.

BepInEx bundles these components, each under its own license: UnityDoorstop (LGPL-2.1), HarmonyX (MIT), MonoMod (MIT), Mono.Cecil (MIT), Cpp2IL (MIT), Il2CppInterop (LGPL-3.0), AsmResolver (MIT), Iced (MIT), Dobby (Apache-2.0), the .NET runtime (MIT). The full list is in the notice file.

The optional Unity libraries file holds the Unity engine libraries (UnityEngine.*.dll) of Unity Technologies, unchanged: byte for byte the file that BepInEx downloads from https://unity.bepinex.dev on the first start. I made none of them. No licence is stated for them, and the permissions of this page do not cover them.

The BepInEx logo in the page images belongs to the BepInEx team.
```
