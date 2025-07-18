pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
  id: states
  property bool screenshotActive: false


  IpcHandler {
    target: "states"

    function activateScreenshot(): void {states.screenshotActive = true}
  }
}
