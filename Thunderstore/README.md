# Bifrost Portals

Step into any portal and choose where to go from a list of all portals. No tag pairing, no portal hubs.

## Features

- **Travel menu**: walk into a portal and a list of every other portal appears, with its distance. Pick one and travel there.
- The list shows 7 portals at a time and scrolls with the mouse wheel, the scrollbar, the arrow keys or the D-pad.
- Click a portal to select it, click it again (or press **Travel** / Enter) to go.
- **Configure** a portal by interacting with it (E): just give it a name.
- Ping a portal on the map from the travel menu.
- The game's portal rules still apply: ores and other restricted items, no-portal world modifiers and boss fights.
- Works with worlds that used XPortal before: existing portal names and destinations are kept.

## Configuration

`BepInEx/config/com.prometheuzzz.bifrostportals.cfg`

| Setting | Default | Description |
|---|---|---|
| TravelMenuOnEnter | true | Show the travel menu when entering a portal. When disabled, portals work like XPortal: each portal has a fixed destination set in the configure window. |
| PingMapDisabled | false | Disable the Ping button. Enforced by the server. |
| HidePortalDistance | false | Don't show distances in the list. Enforced by the server. |
| DoublePortalCosts | false | Double the cost of building portals. Enforced by the server. |
| DisplayPortalColour | false | Show a coloured `>>` tag matching the portal's light (Advanced Portals integration). |

All players and the server must have the mod installed.

## Credits

Bifrost Portals is a fork of [XPortal](https://github.com/SpikeHimself/XPortal) by **SpikeHimself**, which itself is a rewrite of AnyPortal. All the credit for the portal list, syncing and translations goes to them and the XPortal translators.

Do not install Bifrost Portals together with XPortal.

Source code (GPL-3.0): https://github.com/PrometheuzzZ/XPortal
