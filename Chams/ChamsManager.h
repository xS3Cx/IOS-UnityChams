#pragma once
#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include "../IMGUI/imgui.h"
#include "../IL2CPP/Hooks.h"

namespace Chams {
    // UI state
    extern bool chams_enabled;
    extern int selected_shader_idx;
    extern ImVec4 chams_color;
    extern std::vector<std::string> available_shaders;
    extern void* current_shader_ptr;
    
    // Config
    extern float chams_ztest;
    extern float chams_zwrite;
    
    // Target Selection State
    extern std::vector<std::string> loaded_assemblies;
    extern int selected_assembly_idx;
    extern std::vector<std::string> assembly_classes;
    extern int selected_class_idx;
    extern char chams_target_class[512];
    
    struct RendererInfo {
        void* renderer;
        std::string name;
        bool enabled;
    };
    extern std::vector<RendererInfo> found_renderers;
    
    // Logic
    void RefreshAssemblies();
    void RefreshClasses(const char* assemblyName);
    void RefreshRenderers();
    void ApplyChams(); 
    void ApplyDynamicChams();
    std::vector<std::string> GetAllShadersFromGame();
    void* FindShader(const char* name);
    
    // Debug Logic
    extern std::vector<std::string> debugLogs;
    enum LogType { LOG_INFO, LOG_IL2CPP };
    void Log(LogType type, const char* fmt, ...);
}
