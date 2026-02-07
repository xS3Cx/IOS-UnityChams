#import "ChamsManager.h"
#import <Foundation/Foundation.h>
#include <set>
#import <dlfcn.h>
#include <algorithm>

namespace Chams {
    bool chams_enabled = false;
    int selected_shader_idx = -1;
    ImVec4 chams_color = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
    std::vector<std::string> available_shaders;
    void* current_shader_ptr = nullptr;
    float chams_ztest = 8.0f;
    float chams_zwrite = 1.0f;
    
    std::vector<std::string> loaded_assemblies;
    int selected_assembly_idx = -1;
    std::vector<std::string> assembly_classes;
    int selected_class_idx = -1;
    char chams_target_class[512] = ""; 
    std::vector<RendererInfo> found_renderers;
    
    std::vector<std::string> debugLogs;

    void Log(LogType type, const char* fmt, ...) {
        char buffer[1024];
        va_list args;
        va_start(args, fmt);
        vsnprintf(buffer, sizeof(buffer), fmt, args);
        va_end(args);
        
        std::string prefix = (type == LOG_IL2CPP) ? "[IL2CPP] " : "[LOG] ";
        std::string finalLog = prefix + std::string(buffer);
        
        debugLogs.push_back(finalLog);
        if (debugLogs.size() > 100) debugLogs.erase(debugLogs.begin());
        printf("[CHAMS]%s%s\n", prefix.c_str(), buffer);
    }

    // Reflection pointers
    static void* (*il2cpp_domain_get)();
    static void** (*il2cpp_domain_get_assemblies)(void* domain, size_t* size);
    static void* (*il2cpp_assembly_get_image)(void* assembly);
    static const char* (*il2cpp_image_get_name)(void* image);
    static size_t (*il2cpp_image_get_class_count)(void* image);
    static void* (*il2cpp_image_get_class)(void* image, size_t index);
    static const char* (*il2cpp_class_get_name)(void* klass);
    static const char* (*il2cpp_class_get_namespace)(void* klass);

    void InitReflection() {
        if (il2cpp_domain_get) return;
        il2cpp_domain_get = (void* (*)())dlsym(RTLD_DEFAULT, "il2cpp_domain_get");
        il2cpp_domain_get_assemblies = (void** (*)(void*, size_t*))dlsym(RTLD_DEFAULT, "il2cpp_domain_get_assemblies");
        il2cpp_assembly_get_image = (void* (*)(void*))dlsym(RTLD_DEFAULT, "il2cpp_assembly_get_image");
        il2cpp_image_get_name = (const char* (*)(void*))dlsym(RTLD_DEFAULT, "il2cpp_image_get_name");
        il2cpp_image_get_class_count = (size_t (*)(void*))dlsym(RTLD_DEFAULT, "il2cpp_image_get_class_count");
        il2cpp_image_get_class = (void* (*)(void*, size_t))dlsym(RTLD_DEFAULT, "il2cpp_image_get_class");
        il2cpp_class_get_name = (const char* (*)(void*))dlsym(RTLD_DEFAULT, "il2cpp_class_get_name");
        il2cpp_class_get_namespace = (const char* (*)(void*))dlsym(RTLD_DEFAULT, "il2cpp_class_get_namespace");
    }

    // Internal helpers
    template<typename T>
    T GetMethod(const char* image, const char* namespaze, const char* klass, const char* method, int args) {
        return reinterpret_cast<T>((uint64_t)IL2Cpp::GetMethodOffset(image, namespaze, klass, method, args));
    }

