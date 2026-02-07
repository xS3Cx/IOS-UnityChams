#import "DebugLogPanel.h"
#import "../Chams/ChamsManager.h"
#import "../Utils/ImGuiHelpers.h"

namespace UI {
    void DrawDebugLogPanel() {
        ImGui::BeginChild("ChamsLogs", ImVec2(0, 0), true);
        ImGui::TextColored(COLOR_CHECK_MARK, "Debug Logs");
        ImGui::SameLine();
        if (ImGui::SmallButton("Clear")) Chams::debugLogs.clear();
        ImGui::Separator();

        ImGui::BeginChild("LogScroll", ImVec2(0, 0), false, ImGuiWindowFlags_HorizontalScrollbar);
        for (const auto& log : Chams::debugLogs) ImGui::TextUnformatted(log.c_str());
        if (ImGui::GetScrollY() >= ImGui::GetScrollMaxY()) ImGui::SetScrollHereY(1.0f);
        ImGui::EndChild();
        ImGui::EndChild();
    }
}
