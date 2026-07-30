# chocolatey-packages

Chocolatey package sources maintained by [CkEsc](https://community.chocolatey.org/profiles/CkEsc).

| Package | Upstream | Chocolatey |
| --- | --- | --- |
| [wox](wox/src) | [Wox-launcher/Wox](https://github.com/Wox-launcher/Wox) | [community.chocolatey.org/packages/wox](https://community.chocolatey.org/packages/wox) |

## Manual publish (Windows)

From `wox/src`:

1. `1-build-package.bat` — `choco pack`
2. `2-test-package.bat` — install from the local nupkg
3. `3-push-package.bat` — `choco push` (needs your Chocolatey API key configured)

## Automated updates

GitHub Actions workflow [`.github/workflows/update-wox.yml`](.github/workflows/update-wox.yml) polls the latest **stable** Wox GitHub release daily, bumps package metadata with [Chocolatey-AU](https://github.com/chocolatey-community/chocolatey-au), pushes to the community repository, and commits the metadata change back to this repo.

Required repository secret:

- `CHOCOLATEY_API_KEY` — from https://community.chocolatey.org/account (API Key)

Optional local run (Windows, with Chocolatey + Chocolatey-AU installed):

```powershell
Install-Module Chocolatey-AU -Scope CurrentUser
$Env:api_key = '<your-key>'   # only if pushing
$Env:au_Push = 'true'         # optional
./update_all.ps1
```
