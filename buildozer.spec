[app]
title = AnthropicHome
package.name = anthropichome
package.domain = org.lien

source.dir = .
source.include_exts = py,kv,png,jpg,jpeg,json,txt,ttf

version = 1.0.0

# ⚠️ ВАЖНО: именно так
requirements = python3,kivy==2.3.0,requests,certifi,urllib3,idna,charset-normalizer,plyer

orientation = portrait
fullscreen = 0

icon.filename = icon.png

# -------- ANDROID --------
android.api = 33
android.minapi = 26
android.ndk_api = 26

android.archs = arm64-v8a

android.permissions = INTERNET,READ_EXTERNAL_STORAGE,WRITE_EXTERNAL_STORAGE,READ_MEDIA_IMAGES,READ_MEDIA_VIDEO,READ_MEDIA_AUDIO,VIBRATE

android.allow_backup = True
android.enable_androidx = True
android.window_soft_input_mode = adjustResize
android.private_storage = True

# -------- BUILD --------
[buildozer]
log_level = 2
warn_on_root = 0
