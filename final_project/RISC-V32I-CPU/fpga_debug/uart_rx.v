// UART Receiver Module
// Receives 8-bit data serially at specified baud rate
// Protocol: 1 start bit, 8 data bits, 1 stop bit, no parity

module uart_rx #(
    parameter CLOCK_FREQ = 50000000,  // 50 MHz clock on DE10-Lite
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire reset,
    input wire rx,                    // Serial input line
    output reg [7:0] data_out,        // Received data byte
    output reg data_valid,            // Pulse when new data available
    output wire frame_error           // High if stop bit incorrect
);

    // Calculate baud rate divisor
    localparam DIVISOR = CLOCK_FREQ / BAUD_RATE;
    localparam DIVISOR_WIDTH = $clog2(DIVISOR);
    localparam HALF_DIVISOR = DIVISOR / 2;
    
    // State machine states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    reg [1:0] state;
    reg [DIVISOR_WIDTH-1:0] baud_counter;
    reg [2:0] bit_counter;            // Counts 0-7 for data bits
    reg [7:0] data_reg;               // Holds data being received
    reg rx_sync1, rx_sync2;           // Synchronization registers
    reg frame_err_reg;
    
    assign frame_error = frame_err_reg;
    
    // Synchronize incoming rx signal to avoid metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            data_reg <= 8'h00;
            data_out <= 8'h00;
            data_valid <= 1'b0;
            frame_err_reg <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;  // Default: pulse for one cycle
            
            case (state)
                IDLE: begin
                    baud_counter <= 0;
                    bit_counter <= 0;
                    frame_err_reg <= 1'b0;
                    
                    // Detect start bit (falling edge)
                    if (rx_sync2 == 1'b0) begin
                        state <= START;
                    end
                end
                
                START: begin
                    // Wait until middle of start bit to sample
                    if (baud_counter == HALF_DIVISOR - 1) begin
                        if (rx_sync2 == 1'b0) begin
                            // Valid start bit
                            baud_counter <= 0;
                            state <= DATA;
                        end
                        else begin
                            // False start bit
                            state <= IDLE;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                DATA: begin
                    if (baud_counter == DIVISOR - 1) begin
                        baud_counter <= 0;
                        data_reg[bit_counter] <= rx_sync2;  // Sample bit
                        
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
                    if (baud_counter == DIVISOR - 1) begin
                        baud_counter <= 0;
                        
                        // Check for valid stop bit
                        if (rx_sync2 == 1'b1) begin
                            data_out <= data_reg;
                            data_valid <= 1'b1;
                            frame_err_reg <= 1'b0;
                        end
                        else begin
                            frame_err_reg <= 1'b1;
                        end
                        
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

