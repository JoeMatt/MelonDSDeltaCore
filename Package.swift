// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let env: [String: Bool] = [
    "JIT_ENABLED": true,
    "JIT_COMBINED_TARGET": true,
    "MACOS_USE_OPENGL": false,
    "USE_LOCAL_DELTACORE": true,
    "USE_CXX_INTEROP": true,
    "INHIBIT_UPSTREAM_WARNINGS": true,
    "STATIC_LIBRARY": false
]

func envBool(_ key: String) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else { return env[key, default: true] }
    let trueValues = ["1", "on", "true", "yes"]
    return trueValues.contains(value.lowercased())
}

let JIT_ENABLED = envBool("JIT_ENABLED")
let JIT_COMBINED_TARGET = envBool("JIT_COMBINED_TARGET")
let MACOS_USE_OPENGL = envBool("MACOS_USE_OPENGL")
let USE_LOCAL_DELTACORE = envBool("USE_LOCAL_DELTACORE")
let USE_CXX_INTEROP = envBool("USE_CXX_INTEROP")
let INHIBIT_UPSTREAM_WARNINGS = envBool("INHIBIT_UPSTREAM_WARNINGS")
let STATIC_LIBRARY = envBool("STATIC_LIBRARY")

var JIT_COMMON_SOURCES: [String] = [
    "ARM_InstrInfo.cpp",

    "ARMJIT.cpp",
    "ARMJIT_Memory.cpp",

    "dolphin/CommonFuncs.cpp",
]

let MELON_SOURCES: [String] = [
    "ARCodeFile.cpp",
    "AREngine.cpp",
    "ARM.cpp",
    "ARMInterpreter.cpp",
    "ARMInterpreter_ALU.cpp",
    "ARMInterpreter_Branch.cpp",
    "ARMInterpreter_LoadStore.cpp",
    "CP15.cpp",
    "CRC32.cpp",
    "Config.cpp",
    "DMA.cpp",
    "DSi.cpp",
    "DSiCrypto.cpp",
    "DSi_AES.cpp",
    "DSi_Camera.cpp",
    "DSi_I2C.cpp",
    "DSi_NDMA.cpp",
    "DSi_NWifi.cpp",
    "DSi_SD.cpp",
    "DSi_SPI_TSC.cpp",
    "GBACart.cpp",
    "GPU.cpp",
    "GPU2D.cpp",
    "GPU2D_Soft.cpp",
    "GPU3D.cpp",
    "GPU3D_Soft.cpp",
    "NDS.cpp",
    "NDSCart.cpp",
    "RTC.cpp",
    "SPI.cpp",
    "SPU.cpp",
    "Savestate.cpp",
    "Wifi.cpp",
    "WifiAP.cpp",

	// Do we need headers?
//	"ARM_InstrTable.h",
//	"FIFO.h",
//	"melonDLDI.h",
//	"Platform.h",
//	"ROMList.h",
//	"types.h",
//	"version.h",
	"frontend/qt_sdl/PlatformConfig.cpp",

    "tiny-AES-c/aes.c",
    "xxhash/xxhash.c",
].map { "melonDS/src/" + $0 }

var cSettings: [CSetting] = {
	var flags: [CSetting] = [
		// Fix `register` keyword in cpp17
		.define("register", to: "")
	]
	if INHIBIT_UPSTREAM_WARNINGS {
		let inhibitWarnings: CSetting = .unsafeFlags([
			"-w",
			"-Wno-deprecated-register"
		])

		// Inhibit warnings for this target
		flags.append(inhibitWarnings)
	}
	if JIT_ENABLED { flags.append( .define("JIT_ENABLED", to: "1") )}
	if MACOS_USE_OPENGL { flags.append( .define("OGLRENDERER_ENABLED", to: "1", .when(platforms: [.macOS, .macCatalyst])) )}
	if STATIC_LIBRARY {
		flags.append( .define("STATIC_LIBRARY", to: "1") )
	} else {
		flags.append( .define("STATIC_LIBRARY", to: "1", .when(platforms: [.wasi])) )
	}
	return flags
}()

