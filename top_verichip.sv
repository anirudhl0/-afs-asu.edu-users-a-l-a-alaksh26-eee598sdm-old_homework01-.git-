`timescale 1ns/1ps

`define SET_WRITE(addr,val,bytes)   \
   rw_ <= 1'b0;                     \
   chip_select <= 1'b1;             \
   byte_en <= bytes;                \
   address <= addr;                 \
   data_in <= val; 

//enabling and disabling chip select signal 

`define SET_WRITE_CHIPSELECT(addr,val,bytes,enable)   \
   rw_ <= 1'b0;                         \
   if ( enable!= 1 )           		\
   begin                            	\
       chip_select <= 1'b0;             \
   end					\	
   else                                 \
   begin				\
       chip_select <= 1'b1;             \
   end            			\ 
   byte_en <= bytes;               	\
   address <= addr;                 	\
   data_in <= val;

`define SET_READ(addr)              \
   rw_ <= 1'b1;                     \
   chip_select <= 1'b1;             \
   byte_en <= 2'b00;                \
   address <= addr;                 \
   data_in <= 16'h0;

//enabling and disabling chip select signal 

`define SET_READ_CHIPSELECT(addr,enable)    \
   rw_ <= 1'b1;                     \
   if ( enable!= 1 )           	    \
   begin                            \
       chip_select <= 1'b0;         \
   end			    	    \	
   else                             \
   begin			    \
       chip_select <= 1'b1;         \
   end                              \  
   byte_en <= 2'b00;                \
   address <= addr;                 \
   data_in <= 16'h0;

`define CLEAR_BUS                   \
   chip_select    <= 1'b0;          \
   address        <= 7'h0;          \
   byte_en        <= 2'h0;          \
   rw_            <= 1'b1;          \
   data_in        <= 16'h0; 

`define CLEAR_ALL                   \
   export_disable <= 1'b0;          \
   maroon         <= 1'b0;          \
   gold           <= 1'b0;          \
   `CLEAR_BUS

`define CHECK_VAL(val)              \
   if ( data_out != val )           \
   begin                            \
       $display("bad read, got %h but expected %h at %t",data_out,val,$time());        \
   end										       \	
   else                                                                                \
   begin									       \
       $display("Test Pass");                                                          \
   end                                                             

// CHECK_RW calls macros YOU have to write
`define CHECK_RW(addr,wval,rval,bytes)    \
   `WRITE_REG(addr,wval,bytes)            \
   `READ_REG(addr,rval)

`define CHIP_RESET                  \
   wait( clk == 1'b0 );             \	
   rst_b <= 1'b0;                   \
   wait( clk == 1'b1 );             \
   rst_b <= 1'b1;

`define DELAY                       \
   wait(clk == 1'b0);               \
   wait(clk == 1'b1);               \
   wait(clk == 1'b0);               \
   wait(clk == 1'b1);

`define CHANGE_STATE(val1,val2)     \
   maroon <= val1;                  \
   gold <= val2;                    


module top_verichip ();

logic clk;                       // system clock
logic rst_b;                     // chip reset
logic export_disable;            // disable features
logic interrupt_1;               // first interrupt
logic interrupt_2;               // second interrupt 

logic maroon;                    // maroon state machine input
logic gold;                      // gold state machine input

logic chip_select;               // target of r/w
logic [6:0] address;             // address bus
logic [1:0] byte_en;             // write byte enables
logic       rw_;                 // read/write
logic [15:0] data_in;            // input data bus

logic [15:0] data_out;           // output data bus

localparam VCHIP_VER_ADDR       = 7'h00;   // valid addresses
localparam VCHIP_STA_ADDR       = 7'h04;
localparam VCHIP_CMD_ADDR       = 7'h08;
localparam VCHIP_CON_ADDR       = 7'h0C;
localparam VCHIP_ALU_LEFT_ADDR  = 7'h10;
localparam VCHIP_ALU_RIGHT_ADDR = 7'h14;
localparam VCHIP_ALU_OUT_ADDR   = 7'h18;

localparam VCHIP_ALU_VALID = 16'h8000; // the valid bit
localparam VCHIP_ALU_ADD   = 16'h0001; // the various commands
localparam VCHIP_ALU_SUB   = 16'h0002; // OR the valid bit with the commands to do something
localparam VCHIP_ALU_MVL   = 16'h0003;
localparam VCHIP_ALU_MVR   = 16'h0004;
localparam VCHIP_ALU_SWA   = 16'h0005;
localparam VCHIP_ALU_SHL   = 16'h0006;
localparam VCHIP_ALU_SHR   = 16'h0007;

initial      // get the clock running
begin
   clk <= 1'b0;
   while ( 1 )
   begin
      #5 clk <= 1'b1;
      #5 clk <= 1'b0;
   end
end

initial
begin
   // START WITH A NICE CLEAN INTERFACE AND A RESET

   `CLEAR_ALL
   `CHIP_RESET
   `DELAY
  
