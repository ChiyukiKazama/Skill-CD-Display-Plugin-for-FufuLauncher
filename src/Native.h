#pragma once
#include <cstdint>
namespace Patterns
{
    namespace SkillCooldownCN71
    {
        // Matched cn71.exe / cn71.i64. Validate the image and every entry before
        // using the accompanying managed layouts; these are not OS offsets.
        inline constexpr uint32_t Timestamp = 0x6AA122D0;
        inline constexpr uint32_t ImageSize = 0x1B0AD000;
        inline constexpr uintptr_t Managers = 0x5783DE8;
        struct Method { uintptr_t rva; const char* bytes; };
        inline constexpr Method StringNew{0x196ACF20, "56 48 83 EC 20 48 85 C9 74 17 48 89 CE E8 AE 23 5F E8 48 89 F1 89 C2 48 83 C4 20 5E E9 9F 9E E7"};
        // Native charge builder: MonoBaseSkillBtn.OKLIFOLHAMN (CN 7.1).
        inline constexpr uintptr_t ChargeNamePrefix = 0x5A5D558;
        inline constexpr uintptr_t ChargeImageType = 0x579F700;
        inline constexpr Method SetupCharges{0x115F6160, "41 57 41 56 56 57 55 53 48 83 EC 28 41 89 D7 48 89 CF 80 3D 72 9D 11 F4 00 0F 85 1C 02 00 00 48"};
        inline constexpr Method GameObjectTransform{0x1452DA0, "40 53 48 83 EC 20 48 8B D9 48 85 C9 0F 84 85 00 00 00 E8 09 80 FF FF 48 85 C0 74 7B 48 8B 40 40"};
        inline constexpr Method FindTransform{0x1437EB0, "48 89 5C 24 18 57 48 83 EC 50 48 8B D9 48 89 54 24 60 48 8D 54 24 20 48 8D 4C 24 60 E8 7F 9F 08"};
        inline constexpr Method ComponentByType{0x1453D40, "40 53 48 83 EC 20 48 8B DA E8 72 70 FF FF 48 85 C0 74 1F 48 8B 50 40 48 85 D2 74 16 4C 8B C3 48"};
        inline constexpr Method ConcatStrings{0x195180F0, "55 41 57 41 56 41 54 56 57 53 48 83 EC 30 48 8D 6C 24 30 48 C7 45 F8 FE FF FF FF 48 89 D6 48 85"};
        inline constexpr Method SetColor{0x19D9D250, "56 57 48 83 EC 48 48 89 CE 0F 10 02 F3 0F 10 49 24 0F 2E C8 75 38 7A 36 F3 0F 10 4E 28 F3 0F 16"};
        inline constexpr Method BindTeam{0xC8E3F90, "41 57 41 56 41 55 41 54 56 57 55 53 48 83 EC 38 4D 89 CC 44 89 C5 48 89 D6 49 89 CD 0F B6 9C 24"};
        inline constexpr Method SetupRow{0xE6776B0, "56 57 53 48 83 EC 20 49 89 D0 48 89 CE 80 3D 1D 66 09 F7 00 0F 85 EA 00 00 00 4C 89 86 78 01 00"};
        inline constexpr Method UpdateRow{0xE674A00, "56 48 83 EC 20 48 89 CE 80 3D A9 92 09 F7 00 75 3E 48 89 F1 E8 67 00 00 00 48 89 F1 E8 4F 01 00"};
        inline constexpr Method DisableRow{0xE677510, "56 57 48 83 EC 28 48 89 CE 80 3D C0 67 09 F7 00 0F 85 C2 00 00 00 80 3D 75 67 09 F7 00 0F 85 E1"};
        inline constexpr Method DestroyRow{0xE672350, "56 57 48 83 EC 28 48 89 CE 80 3D 44 B9 09 F7 00 75 6F 48 8B 46 48 48 85 C0 74 47 48 83 78 10 00"};
        inline constexpr Method ResolveSkill{0xB55FEA0, "56 57 48 83 EC 28 89 D6 48 89 CF 80 3D 05 F8 52 FA 00 74 47 80 3D 2E EF 1B FA 00 75 58 48 8B BF"};
        inline constexpr Method DecodeFloat{0x9391B70, "56 53 48 83 EC 38 49 89 C8 48 8B 19 48 85 DB 75 0B 49 83 78 08 00 0F 84 20 03 00 00 C7 44 24 28"};
        inline constexpr Method DecodeInt{0xAED1990, "56 53 48 83 EC 38 49 89 C8 48 8B 19 48 85 DB 75 0B 49 83 78 08 00 0F 84 10 03 00 00 C7 44 24 28"};
        inline constexpr Method CloneText{0x19CB3430, "56 57 48 83 EC 28 48 85 D2 74 17 48 83 7A 10 00 74 10 48 85 C9 74 17 48 83 C4 28 5F 5E E9 3E 52"};
        inline constexpr Method DestroyObject{0x19CB2D80, "0F 57 C9 E9 C8 5A 78 E7 0F 1F 84 00 00 00 00 00 E9 EB 5A 78 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method GetTransform{0x19CBC860, "E9 AB 73 79 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 9B 73 79 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method GetGameObject{0x19CBC880, "E9 DB 73 79 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 3B 74 79 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method GetEnabled{0x19C8CCA0, "E9 CB 21 45 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 FB 21 45 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method SetEnabled{0x19C8CCB0, "E9 FB 21 45 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 9B 83 7C E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method GetRect{0x19CB3600, "56 48 83 EC 20 48 89 CE 0F 57 C0 0F 11 01 48 89 D1 48 89 F2 E8 D7 05 79 E7 48 89 F0 48 83 C4 20"};
        inline constexpr Method SetPosition{0x19CB62C0, "E9 8B 0A 78 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 7B 0A 78 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method TransformPoint{0x19CB83F0, "56 48 83 EC 20 48 89 CE C7 41 08 00 00 00 00 48 C7 01 00 00 00 00 48 89 D1 4C 89 C2 49 89 F0 E8"};
        inline constexpr Method InverseTransformPoint{0x19CB84D0, "56 48 83 EC 20 48 89 CE C7 41 08 00 00 00 00 48 C7 01 00 00 00 00 48 89 D1 4C 89 C2 49 89 F0 E8"};
        inline constexpr Method SetScale{0x19CB6ED0, "E9 3B 03 78 E7 66 66 2E 0F 1F 84 00 00 00 00 00 E9 2B 03 78 E7 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method SetSize{0x19CB38F0, "48 83 EC 28 48 89 54 24 20 48 8D 54 24 20 E8 7D 06 79 E7 90 48 83 C4 28 C3 0F 1F 80 00 00 00 00"};
        inline constexpr Method SetAnchorMin{0x19CB3680, "48 83 EC 28 48 89 54 24 20 48 8D 54 24 20 E8 FD 05 79 E7 90 48 83 C4 28 C3 0F 1F 80 00 00 00 00"};
        inline constexpr Method SetAnchorMax{0x19CB36F0, "48 83 EC 28 48 89 54 24 20 48 8D 54 24 20 E8 7D 06 79 E7 90 48 83 C4 28 C3 0F 1F 80 00 00 00 00"};
        inline constexpr Method SetPivot{0x19CB3960, "48 83 EC 28 48 89 54 24 20 48 8D 54 24 20 E8 FD 06 79 E7 90 48 83 C4 28 C3 0F 1F 80 00 00 00 00"};
        inline constexpr Method SetText{0x118FA530, "56 57 53 48 83 EC 20 48 89 D7 48 89 CE 48 8D 99 18 01 00 00 48 85 D2 74 14 83 7F 10 00 48 8B 8E"};
        inline constexpr Method SetAlignment{0x118FB840, "39 91 F0 00 00 00 75 01 C3 89 91 F0 00 00 00 E9 4C D0 FF FF 66 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method SetRaycast{0x19D9D3B0, "88 51 34 C3 66 66 66 2E 0F 1F 84 00 00 00 00 00 0F B6 41 50 C3 66 66 2E 0F 1F 84 00 00 00 00 00"};
        inline constexpr Method SetActive{0x1452EE0, "48 89 5C 24 08 57 48 83 EC 20 0F B6 FA 48 8B D9 48 85 C9 74 22 E8 C6 7E FF FF 48 85 C0 74 18 40"};
    }


}
