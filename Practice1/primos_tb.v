module primos_tb();

    reg [3:0] SW;      // Entrada
    wire LED;         // Salida
    integer C;        // Variable de control del for

    
    primos DUT (
        .SW(SW),
        .LED(LED)
    );

    initial begin
        $display("primo o no");

        
        for (C = 0; C < 16; C = C + 1) begin
            SW = C[3:0];   // variable de control definida
            #10;         
        end

        $display("se acabo");
        $stop;
        $finish;
    end

    
    initial begin
        $monitor("SW = %b (%d) | LED = %b", SW, SW, LED);
    end

endmodule