// Simple UART Activity Indicator
// Add to cpu_with_debug.v to blink LED when UART receives data

// Add this to cpu_with_debug.v after the debug_interface instantiation:

// UART Activity LED blinker
reg [23:0] uart_activity_counter;
reg uart_activity_led;

always @(posedge clk or posedge cpu_reset) begin
    if (cpu_reset) begin
        uart_activity_counter <= 24'h0;
        uart_activity_led <= 1'b0;
    end
    else begin
        // Blink LED when UART receives data
        if (uart_rx == 1'b0) begin  // Start bit detected
            uart_activity_counter <= 24'hFFFFFF;  // Set max
            uart_activity_led <= 1'b1;
        end
        else if (uart_activity_counter > 0) begin
            uart_activity_counter <= uart_activity_counter - 1;
        end
        else begin
            uart_activity_led <= 1'b0;
        end
    end
end

// Connect to LED
assign status_leds[0] = uart_activity_led;  // Blinks when receiving
assign status_leds[1] = ~uart_rx;           // Shows RX line state
assign status_leds[2] = uart_tx;            // Shows TX line state
assign status_leds[3] = debug_cpu_enable;   // Shows if CPU enabled

// With this code:
// LED0 = Blinks briefly when data received
// LED1 = Lights up during RX transmission (inverted)
// LED2 = Lights up during TX transmission
// LED3 = CPU enable status

