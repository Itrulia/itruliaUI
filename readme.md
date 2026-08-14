# Itrulia UI

Installs the addon profiles of Itrulia's UI

## Features

- **Installer** - one page per addon, each importing the bundled profile through that addon's own profile system. Nothing is imported until you press its button, and the run remembers what it imported so later updates only offer the profiles that actually changed.

Covers EllesmereUI (module by module, all ticked unless you untick), [ItruliaQoL](../ItruliaQoL/readme.md), [ItruliaEUI](../ItruliaEUI/readme.md), BigWigs, Northern Sky Raid Tools, EXBoss, Hiding Bar and the Blizzard Edit Mode layout.

## Configure

Settings live in the **EllesmereUI** config window, under the **Itrulia UI** sidebar group.

- `/iui` - open the installer (`/iui install` does the same)
- `/iui update` - only the profiles whose bundled version has moved on
- `/iui config` - open the EllesmereUI panel on this addon's row

## AI Use

There's a limited amount of AI used in the code. Such as the Wizarf frame, Ellesmere configs, EllesmereUI integration, spell checking and writing documentation. None of the dangerous code such as importing profiles have been done by AI. All code is checked and approved before committed.