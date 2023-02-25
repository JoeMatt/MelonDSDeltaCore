//
//  ARMJIT_Compiler.cpp
//  
//
//  Created by Joseph Mattiello on 2/25/23.
//

#if JIT_ENABLED
#include <TargetConditionals.h>

#if TARGET_CPU_ARM64
#include "../melonDS/melonDS/src/ARMJIT_A64/ARMJIT_Compiler.cpp"
#elif TARGET_CPU_X86_64
#include "../melonDS/melonDS/src/ARMJIT_x64/ARMJIT_Compiler.cpp"
#else
#endif
#endif
