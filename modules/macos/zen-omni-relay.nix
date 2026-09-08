# zen-omni-sync relay — cross-machine "window bus" for Zen.
# Treats Zen instances on every machine as extra windows of one browser:
# tabs, navigation and cookies mirror live through this hub.
# Extension lives inside the (synced) zen profile dirs, so it
# self-distributes to loligo/hapalo via the zen profile sync.
{
  launchd.user.agents.zen-omni-relay = {
    command = "/run/current-system/sw/bin/python3 /Users/sqibo/devel/zen-omni-sync/relay.py";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ThrottleInterval = 10;
      StandardOutPath = "/Users/sqibo/devel/zen-omni-sync/relay-launchd.log";
      StandardErrorPath = "/Users/sqibo/devel/zen-omni-sync/relay-launchd.log";
    };
  };
}
