// Módulo principal que muestra un contador en VGA con fuente 8x16 bits
module VGACounterDemo(
    input MAX10_CLK1_50,      // reloj de 50 MHz de la tarjeta
    output reg [2:0] pixel,   // salida de color RGB (3 bits)
	 input [7:0] angle_x,
	 input [7:0] angle_y,
	 input [7:0] angle_z,
	 input [7:0] angle_g,
    output hsync_out,         // señal de sincronización horizontal
    output vsync_out          // señal de sincronización vertical
);

//-------------------------------------------------
// Señales del sistema VGA
//-------------------------------------------------

wire inDisplayArea;   // indica si estamos dentro del área visible de la pantalla
wire [9:0] CounterX;  // posición horizontal actual del pixel
wire [9:0] CounterY;  // posición vertical actual del pixel


//-------------------------------------------------
// Generación de pixel clock (25 MHz)
//-------------------------------------------------

// VGA 640x480 usa aproximadamente 25 MHz
// aquí dividimos el reloj de 50 MHz entre 2
reg pixel_tick = 0;

always @(posedge MAX10_CLK1_50)
    pixel_tick <= ~pixel_tick;


//-------------------------------------------------
// Generador de sincronización VGA
//-------------------------------------------------

// Este módulo genera las señales hsync, vsync
// y también las coordenadas del pixel actual
hvsync_generator hvsync(
    .clk(MAX10_CLK1_50),
    .pixel_tick(pixel_tick),
    .vga_h_sync(hsync_out),
    .vga_v_sync(vsync_out),
    .CounterX(CounterX),
    .CounterY(CounterY),
    .inDisplayArea(inDisplayArea)
);


//-------------------------------------------------
// Divisor de reloj para hacer el contador más lento
//-------------------------------------------------

reg [25:0] clk_div = 0; // contador para dividir el reloj
reg slow_clk = 0;       // reloj más lento

always @(posedge MAX10_CLK1_50)
begin
    if(clk_div == 50_000_000-1) // aproximadamente 1 segundo
    begin
        clk_div <= 0;
        slow_clk <= ~slow_clk;  // cambia el estado del reloj lento
    end
    else
        clk_div <= clk_div + 1;
end


//-------------------------------------------------
// Contador principal
//-------------------------------------------------


//-------------------------------------------------
// Conversión del contador a dígitos decimales
//-------------------------------------------------

// se separa el número en unidades, decenas, centenas y millares
wire [3:0] d0;
wire [3:0] d1;
wire [3:0] d2;
wire [3:0] d3;

assign d0 = angle_x % 10;
assign d1 = (angle_x / 10) % 10;
assign d2 = (angle_x / 100) % 10;
assign d3 = (angle_x / 1000) % 10;

wire [3:0] d0_y;
wire [3:0] d1_y;
wire [3:0] d2_y;
wire [3:0] d3_y;

assign d0_y = angle_y % 10;
assign d1_y = (angle_y / 10) % 10;
assign d2_y = (angle_y / 100) % 10;
assign d3_y = (angle_y / 1000) % 10;

wire [3:0] d0_z;
wire [3:0] d1_z;
wire [3:0] d2_z;
wire [3:0] d3_z;

assign d0_z = angle_z % 10;
assign d1_z = (angle_z / 10) % 10;
assign d2_z = (angle_z / 100) % 10;
assign d3_z = (angle_z / 1000) % 10;

wire [3:0] d0_g;
wire [3:0] d1_g;
wire [3:0] d2_g;
wire [3:0] d3_g;

assign d0_g = angle_g % 10;
assign d1_g = (angle_g / 10) % 10;
assign d2_g = (angle_g / 100) % 10;
assign d3_g = (angle_g / 1000) % 10;

//-------------------------------------------------
// Conversión de dígitos a ASCII
//-------------------------------------------------

// se suma "0" para obtener el código ASCII del número
wire [7:0] ascii0;
wire [7:0] ascii1;
wire [7:0] ascii2;
wire [7:0] ascii3;

assign ascii0 = d0 + "0";
assign ascii1 = d1 + "0";
assign ascii2 = d2 + "0";
assign ascii3 = d3 + "0";

wire [7:0] ascii0_y;
wire [7:0] ascii1_y;
wire [7:0] ascii2_y;
wire [7:0] ascii3_y;

assign ascii0_y = d0_y + "0";
assign ascii1_y = d1_y + "0";
assign ascii2_y = d2_y + "0";
assign ascii3_y = d3_y + "0";

