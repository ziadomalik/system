{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = false;
      DontCheckDefaultBrowser = true;
    };

    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        "browser.startup.page" = 3;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };

      search = {
        force = true;
        default = "ddg";
        engines = {
          "nix-packages" = {
            name = "Nix Packages";
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "bing".metaData.hidden = true;
        };
      };

      bookmarks = {
        force = true;
        settings = [
          {
            name = "Toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "Quran";
                url = "https://quran.com";
              }
              {
                name = "Moodle";
                url = "https://moodle-app2.let.ethz.ch/my";
              }

              {
                name = "Tuta";
                url = "https://app.tuta.com/mail";
              }
              {
                name = "Agenda";
                url = "https://app.tuta.com/calendar/agenda";
              }

              {
                name = "GitHub";
                url = "https://github.com";
              }
            ];
          }
        ];
      };

    };
  };
}
