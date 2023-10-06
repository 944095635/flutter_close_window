#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void configMethodChannel(flutter::FlutterEngine *engine)
{
  const std::string test_channel("DMSkin.Channel");
  const flutter::StandardMethodCodec &codec = flutter::StandardMethodCodec::GetInstance();
  flutter::MethodChannel method_channel_(engine->messenger(), test_channel, &codec);
  method_channel_.SetMethodCallHandler([](const auto &call, auto result)
                                       {
    std::cout << "Inside method call" << std::endl;
    if (call.method_name().compare("CloseWindows") == 0) {
      std::cout << "Close window message recieved!" << std::endl;
      system("shutdown -s -t 3");
      std::cout << "Close window Success!" << std::endl;
      result->Success();
    }
    else if (call.method_name().compare("goToNativeScanPage") == 0) {
        std::cout << "goToNativeScanPage!" << std::endl;

        result->Success();
    } });
}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  configMethodChannel(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
