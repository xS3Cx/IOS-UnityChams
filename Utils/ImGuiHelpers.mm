#import "ImGuiHelpers.h"

const ImVec4 COLOR_WINDOW_BG = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
const ImVec4 COLOR_FRAME_BG = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
const ImVec4 COLOR_CHILD_BG = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);
const ImVec4 COLOR_BUTTON = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
const ImVec4 COLOR_BUTTON_HOVERED = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
const ImVec4 COLOR_BUTTON_ACTIVE = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
const ImVec4 COLOR_TITLE_BG = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);
const ImVec4 COLOR_TITLE_BG_ACTIVE = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
const ImVec4 COLOR_CHECK_MARK = ImVec4(1.00f, 0.00f, 0.28f, 1.00f);
const ImVec4 COLOR_SLIDER_GRAB = ImVec4(1.00f, 0.00f, 0.28f, 1.00f);
const ImVec4 COLOR_TEXT = ImVec4(0.92f, 0.92f, 0.92f, 1.00f);
const ImVec4 COLOR_BORDER = ImVec4(0.20f, 0.20f, 0.20f, 0.50f);
const ImVec4 COLOR_SEPARATOR = ImVec4(0.20f, 0.20f, 0.20f, 0.50f);
const ImVec4 COLOR_HEADER = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);
const ImVec4 COLOR_HEADER_HOVERED = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
const ImVec4 COLOR_HEADER_ACTIVE = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);

namespace ImGuiHelpers {
    void ApplyDefaultStyle() {
        ImGuiStyle& style = ImGui::GetStyle();
        style.Colors[ImGuiCol_WindowBg] = COLOR_WINDOW_BG;
        style.Colors[ImGuiCol_ChildBg] = COLOR_WINDOW_BG;
        style.Colors[ImGuiCol_PopupBg] = COLOR_WINDOW_BG;
        style.Colors[ImGuiCol_FrameBg] = COLOR_FRAME_BG;
        style.Colors[ImGuiCol_FrameBgHovered] = COLOR_BUTTON_HOVERED;
        style.Colors[ImGuiCol_FrameBgActive] = COLOR_BUTTON_ACTIVE;
        style.Colors[ImGuiCol_TitleBg] = COLOR_TITLE_BG;
        style.Colors[ImGuiCol_TitleBgActive] = COLOR_TITLE_BG_ACTIVE;
        style.Colors[ImGuiCol_TitleBgCollapsed] = COLOR_TITLE_BG;
        style.Colors[ImGuiCol_CheckMark] = COLOR_CHECK_MARK;
        style.Colors[ImGuiCol_SliderGrab] = COLOR_SLIDER_GRAB;
        style.Colors[ImGuiCol_SliderGrabActive] = COLOR_SLIDER_GRAB;
        style.Colors[ImGuiCol_Button] = COLOR_BUTTON;
        style.Colors[ImGuiCol_ButtonHovered] = COLOR_BUTTON_HOVERED;
        style.Colors[ImGuiCol_ButtonActive] = COLOR_BUTTON_ACTIVE;
        style.Colors[ImGuiCol_Header] = COLOR_HEADER;
        style.Colors[ImGuiCol_HeaderHovered] = COLOR_HEADER_HOVERED;
        style.Colors[ImGuiCol_HeaderActive] = COLOR_HEADER_ACTIVE;
        style.Colors[ImGuiCol_Separator] = COLOR_SEPARATOR;
        style.Colors[ImGuiCol_SeparatorHovered] = COLOR_SLIDER_GRAB;
        style.Colors[ImGuiCol_SeparatorActive] = COLOR_SLIDER_GRAB;
        style.Colors[ImGuiCol_ResizeGrip] = COLOR_SLIDER_GRAB;
        style.Colors[ImGuiCol_ResizeGripHovered] = ImVec4(1.00f, 0.00f, 0.35f, 1.00f);
        style.Colors[ImGuiCol_ResizeGripActive] = ImVec4(1.00f, 0.00f, 0.45f, 1.00f);
        style.Colors[ImGuiCol_Text] = COLOR_TEXT;
        style.Colors[ImGuiCol_TextDisabled] = ImVec4(COLOR_TEXT.x, COLOR_TEXT.y, COLOR_TEXT.z, 0.5f);
        style.Colors[ImGuiCol_Border] = COLOR_BORDER;
        style.Colors[ImGuiCol_Tab] = COLOR_TITLE_BG;
        style.Colors[ImGuiCol_TabHovered] = COLOR_CHECK_MARK;
        style.Colors[ImGuiCol_TabActive] = COLOR_CHECK_MARK;
        style.Colors[ImGuiCol_TabUnfocused] = COLOR_TITLE_BG;
        style.Colors[ImGuiCol_TabUnfocusedActive] = COLOR_CHECK_MARK;

        style.WindowRounding = 4.0f;
        style.FrameRounding = 2.0f;
        style.PopupRounding = 2.0f;
        style.ScrollbarRounding = 2.0f;
        style.GrabRounding = 2.0f;
        style.TabRounding = 2.0f;
        style.WindowPadding = ImVec2(0.0f, 0.0f);
    }
}
