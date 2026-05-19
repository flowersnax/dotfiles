//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import Quickshell
import QtQuick
import "bar" //no idea why (YET) but putting the bar stuff in its own folder and importing *that* makes the color work?
import qs.services
import "utilities/launcher"

//a LOT of the base of these dotfiles were referenced from octagonemusic's octashell
//it's a good learning tool imo :)

//main shell entry point; manages surface orchestration
ShellRoot {
  id: root

  //screen masking for rounded workspace effect SIKE corners bitch
  //figured it out. im goated
  //this has to be before everything else or the whole shell just kinda shits itself
  //idk why
  BezelsMask {
    id: desktopBezels
  }
  
  //primary desktop bars 
  TopBar {
    id: topBar
  }

  BottomBar {
    id: bottomBar
  }

  RightBar {
    id: rightBar
  }

  //system status bar
  LeftBar {
    id: leftBar
  }

  Launcher {
    id: launcherWindow
  }
}