var cxxSettings: [CXXSetting] = {
	var flags: [CXXSetting] = [
		// Fix `register` keyword in cpp17
		.define("register", to: ""),
	]
	if INHIBIT_UPSTREAM_WARNINGS {
		let inhibitWarnings: CXXSetting = .unsafeFlags([
			"-w",
			"-Wno-deprecated-register"
		])

		// Inhibit warnings for this target
		flags.append(inhibitWarnings)
	}
	if JIT_ENABLED { flags.append( .define("JIT_ENABLED", to: "1") )}
	if MACOS_USE_OPENGL { flags.append( .define("OGLRENDERER_ENABLED", to: "1", .when(platforms: [.macOS, .macCatalyst])) )}
	if STATIC_LIBRARY {
		flags.append( .define("STATIC_LIBRARY", to: "1") )
	} else {
		flags.append( .define("STATIC_LIBRARY", to: "1", .when(platforms: [.wasi])) )
	}
	return flags
}()

let swiftUnsafeFlags: [SwiftSetting] = {
	var flags: [SwiftSetting] = []
	
	if USE_CXX_INTEROP {
		let useCXX: SwiftSetting = SwiftSetting.unsafeFlags(["-enable-experimental-cxx-interop"])
		flags.append(useCXX)
	}
	return flags
}()

var swiftSettings: [SwiftSetting] = {
	let flags: [SwiftSetting] = swiftUnsafeFlags + [
		.define("STATIC_LIBRARY", .when(platforms: [.wasi]))
	]
	return flags
}()

var melonDS_dependencies: [Target.Dependency] = []

if JIT_ENABLED {
    if JIT_COMBINED_TARGET {
        melonDS_dependencies.append("melonDS-JIT")
		let additionalSources: [String] = [
			"JIT/ARMJIT_ALU.cpp",
			"JIT/ARMJIT_Branch.cpp",
			"JIT/ARMJIT_Compiler.cpp",
			"JIT/ARMJIT_Linkage.S",
			"JIT/ARMJIT_LoadStore.cpp",
			"JIT/ARMJIT_GenOffsets.cpp",

			"dolphin/Arm64Emitter.cpp", //ARM
			"dolphin/MathUtil.cpp",	// ARM

			"dolphin/x64ABI.cpp", // INTEL
			"dolphin/x64Emitter.cpp", // INTEL
			"dolphin/x64CPUDetect.cpp", // INTEL
		]
		JIT_COMMON_SOURCES = JIT_COMMON_SOURCES + additionalSources
    } else {
        let a64: Target.Dependency = .targetItem(name: "melonDS-ARMJIT_A64",
												 condition: .when(platforms: [.iOS, .tvOS, .watchOS]))
		melonDS_dependencies.append(a64)

        let x64: Target.Dependency = .targetItem(name: "melonDS-ARMJIT_x64",
                                                 condition: .when(platforms: [.macOS, .macCatalyst]))
		melonDS_dependencies.append(x64)
    }
}

if MACOS_USE_OPENGL {
    melonDS_dependencies.append(
        .targetItem(name: "melonDS-OpenGL",
                    condition: .when(platforms: [.macOS, .macCatalyst]))
    )
}

let JIT_COMMON_CSETTINGS: [CSetting] = cSettings + {
	let combined: [CSetting] = [
		.headerSearchPath("./"),
		.headerSearchPath("../melonDS/include"),
		.headerSearchPath("../melonDS/melonDS/src"),
		.headerSearchPath("../melonDS/melonDS/src/dolphin")
	]
	let seperate: [CSetting] = [
		// We're in the "Sources/melonDS/melonDS/src" dir
		.headerSearchPath("./"),
		.headerSearchPath("../melonDS/melonDS/src/dolphin"),
		.headerSearchPath("../include")
	]
	return JIT_COMBINED_TARGET ? combined : seperate
}()

let JIT_COMMON_CXXSETTINGS: [CXXSetting] = cxxSettings + {
	return {
		let combined: [CXXSetting] = [
			.headerSearchPath("./"),
			.headerSearchPath("../melonDS/include"),
			.headerSearchPath("../melonDS/melonDS/src"),
			.headerSearchPath("../melonDS/melonDS/src/dolphin")
		]
		let seperate: [CXXSetting] = [
			// We're in the "Sources/melonDS/melonDS/src" dir
			.headerSearchPath("./"),
			.headerSearchPath("../melonDS/melonDS/src/dolphin"),
			.headerSearchPath("../include")
		]
		return JIT_COMBINED_TARGET ? combined : seperate
	}()
}()

