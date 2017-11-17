
MODULES = jailed
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Spotify
DISPLAY_NAME = Spotify+
BUNDLE_ID = com.hidan.spotify-gestures

Spotify_FILES = Tweak.xm Settings.xm
Spotify_IPA = /Users/sokol/Documents/projects/iOS/spotify/Spotify++.ipa

include $(THEOS_MAKE_PATH)/tweak.mk
