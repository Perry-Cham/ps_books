//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <charset_converter/charset_converter_plugin.h>
#include <desktop_webview_window/desktop_webview_window_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <webview_all_windows/webview_windows_plugin.h>
#include <webview_windows/webview_windows_plugin.h>
#include <window_to_front/window_to_front_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  CharsetConverterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CharsetConverterPlugin"));
  DesktopWebviewWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWebviewWindowPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WebviewWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewWindowsPlugin"));
  WebviewWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewWindowsPlugin"));
  WindowToFrontPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowToFrontPlugin"));
}
