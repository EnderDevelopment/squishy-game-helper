# Roblox Tool-Gifting Script

Squishy Game Helper is a Roblox tool-gifting script for an experience you own or are authorized to edit. It adds an interface for nearby players to give tools they own to one another, with server-side checks for player distance, tool ownership, and request rate. It does not grant items from another Roblox experience.

## Install

1. In Roblox Studio, add a Script under `ServerScriptService` and paste in the contents of `src/GiveServer.server.lua`.
2. Add a LocalScript under `StarterPlayer > StarterPlayerScripts` and paste in the contents of `src/GiveClient.client.lua`.
3. Test in Studio with Start Server and at least two players.

The server script creates the `ReplicatedStorage.GiveSystem` folder and its RemoteEvents automatically.

## Use

1. In game, select the Give item button to open the interface.
2. Choose a nearby player from the list.
3. Choose a tool from your Backpack or character to send it.
4. Check the status message for the transfer result.

Players must be within 12 studs. The server validates the request and enforces a 1.5-second cooldown between requests from each player.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/e96ba9e5-3d21-44d1-83bd-6aa2edadbb20?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=e96ba9e5-3d21-44d1-83bd-6aa2edadbb20
