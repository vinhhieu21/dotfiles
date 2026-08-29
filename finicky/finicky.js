module.exports = {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Profile 1",
  },
  handlers: [
    {
      match: ["youtube.com*", "twitch.tv*"],
      browser: {
        name: "Google Chrome",
        profile: "Default", // or "Profile 2",
      }
    }
  ]
};
