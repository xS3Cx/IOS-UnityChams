#pragma once
#include <Metal/Metal.h>
#include "../IMGUI/imgui.h"

// Constants and Colors
extern const ImVec4 COLOR_WINDOW_BG;
extern const ImVec4 COLOR_FRAME_BG;
extern const ImVec4 COLOR_CHILD_BG;
extern const ImVec4 COLOR_BUTTON;
extern const ImVec4 COLOR_BUTTON_HOVERED;
extern const ImVec4 COLOR_BUTTON_ACTIVE;
extern const ImVec4 COLOR_TITLE_BG;
extern const ImVec4 COLOR_TITLE_BG_ACTIVE;
extern const ImVec4 COLOR_CHECK_MARK;
extern const ImVec4 COLOR_SLIDER_GRAB;
extern const ImVec4 COLOR_TEXT;
extern const ImVec4 COLOR_BORDER;
extern const ImVec4 COLOR_SEPARATOR;
extern const ImVec4 COLOR_HEADER;
extern const ImVec4 COLOR_HEADER_HOVERED;
extern const ImVec4 COLOR_HEADER_ACTIVE;

namespace ImGuiHelpers {
    void ApplyDefaultStyle();
}
