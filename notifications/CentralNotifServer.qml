pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

//singleton service providing a centralized interface for dbus notif signals
//code yoinked from octagonemusic's octashell

NotificationServer {
  id: centralNotificationServer

  //capabilities advertised to the system notification daemon
  bodySupported: true
  actionsSupported: true
  imageSupported: true
  persistenceSupported: true

  //primary handler for incoming notification requests.
  //maps external system events to the internal shell state

  onNotification: notification => {
    //enables automatic management within the trackedNotifications objectmodel
    notification.tracked = true;
  }
}
