[app]
title = Anthropichome
package.name = anthropichome
package.domain = org.lien

source.dir = .
source.include_exts = py,kv,png,jpg,jpeg,json,txt

version = 0.1

requirements = python3,kivy==2.3.0

orientation = portrait
fullscreen = 0

icon.filename = icon.png

android.permissions = INTERNET
android.api = 33
android.minapi = 28
android.archs = arm64-v8a

android.allow_backup = True
android.enable_androidx = True
android.window_soft_input_mode = adjustResize


[buildozer]
log_level = 2
warn_on_root = 1