    void* Shader_get_name(void* shader) {
        static auto method = GetMethod<void*(*)(void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Shader", "get_name", 0);
        return method ? method(shader) : nullptr;
    }

    void* Renderer_get_material(void* renderer) {
        static auto method = GetMethod<void*(*)(void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Renderer", "get_material", 0);
        return method ? method(renderer) : nullptr;
    }

    void* Material_get_shader(void* material) {
        static auto method = GetMethod<void*(*)(void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Material", "get_shader", 0);
        return method ? method(material) : nullptr;
    }

    void Material_SetShader(void* material, void* shader) {
        static auto method = GetMethod<void(*)(void*, void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Material", "set_shader", 1);
        if (method) method(material, shader);
    }

    void Material_SetColor_WithName(void* material, const char* name, Color color) {
        static auto method = GetMethod<void(*)(void*, monoString*, Color)>("UnityEngine.CoreModule.dll", "UnityEngine", "Material", "SetColor", 2);
        if (method) method(material, String_CreateString(name), color);
    }

    void Material_SetFloat(void* material, const char* name, float value) {
        static auto method = GetMethod<void(*)(void*, monoString*, float)>("UnityEngine.CoreModule.dll", "UnityEngine", "Material", "SetFloat", 2);
        if (method) method(material, String_CreateString(name), value);
    }

    void* Shader_Find(const char* name) {
        static auto method = GetMethod<void*(*)(monoString*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Shader", "Find", 1);
        return method ? method(String_CreateString(name)) : nullptr;
    }

    void* GameObject_get_name(void* gameObj) {
        static auto method = GetMethod<void*(*)(void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Object", "get_name", 0);
        return method ? method(gameObj) : nullptr;
    }

    monoArray<void**>* GameObject_GetRenderers(void* gameObj) {
        void* rendererType = Type_GetType(String_CreateString("UnityEngine.Renderer, UnityEngine.CoreModule"));
        if (!rendererType) return nullptr;
        return GameObject_GetComponentsInternal(gameObj, rendererType, false, true, false, false, nullptr);
    }

    void ApplyChams(void* gameObj, void* cachedShader, Color batchColor) {
        if (!gameObj || !cachedShader) return;
        monoArray<void**>* objRenderers = GameObject_GetRenderers(gameObj);
        if (objRenderers && objRenderers->getLength() > 0) {
            void** renderers = objRenderers->getPointer();
            for (int j = 0; j < objRenderers->getLength(); j++) {
                void* renderer = renderers[j];
                if (renderer) {
                    void* material = Renderer_get_material(renderer);
                    if (material) {
                        Material_SetShader(material, cachedShader);
                        Material_SetColor_WithName(material, "_Color", batchColor);
                        Material_SetFloat(material, "_ZTest", chams_ztest);
                        Material_SetFloat(material, "_ZWrite", chams_zwrite);
                    }
                }
            }
        }
    }

    void ApplyChams() {
        if (!chams_enabled || !current_shader_ptr) return;
        Color c = { chams_color.x, chams_color.y, chams_color.z, chams_color.w };
        for (const auto& info : found_renderers) {
            if (!info.enabled || !info.renderer) continue;
            void* material = Renderer_get_material(info.renderer);
            if (material) {
                Material_SetShader(material, current_shader_ptr);
                Material_SetColor_WithName(material, "_Color", c);
                Material_SetFloat(material, "_ZTest", chams_ztest);
                Material_SetFloat(material, "_ZWrite", chams_zwrite);
            }
        }
    }

    void ApplyDynamicChams() {
        if (!chams_enabled || !current_shader_ptr) return;
        static void* cachedType = nullptr;
        static std::string lastTargetClass = "";
        static time_t lastScanTime = 0;
        static std::vector<void*> cachedObjects;
        
        time_t now = time(0);
        bool shouldRescan = (now != lastScanTime);
        
        std::string currentTargetClass(chams_target_class);
        if (currentTargetClass != lastTargetClass) {
            cachedType = nullptr;
            lastTargetClass = currentTargetClass;
            cachedObjects.clear();
            if (!currentTargetClass.empty()) cachedType = Type_GetType(String_CreateString(currentTargetClass.c_str()));
            shouldRescan = true;
        }
        
        if (shouldRescan && cachedType) {
            lastScanTime = now;
            cachedObjects.clear();
            monoArray<void**>* objects = Object_FindObjectsOfType(cachedType);
            if (objects && objects->getLength() > 0) {
                void** objs_raw = objects->getPointer();
                for (int i = 0; i < objects->getLength(); i++) {
                     if (objs_raw[i]) cachedObjects.push_back(objs_raw[i]);
                }
            }
        }
        
        if (!cachedObjects.empty()) {
            Color c = { chams_color.x, chams_color.y, chams_color.z, chams_color.w };
            for (void* obj : cachedObjects) {
                if (!obj) continue;
                void* gameObj = Component_get_gameObject(obj);
                if (gameObj) ApplyChams(gameObj, current_shader_ptr, c);
            }
        }
    }

    std::vector<std::string> GetAllShadersFromGame() {
        Log(LOG_INFO, "Starting GetAllShadersFromGame...");
        std::vector<std::string> shaders;
        std::set<std::string> uniqueShaders;
        void* shaderType = Type_GetType(String_CreateString("UnityEngine.Shader, UnityEngine.CoreModule"));
        if (!shaderType) shaderType = Type_GetType(String_CreateString("UnityEngine.Shader, UnityEngine"));
        
        if (shaderType) {
            monoArray<void**>* shaderArray = Object_FindObjectsOfType(shaderType);
            if (shaderArray && shaderArray->getLength() > 0) {
                void** shaders_raw = shaderArray->getPointer();
                for (int i = 0; i < shaderArray->getLength(); i++) {
                    void* shader = shaders_raw[i];
                    if (!shader) continue;
                    void* namePtr = Shader_get_name(shader);
                    if (namePtr) {
                        monoString* nameString = (monoString*)namePtr;
                        if (nameString) uniqueShaders.insert(std::string(nameString->toCString()));
                    }
                }
            }
        }

        if (uniqueShaders.empty() && shaderType) {
            auto method = GetMethod<monoArray<void**>*(*)(void*)>("UnityEngine.CoreModule.dll", "UnityEngine", "Resources", "FindObjectsOfTypeAll", 1);
            if (method) {
                monoArray<void**>* allShaders = method(shaderType);
                if (allShaders && allShaders->getLength() > 0) {
                    void** shaders_raw = allShaders->getPointer();
                    for (int i = 0; i < allShaders->getLength(); i++) {
                        void* shader = shaders_raw[i];
                        if (!shader) continue;
                        void* namePtr = Shader_get_name(shader);
                        if (namePtr) {
                             monoString* nameString = (monoString*)namePtr;
                             if (nameString) uniqueShaders.insert(std::string(nameString->toCString()));
                        }
                    }
                }
            }
        }

        if (uniqueShaders.empty()) {
            void* materialType = Type_GetType(String_CreateString("UnityEngine.Material, UnityEngine.CoreModule"));
            if (!materialType) materialType = Type_GetType(String_CreateString("UnityEngine.Material, UnityEngine"));
            if (materialType) {
                monoArray<void**>* materialArray = Object_FindObjectsOfType(materialType);
                if (materialArray && materialArray->getLength() > 0) {
                    void** mats = materialArray->getPointer();
                    for (int i = 0; i < materialArray->getLength(); i++) {
                        void* mat = mats[i];
                        if (mat) {
                            void* shader = Material_get_shader(mat);
                            if (shader) {
                                 void* namePtr = Shader_get_name(shader);
                                 if (namePtr) {
                                     monoString* nameString = (monoString*)namePtr;
                                     if (nameString) uniqueShaders.insert(std::string(nameString->toCString()));
                                 }
                            }
                        }
                    }
                }
            }
        }

        for (const auto& name : uniqueShaders) shaders.push_back(name);
        if (shaders.empty()) {
            shaders.push_back("Hidden/Internal-Colored");
            shaders.push_back("Legacy Shaders/Transparent/Bumped Diffuse");
            shaders.push_back("Standard");
        }
        return shaders;
    }

    void* FindShader(const char* name) {
        return Shader_Find(name);
    }

    void RefreshAssemblies() {
        InitReflection();
        loaded_assemblies.clear();
        selected_assembly_idx = -1;
        if (!il2cpp_domain_get || !il2cpp_domain_get_assemblies) return;
        
        void* domain = il2cpp_domain_get();
        if (!domain) return;
        size_t size = 0;
        void** assemblies = il2cpp_domain_get_assemblies(domain, &size);
        for (size_t i = 0; i < size; i++) {
            void* image = il2cpp_assembly_get_image(assemblies[i]);
            if (image) {
                const char* name = il2cpp_image_get_name(image);
                if (name) loaded_assemblies.push_back(std::string(name));
            }
        }
        std::sort(loaded_assemblies.begin(), loaded_assemblies.end());
    }

    void RefreshClasses(const char* assemblyName) {
        InitReflection();
        assembly_classes.clear();
        selected_class_idx = -1;
        if (!il2cpp_domain_get || !il2cpp_domain_get_assemblies) return;
        
        void* domain = il2cpp_domain_get();
        size_t size = 0;
        void** assemblies = il2cpp_domain_get_assemblies(domain, &size);
        void* targetImage = nullptr;
        for (size_t i = 0; i < size; i++) {
            void* image = il2cpp_assembly_get_image(assemblies[i]);
            if (image) {
                const char* name = il2cpp_image_get_name(image);
                if (name && strcmp(name, assemblyName) == 0) {
                    targetImage = image;
                    break;
                }
            }
        }
        
        if (targetImage) {
            size_t classCount = il2cpp_image_get_class_count(targetImage);
            for (size_t i = 0; i < classCount; i++) {
                void* klass = il2cpp_image_get_class(targetImage, i);
                if (klass) {
                    const char* name = il2cpp_class_get_name(klass);
                    const char* ns = il2cpp_class_get_namespace(klass);
                    if (name) {
                        std::string fullName = (ns && strlen(ns) > 0) ? std::string(ns) + "." + name : std::string(name);
                        assembly_classes.push_back(fullName);
                    }
                }
            }
        }
        std::sort(assembly_classes.begin(), assembly_classes.end());
    }

    void RefreshRenderers() {
        found_renderers.clear();
        if (strlen(chams_target_class) == 0) return;
        InitReflection();
        void* type = Type_GetType(String_CreateString(chams_target_class));
        if (!type) return;
        
        monoArray<void**>* objects = Object_FindObjectsOfType(type);
        if (!objects || objects->getLength() == 0) return;
        
        void** objs_raw = objects->getPointer();
        for (int i = 0; i < objects->getLength(); i++) {
            void* obj = objs_raw[i];
            if (!obj) continue;
            void* gameObj = Component_get_gameObject(obj);
            if (!gameObj) continue;
            
            std::string objName = "Unknown";
            void* namePtr = GameObject_get_name(gameObj);
            if (namePtr) objName = ((monoString*)namePtr)->toCString();
            
            monoArray<void**>* renderers = GameObject_GetRenderers(gameObj);
            if (renderers && renderers->getLength() > 0) {
                 void** r_raw = renderers->getPointer();
                 for (int j = 0; j < renderers->getLength(); j++) {
                     if (r_raw[j]) {
                         RendererInfo info;
                         info.renderer = r_raw[j];
                         info.name = objName + " (Renderer " + std::to_string(j) + ")"; 
                         info.enabled = true;
                         found_renderers.push_back(info);
                     }
                 }
            }
        }
    }
}