// CHECKING ALL R/W IN RESET STATE
  
    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'hFFFF
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)


    `SET_WRITE(6'h10,16'h0000,2'b11)      // Writing 16'h0000
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)


    `SET_WRITE(6'h10,16'h1111,2'b11)      // Writing 16'h1111
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h1111)


    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)


    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)

    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY

// CHECKING ALL R/W IN NORMAL STATE

    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'hFFFF
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)


    `SET_WRITE(6'h10,16'h0000,2'b11)      // Writing 16'h0000
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)


    `SET_WRITE(6'h10,16'h1111,2'b11)      // Writing 16'h1111
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h1111)


    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)


    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE(6'h08,16'h800A,2'b11)      // Giving wrong command to command register
    `DELAY

// CHECKING ALL R/W IN ERROR STATE

    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'hFFFF
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE(6'h10,16'h0000,2'b11)      // Writing 16'h0000
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE(6'h10,16'h1111,2'b11)      // Writing 16'h1111
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL
    
//TO CHECK THERE IS NO CHANGE IN DATA IN REGISTER ON TRANSITION FROM NORMAL TO ERROR STATE

    `SET_WRITE(6'h10,16'h0000,2'b11)      // Writing 16'h0000
    `DELAY
    `SET_WRITE(6'h08,16'h800B,2'b11)      // Giving bad command to command register
    `DELAY
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL
    
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Giving bad command to command register
    `DELAY
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL

    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Giving bad command to command register
    `DELAY
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL

    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Giving bad command to command register
    `DELAY
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL
 
    `SET_WRITE(6'h10,16'h1111,2'b11)      // Writing 16'h1111
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Giving bad command to command register
    `DELAY
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h1111)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL

//checking Read in Export Violation State

    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY   
     export_disable <= 1'b1;    
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Transition to export Violation
    `DELAY       
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHIP_RESET 
    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY

    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY   
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Transition to export Violation
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHIP_RESET 
    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY   
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Transition to export Violation
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)
    
    `CHIP_RESET 
    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY
    
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hAAAA
    `DELAY 
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Transition to export Violation
    `DELAY  
    
// CHECKING WRITES IN EXPORT VIOLATION STATE

    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY   
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY   
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY   
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU Left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

//BYTE ENABLE CHECKS IN RESET STATE

    `CHIP_RESET 
    `DELAY

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'hAAAA,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h55AA)

    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAFF)


//CHECKING RESET FUNCTIONALITY FROM NORMAL STATE

    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

//CHECKING RESET FUNCTIONALITY FROM ERROR STATE

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY
    `SET_WRITE(6'h08,16'h800A,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000) 

//CHECKING RESET FUNCTIONALITY FROM EXPORT VIOLATION STATE

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)  

    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY
     export_disable <= 1'b1;
    `SET_WRITE(6'h08,16'h8005,2'b11)      // Writing 16'h5555
    `DELAY
    `SET_READ(6'h04)                      // Reading Register
    `DELAY
     $display ("Data in status register = 0x%h", data_out);
    `CHIP_RESET
    `DELAY
    `SET_READ(6'h10)                      // Reading Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000) 


// Aliasing in normal state

    `CLEAR_ALL
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    
    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHIP_RESET
    `DELAY
    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY

    `SET_WRITE(7'h50,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

// reset state

    `CHIP_RESET
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    
    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY
    `CHIP_RESET  // ressetting the ALU left register
    `DELAY

    `SET_WRITE(7'h50,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)


// Aliasing in error state
    `CHIP_RESET
    `DELAY
    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY
    `SET_WRITE(6'h10,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY  
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL

    `SET_WRITE(6'h10,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY  
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHANGE_STATE(1'b1,1'b0)              // Changing state from error to normal
    `DELAY
    `CLEAR_ALL
    
    `SET_WRITE(6'h10,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY    
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY  
    `SET_READ(7'h50)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `CHIP_RESET  // ressetting the ALU left register
    `DELAY
    `CHANGE_STATE(1'b0,1'b1)              // Changing state from reset to normal
    `DELAY

    `SET_WRITE(7'h50,16'hFFFF,2'b11)      // Writing 16'hFFFF
    `DELAY  
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY  
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'hAAAA,2'b11)      // Writing 16'hAAAA
    `DELAY   
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY  
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE(7'h50,16'h5555,2'b11)      // Writing 16'h5555
    `DELAY  
    `SET_WRITE(6'h08,16'h800A,2'b11)      // ERROR STATE
    `DELAY   
    `SET_READ(6'h10)                      // Reading ALU Register
    `DELAY
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

     
//BYTE ENABLE CHECKS IN NORMAL STATE

    `CHIP_RESET 
    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'hAAAA,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h55AA)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAA55)


    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'hFFFF,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h55FF)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFF55)


    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'h0000,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'h0000,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5500)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'h0000,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0055)




    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)

    `SET_WRITE(6'h10,16'hAAAA,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFAA)

    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAFF)


    `SET_WRITE(6'h10,16'hAAAA,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)

    `SET_WRITE(6'h10,16'hFFFF,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAFF)

    `SET_WRITE(6'h10,16'hAAAA,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFAA)


//BYTE ENABLE CHECKS IN RESET STATE

    `CHIP_RESET 
    `DELAY

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'hAAAA,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h55AA)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAA55)


    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'hFFFF,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h55FF)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFF55)


    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'h0000,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE(6'h10,16'h0000,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5500)

    `SET_WRITE(6'h10,16'h5555,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'h0000,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0055)




    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)

    `SET_WRITE(6'h10,16'hAAAA,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFAA)

    `SET_WRITE(6'h10,16'hFFFF,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hAAAA,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAFF)




    `SET_WRITE(6'h10,16'hAAAA,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b00)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)

    `SET_WRITE(6'h10,16'hFFFF,2'b01)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAFF)

    `SET_WRITE(6'h10,16'hAAAA,2'b11)       // Writing 16'h5555
    `DELAY

    `SET_WRITE(6'h10,16'hFFFF,2'b10)       // Writing 16'hAAAA
    `DELAY
    `SET_READ(6'h10)                       // Reading Register
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFAA)


// Chip selects using another Macro using an enable 1 for chip_select on and enable=0 for chip_select off_NORMAL STATE


    `CHIP_RESET  // ressetting the ALU left register
    `DELAY
    `CHANGE_STATE(1'b0,1'b1)               // Changing state from reset to normal
    `DELAY
    `SET_WRITE_CHIPSELECT(6'h10,16'hFFFF,2'b11,0)       // Writing 16'hFFFF with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'h5555,2'b11,0)       // Writing 16'h5555 with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'hAAAA,2'b11,0)       // Writing 16'hAAAA with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'h0000,2'b11,0)       // Writing 16'h0000 with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)


    `SET_WRITE_CHIPSELECT(6'h10,16'hFFFF,2'b11,1)       // Writing 16'hFFFF with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)

    `SET_WRITE_CHIPSELECT(6'h10,16'h5555,2'b11,1)       // Writing 16'hAAAA with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on 
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE_CHIPSELECT(6'h10,16'hAAAA,2'b11,1)       // Writing 16'h5555 with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE_CHIPSELECT(6'h10,16'h0000,2'b11,1)       // Writing 16'h0000 with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

// Chip selects using another Macro using an enable 1 for chip_select on and enable=0 for chip_select off_RESET STATE


    `CHIP_RESET  // ressetting the ALU left register
    `DELAY
    `SET_WRITE_CHIPSELECT(6'h10,16'hFFFF,2'b11,0)       // Writing 16'hFFFF with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'h5555,2'b11,0)       // Writing 16'h5555 with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'hAAAA,2'b11,0)       // Writing 16'hAAAA with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)

    `SET_WRITE_CHIPSELECT(6'h10,16'h0000,2'b11,0)       // Writing 16'h0000 with chipselect signal off
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,0)                       // Reading Register with chip select signal off
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)


    `SET_WRITE_CHIPSELECT(6'h10,16'hFFFF,2'b11,1)       // Writing 16'hFFFF with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hFFFF)

    `SET_WRITE_CHIPSELECT(6'h10,16'h5555,2'b11,1)       // Writing 16'hAAAA with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on 
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h5555)

    `SET_WRITE_CHIPSELECT(6'h10,16'hAAAA,2'b11,1)       // Writing 16'h5555 with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'hAAAA)


    `SET_WRITE_CHIPSELECT(6'h10,16'h0000,2'b11,1)       // Writing 16'h0000 with chipselect signal on
    `DELAY
    `SET_READ_CHIPSELECT(6'h10,1)                       // Reading Register with chip select signal on
     $display ("Data in ALU left register = 0x%h", data_out);
    `CHECK_VAL(16'h0000)
   

   #5 $finish;    // THIS MUST BE THE LAST THING YOU EXECUTE!
end // initial begin

// instantiate the VeriChip!
verichip verichip (.clk           ( clk            ),    // system clock
                   .rst_b         ( rst_b          ),    // chip reset
                   .export_disable( export_disable ),    // disable features
                   .interrupt_1   ( interrupt_1    ),    // first interrupt
                   .interrupt_2   ( interrupt_2    ),    // second interrupt
 
                   .maroon        ( maroon         ),    // maroon state machine input
                   .gold          ( gold           ),    // gold state machine input

                   .chip_select   ( chip_select    ),    // target of r/w
                   .address       ( address        ),    // address bus
                   .byte_en       ( byte_en        ),    // write byte enables
                   .rw_           ( rw_            ),    // read/write
                   .data_in       ( data_in        ),    // data bus

                   .data_out      ( data_out       ) );  // output data bus

endmodule // top_verichip
