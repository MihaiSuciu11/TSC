/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/ // DUT   //memoreaza date si in fct de write si read pointer
module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word,
 output operand_d      rezultat
);

  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures, a nu se confunda cu registru reg [31,0]
//reset initializeaza toate variabilele cu o valoare data, fixa
  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (load_en) begin
    rezultat = 0;
    case(opcode)
  	  ZERO: rezultat = 0;
      PASSA: rezultat = operand_a;
      PASSB: rezultat = operand_b;
      ADD: rezultat = operand_a + operand_b;
      SUB: rezultat = operand_a - operand_b;
      MULT: rezultat = operand_a * operand_b;
      DIV : if (operand_b === 0)
          rezultat = 0;
        else
          rezultat = operand_a / operand_b;
      MOD : if (operand_b === 0) 
          rezultat = 0;
        else
          rezultat = operand_a % operand_b;
      POW : if (operand_a === 0) 
          rezultat = 0;
        else
          rezultat = operand_a ** operand_b;
    endcase
      iw_reg[write_pointer] = '{opcode,operand_a,operand_b,rezultat};
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
