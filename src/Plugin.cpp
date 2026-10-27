// Copyright (c) FufuLauncher Dev Team. AGPL-3.0.
#include "Config.h"
#include "Support.h"
#include "HookSetupGuard.h"
#include "SkillCooldown/SkillCooldown.h"
#include <exception>

namespace
{
    DWORD WINAPI Worker(void*)
    {
        // The injector owns DLL selection. Keep callbacks resident until exit.
        HMODULE pinned = nullptr;
        if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
            reinterpret_cast<LPCWSTR>(&Worker), &pinned)) return 0;
        wchar_t executable[32768]{};
        GetModuleFileNameW(nullptr, executable, 32768);
        if (_wcsicmp(std::filesystem::path(executable).filename().c_str(), L"YuanShen.exe") != 0)
        { Support::Log("Inactive: only the verified CN 7.1 YuanShen.exe build is supported."); return 0; }
        try
        {
            const auto config = Support::Directory() / L"config.ini";
            Config::Reload(config);
            {
                Detached::HookSetupGuard guard;
                if (!guard) { Support::Log("Inactive: timed out waiting for shared hook setup."); return 0; }
                if (!SkillCooldown::Init()) return 0;
            }
            Support::Log("DisplayCD " DISPLAYCD_VERSION " initialized; configuration reload interval: 250 ms.");
            for (;;)
            {
                Sleep(250);
                Config::Reload(config);
            }
        }
        catch (const std::exception& error) { Support::Log(error.what()); }
        return 0;
    }
}
BOOL APIENTRY DllMain(HMODULE, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH)
    {
        // Keep CRT thread notifications: this DLL statically links the CRT.
        HANDLE thread = CreateThread(nullptr, 0, &Worker, nullptr, 0, nullptr);
        if (thread) CloseHandle(thread);
    }
    return TRUE;
}