let packageDependencies: [Package.Dependency]
if USE_LOCAL_DELTACORE {
    packageDependencies = [
        .package(path: "../DeltaCore")
    ]
} else {
	packageDependencies = [
        .package(url: "https://github.com/rileytestut/DeltaCore.git", branch: "main")
    ]
}

let swiftTargets: [Target] = [

      // MARK: MelonDSSwift

        .target(
            name: "MelonDSSwift",
            dependencies: ["DeltaCore"]
        ),

        // MARK: MelonDSBridge

        .target(
            name: "MelonDSBridge",
            dependencies: ["DeltaCore", "melonDS", "MelonDSSwift"],
            publicHeadersPath: "",
            cSettings: cSettings + [
                .headerSearchPath("../melonDS/include"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    
                    "-ftree-vectorize",
                    "-fexceptions",
                ]),
            ],
            cxxSettings: cxxSettings + [
                .headerSearchPath("../melonDS/include"),
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",

                    "-ftree-vectorize",
                    "-fexceptions",
                ]),
            ],
            swiftSettings: swiftSettings + [
                .unsafeFlags([
                    "-I", "../melonDS/include/",
                    "-I", "../melonDS/melonDS/src/"
                ]),
            ]
        ),

        // MARK: MelonDSDeltaCore

        .target(
            name: "MelonDSDeltaCore",
            dependencies: ["DeltaCore", "melonDS", "MelonDSSwift", "MelonDSBridge"],
            exclude: [
                "info.json",
                "ipad_landscape.png",
                "ipad_portrait.png",
                "ipad_splitview_landscape.pdf",
                "ipad_splitview_portrait.png",
                "iphone_edgetoedge_landscape.pdf",
                "iphone_edgetoedge_portrait.pdf",
                "iphone_landscape.pdf",
                "iphone_portrait.pdf",
            ].map { "Resources/Controller Skin/\($0)" },
            resources: [
                .copy("Resources/Controller Skin/Standard.deltaskin"),
                .copy("Resources/Standard.deltamapping"),
            ],
            cSettings: cSettings + [
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions",
                ]),
            ],
            cxxSettings: cxxSettings + [
                .unsafeFlags([
                    "-fmodules",
                    "-fcxx-modules",
                    "-ftree-vectorize",
                    "-fexceptions",
                ]),
            ],
            swiftSettings: swiftSettings + [
                .unsafeFlags([
                    "-I", "../melonDS/include/",
                    "-I", "../melonDS/melonDS/src/"
                ]),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation", .when(platforms: [.iOS, .tvOS, .macCatalyst])),
            ]
        )
]

var targets: [Target] = swiftTargets

if JIT_ENABLED {
    let jitCommonTarget: Target
    if JIT_COMBINED_TARGET {
        // MARK: JIT Common
        jitCommonTarget = .target(
            name: "melonDS-JIT",
            sources: JIT_COMMON_SOURCES,
            cSettings: JIT_COMMON_CSETTINGS,
            cxxSettings: JIT_COMMON_CXXSETTINGS,
            swiftSettings: swiftSettings
        )
    } else { 
        // -- Not combined --

        // MARK: JIT Common
        jitCommonTarget = .target(
            name: "melonDS-JIT",
            path: "Sources/melonDS/melonDS/src/",
            sources: JIT_COMMON_SOURCES,
            cSettings: JIT_COMMON_CSETTINGS,
            cxxSettings: JIT_COMMON_CXXSETTINGS,
            swiftSettings: swiftSettings
        )

        // MARK: X64 JIT 
        let jit_X64Target: Target = .target(
            name: "melonDS-ARMJIT_x64",
            dependencies: ["melonDS-JIT"],
			path: "Sources/melonDS/melonDS/src/",
            sources: [
                "dolphin/x64ABI.cpp",
                "dolphin/x64CPUDetect.cpp",
                "dolphin/x64Emitter.cpp",
                "dolphin/MathUtil.cpp",

                "ARMJIT_x64/ARMJIT_Compiler.cpp",
                "ARMJIT_x64/ARMJIT_ALU.cpp",
                "ARMJIT_x64/ARMJIT_LoadStore.cpp",
                "ARMJIT_x64/ARMJIT_Branch.cpp",

                "ARMJIT_x64/ARMJIT_Linkage.S",
            ],
            publicHeadersPath: "ARMJIT_x64/",
            cSettings: cSettings + [
                .unsafeFlags(["-m64"]),
            ],
            cxxSettings: cxxSettings + [
                .headerSearchPath("./"),
                .headerSearchPath("../include"),
				.headerSearchPath("./ARMJIT_A64"),
                .unsafeFlags(["-m64"]),
            ],
            swiftSettings: swiftSettings
        )
        targets.append(jit_X64Target)

        // MARK: ARM64 JIT 
        let jit_A64Target: Target = .target(
            name: "melonDS-ARMJIT_A64",
			dependencies: ["melonDS-JIT"],
            path: "Sources/melonDS/melonDS/src/",
            sources: [
                "dolphin/Arm64Emitter.cpp",
                "dolphin/MathUtil.cpp",
                "dolphin/Arm64ABI.cpp",

                "ARMJIT_A64/ARMJIT_Compiler.cpp",
                "ARMJIT_A64/ARMJIT_ALU.cpp",
                "ARMJIT_A64/ARMJIT_LoadStore.cpp",
                "ARMJIT_A64/ARMJIT_Branch.cpp",

                "ARMJIT_A64/ARMJIT_Linkage.S",
            ],
            publicHeadersPath: "ARMJIT_A64/",
            cSettings: cSettings + [
				.headerSearchPath("./"),
                .headerSearchPath("../include"),
				.headerSearchPath("./ARMJIT_A64"),
            ],
            cxxSettings: cxxSettings + [
				.headerSearchPath("./"),
                .headerSearchPath("../include"),
				.headerSearchPath("./ARMJIT_A64"),
            ]
        )
        targets.append(jit_A64Target)
    }
    targets.append(jitCommonTarget)
}

