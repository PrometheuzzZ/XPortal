using HarmonyLib;

namespace XPortal.Patches
{
    [HarmonyPatch(typeof(TeleportWorld), nameof(TeleportWorld.GetHoverText))]
    static class TeleportWorld_GetHoverText
    {
        /// <summary>
        /// Replace the game's hover text
        /// </summary>
        static bool Prefix(ZNetView ___m_nview, ref string __result)
        {
            if (Environment.ShuttingDown)
            {
                Log.Debug("Shutting down, ignoring hover");

                // Don't run the original method
                return false;
            }

            if (!___m_nview || ___m_nview.GetZDO() == null)
            {
                Log.Error("TeleportWorldGetHoverTextPatch: This portal does not exist. Odin strokes his beard in confusion..");
                __result = "This portal doesn't actually appear to exist. Heimdallr sees you...";

                // Don't run the original method
                return false;
            }

            ZDO portalZDO = ___m_nview.GetZDO();
            var portalId = portalZDO.m_uid;
            var location = portalZDO.GetPosition();
            XPortal.OnPrePortalHover(out __result, portalId, location);

            // Don't run the original method
            return false;
        }
    }

    [HarmonyPatch(typeof(TeleportWorld), nameof(TeleportWorld.Teleport))]
    static class TeleportWorld_Teleport
    {
        /// <summary>
        /// When the player enters a portal, show the list of destinations instead of teleporting straight away
        /// </summary>
        static bool Prefix(TeleportWorld __instance, Player player)
        {
            if (!XPortalConfig.Instance.Local.TravelMenuOnEnter)
            {
                // Continue as normal
                return true;
            }

            if (!player || player != Player.m_localPlayer || !__instance.m_nview || __instance.m_nview.GetZDO() == null)
            {
                return false;
            }

            // Don't open the menu while teleporting, or when arriving inside a portal
            if (player.IsTeleporting() || player.m_teleportCooldown < 2f)
            {
                return false;
            }

            if (!__instance.m_allowAllItems && !player.IsTeleportable())
            {
                player.Message(MessageHud.MessageType.Center, "$msg_noteleport");
                return false;
            }

            XPortal.OnPortalEntered(__instance.m_nview.GetZDO().m_uid, __instance.m_exitDistance, __instance.m_allowAllItems);

            // Don't run the original method
            return false;
        }
    }

    [HarmonyPatch(typeof(TeleportWorld), nameof(TeleportWorld.TargetFound))]
    static class TeleportWorld_TargetFound
    {
        /// <summary>
        /// With the travel menu every portal can be used, so every portal should look active
        /// </summary>
        static void Postfix(ref bool __result)
        {
            if (XPortalConfig.Instance.Local.TravelMenuOnEnter)
            {
                __result = true;
            }
        }
    }
}
