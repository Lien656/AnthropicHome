[app]
title = AnthropicHome
package.name = anthropichome
package.domain = org.lien

source.dir = .
source.include_exts = py,kv,png,json,ttf

version = 0.1

requirements = python3,kivy==2.3.0,requests,certifi,urllib3,idna,charset-normalizer,plyer

orientation = portrait
fullscreen = 0

android.api = 33
android.minapi = 28
android.archs = arm64-v8a
android.permissions = INTERNET,READ_EXTERNAL_STORAGE,WRITE_EXTERNAL_STORAGE

icon.filename = icon.png

[buildozer]
log_level = 2
warn_on_root = 0
