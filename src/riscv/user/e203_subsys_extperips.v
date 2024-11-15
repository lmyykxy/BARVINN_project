 /*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Seven Lai
//
// Description:
//  User extend peirpheral bus and the connected devices 
//
// ====================================================================

`include "e203_defines.v"


module e203_subsys_extperips(
  input                          extppi_icb_cmd_valid,
  output                         extppi_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   extppi_icb_cmd_addr, 
  input                          extppi_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        extppi_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      extppi_icb_cmd_wmask,
  //
  output                         extppi_icb_rsp_valid,
  input                          extppi_icb_rsp_ready,
  output                         extppi_icb_rsp_err,
  output [`E203_XLEN-1:0]        extppi_icb_rsp_rdata,

  output                         dma_icb_cmd_valid,
  input                          dma_icb_cmd_ready,
  output  [`E203_ADDR_SIZE-1:0]  dma_icb_cmd_addr, 
  output                         dma_icb_cmd_read, 
  output  [`E203_XLEN-1:0]       dma_icb_cmd_wdata,
  output  [`E203_XLEN/8-1:0]     dma_icb_cmd_wmask,
  //
  input                          dma_icb_rsp_valid,
  output                         dma_icb_rsp_ready,
  input                          dma_icb_rsp_err,
  input [`E203_XLEN-1:0]         dma_icb_rsp_rdata,

  output [32-1:0]                mvu_apb_paddr,  
  output                         mvu_apb_pwrite, 
  output                         mvu_apb_pselx,  
  output                         mvu_apb_penable,
  output [32-1:0]                mvu_apb_pwdata, 
  input  [32-1:0]                mvu_apb_prdata, 

  input  clk,
  input  bus_rst_n,
  input  rst_n
  );

  wire                     exttest_icb_cmd_valid;
  wire                     exttest_icb_cmd_ready;
  wire [32-1:0]            exttest_icb_cmd_addr; 
  wire                     exttest_icb_cmd_read; 
  wire [32-1:0]            exttest_icb_cmd_wdata;
  wire [4 -1:0]            exttest_icb_cmd_wmask;

  wire                     exttest_icb_rsp_valid;
  wire                     exttest_icb_rsp_ready;
  wire [32-1:0]            exttest_icb_rsp_rdata;
  wire                     exttest_icb_rsp_err;

  wire                     mvu_icb_cmd_valid;
  wire                     mvu_icb_cmd_ready;
  wire [32-1:0]            mvu_icb_cmd_addr; 
  wire                     mvu_icb_cmd_read; 
  wire [32-1:0]            mvu_icb_cmd_wdata;
  wire [4 -1:0]            mvu_icb_cmd_wmask;

  wire                     mvu_icb_rsp_valid;
  wire                     mvu_icb_rsp_ready;
  wire [32-1:0]            mvu_icb_rsp_rdata;
  wire                     mvu_icb_rsp_err;


  // The total address range for the EXTPPI is from/to
  //  **************0x1200 0000 -- 0x19FF FFFF
  // There are several slaves for EXTPPI bus, including:
  //  * TEST                : 0x1200 0000 -- 0x120F FFFF
  //  * MVU			        : 0x1210 0000 -- 0x121F FFFF
  //  * DMA         		: 0x1220 0000 -- 0x122F FFFF
  //  * Preserved 3         : 0x1230 0000 -- 0x123F FFFF
  //  * Preserved 4         : 0x1240 0000 -- 0x124F FFFF
  //  * Preserved 5         : 0x1250 0000 -- 0x125F FFFF
  //  * Preserved 6         : 0x1260 0000 -- 0x126F FFFF
  //  * Preserved 7         : 0x1270 0000 -- 0x127F FFFF
  //  * Preserved 8         : 0x1280 0000 -- 0x128F FFFF
  //  * Preserved 9         : 0x1290 0000 -- 0x129F FFFF
  //  * Preserved 10        : 0x12A0 0000 -- 0x12AF FFFF
  //  * Preserved 11        : 0x12B0 0000 -- 0x12BF FFFF
  //  * Preserved 12        : 0x12C0 0000 -- 0x12CF FFFF
  //  * Preserved 13        : 0x12D0 0000 -- 0x12DF FFFF
  //  * Preserved 14        : 0x12E0 0000 -- 0x12EF FFFF
  //  * Preserved 15        : 0x12F0 0000 -- 0x12FF FFFF


  sirv_icb1to16_bus # (
  .ICB_FIFO_DP        (2),// We add a ping-pong buffer here to cut down the timing path
  .ICB_FIFO_CUT_READY (1),// We configure it to cut down the back-pressure ready signal

  .AW                   (32),
  .DW                   (`E203_XLEN),
  .SPLT_FIFO_OUTS_NUM   (1),// The peirpherals only allow 1 oustanding
  .SPLT_FIFO_CUT_READY  (1),// The peirpherals always cut ready
  //  * EXTTEST     : 0x1200 0000 -- 0x120F FFFF
  .O0_BASE_ADDR       (32'h1200_0000),       
  .O0_BASE_REGION_LSB (20),
  //  * MVU			: 0x1210 0000 -- 0x121F FFFF
  .O1_BASE_ADDR       (32'h1210_0000),       
  .O1_BASE_REGION_LSB (20),
  //  DMA			: 0x1220 0000 -- 0x122F FFFF
  .O2_BASE_ADDR       (32'h1220_0000),       
  .O2_BASE_REGION_LSB (20),
  //  * Preserved 3 : 0x1230 0000 -- 0x123F FFFF
  .O3_BASE_ADDR       (32'h1230_0000),       
  .O3_BASE_REGION_LSB (20),
  //  * Preserved 4 : 0x1240 0000 -- 0x124F FFFF
  .O4_BASE_ADDR       (32'h1240_0000),       
  .O4_BASE_REGION_LSB (20),
  //  * Preserved 5 : 0x1250 0000 -- 0x125F FFFF
  .O5_BASE_ADDR       (32'h1250_0000),       
  .O5_BASE_REGION_LSB (20),
  //  * Preserved 6 : 0x1260 0000 -- 0x126F FFFF
  .O6_BASE_ADDR       (32'h1260_0000),       
  .O6_BASE_REGION_LSB (20),
  //  * Preserved 7 : 0x1270 0000 -- 0x127F FFFF
  .O7_BASE_ADDR       (32'h1270_0000),       
  .O7_BASE_REGION_LSB (20),
  //  * Preserved 8 : 0x1280 0000 -- 0x128F FFFF
  .O8_BASE_ADDR       (32'h1280_0000),       
  .O8_BASE_REGION_LSB (20),
  //  * Preserved 9 : 0x1290 0000 -- 0x129F FFFF
  .O9_BASE_ADDR       (32'h1290_0000),       
  .O9_BASE_REGION_LSB (20),
  //  * Preserved 10 : 0x12A0 0000 -- 0x12AF FFFF
  .O10_BASE_ADDR       (32'h12A0_0000),       
  .O10_BASE_REGION_LSB (20),
  //  * Preserved 11 : 0x12B0 0000 -- 0x12BF FFFF
  .O11_BASE_ADDR       (32'h12B0_0000),       
  .O11_BASE_REGION_LSB (20),
  //  * Preserved 12 : 0x12C0 0000 -- 0x12CF FFFF
  .O12_BASE_ADDR       (32'h12C0_0000),       
  .O12_BASE_REGION_LSB (20),
  //  * Preserved 13 : 0x12D0 0000 -- 0x12DF FFFF
  .O13_BASE_ADDR       (32'h12D0_0000),       
  .O13_BASE_REGION_LSB (20),
  //  * Preserved 14 : 0x12E0 0000 -- 0x12EF FFFF
  .O14_BASE_ADDR       (32'h12E0_0000),       
  .O14_BASE_REGION_LSB (20),
  //  * Preserved 15 : 0x12F0 0000 -- 0x12FF FFFF
  .O15_BASE_ADDR       (32'h12F0_0000),       
  .O15_BASE_REGION_LSB (20)

  )u_sirv_extppi_fab(

    .i_icb_cmd_valid  (extppi_icb_cmd_valid),
    .i_icb_cmd_ready  (extppi_icb_cmd_ready),
    .i_icb_cmd_addr   (extppi_icb_cmd_addr ),
    .i_icb_cmd_read   (extppi_icb_cmd_read ),
    .i_icb_cmd_wdata  (extppi_icb_cmd_wdata),
    .i_icb_cmd_wmask  (extppi_icb_cmd_wmask),
    .i_icb_cmd_lock   (1'b0),
    .i_icb_cmd_excl   (1'b0 ),
    .i_icb_cmd_size   (2'b0 ),
    .i_icb_cmd_burst  (2'b0 ),
    .i_icb_cmd_beat   (2'b0 ),
    
    .i_icb_rsp_valid  (extppi_icb_rsp_valid),
    .i_icb_rsp_ready  (extppi_icb_rsp_ready),
    .i_icb_rsp_err    (extppi_icb_rsp_err  ),
    .i_icb_rsp_excl_ok(),
    .i_icb_rsp_rdata  (extppi_icb_rsp_rdata),
    
  //  * TEST    
    .o0_icb_enable     (1'b1),

    .o0_icb_cmd_valid  (exttest_icb_cmd_valid),
    .o0_icb_cmd_ready  (exttest_icb_cmd_ready),
    .o0_icb_cmd_addr   (exttest_icb_cmd_addr),
    .o0_icb_cmd_read   (exttest_icb_cmd_read),
    .o0_icb_cmd_wdata  (exttest_icb_cmd_wdata),
    .o0_icb_cmd_wmask  (exttest_icb_cmd_wmask),
    .o0_icb_cmd_lock   (),
    .o0_icb_cmd_excl   (),
    .o0_icb_cmd_size   (),
    .o0_icb_cmd_burst  (),
    .o0_icb_cmd_beat   (),
    
    .o0_icb_rsp_valid  (exttest_icb_rsp_valid),
    .o0_icb_rsp_ready  (exttest_icb_rsp_ready),
    .o0_icb_rsp_err    (exttest_icb_rsp_err),
    .o0_icb_rsp_excl_ok(1'b0),
    .o0_icb_rsp_rdata  (exttest_icb_rsp_rdata),

  // MVU
    .o1_icb_enable     (1'b1),

    .o1_icb_cmd_valid  (mvu_icb_cmd_valid),
    .o1_icb_cmd_ready  (mvu_icb_cmd_ready),
    .o1_icb_cmd_addr   (mvu_icb_cmd_addr),
    .o1_icb_cmd_read   (mvu_icb_cmd_read),
    .o1_icb_cmd_wdata  (mvu_icb_cmd_wdata),
    .o1_icb_cmd_wmask  (mvu_icb_cmd_wmask),
    .o1_icb_cmd_lock   (),
    .o1_icb_cmd_excl   (),
    .o1_icb_cmd_size   (),
    .o1_icb_cmd_burst  (),
    .o1_icb_cmd_beat   (),
    
    .o1_icb_rsp_valid  (mvu_icb_rsp_valid),
    .o1_icb_rsp_ready  (mvu_icb_rsp_ready),
    .o1_icb_rsp_err    (mvu_icb_rsp_err),
    .o1_icb_rsp_excl_ok(1'b0),
    .o1_icb_rsp_rdata  (mvu_icb_rsp_rdata),


  //  DMA    
    .o2_icb_enable     (1'b1),

    .o2_icb_cmd_valid  (dma_icb_cmd_valid),
    .o2_icb_cmd_ready  (dma_icb_cmd_ready),
    .o2_icb_cmd_addr   (dma_icb_cmd_addr),
    .o2_icb_cmd_read   (dma_icb_cmd_read),
    .o2_icb_cmd_wdata  (dma_icb_cmd_wdata),
    .o2_icb_cmd_wmask  (dma_icb_cmd_wmask),
    .o2_icb_cmd_lock   (),
    .o2_icb_cmd_excl   (),
    .o2_icb_cmd_size   (),
    .o2_icb_cmd_burst  (),
    .o2_icb_cmd_beat   (),
    
    .o2_icb_rsp_valid  (dma_icb_rsp_valid),
    .o2_icb_rsp_ready  (dma_icb_rsp_ready),
    .o2_icb_rsp_err    (dma_icb_rsp_err),
    .o2_icb_rsp_excl_ok(1'b0),
    .o2_icb_rsp_rdata  (dma_icb_rsp_rdata),

  //  * Preserved 3     
    .o3_icb_enable     (1'b0),

    .o3_icb_cmd_valid  (),
    .o3_icb_cmd_ready  (1'b0),
    .o3_icb_cmd_addr   (),
    .o3_icb_cmd_read   (),
    .o3_icb_cmd_wdata  (),
    .o3_icb_cmd_wmask  (),
    .o3_icb_cmd_lock   (),
    .o3_icb_cmd_excl   (),
    .o3_icb_cmd_size   (),
    .o3_icb_cmd_burst  (),
    .o3_icb_cmd_beat   (),
    
    .o3_icb_rsp_valid  (1'b0),
    .o3_icb_rsp_ready  (),
    .o3_icb_rsp_err    (1'b0),
    .o3_icb_rsp_excl_ok(1'b0),
    .o3_icb_rsp_rdata  (32'b0),

  //  * Preserved 4     
    .o4_icb_enable     (1'b0),

    .o4_icb_cmd_valid  (),
    .o4_icb_cmd_ready  (1'b0),
    .o4_icb_cmd_addr   (),
    .o4_icb_cmd_read   (),
    .o4_icb_cmd_wdata  (),
    .o4_icb_cmd_wmask  (),
    .o4_icb_cmd_lock   (),
    .o4_icb_cmd_excl   (),
    .o4_icb_cmd_size   (),
    .o4_icb_cmd_burst  (),
    .o4_icb_cmd_beat   (),
    
    .o4_icb_rsp_valid  (1'b0),
    .o4_icb_rsp_ready  (),
    .o4_icb_rsp_err    (1'b0),
    .o4_icb_rsp_excl_ok(1'b0),
    .o4_icb_rsp_rdata  (32'b0),


  //  * Preserved 5      
    .o5_icb_enable     (1'b0),

    .o5_icb_cmd_valid  (),
    .o5_icb_cmd_ready  (1'b0),
    .o5_icb_cmd_addr   (),
    .o5_icb_cmd_read   (),
    .o5_icb_cmd_wdata  (),
    .o5_icb_cmd_wmask  (),
    .o5_icb_cmd_lock   (),
    .o5_icb_cmd_excl   (),
    .o5_icb_cmd_size   (),
    .o5_icb_cmd_burst  (),
    .o5_icb_cmd_beat   (),
    
    .o5_icb_rsp_valid  (1'b0),
    .o5_icb_rsp_ready  (),
    .o5_icb_rsp_err    (1'b0),
    .o5_icb_rsp_excl_ok(1'b0),
    .o5_icb_rsp_rdata  (32'b0),

  //  * Preserved 6     
    .o6_icb_enable     (1'b0),

    .o6_icb_cmd_valid  (),
    .o6_icb_cmd_ready  (1'b0),
    .o6_icb_cmd_addr   (),
    .o6_icb_cmd_read   (),
    .o6_icb_cmd_wdata  (),
    .o6_icb_cmd_wmask  (),
    .o6_icb_cmd_lock   (),
    .o6_icb_cmd_excl   (),
    .o6_icb_cmd_size   (),
    .o6_icb_cmd_burst  (),
    .o6_icb_cmd_beat   (),
    
    .o6_icb_rsp_valid  (1'b0),
    .o6_icb_rsp_ready  (),
    .o6_icb_rsp_err    (1'b0),
    .o6_icb_rsp_excl_ok(1'b0),
    .o6_icb_rsp_rdata  (32'b0),

  //  * Preserved 7    
    .o7_icb_enable     (1'b0),

    .o7_icb_cmd_valid  (),
    .o7_icb_cmd_ready  (1'b0),
    .o7_icb_cmd_addr   (),
    .o7_icb_cmd_read   (),
    .o7_icb_cmd_wdata  (),
    .o7_icb_cmd_wmask  (),
    .o7_icb_cmd_lock   (),
    .o7_icb_cmd_excl   (),
    .o7_icb_cmd_size   (),
    .o7_icb_cmd_burst  (),
    .o7_icb_cmd_beat   (),
    
    .o7_icb_rsp_valid  (1'b0),
    .o7_icb_rsp_ready  (),
    .o7_icb_rsp_err    (1'b0),
    .o7_icb_rsp_excl_ok(1'b0),
    .o7_icb_rsp_rdata  (32'b0),

  //  * Preserved 8    
    .o8_icb_enable     (1'b0),

    .o8_icb_cmd_valid  (),
    .o8_icb_cmd_ready  (1'b0),
    .o8_icb_cmd_addr   (),
    .o8_icb_cmd_read   (),
    .o8_icb_cmd_wdata  (),
    .o8_icb_cmd_wmask  (),
    .o8_icb_cmd_lock   (),
    .o8_icb_cmd_excl   (),
    .o8_icb_cmd_size   (),
    .o8_icb_cmd_burst  (),
    .o8_icb_cmd_beat   (),
    
    .o8_icb_rsp_valid  (1'b0),
    .o8_icb_rsp_ready  (),
    .o8_icb_rsp_err    (1'b0),
    .o8_icb_rsp_excl_ok(1'b0),
    .o8_icb_rsp_rdata  (32'b0),

  //  * Preserved 9   
    .o9_icb_enable     (1'b0),

    .o9_icb_cmd_valid  (),
    .o9_icb_cmd_ready  (1'b0),
    .o9_icb_cmd_addr   (),
    .o9_icb_cmd_read   (),
    .o9_icb_cmd_wdata  (),
    .o9_icb_cmd_wmask  (),
    .o9_icb_cmd_lock   (),
    .o9_icb_cmd_excl   (),
    .o9_icb_cmd_size   (),
    .o9_icb_cmd_burst  (),
    .o9_icb_cmd_beat   (),
    
    .o9_icb_rsp_valid  (1'b0),
    .o9_icb_rsp_ready  (),
    .o9_icb_rsp_err    (1'b0),
    .o9_icb_rsp_excl_ok(1'b0),
    .o9_icb_rsp_rdata  (32'b0),

  //  * Preserved 10  
    .o10_icb_enable     (1'b0),

    .o10_icb_cmd_valid  (),
    .o10_icb_cmd_ready  (1'b0),
    .o10_icb_cmd_addr   (),
    .o10_icb_cmd_read   (),
    .o10_icb_cmd_wdata  (),
    .o10_icb_cmd_wmask  (),
    .o10_icb_cmd_lock   (),
    .o10_icb_cmd_excl   (),
    .o10_icb_cmd_size   (),
    .o10_icb_cmd_burst  (),
    .o10_icb_cmd_beat   (),
    
    .o10_icb_rsp_valid  (1'b0),
    .o10_icb_rsp_ready  (),
    .o10_icb_rsp_err    (1'b0),
    .o10_icb_rsp_excl_ok(1'b0),
    .o10_icb_rsp_rdata  (32'b0),

  //  * Preserved 11
    .o11_icb_enable     (1'b0),

    .o11_icb_cmd_valid  (),
    .o11_icb_cmd_ready  (1'b0),
    .o11_icb_cmd_addr   (),
    .o11_icb_cmd_read   (),
    .o11_icb_cmd_wdata  (),
    .o11_icb_cmd_wmask  (),
    .o11_icb_cmd_lock   (),
    .o11_icb_cmd_excl   (),
    .o11_icb_cmd_size   (),
    .o11_icb_cmd_burst  (),
    .o11_icb_cmd_beat   (),
    
    .o11_icb_rsp_valid  (1'b0),
    .o11_icb_rsp_ready  (),
    .o11_icb_rsp_err    (1'b0),
    .o11_icb_rsp_excl_ok(1'b0),
    .o11_icb_rsp_rdata  (32'b0),     

  //  * Preserved 12
    .o12_icb_enable     (1'b0),

    .o12_icb_cmd_valid  (),
    .o12_icb_cmd_ready  (1'b0),
    .o12_icb_cmd_addr   (),
    .o12_icb_cmd_read   (),
    .o12_icb_cmd_wdata  (),
    .o12_icb_cmd_wmask  (),
    .o12_icb_cmd_lock   (),
    .o12_icb_cmd_excl   (),
    .o12_icb_cmd_size   (),
    .o12_icb_cmd_burst  (),
    .o12_icb_cmd_beat   (),
    
    .o12_icb_rsp_valid  (1'b0),
    .o12_icb_rsp_ready  (),
    .o12_icb_rsp_err    (1'b0),
    .o12_icb_rsp_excl_ok(1'b0),
    .o12_icb_rsp_rdata  (32'b0),

  //  * Preserved 13
    .o13_icb_enable     (1'b0),

    .o13_icb_cmd_valid  (),
    .o13_icb_cmd_ready  (1'b0),
    .o13_icb_cmd_addr   (),
    .o13_icb_cmd_read   (),
    .o13_icb_cmd_wdata  (),
    .o13_icb_cmd_wmask  (),
    .o13_icb_cmd_lock   (),
    .o13_icb_cmd_excl   (),
    .o13_icb_cmd_size   (),
    .o13_icb_cmd_burst  (),
    .o13_icb_cmd_beat   (),
    
    .o13_icb_rsp_valid  (1'b0),
    .o13_icb_rsp_ready  (),
    .o13_icb_rsp_err    (1'b0),
    .o13_icb_rsp_excl_ok(1'b0),
    .o13_icb_rsp_rdata  (32'b0),

   //  * Preserved 14  
    .o14_icb_enable     (1'b0),

    .o14_icb_cmd_valid  (),
    .o14_icb_cmd_ready  (1'b0),
    .o14_icb_cmd_addr   (),
    .o14_icb_cmd_read   (),
    .o14_icb_cmd_wdata  (),
    .o14_icb_cmd_wmask  (),
    .o14_icb_cmd_lock   (),
    .o14_icb_cmd_excl   (),
    .o14_icb_cmd_size   (),
    .o14_icb_cmd_burst  (),
    .o14_icb_cmd_beat   (),
    
    .o14_icb_rsp_valid  (1'b0),
    .o14_icb_rsp_ready  (),
    .o14_icb_rsp_err    (1'b0),
    .o14_icb_rsp_excl_ok(1'b0 ),
    .o14_icb_rsp_rdata  (32'b0),


   //  * Preserved 15     
    .o15_icb_enable     (1'b0),

    .o15_icb_cmd_valid  (),
    .o15_icb_cmd_ready  (1'b0),
    .o15_icb_cmd_addr   (),
    .o15_icb_cmd_read   (),
    .o15_icb_cmd_wdata  (),
    .o15_icb_cmd_wmask  (),
    .o15_icb_cmd_lock   (),
    .o15_icb_cmd_excl   (),
    .o15_icb_cmd_size   (),
    .o15_icb_cmd_burst  (),
    .o15_icb_cmd_beat   (),
    
    .o15_icb_rsp_valid  (1'b0),
    .o15_icb_rsp_ready  (),
    .o15_icb_rsp_err    (1'b0),
    .o15_icb_rsp_excl_ok(1'b0),
    .o15_icb_rsp_rdata  (32'b0),

    .clk           (clk  ),
    .rst_n         (bus_rst_n) 
  );


sirv_icb_slv_test module_test(
    .i_icb_cmd_valid (exttest_icb_cmd_valid),
    .i_icb_cmd_ready (exttest_icb_cmd_ready),
    .i_icb_cmd_addr  (exttest_icb_cmd_addr),
    .i_icb_cmd_read  (exttest_icb_cmd_read),
    .i_icb_cmd_wdata (exttest_icb_cmd_wdata),
    .i_icb_cmd_wmask (exttest_icb_cmd_wmask),
    
    .i_icb_rsp_valid (exttest_icb_rsp_valid),
    .i_icb_rsp_ready (exttest_icb_rsp_ready),
    .i_icb_rsp_rdata (exttest_icb_rsp_rdata),
    .i_icb_rsp_err   (exttest_icb_rsp_err),

	.clk           (clk  ),
    .bus_rst_n     (bus_rst_n),
    .rst_n         (rst_n)
);


sirv_gnrl_icb2apb # (
  .AW   (32),
  .DW   (`E203_XLEN) 
) u_i2c0_apb_icb2apb(
    .i_icb_cmd_valid (mvu_icb_cmd_valid),
    .i_icb_cmd_ready (mvu_icb_cmd_ready),
    .i_icb_cmd_addr  (mvu_icb_cmd_addr ),
    .i_icb_cmd_read  (mvu_icb_cmd_read ),
    .i_icb_cmd_wdata (mvu_icb_cmd_wdata),
    .i_icb_cmd_wmask (mvu_icb_cmd_wmask),
    .i_icb_cmd_size  (),
    
    .i_icb_rsp_valid (mvu_icb_rsp_valid),
    .i_icb_rsp_ready (mvu_icb_rsp_ready),
    .i_icb_rsp_rdata (mvu_icb_rsp_rdata),
    .i_icb_rsp_err   (mvu_icb_rsp_err),

    .apb_paddr       (mvu_apb_paddr  ),
    .apb_pwrite      (mvu_apb_pwrite ),
    .apb_pselx       (mvu_apb_pselx  ),
    .apb_penable     (mvu_apb_penable), 
    .apb_pwdata      (mvu_apb_pwdata ),
    .apb_prdata      (mvu_apb_prdata ),

    .clk             (clk  ),
    .rst_n           (bus_rst_n) 
  );

endmodule
