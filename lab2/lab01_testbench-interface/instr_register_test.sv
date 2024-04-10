/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;

  parameter TEST_CASE;

  //fopen("regression", "a");

  parameter WRITE_NR = 30;
  parameter READ_NR = 30;
  parameter READ_ORDER = 2; //0-incremental, 1-decremental, 2 random
  parameter WRITE_ORDER = 2; //0-incremental, 1-decremental, 2 random

  int failcounter = 0;

  instruction_t  iw_reg_test [0:31];

  parameter SEED_VAL = 555;
  int seed = SEED_VAL;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***    THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU    ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin          MODIFICARE lab3
    repeat (WRITE_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin            MODIFICARE LAB3
    for (int i=0; i<=READ_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) case (READ_ORDER)
        0 : read_pointer = i % 32;
        1 : read_pointer = 31 - (i % 32);
        2 : read_pointer = $random($random) % 32;
      endcase

      @(negedge clk) print_results;
      check_result;
    end

    @(posedge clk) ;
    final_report;
    $display("\n***********************************************************");
    $display(  "***    THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU    ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
  static int temp_incr = 0;
  static int temp_decr = 31;
      
  
  operand_a = $random(seed)%16; // between -15 and 15. Algoritmul de randomize vine cu verilog-ul. Se iau valori intre 15 si -15 deoarece este signed
  operand_b = $unsigned($random)%16;  // between 0 and 15
  opcode = opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
  //cast converteste tipul de variabila. 
  //se face %8 deoarece sunt 8 operatii

  case (WRITE_ORDER)
      0 : write_pointer = temp_incr++;
      1 : write_pointer = temp_decr--;
      2 : write_pointer = $random($random)%32;
  endcase
  
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //temp++ se incrementeaza (creste valoarea cu 1). primeste 0 deoarece ++ este dupa 'temp'

    //$display("Se verifica blocant/neblocant: operand_a = %d, operand_b = %d, opcode = %d, time = %t", operand_a, operand_b, opcode, $time);
    $display("At write pointer = %0d:, timp %0t: ", write_pointer, $time);
    $display("  opcode = %0d", opcode,);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    iw_reg_test[write_pointer] <= '{opcode,operand_a,operand_b,0};

  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    $display("  rezultat = %0d\n", instruction_word.rezultat);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  rezultat = %0d\n", instruction_word.rezultat);
    $display("Fail counter: %0d\n", failcounter);
  endfunction: print_results

  function void check_result;

  operand_d res;
    case(iw_reg_test[read_pointer].opc)
        ZERO: res = 0;
        PASSA: res = iw_reg_test[read_pointer].op_a;
        PASSB: res = iw_reg_test[read_pointer].op_b;
        ADD: res = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
        SUB: res = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
        MULT: res = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
        DIV: begin
          if (iw_reg_test[read_pointer].op_b === 0) res = 0;
          else res = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
        end
        MOD: res = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
        default : res = 0;
    endcase
    if (res !== instruction_word.rezultat) begin
      $display("Valorile nu sunt aceleasi.");
      $display("Valoare asteptata: %0d", instruction_word.rezultat);
      $display("Valoare primita: %0d\n", res);
      failcounter++;
    end
    else begin
      $display("Valoarea citita este corecta.");
      $display("Valoare asteptata: %0d", instruction_word.rezultat);
      $display("Valoare citita: %0d\n", res);
    end

  endfunction: check_result

  function void final_report;
  int file;
  file = $fopen("../reports/regression_status.txt", "a");
  if(failcounter != 0)
  begin
    $fdisplay(file, "%s: failed", TEST_CASE);
  end
  else
  begin
    $fdisplay(file, "%s: passed", TEST_CASE);
  end
  $fclose(file);
  endfunction:final_report


endmodule: instr_register_test
