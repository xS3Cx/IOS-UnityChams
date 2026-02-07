#import "UIFooter.h"
#import "../Utils/ImGuiHelpers.h"
#import <Foundation/Foundation.h>
#include <time.h>

namespace UI {
    void DrawFooter(ImDrawList* drawList, ImVec2 windowPos, ImVec2 windowSize, float footerHeight) {
        ImVec2 footerPos = ImVec2(windowPos.x, windowPos.y + windowSize.y - footerHeight);
        drawList->AddRectFilled(footerPos, ImVec2(windowPos.x + windowSize.x, footerPos.y + footerHeight), ImGui::ColorConvertFloat4ToU32(COLOR_TITLE_BG), ImGui::GetStyle().WindowRounding, ImDrawFlags_RoundCornersBottom);
        drawList->AddLine(footerPos, ImVec2(footerPos.x + windowSize.x, footerPos.y), ImGui::ColorConvertFloat4ToU32(COLOR_BORDER));

        static char footerTime[64] = "";
        static time_t lastTime = 0;
        time_t now = time(0);
        if (now != lastTime) {
            struct tm tstruct = *localtime(&now);
            strftime(footerTime, sizeof(footerTime), "%Y-%m-%d %H:%M:%S", &tstruct);
            lastTime = now;
        }

        NSString *gameNameStr = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] infoDictionary][@"CFBundleName"] ?: @"Game";
        NSString *versionStr = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: @"1.0";
        const char* gameInfo = [[NSString stringWithFormat:@"%@ | v%@", gameNameStr, versionStr] UTF8String];
        const char* urlStr = "https://goodfeelings.cc";

        float centerY = footerPos.y + (footerHeight - ImGui::GetTextLineHeight()) * 0.5f;
        drawList->AddText(ImVec2(footerPos.x + 10, centerY), ImGui::ColorConvertFloat4ToU32(ImVec4(0.6f, 0.6f, 0.6f, 1.0f)), footerTime);
        
        float urlWidth = ImGui::CalcTextSize(urlStr).x;
        drawList->AddText(ImVec2(footerPos.x + (windowSize.x - urlWidth) * 0.5f, centerY), ImGui::ColorConvertFloat4ToU32(COLOR_CHECK_MARK), urlStr);

        float infoWidth = ImGui::CalcTextSize(gameInfo).x;
        drawList->AddText(ImVec2(footerPos.x + windowSize.x - infoWidth - 10, centerY), ImGui::ColorConvertFloat4ToU32(ImVec4(0.6f, 0.6f, 0.6f, 1.0f)), gameInfo);
    }
}