if MACOS_USE_OPENGL {
            // // MARK: macOS OpenGL
    let macosOpenGLTarget: Target = .target(
            name: "melonDS-OpenGL",
            path: "Sources/melonDS/melonDS/src/",
            sources: [
                "GPU3D_OpenGL.cpp",
                "GPU_OpenGL.cpp",
                "OpenGLSupport.cpp",
            ],
            publicHeadersPath: "",
            cSettings: cSettings + [
                .headerSearchPath("./"),
                .headerSearchPath("./xxhash"),
				.headerSearchPath("../include"),
            ],
            cxxSettings: cxxSettings + [
                .headerSearchPath("./"),
                .headerSearchPath("./xxhash"),
				.headerSearchPath("../include"),
            ]
        )
    targets.append(macosOpenGLTarget)
}

	// // MARK: - melonDS
let melonDS_Target: Target = {
	let exclude: [String] = [
		"cmake/",
		"flatpak/",
		"icon/",
		"CMakeLists.txt",
		"LICENSE",
		"melon_grc.xml",
		"melon.ico",
		"melon.qrc",
		"melon.rc",
		"melonDS.icns",
		"melonDS.plist",
		"msys-dist.sh",
		"README.md",
		"net.kuribo64.melonDS.desktop",
		"xp.manifest",
		"src/frontend/qt_sdl/pcap/",
	].map { "melonDS/\($0)" } // Add diretory prefix

    return .target(
            name: "melonDS",
            dependencies: melonDS_dependencies,
            exclude: exclude,
            sources: MELON_SOURCES,
            publicHeadersPath: "include",
            cSettings: cSettings + [
                .headerSearchPath("./melonDS"),
                .headerSearchPath("./melonDS/xxhash"),
                .headerSearchPath("./melonDS/include"),
            ],
            cxxSettings: cxxSettings + [
				.headerSearchPath("./melonDS"),
				.headerSearchPath("./melonDS/xxhash"),
				.headerSearchPath("./melonDS/include"),
            ]
        )
}()
targets.append(melonDS_Target)

let package = Package(
    name: "MelonDSDeltaCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
        .macOS(.v12),
        .tvOS(.v12),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "MelonDSDeltaCore",
            targets: ["MelonDSDeltaCore"]
        ),
        .library(
            name: "MelonDSDeltaCore-Static",
            type: .static,
            targets: ["MelonDSDeltaCore"]
        ),
        .library(
            name: "MelonDSDeltaCore-Dynamic",
            type: .dynamic,
            targets: ["MelonDSDeltaCore"]
        )
	],
    dependencies: packageDependencies,
    targets: targets,
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .c11, // From melon's makefile
    cxxLanguageStandard: .cxx17 // From melon's makefile
)
