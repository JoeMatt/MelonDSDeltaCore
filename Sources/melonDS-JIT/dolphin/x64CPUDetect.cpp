//
//  x64CPUDetect.cpp
//  
//
//  Created by Joseph Mattiello on 2/25/23.
//

#if JIT_ENABLED
	#include <TargetConditionals.h>

	#if TARGET_CPU_ARM64
		// DO NOTHING
	#elif TARGET_CPU_X86_64
		#include "../../melonDS/melonDS/src/dolphin/x64CPUDetect.cpp"
	#else
		#error "Unsupported CPU type"
	#endif
#endif
