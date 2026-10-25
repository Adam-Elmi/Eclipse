-- ###################
-- Environment: what apps are told when they start (cursor size, Wayland for toolkits that ask,
-- Qt's colors)
-- ###################

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")         -- Qt apps: the Eclipse colors (qt/qt6ct)
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")
