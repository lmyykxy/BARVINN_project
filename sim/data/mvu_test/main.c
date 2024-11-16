// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "mvu_def.h"

volatile int mvu_irq_flag;
volatile int dma_irq_flag;

void write_mvu(volatile uint32_t* mvu_csr, uint32_t value)
{
	*mvu_csr = value;
}

void write_dma(volatile uint32_t* dma_reg, uint32_t value)
{
	*dma_reg = value;
}

void delay_loop(unsigned long iterations) {
    while (iterations--);
}

void plic_mvu_handler(void)
{
    mvu_irq_flag = 1;
	printf("Trigger MVU IRQ!!!!\r\n");
}

void plic_dma_handler(void)
{
    dma_irq_flag = 1;
	printf("Trigger DMA IRQ!!!!\r\n");
}

int main(void)
{
    printf("Hello World From RISC-V Processor!\r\n");

    printf("Begin to config IRQ\r\n");
	dma_irq_flag = 0;
	mvu_irq_flag = 0;
	int32_t returnCode = PLIC_Register_IRQ(PLIC_MVU0_IRQn, 1, plic_mvu_handler);
	printf("mvu irq_ret_code:%d\r\n",returnCode);
	returnCode = PLIC_Register_IRQ(PLIC_DMA_IRQn, 1, plic_dma_handler);
	printf("dma irq_ret_code:%d\r\n",returnCode);
	__enable_irq();

	printf("------------------------------------------------\r\n");
	printf("               Begin to move data               \r\n");
	printf("------------------------------------------------\r\n");

    write_dma(dma_source_addr	, (uint32_t)0x00000000		);
    write_dma(dma_dest_addr		, (uint32_t)0x00000000		);
    write_dma(dma_info_addr		, (uint32_t)0x000000ff		);
    write_dma(dma_start_addr	, (uint32_t)0x00000001		);
	while(dma_irq_flag == 0);
	printf("next\r\n");
	dma_irq_flag = 0;

    write_dma(dma_source_addr	, (uint32_t)0x00000100		);
    write_dma(dma_dest_addr		, (uint32_t)0x00000000		);
    write_dma(dma_info_addr		, (uint32_t)0x00010001		);
    write_dma(dma_start_addr	, (uint32_t)0x00000001		);

	while(dma_irq_flag == 0);
	dma_irq_flag = 0;

	printf("------------------------------------------------\r\n");
	printf("               Begin to config MVU              \r\n");
	printf("------------------------------------------------\r\n");	
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

	for (uint32_t i = 0; i < 63; i++)
	{
		while(mvu_irq_flag == 0);
		mvu_irq_flag = 0;
		write_mvu(mvuobaseptr	, (uint32_t)(0x00000400+8*(i+1))		);
		write_mvu(mvuibaseptr	, (uint32_t)(0x00000000+2*(i+1))		);
		write_mvu(mvucommand	, (uint32_t)0x40000004		);
		printf("Start iter:%d",i+1);
	}
	
	while(mvu_irq_flag == 0);
	mvu_irq_flag = 0;
	
	printf("Program finish!!!!\r\n");

    return 0;
}

