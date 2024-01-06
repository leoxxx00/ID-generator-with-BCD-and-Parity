module X (digit,bcd, odd_parity,even_parity,clk,reset,enable);//Top gate level hierarchy module X
//input and out assignments
  input wire clk;//input as clk from module BrunelIDNumberGenerator
  input wire reset;//input reset from module BrunelIDNumberGenerator
  input wire enable;//input enable from module BrunelIDNumberGenerator
  output [3:0] digit;//output digit from module BrunelIDNumberGenerator
  output [3:0] bcd;//output bcd from BinaryToBCDEncoder bcd_encoder module
  output wire odd_parity;//output odd_parity from BinaryToBCDEncoder bcd_encoder module
  output wire even_parity;//output even_parity form BinaryToBCDEncoder bcd_encoder module
//wire connections
  wire [3:0] generated_digit;//connect digits to use in this gate top level module
  wire [3:0] encoded_bcd;//connect bcd to output from this top level module
  wire [3:0] generated_odd_parity;//connect odd_parity to use in this gate top level module
  wire [3:0] generated_even_parity;//connect odd_parity to use in this gate top level module
// Instantiate BrunelIDNumberGenerator module to connect between separate modules and this gate top level module
  BrunelIDNumberGenerator brunel_gen (
    .clk(clk),//To use clk from module BrunelIDNumberGenerator
    .reset(reset),//To use reset from module BrunelIDNumberGenerator
    .enable(enable),//To use enable from module BrunelIDNumberGenerator
    .digit(generated_digit)//To use digit from module BrunelIDNumberGenerator and pair with generated_digit
  );
// Instantiate BinaryToBCDEncoder module to connect between separate modules and this gate top level module
  BinaryToBCDEncoder bcd_encoder (
    .digit(generated_digit),//To use digit from module BinaryToBCDEncoder and pair with generarted_digit
    .bcd(encoded_bcd)//To use bcd from module BinaryToBCDEncoder an pair with encoded_bcd
  );
// Instantiate ParityGenerator module to connect between separate modules and this gate top level module
  ParityGenerator parity_gen (
    .bcd(encoded_bcd),//To use bcd from module ParityGenerator adn pair with encoded_bcd for output from this gate top level module
    .odd_parity(generated_odd_parity),//To use bcd from module ParityGenerator and pair with generated_odd_parity for input to use in this module
    .even_parity(generated_even_parity)//To use bcd from module ParityGenerator and pair with generated_even_parity for input to use in this module
  );
// Output assignments
  assign digit = generated_digit;//pair digit to show in output
  assign bcd = encoded_bcd;//pair to show in output
  assign odd_parity = generated_odd_parity[0];//pair to output in odd_parity
  assign even_parity = generated_even_parity[0];//pair to output in even_parity
endmodule//end of top gate level hierarchy module
module BrunelIDNumberGenerator (digit,clk,reset,enable);//Functional level Burnel ID generator 
//input and out assignments
  input wire clk;//input clk
  input wire reset;//input reset
  input wire enable;//input enable
  output reg [3:0] digit;//input digit
 //register connections
  reg [2:0] counter;//register counter to use on always @
  reg [3:0] currentDigit;//register currentDigit to use on always @
  reg [2:0] pulseInterval;//register pulseInterval to use on always @
always @(posedge clk or posedge reset) begin//begin the counter to move down  of the enable and reset 
    // Synchronous reset and enable logic
    if (reset)//make a reset
        counter = 0; // Reset counter to 0
    else if (enable)//if not reset
        counter = counter + 1; // Increment counter when enable is active
end//end the always @
always @(posedge clk) begin//begin
    // Synchronous reset and enable logic for pulseInterval
    if (reset)//make reset if the condition is met
        pulseInterval = 0; // Reset pulseInterval to 0
    else if (enable)//make enable if the condition is met
        pulseInterval = counter[2:0]; // Assign the lower 3 bits of counter to pulseInterval
end//end the always @
always @(posedge clk) begin//begin the function that produce the output base on the clock interval
    // Logic for determining currentDigit based on pulseInterval
    case (pulseInterval)//start the case for output logic
        3'b010: currentDigit = 4'b0010;// If pulseInterval is 010 = 2clockcycle, set currentDigit to 0010 = 2
        3'b101: currentDigit = 4'b0100;// If pulseInterval is 101 = 5clockcycle, set currentDigit to 0100 = 4
        3'b110: currentDigit = 4'b0111;// If pulseInterval is 110 = 6clockcycle, set currentDigit to 0111 = 7
        default: currentDigit = 4'b0001;// For all other cases, set currentDigit to 0001 = 1
    endcase//end the case of defining output base4 on the clock cycle every 2,5 or 6 interval
end//end the always @
always @(posedge clk) begin
    // Synchronous reset and enable logic for digit
    if (reset)
        digit <= 4'b0000; // Reset digit to 0000
    else if (enable)
        digit <= currentDigit; // Assign currentDigit to digit when enable is active
end//end the always @
endmodule//end the top level hirarchy
module BinaryToBCDEncoder(bcd,digit);//Functional level module BinaryToBCDEncoder
  input wire [3:0] digit;//input digit from the output of module BrunelIDNumberGenerator
  output reg [3:0] bcd;//output the binary coded version bcd
//function to convert the binary digit value to encoded bcd
always @(*) begin//start
  case (digit)//case assignment or announcement 
    4'b0000: bcd = 4'b0000;//convert digit 4'b0000 to bcd 4'b0000
    4'b0001: bcd = 4'b0001;//convert digit 4'b0001 to bcd 4'b0001
    4'b0010: bcd = 4'b0010;//convert digit 4'b0010 to bcd 4'b0010
    4'b0011: bcd = 4'b0011;//convert digit 4'b0011 to bcd 4'b0011
    4'b0100: bcd = 4'b0100;//convert digit 4'b0100 to bcd 4'b0100
    4'b0101: bcd = 4'b0101;//convert digit 4'b0101 to bcd 4'b0101
    4'b0110: bcd = 4'b0110;//convert digit 4'b0110 to bcd 4'b0110
    4'b0111: bcd = 4'b0111;//convert digit 4'b0111 to bcd 4'b0111
    4'b1000: bcd = 4'b1000;//convert digit 4'b1000 to bcd 4'b1000
    4'b1001: bcd = 4'b1001;//convert digit 4'b1001 to bcd 4'b1001
    default: bcd = 4'b0000;// Handle invalid input
  endcase//case end
end//end
endmodule//end of Functional level module BinaryToBCDEncoder
module ParityGenerator (odd_parity, even_parity,bcd);//Pure gate level module BinaryToBCDEncoder
  output wire odd_parity;//output odd_parity
  output wire even_parity;//output even_parity
  input wire [3:0] bcd;// input the bcdcoded form module BinaryToBCDEncoder to detect even or odd
  // AND gate for even parity
  assign even_parity = &bcd; //As long as bcd input is and the even_parity outputted
  // XOR gates for odd parity
  //If an odd number of bits are set to 1 among these four bits, the result is 1 (indicating odd parity).
  //If an even number of bits are set to 1, the result is 0 (indicating even parity).
  wire xor_result1 = bcd[0] ^ bcd[1] ^ bcd[2] ^ bcd[3];
  // OR gate for odd parity
  assign odd_parity = xor_result1 | ~even_parity;//assign logic tp output odd parity
endmodule//end of Pure gate level module BinaryToBCDEncoder





