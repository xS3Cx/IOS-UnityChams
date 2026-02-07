#import "MainMenuWindow.h"
#import "ChamsPanel.h"
#import "UIFooter.h"
#import "../Utils/ImGuiHelpers.h"
#import "../Resources/Textures/Logo/LogoData.h"
#import "../Resources/Fonts/IconsFontAwesome6.h"

namespace UI {
    void DrawHeader(ImDrawList* drawList, ImVec2 windowPos, ImVec2 windowSize, float headerHeight) {
        drawList->AddRectFilled(windowPos, ImVec2(windowPos.x + windowSize.x, windowPos.y + headerHeight), ImGui::ColorConvertFloat4ToU32(COLOR_TITLE_BG), ImGui::GetStyle().WindowRounding, ImDrawFlags_RoundCornersTop);
        drawList->AddLine(ImVec2(windowPos.x, windowPos.y + headerHeight), ImVec2(windowPos.x + windowSize.x, windowPos.y + headerHeight), ImGui::ColorConvertFloat4ToU32(COLOR_BORDER));

        const char* leftText = "GoodFeelings";
        ImVec2 leftTextSize = ImGui::CalcTextSize(leftText);
        drawList->AddText(ImVec2(windowPos.x + 10, windowPos.y + (headerHeight - leftTextSize.y) * 0.5f), ImGui::ColorConvertFloat4ToU32(COLOR_CHECK_MARK), leftText);

        const char* titleText = "Shader Chams Tester";
        ImVec2 textSize = ImGui::CalcTextSize(titleText);
        drawList->AddText(ImVec2(windowPos.x + windowSize.x - textSize.x - 10, windowPos.y + (headerHeight - textSize.y) * 0.5f), ImGui::ColorConvertFloat4ToU32(COLOR_CHECK_MARK), titleText);

        ImTextureID logoTex = getLogoTexture();
        if (logoTex) {
             float logoW = getLogoImageWidth();
             float logoH = getLogoImageHeight();
             float maxLogoH = headerHeight - 4.0f;
             float scale = maxLogoH / logoH;
             float drawW = logoW * scale;
             float drawH = logoH * scale;
             float logoX = windowPos.x + (windowSize.x - drawW) * 0.5f;
             float logoY = windowPos.y + (headerHeight - drawH) * 0.5f;
             drawList->AddImage(logoTex, ImVec2(logoX, logoY), ImVec2(logoX + drawW, logoY + drawH));
        }

        ImGui::SetCursorPos(ImVec2(0, 0));
        ImGui::InvisibleButton("##HeaderDrag", ImVec2(windowSize.x - 30, headerHeight));
        if (ImGui::IsItemActive()) {
            ImVec2 delta = ImGui::GetIO().MouseDelta;
            ImVec2 pos = ImGui::GetWindowPos();
            ImGui::SetWindowPos(ImVec2(pos.x + delta.x, pos.y + delta.y));
        }
    }

    void DrawMainMenu(bool* p_open) {
        if (!*p_open) return;

        ImGui::Begin("GoodFeelings | https://goodfeelings.cc", p_open, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse);
        
        ImDrawList* drawList = ImGui::GetWindowDrawList();
        ImVec2 windowPos = ImGui::GetWindowPos();
        ImVec2 windowSize = ImGui::GetWindowSize();
        float headerHeight = 25.0f;
        float footerHeight = 25.0f;
        float contentPadding = 10.0f;

        DrawHeader(drawList, windowPos, windowSize, headerHeight);

        ImGui::SetCursorPos(ImVec2(contentPadding, headerHeight + contentPadding));
        float contentHeight = windowSize.y - headerHeight - footerHeight - (contentPadding * 2);
        float contentWidth = windowSize.x - (contentPadding * 2);

        if (ImGui::BeginChild("##MainContent", ImVec2(contentWidth, contentHeight), false, ImGuiWindowFlags_NoBackground)) {
            if (ImGui::BeginTabBar("MainTabBar")) {
                if (ImGui::BeginTabItem(ICON_FA_WAND_MAGIC " Chams")) {
                    DrawChamsPanel(contentWidth);
                    ImGui::EndTabItem();
                }
                ImGui::EndTabBar();
            }
        }
        ImGui::EndChild();

        DrawFooter(drawList, windowPos, windowSize, footerHeight);

        ImGui::End();
    }
}
