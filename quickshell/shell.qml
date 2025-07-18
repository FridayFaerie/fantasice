#!/usr/bin/env -S quickshell -p
//@ pragma UseQApplication
import Quickshell
import "./notifs"

ShellRoot {
    Bar {}
    Toaster {}
    ReloadPopup {}
    Quickshot {
      id: quickshot
      property var variable: "hihihihi"
    }
}
