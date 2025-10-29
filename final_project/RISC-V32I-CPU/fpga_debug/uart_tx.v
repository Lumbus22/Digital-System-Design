// UART Transmitter Module
// Transmits 8-bit data serially at specified baud rate
// Protocol: 1 start bit, 8 data bits, 1 stop bit, no parity

module uart_tx #(
    parameter CLOCK_FREQ = 50000000,  // 50 MHz clock on DE10-Lite
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,         // Data byte to transmit
    input wire transmit,              // Start transmission pulse
    output reg tx,                    // Serial output line
    output wire busy                  // High when transmitting
);

    // Calculate baud rate divisor
    localparam DIVISOR = CLOCK_FREQ / BAUD_RATE;
    localparam DIVISOR_WIDTH = $clog2(DIVISOR);
    
    // State machine states
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    
    reg [2:0] state;
    reg [DIVISOR_WIDTH-1:0] baud_counter;
    reg [2:0] bit_counter;            // Counts 0-7 for data bits
    reg [7:0] data_reg;               // Holds data being transmitted
    
    assign busy = (state != IDLE);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1;               // Idle high
            baud_counter <= 0;
            bit_counter <= 0;
            data_reg <= 8'h00;
        end
        else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;       // Line idle high
                    baud_counter <= 0;
                    bit_counter <= 0;
                    
                    if (transmit) begin
                        data_reg <= data_in;
                        state <= START;
                    end
                end
                
                START: begin
                    tx <= 1'b0;       // Start bit (low)
                    
                    if (baud_counter == DIVISOR - 1) begin
                        baud_counter <= 0;
                        state <= DATA;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                DATA: begin
                    tx <= data_reg[bit_counter];  // Send current bit
                    
                    if (baud_counter == DIVISOR - 1) begin
                        baud_counter <= 0;
                        
                        if (bit_counter == 7) begin
                            bit_counter <= 0;
                            state <= STOP;
                        end
                        else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STOP: begin
                    tx <= 1'b1;       // Stop bit (high)
                    
                    if (baud_counter == DIVISOR - 1) begin
                        baud_counter <= 0;
                        state <= IDLE;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule

