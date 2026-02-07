#import "InitializationOverlay.h"
#import "../Init/IL2CPPInit.h"
#include <string>

namespace UI {
    void DrawInitializationOverlay(float width, float height) {
        ImGui::SetNextWindowPos(ImVec2(0, 0));
        ImGui::SetNextWindowSize(ImVec2(width, height));
        ImGui::SetNextWindowBgAlpha(0.0f);

        ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoTitleBar |
                                       ImGuiWindowFlags_NoResize |
                                       ImGuiWindowFlags_NoMove |
                                       ImGuiWindowFlags_NoScrollbar |
                                       ImGuiWindowFlags_NoScrollWithMouse |
                                       ImGuiWindowFlags_NoCollapse |
                                       ImGuiWindowFlags_NoSavedSettings;

        if (ImGui::Begin("InitializationOverlay", nullptr, window_flags)) {
            ImVec2 center = ImGui::GetMainViewport()->GetCenter();
            ImGui::SetNextWindowPos(center, ImGuiCond_Always, ImVec2(0.5f, 0.5f));
            ImGui::SetNextWindowSize(ImVec2(320, 160), ImGuiCond_Always);

            ImGuiWindowFlags panel_flags = ImGuiWindowFlags_NoTitleBar |
                                          ImGuiWindowFlags_NoResize |
                                          ImGuiWindowFlags_NoMove |
                                          ImGuiWindowFlags_NoScrollbar |
                                          ImGuiWindowFlags_NoScrollWithMouse |
                                          ImGuiWindowFlags_NoCollapse |
                                          ImGuiWindowFlags_NoSavedSettings;

            if (ImGui::Begin("InitPanel", nullptr, panel_flags)) {
                ImGui::TextColored(ImVec4(0.0f, 0.0f, 0.0f, 1.0f), "Checking IL2CPP functions and symbols...");
                ImGui::Spacing();

                float progress = [IL2CPPInit getInitializationProgress];
                ImGui::ProgressBar(progress, ImVec2(-1, 0), "");
                ImGui::Spacing();

                const char* currentLabel = [IL2CPPInit getCurrentCheckLabel];
                int dotCount = [IL2CPPInit getDotCount];
                std::string dots(dotCount, '.');
                std::string labelText = std::string("Checking: ") + currentLabel + dots;
                ImGui::TextColored(ImVec4(0.0f, 0.0f, 0.0f, 1.0f), "%s", labelText.c_str());

                static float spinnerAngle = 0.0f;
                spinnerAngle += 0.1f;
                if (spinnerAngle > 6.28f) spinnerAngle = 0.0f;

                ImVec2 spinnerPos = ImGui::GetCursorScreenPos();
                ImGui::GetWindowDrawList()->AddText(
                    ImVec2(spinnerPos.x + 150, spinnerPos.y + 20),
                    ImGui::GetColorU32(ImVec4(0.0f, 0.0f, 0.0f, 1.0f)),
                    "⟳"
                );
            }
            ImGui::End();
        }
        ImGui::End();
    }
}