wire [7:0] ascii0_z;
wire [7:0] ascii1_z;
wire [7:0] ascii2_z;
wire [7:0] ascii3_z;

assign ascii0_z = d0_z + "0";
assign ascii1_z = d1_z + "0";
assign ascii2_z = d2_z + "0";
assign ascii3_z = d3_z + "0";

wire [7:0] ascii0_g;
wire [7:0] ascii1_g;
wire [7:0] ascii2_g;
wire [7:0] ascii3_g;

assign ascii0_g = d0_g + "0";
assign ascii1_g = d1_g + "0";
assign ascii2_g = d2_g + "0";
assign ascii3_g = d3_g + "0";


//-------------------------------------------------
// Posición donde aparecerá el texto
//-------------------------------------------------

parameter X_START = 200; // posición horizontal inicial
parameter Y_START = 250; // posición vertical inicial


wire [9:0] rel_x;
wire [9:0] rel_y;

assign rel_x = CounterX - X_START;
assign rel_y = CounterY - Y_START;


//-------------------------------------------------
// Posición del pixel dentro del carácter
//-------------------------------------------------

wire [2:0] col;
wire [3:0] row;

assign col = rel_x[2:0];
assign row = rel_y[3:0];


//-------------------------------------------------
// Determinar qué carácter se está dibujando
//-------------------------------------------------

// cada carácter mide 8 pixels de ancho
wire [2:0] char_index;
wire [1:0] line_index;

assign char_index = rel_x[5:3];   // 0..5
assign line_index   = rel_y[5:4];   // 0..3


//-------------------------------------------------
// Selección del dígito que se va a mostrar
//-------------------------------------------------

reg [7:0] ascii_letra;
always @* begin
    if (CounterY < Y_START + 16)
        ascii_letra = "x";
    else if (CounterY < Y_START + 32)
        ascii_letra = "y";
    else if (CounterY < Y_START + 48)
        ascii_letra = "z";
    else
        ascii_letra = "g";
end

reg [7:0] ascii;

always @*
begin
    case(char_index)
        3'd0: ascii = ascii_letra;
        3'd1: ascii = ":";
        3'd2: begin
            case(line_index)
                2'd0: ascii = ascii3;
                2'd1: ascii = ascii3_y;
                2'd2: ascii = ascii3_z;
                2'd3: ascii = ascii3_g;
            endcase
        end
        3'd3: begin
            case(line_index)
                2'd0: ascii = ascii2;
                2'd1: ascii = ascii2_y;
                2'd2: ascii = ascii2_z;
                2'd3: ascii = ascii2_g;
            endcase
        end
        3'd4: begin
            case(line_index)
                2'd0: ascii = ascii1;
                2'd1: ascii = ascii1_y;
                2'd2: ascii = ascii1_z;
                2'd3: ascii = ascii1_g;
            endcase
        end
        3'd5: begin
            case(line_index)
                2'd0: ascii = ascii0;
                2'd1: ascii = ascii0_y;
                2'd2: ascii = ascii0_z;
                2'd3: ascii = ascii0_g;
            endcase
        end
        default: ascii = " ";
    endcase
end

//-------------------------------------------------
// Dirección de la memoria de fuente
//-------------------------------------------------

// cada carácter tiene 16 filas
wire [11:0] rom_addr;

assign rom_addr = (ascii << 4) + row;


//-------------------------------------------------
// Lectura de la ROM de fuentes
//-------------------------------------------------

wire [7:0] font_row;

// ROM que contiene los pixels de los caracteres
font_rom font(
    .addr(rom_addr),
    .data(font_row)
);


//-------------------------------------------------
// Determinar si el pixel está encendido
//-------------------------------------------------

wire pixel_on;

// selecciona el bit correspondiente de la fila
assign pixel_on = font_row[7-col];


//-------------------------------------------------
// Dibujar el pixel en pantalla
//-------------------------------------------------

always @(posedge MAX10_CLK1_50)
begin
    if(inDisplayArea) // solo dibujar dentro del área visible
    begin
        // verificar si estamos dentro del área del texto
        if(CounterX >= X_START && CounterX < X_START + 48 &&
           CounterY >= Y_START && CounterY < Y_START + 64)
        begin
            if(pixel_on)
                pixel <= 3'b111; // pixel blanco
            else
                pixel <= 3'b000; // pixel negro
        end
        else
            pixel <= 3'b000;
    end
    else
        pixel <= 3'b000;
end

endmodule
