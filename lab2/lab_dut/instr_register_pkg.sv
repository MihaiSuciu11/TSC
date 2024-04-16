/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
 //PACKAGE  //tipuri de data def de util
package instr_register_pkg;   //se declara pagkage
  timeunit 1ns/1ns;

  typedef enum logic [3:0] {    //defineste tip de daata de tip enum care poate avea pana la 2^4 stari
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD,
    POW
  } opcode_t;
//operatii matematice ale dut-ului(un fel de calculator)
  typedef logic signed [31:0] operand_t; 
  typedef logic signed [63:0] operand_d;//cu semn, pe 32 biti
  
  typedef logic [4:0] address_t;  //daca nu se specifica signed, va fi unsigned
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    operand_d rezultat;
  } instruction_t;

endpackage: instr_register_pkg
