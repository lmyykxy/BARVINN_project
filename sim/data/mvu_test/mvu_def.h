#ifndef __MVU_DEF_H__
#define __MVU_DEF_H__

#define mvuwbaseptr   (uint32_t*)0x1210F200 // Base address for weight memory
#define mvuibaseptr   (uint32_t*)0x1210F210 // Base address for input memory
#define mvusbaseptr   (uint32_t*)0x1210F220 // Base address for scaler memory (6 bits)
#define mvubbaseptr   (uint32_t*)0x1210F230 // Base address for bias memory (6 bits)
#define mvuobaseptr   (uint32_t*)0x1210F240 // Output base address
#define mvuwjump_0    (uint32_t*)0x1210F250 // Weight address jumps in loops 0
#define mvuwjump_1    (uint32_t*)0x1210F260 // Weight address jumps in loops 1
#define mvuwjump_2    (uint32_t*)0x1210F270 // Weight address jumps in loops 2
#define mvuwjump_3    (uint32_t*)0x1210F280 // Weight address jumps in loops 3
#define mvuwjump_4    (uint32_t*)0x1210F290 // Weight address jumps in loops 4
#define mvuijump_0    (uint32_t*)0x1210F2A0 // Input data address jumps in loops 0
#define mvuijump_1    (uint32_t*)0x1210F2B0 // Input data address jumps in loops 1
#define mvuijump_2    (uint32_t*)0x1210F2C0 // Input data address jumps in loops 2
#define mvuijump_3    (uint32_t*)0x1210F2D0 // Input data address jumps in loops 3
#define mvuijump_4    (uint32_t*)0x1210F2E0 // Input data address jumps in loops 4
#define mvusjump_0    (uint32_t*)0x1210F2F0 // Scaler memory address jumps (6 bits)
#define mvusjump_1    (uint32_t*)0x1210F300 // Scaler memory address jumps (6 bits)
#define mvusjump_2    (uint32_t*)0x1210F310 // Scaler memory address jumps (6 bits)
#define mvusjump_3    (uint32_t*)0x1210F320 // Scaler memory address jumps (6 bits)
#define mvusjump_4    (uint32_t*)0x1210F330 // Scaler memory address jumps (6 bits)
#define mvubjump_0    (uint32_t*)0x1210F340 // Bias memory address jumps (6 bits)
#define mvubjump_1    (uint32_t*)0x1210F350 // Bias memory address jumps (6 bits)
#define mvubjump_2    (uint32_t*)0x1210F360 // Bias memory address jumps (6 bits)
#define mvubjump_3    (uint32_t*)0x1210F370 // Bias memory address jumps (6 bits)
#define mvubjump_4    (uint32_t*)0x1210F380 // Bias memory address jumps (6 bits)
#define mvuojump_0    (uint32_t*)0x1210F390 // Output data address jumps in loops 0
#define mvuojump_1    (uint32_t*)0x1210F3a0 // Output data address jumps in loops 1
#define mvuojump_2    (uint32_t*)0x1210F3b0 // Output data address jumps in loops 2
#define mvuojump_3    (uint32_t*)0x1210F3c0 // Output data address jumps in loops 3
#define mvuojump_4    (uint32_t*)0x1210F3d0 // Output data address jumps in loops 4
#define mvuwlength_0  (uint32_t*)0x1210F3e0 // Weight length in loops 0
#define mvuwlength_1  (uint32_t*)0x1210F3f0 // Weight length in loops 1
#define mvuwlength_2  (uint32_t*)0x1210F400 // Weight length in loops 2
#define mvuwlength_3  (uint32_t*)0x1210F410 // Weight length in loops 3
#define mvuwlength_4  (uint32_t*)0x1210F420 // Weight length in loops 4
#define mvuilength_1  (uint32_t*)0x1210F430 // Input data length in loops 0
#define mvuilength_2  (uint32_t*)0x1210F440 // Input data length in loops 1
#define mvuilength_3  (uint32_t*)0x1210F450 // Input data length in loops 2
#define mvuilength_4  (uint32_t*)0x1210F460 // Input data length in loops 3
#define mvuslength_1  (uint32_t*)0x1210F470 // Scaler tensor length 15 bits
#define mvuslength_2  (uint32_t*)0x1210F480 // Scaler tensor length 15 bits
#define mvuslength_3  (uint32_t*)0x1210F490 // Scaler tensor length 15 bits
#define mvuslength_4  (uint32_t*)0x1210F4a0 // Scaler tensor length 15 bits
#define mvublength_1  (uint32_t*)0x1210F4b0 // Bias tensor length 15 bits
#define mvublength_2  (uint32_t*)0x1210F4c0 // Bias tensor length 15 bits
#define mvublength_3  (uint32_t*)0x1210F4d0 // Bias tensor length 15 bits
#define mvublength_4  (uint32_t*)0x1210F4e0 // Bias tensor length 15 bits
#define mvuolength_1  (uint32_t*)0x1210F4f0 // Output data length in loops 0
#define mvuolength_2  (uint32_t*)0x1210F500 // Output data length in loops 1
#define mvuolength_3  (uint32_t*)0x1210F510 // Output data length in loops 2
#define mvuolength_4  (uint32_t*)0x1210F520 // Output data length in loops 3
#define mvuprecision  (uint32_t*)0x1210F530 // Precision in bits for all tensors
#define mvustatus     (uint32_t*)0x1210F540 // Status of MVU
#define mvucommand    (uint32_t*)0x1210F550 // Kick to send command.
#define mvuquant      (uint32_t*)0x1210F560 // MSB index position
#define mvuscaler     (uint32_t*)0x1210F570 // fixed point operand for multiplicative scaling
#define mvuconfig1    (uint32_t*)0x1210F580 //Shift/accumulator load on jump select (only 0-4 valid) Pool/Activation clear on jump select (only 0-4 valid)
#define mvuomvusel    (uint32_t*)0x1210F590 //outmvu
#define mvuusescaler  (uint32_t*)0x1210F660 //use scaler
#define mvuusebias    (uint32_t*)0x1210F670 //use bias


#endif