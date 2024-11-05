 /*                                                                      
 Copyright 2018-2020  Beijing University of Posts and Telecommunications, Inc.                
                                                                         
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
//  ICB bus simple test case
//
// ====================================================================

`include "e203_defines.v"

module sirv_icb_slv_test (
  input                          i_icb_cmd_valid,
  output                         i_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   i_icb_cmd_addr, 
  input                          i_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        i_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      i_icb_cmd_wmask,
  //
  output                         i_icb_rsp_valid,
  input                          i_icb_rsp_ready,
  output                         i_icb_rsp_err,
  output [`E203_XLEN-1:0]        i_icb_rsp_rdata,

  input  clk,
  input  bus_rst_n,
  input  rst_n
);

wire icb_cmd_read_real = i_icb_cmd_valid & i_icb_cmd_read;
wire icb_cmd_write_real = i_icb_cmd_valid & ~i_icb_cmd_read;

assign i_icb_cmd_ready = i_icb_rsp_ready;
assign i_icb_rsp_valid = icb_cmd_read_real | icb_cmd_write_real;

assign i_icb_rsp_err = 1'b0;
assign i_icb_rsp_rdata = {`E203_XLEN{1'b1}};

endmodule