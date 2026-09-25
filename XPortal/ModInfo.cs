namespace Mod
{
    public static class Info
    {
        // This is *the* place to edit plugin details. Everywhere else will be generated based on this info.
        public const string GUID = "com.prometheuzzz.bifrostportals";
        public const string HarmonyGUID = GUID + ".harmony";
        public const string Author = "PrometheuzzZ";
        public const string Name = "BifrostPortals";
        public const string GitHubRepo = "PrometheuzzZ/XPortal";
        public const string Version = "1.0.0";
        public const string Description = "Step into any portal and choose where to go from a list of all portals. No tag pairing, no portal hubs. A fork of XPortal by SpikeHimself.";
        public const string WebsiteUrl = "https://github.com/" + GitHubRepo;
        public const string BepInExPackVersion = "5.4.2351";

        // The original mod this is a fork of. Both cannot be installed at the same time.
        public const string OriginalGUID = "yay.spikehimself.xportal";
        public const string JotunnVersion = Jotunn.Main.Version;
    }
}
