pragma Singleton

import Quickshell.Services.Mpris
import Quickshell
import QtQuick

Singleton {
  id: root

  property MprisPlayer allPlayers: Mpris.players.values[0]

  property string title: allPlayers.trackTitle ?? "No title"
  property string artist: allPlayers.trackArtist ?? "No artist"
}
