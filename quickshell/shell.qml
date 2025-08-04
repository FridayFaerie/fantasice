#!/usr/bin/env -S quickshell -p
//@ pragma UseQApplication
//@ pragma Env QT_STYLE_OVERRIDE=

import Quickshell
import "./notifs"

ShellRoot {
    Bar {}
    Toaster {}
    ReloadPopup {}
    Quickshot {
      id: quickshot
    }
}
