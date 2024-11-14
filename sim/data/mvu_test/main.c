// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "mvu_def.h"


void write_mvu(uint32_t* mvu_csr, uint32_t value)
{
	*mvu_csr = value;
}

int main(void)
{
    printf("Hello World From RISC-V Processor!\r\n");
    
	
	printf("------------------------------------------------");
	printf("               Begin to config MVU              ");
	printf("------------------------------------------------");	
	write_mvu(mvuprecision	, (uint32_t)0x00008082		);

	write_mvu(mvuwjump_0	, (uint32_t)0x00000002		);
	write_mvu(mvuwjump_1	, (uint32_t)0x00000000		);
	write_mvu(mvuwjump_2	, (uint32_t)0x00000002		);
	write_mvu(mvuwjump_3	, (uint32_t)0x00000000		);
	write_mvu(mvuwjump_4	, (uint32_t)0x00000000		);

	write_mvu(mvuijump_0	, (uint32_t)0x00000000		);
	write_mvu(mvuijump_1	, (uint32_t)0x00000002		);
	write_mvu(mvuijump_2	, (uint32_t)0x00000000		);
	write_mvu(mvuijump_3	, (uint32_t)0x00000000		);
	write_mvu(mvuijump_4	, (uint32_t)0x00000000		);

	write_mvu(mvusjump_0	, (uint32_t)0x00000000		);
	write_mvu(mvusjump_1	, (uint32_t)0x00000000		);
	write_mvu(mvusjump_2	, (uint32_t)0x00000000		);
	write_mvu(mvusjump_3	, (uint32_t)0x00000000		);
	write_mvu(mvusjump_4	, (uint32_t)0x00000000		);
	
	write_mvu(mvubjump_0	, (uint32_t)0x00000000		);
	write_mvu(mvubjump_1	, (uint32_t)0x00000000		);
	write_mvu(mvubjump_2	, (uint32_t)0x00000000		);
	write_mvu(mvubjump_3	, (uint32_t)0x00000000		);
	write_mvu(mvubjump_4	, (uint32_t)0x00000000		);

	write_mvu(mvuojump_0	, (uint32_t)0x00000000		);
	write_mvu(mvuojump_1	, (uint32_t)0x00000000		);
	write_mvu(mvuojump_2	, (uint32_t)0x00000000		);
	write_mvu(mvuojump_3	, (uint32_t)0x00000000		);
	write_mvu(mvuojump_4	, (uint32_t)0x00000000		);

	write_mvu(mvuwlength_1	, (uint32_t)0x00000003		);
	write_mvu(mvuwlength_0	, (uint32_t)0x00000000		);
	write_mvu(mvuwlength_2	, (uint32_t)0x00000000		);
	write_mvu(mvuwlength_3	, (uint32_t)0x00000000		);
	write_mvu(mvuwlength_4	, (uint32_t)0x00000000		);

	write_mvu(mvuilength_1	, (uint32_t)0x00000000		);
	write_mvu(mvuilength_2	, (uint32_t)0x00000000		);
	write_mvu(mvuilength_3	, (uint32_t)0x00000000		);
	write_mvu(mvuilength_4	, (uint32_t)0x00000000		);

	write_mvu(mvuolength_1	, (uint32_t)0x00000000		);
	write_mvu(mvuolength_2	, (uint32_t)0x00000000		);
	write_mvu(mvuolength_3	, (uint32_t)0x00000000		);
	write_mvu(mvuolength_4	, (uint32_t)0x00000000		);

	write_mvu(mvuquant		, (uint32_t)0x00000007		);

	write_mvu(mvuwbaseptr	, (uint32_t)0x00000000		);
	write_mvu(mvuibaseptr	, (uint32_t)0x00000000		);
	write_mvu(mvuobaseptr	, (uint32_t)0x00000400		);
	write_mvu(mvuomvusel	, (uint32_t)0x00000000		);
	
	write_mvu(mvuusescaler	, (uint32_t)0x00000000		);
	write_mvu(mvuscaler		, (uint32_t)0x00000001		);
	write_mvu(mvuusebias	, (uint32_t)0x00000000		);
	
	write_mvu(mvuconfig1	, (uint32_t)0x00000301		);

	write_mvu(mvucommand	, (uint32_t)0x40000004		);

    return 0;
}

