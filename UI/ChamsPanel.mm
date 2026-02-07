#import "ChamsPanel.h"
#import "DebugLogPanel.h"
#import "../Chams/ChamsManager.h"
#import "../Resources/Fonts/IconsFontAwesome6.h"
#import "../Utils/ImGuiHelpers.h"

namespace UI {
    void DrawChamsPanel(float contentWidth) {
        if (Chams::chams_enabled) {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
            // Note: Tab item is handled by caller in MainMenuWindow
            ImGui::PopStyleColor();

            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(10.0f, 10.0f));
            ImGui::BeginChild("ChamsSettings", ImVec2(contentWidth * 0.5f, 0), true);
            ImGui::PopStyleVar();

            ImGui::Checkbox(ICON_FA_TOGGLE_ON " Enable Chams", &Chams::chams_enabled);
            ImGui::Separator();

            if (ImGui::Button(ICON_FA_SEARCH " Refresh Shaders", ImVec2(-1, 0))) {
                Chams::available_shaders = Chams::GetAllShadersFromGame();
            }

            if (!Chams::available_shaders.empty()) {
                ImGui::Text("Found %zu shaders", Chams::available_shaders.size());
                const char* current_shader_name = (Chams::selected_shader_idx != -1 && Chams::selected_shader_idx < Chams::available_shaders.size())
                    ? Chams::available_shaders[Chams::selected_shader_idx].c_str()
                    : "Select Shader...";

                ImGui::PushItemWidth(-1);
                if (ImGui::BeginCombo("##Shaders", current_shader_name)) {
                    for (int i = 0; i < (int)Chams::available_shaders.size(); i++) {
                        bool is_selected = (Chams::selected_shader_idx == i);
                        if (ImGui::Selectable(Chams::available_shaders[i].c_str(), is_selected)) {
                            Chams::selected_shader_idx = i;
                            Chams::current_shader_ptr = Chams::FindShader(Chams::available_shaders[i].c_str());
                        }
                    }
                    ImGui::EndCombo();
                }
                ImGui::PopItemWidth();

                float availWidth = ImGui::GetContentRegionAvail().x;
                float btnWidth = 30.0f;
                float textWidth = availWidth - (btnWidth * 2) - 16;

                if (ImGui::Button(ICON_FA_ARROW_LEFT, ImVec2(btnWidth, 0))) {
                    if (Chams::selected_shader_idx > 0) {
                        Chams::selected_shader_idx--;
                        Chams::current_shader_ptr = Chams::FindShader(Chams::available_shaders[Chams::selected_shader_idx].c_str());
                    } else if (!Chams::available_shaders.empty()) {
                         Chams::selected_shader_idx = (int)Chams::available_shaders.size() - 1;
                         Chams::current_shader_ptr = Chams::FindShader(Chams::available_shaders[Chams::selected_shader_idx].c_str());
                    }
                }
                ImGui::SameLine();
                ImGui::SetCursorPosX(ImGui::GetCursorPosX() + (textWidth - ImGui::CalcTextSize("000 / 000").x) * 0.5f);
                ImGui::Text("%d / %d", Chams::selected_shader_idx + 1, (int)Chams::available_shaders.size());
                ImGui::SameLine();
                ImGui::SetCursorPosX(ImGui::GetCursorPosX() + (textWidth - ImGui::CalcTextSize("000 / 000").x) * 0.5f);
                if (ImGui::Button(ICON_FA_ARROW_RIGHT, ImVec2(btnWidth, 0))) {
                    if (Chams::selected_shader_idx < (int)Chams::available_shaders.size() - 1) {
                        Chams::selected_shader_idx++;
                        Chams::current_shader_ptr = Chams::FindShader(Chams::available_shaders[Chams::selected_shader_idx].c_str());
                    } else if (!Chams::available_shaders.empty()) {
                        Chams::selected_shader_idx = 0;
                        Chams::current_shader_ptr = Chams::FindShader(Chams::available_shaders[Chams::selected_shader_idx].c_str());
                    }
                }
            } else {
                ImGui::TextColored(ImVec4(1, 1, 0, 1), "Click 'Refresh' to discover.");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Text("Settings");
            ImGui::TextWrapped("(Note: Most shaders may ignore Z-Test/Z-Write settings)");
            ImGui::ColorEdit4("Color", (float*)&Chams::chams_color, ImGuiColorEditFlags_NoInputs);

            int currentZTest = (int)Chams::chams_ztest;
            ImGui::PushItemWidth(-1);
            if (ImGui::SliderInt("##ZTest", &currentZTest, 0, 8, "Z-Test: %d")) {
                Chams::chams_ztest = (float)currentZTest;
            }
            ImGui::PopItemWidth();
            if (ImGui::IsItemHovered()) ImGui::SetTooltip("0:Off, 4:Standard, 8:Wallhack");

            bool zWrite = (Chams::chams_zwrite > 0.5f);
            if (ImGui::Checkbox("Z-Write Depth", &zWrite)) {
                Chams::chams_zwrite = zWrite ? 1.0f : 0.0f;
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Text("Target Settings");

            if (ImGui::Button("Refresh Assemblies")) Chams::RefreshAssemblies();

            const char* current_assembly_name = (Chams::selected_assembly_idx != -1 && Chams::selected_assembly_idx < Chams::loaded_assemblies.size())
                ? Chams::loaded_assemblies[Chams::selected_assembly_idx].c_str()
                : "Select Assembly...";

            if (ImGui::BeginCombo("Assembly", current_assembly_name)) {
                for (int i = 0; i < (int)Chams::loaded_assemblies.size(); i++) {
                    bool is_selected = (Chams::selected_assembly_idx == i);
                    if (ImGui::Selectable(Chams::loaded_assemblies[i].c_str(), is_selected)) {
                        Chams::selected_assembly_idx = i;
                        Chams::RefreshClasses(Chams::loaded_assemblies[i].c_str());
                    }
                }
                ImGui::EndCombo();
            }

            if (!Chams::assembly_classes.empty()) {
                const char* current_class_name = (Chams::selected_class_idx != -1 && Chams::selected_class_idx < Chams::assembly_classes.size())
                    ? Chams::assembly_classes[Chams::selected_class_idx].c_str()
                    : "Select Class...";

                if (ImGui::BeginCombo("Class", current_class_name)) {
                    ImGuiListClipper clipper;
                    clipper.Begin((int)Chams::assembly_classes.size());
                    while (clipper.Step()) {
                        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                            bool is_selected = (Chams::selected_class_idx == i);
                            if (ImGui::Selectable(Chams::assembly_classes[i].c_str(), is_selected)) {
                                Chams::selected_class_idx = i;
                                std::string assemblyName = Chams::loaded_assemblies[Chams::selected_assembly_idx];
                                size_t lastDot = assemblyName.find_last_of(".");
                                if (lastDot != std::string::npos && assemblyName.substr(lastDot) == ".dll") {
                                    assemblyName = assemblyName.substr(0, lastDot);
                                }
                                std::string finalStr = Chams::assembly_classes[i] + ", " + assemblyName;
                                strlcpy(Chams::chams_target_class, finalStr.c_str(), sizeof(Chams::chams_target_class));
                                Chams::Log(Chams::LOG_INFO, "Selected: %s", Chams::chams_target_class);
                            }
                        }
                    }
                    ImGui::EndCombo();
                }
            } else if (Chams::selected_assembly_idx != -1) {
                ImGui::TextColored(ImVec4(1, 1, 0, 1), "No classes found or loading...");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Text("Renderers");
            if (ImGui::Button("Refresh Renderers")) Chams::RefreshRenderers();

            if (!Chams::found_renderers.empty()) {
                if (ImGui::Button("Select All")) for (auto& info : Chams::found_renderers) info.enabled = true;
                ImGui::SameLine();
                if (ImGui::Button("Deselect All")) for (auto& info : Chams::found_renderers) info.enabled = false;

                ImGui::BeginChild("RendererList", ImVec2(0, 150), true);
                for (size_t i = 0; i < Chams::found_renderers.size(); i++) {
                    ImGui::PushID((int)i);
                    bool enabled = Chams::found_renderers[i].enabled;
                    if (ImGui::Checkbox(Chams::found_renderers[i].name.c_str(), &enabled)) Chams::found_renderers[i].enabled = enabled;
                    ImGui::PopID();
                }
                ImGui::EndChild();
                size_t activeCount = 0;
                for(const auto& r : Chams::found_renderers) if(r.enabled) activeCount++;
                ImGui::Text("Total: %zu | Active: %zu", Chams::found_renderers.size(), activeCount);
            } else {
                ImGui::TextColored(ImVec4(1,1,0,1), "No renderers found/refreshed.");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::TextColored(COLOR_CHECK_MARK, "Credits:");
            ImGui::Text("Released By: GoodFeelings");
            ImGui::Text("Shader Chams Source: Leeksov");
            ImGui::SameLine();
            if (ImGui::SmallButton(ICON_FA_LINK " Link")) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Leeksov/FWDUnityChams-iOS/tree/main/FWDUnityChams-iOS"] options:@{} completionHandler:nil];
            }
            ImGui::Text("IL2CPP Framework: Hao Dam (damduchao)");
            ImGui::EndChild();

            ImGui::SameLine();
            DrawDebugLogPanel();
        } else {
            ImGui::Checkbox(ICON_FA_TOGGLE_ON " Enable Chams", &Chams::chams_enabled);
            ImGui::Text("Enable chams to start testing.");
        }
    }
}
