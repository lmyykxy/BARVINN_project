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

module sirv_apb_slv_test (
  input  [32-1:0] apb_paddr,
  input           apb_pwrite,
  input           apb_pselx,
  input           apb_penable,
  input  [32-1:0] apb_pwdata,
  output [32-1:0] apb_prdata,

  input  clk,
  input  rst_n
);

assign apb_prdata = (apb_pselx && !apb_pwrite && apb_paddr == 32'h1210_0000) ? 32'h1111_1111
				   :(apb_pselx && !apb_pwrite && apb_paddr == 32'h1211_0000) ? 32'h2222_2222
				   :(apb_pselx && !apb_pwrite) ? 32'hffff_ffff
				   : 32'h0000_0000;

endmodule