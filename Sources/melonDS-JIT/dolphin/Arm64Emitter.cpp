//
//  Arm64Emitter.cpp
//  
//
//  Created by Joseph Mattiello on 2/25/23.
//

#if JIT_ENABLED
	#include <TargetConditionals.h>

	#if TARGET_CPU_ARM64
		#include "../../melonDS/melonDS/src/dolphin/Arm64Emitter.cpp"
	#elif TARGET_CPU_X86_64
		// DO NOTHING
	#else
		#error "Unsupported CPU type"
	#endif
#endif
