import QtQuick
import Quickshell.Io

Item {
  id: backend

  //ui orchestration signals
  signal openMenuRequested
  signal closeMenuRequested

  property string searchText: ""

  function launchApp(desktopEntry) {
    desktopEntry.execute();
    backend.closeMenuRequested();
  }

  IpcHandler {
    target: "appLauncher"
    function toggle() {
      backend.openMenuRequested();
    }
  }
}
