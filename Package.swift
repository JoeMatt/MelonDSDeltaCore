// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "melonDSDeltaCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
        .macOS(.v11),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "melonDSDeltaCore",
            targets: ["melonDSDeltaCore"]),
        .library(
            name: "melonDSDeltaCoreStatic",
            type: .static,
            targets: ["melonDSDeltaCore"]),
        .library(
            name: "melonDSDeltaCoreDynamic",
            type: .dynamic,
            targets: ["melonDSDeltaCore"])
    ],
    dependencies: [
        //        .package(url: "https://github.com/rileytestut/DeltaCore.git", .branch("main"))
        .package(path: "../DeltaCore")
    ],
    targets: [
        .target(
            name: "melonDSSwift",
            dependencies: ["DeltaCore"]
        ),
        .target(
            name: "melonDSBridge",
            dependencies: ["DeltaCore", "melonDS", "melonDSSwift"],
            publicHeadersPath: "",
            cSettings: [
                .define("JIT_ENABLED", to:"1"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions"
                ]),
            ],
            cxxSettings: [
                .define("JIT_ENABLED", to: "1"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions"
                ]),
            ],
            swiftSettings: [
                .define("STATIC_LIBRARY", .when(platforms: [.wasi])),
                .unsafeFlags([
                    "-enable-experimental-cxx-interop",
                    "-I", "../melonDS/include/",
                    "-I", "../melonDS/melonDS/src/"
                ])
            ]
        ),
        .target(
            name: "melonDSDeltaCore",
            dependencies: ["DeltaCore", "melonDS", "melonDSSwift", "melonDSBridge"],
            exclude: [
                "Resources/Controller Skin/info.json",
                "Resources/Controller Skin/iphone_portrait.pdf",
                "Resources/Controller Skin/iphone_landscape.pdf",
                "Resources/Controller Skin/iphone_edgetoedge_portrait.pdf",
                "Resources/Controller Skin/iphone_edgetoedge_landscape.pdf",
                "Resources/Controller Skin/ipad_portrait.pdf",
                "Resources/Controller Skin/ipad_landscape.pdf",
                "Resources/Controller Skin/ipad_splitview_portrait.pdf",
                "Resources/Controller Skin/ipad_splitview_landscape.pdf"
            ],
            resources: [
                .copy("Resources/Controller Skin/Standard.deltaskin"),
                .copy("Resources/Standard.deltamapping"),
            ],
            cSettings: [
                .define("JIT_ENABLED", to:"1"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions"
                ]),
            ],
            cxxSettings: [
                .define("JIT_ENABLED", to: "1"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions"
                ]),
            ],
            swiftSettings: [
                .define("STATIC_LIBRARY", .when(platforms: [.wasi])),
                .unsafeFlags([
                    "-enable-experimental-cxx-interop",
                    "-I", "../melonDS/include/",
                    "-I", "../melonDS/melonDS/src/"
                ])
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation", .when(platforms: [.iOS, .tvOS, .macCatalyst])),
            ]
        ),
        .target(
            name: "melonDS",
            exclude: [
                //"melonDS/src/*.{h,hpp,cpp}",
                "melonDS/cmake/",
                "melonDS/flatpak/",
                "melonDS/icon/",
                "melonDS/CMakeLists.txt",
                "melonDS/LICENSE",
                "melonDS/melon_grc.xml",
                "melonDS/melon.ico",
                "melonDS/melon.qrc",
                "melonDS/melon.rc",
                "melonDS/melonDS.icns",
                "melonDS/melonDS.plist",
                "melonDS/msys-dist.sh",
                "melonDS/README",
                "melonDS/net.kuribo64.melonDS.desktop",
                "melonDS/xp.manifest",
                "melonDS/src/GPU3D_OpenGL.cpp",
                "melonDS/src/OpenGLSupport.cpp",
                "melonDS/src/GPU_OpenGL.cpp",
                "melonDS/src/ARMJIT_x64/",
//                "melonDS/src/frontend/",
//                "melonDS/src/frontend/qt_sdl/",
                "melonDS/src/frontend/qt_sdl/pcap/",
            ],
            sources: [
                "melonDS/src/ARCodeFile.cpp",
                "melonDS/src/AREngine.cpp",
                "melonDS/src/ARM.cpp",
                "melonDS/src/ARMInterpreter.cpp",
                "melonDS/src/ARMInterpreter_ALU.cpp",
                "melonDS/src/ARMInterpreter_Branch.cpp",
                "melonDS/src/ARMInterpreter_LoadStore.cpp",
                "melonDS/src/ARMJIT.cpp",
                "melonDS/src/ARMJIT_A64/ARMJIT_ALU.cpp",
                "melonDS/src/ARMJIT_A64/ARMJIT_Branch.cpp",
                "melonDS/src/ARMJIT_A64/ARMJIT_Compiler.cpp",
                "melonDS/src/ARMJIT_A64/ARMJIT_Compiler.h",
                "melonDS/src/ARMJIT_A64/ARMJIT_Linkage.S",
                "melonDS/src/ARMJIT_A64/ARMJIT_LoadStore.cpp",
                "melonDS/src/ARMJIT_Memory.cpp",
                "melonDS/src/ARM_InstrInfo.cpp",
                "melonDS/src/CP15.cpp",
                "melonDS/src/CRC32.cpp",
                "melonDS/src/Config.cpp",
                "melonDS/src/DMA.cpp",
                "melonDS/src/DSi.cpp",
                "melonDS/src/DSiCrypto.cpp",
                "melonDS/src/DSi_AES.cpp",
                "melonDS/src/DSi_Camera.cpp",
                "melonDS/src/DSi_I2C.cpp",
                "melonDS/src/DSi_NDMA.cpp",
                "melonDS/src/DSi_NWifi.cpp",
                "melonDS/src/DSi_SD.cpp",
                "melonDS/src/DSi_SPI_TSC.cpp",
                "melonDS/src/GBACart.cpp",
                "melonDS/src/GPU.cpp",
                "melonDS/src/GPU2D.cpp",
                "melonDS/src/GPU2D_Soft.cpp",
                "melonDS/src/GPU3D.cpp",
                "melonDS/src/GPU3D_Soft.cpp",
                "melonDS/src/NDS.cpp",
                "melonDS/src/NDSCart.cpp",
                "melonDS/src/RTC.cpp",
                "melonDS/src/SPI.cpp",
                "melonDS/src/SPU.cpp",
                "melonDS/src/Savestate.cpp",
                "melonDS/src/Wifi.cpp",
                "melonDS/src/WifiAP.cpp",
                "melonDS/src/dolphin/Arm64Emitter.cpp",
                "melonDS/src/dolphin/CommonFuncs.cpp",
                "melonDS/src/dolphin/MathUtil.cpp",
                "melonDS/src/frontend/qt_sdl/PlatformConfig.cpp",
                "melonDS/src/tiny-AES-c/aes.c",
                "melonDS/src/xxhash/xxhash.c",
//                "melonDS/src/GPU3D_OpenGL.cpp",
//                "melonDS/src/GPU_OpenGL.cpp",
//                "melonDS/src/OpenGLSupport.cpp",
            ],
            publicHeadersPath: "include",
            cSettings: [
//                .define("STATIC_LIBRARY", to:"1"),
                .define("JIT_ENABLED", to:"1"),
            ],
            cxxSettings: [
//                .define("STATIC_LIBRARY", to:"1"),
                .define("JIT_ENABLED", to:"1"),
            ]
        )
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx14
)
