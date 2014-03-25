
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kirsch is
  port(
    ------------------------------------------
    -- main inputs and outputs
    i_clock    : in  std_logic;                      
    i_reset    : in  std_logic;                      
    i_valid    : in  std_logic;                 
    i_pixel    : in  std_logic_vector(7 downto 0);
    o_valid    : out std_logic;                 
    o_edge     : out std_logic;	                     
    o_dir      : out std_logic_vector(2 downto 0);                      
    o_mode     : out std_logic_vector(1 downto 0);
    o_row      : out std_logic_vector(7 downto 0);
    ------------------------------------------
    -- debugging inputs and outputs
    debug_key      : in  std_logic_vector( 3 downto 1) ; 
    debug_switch   : in  std_logic_vector(17 downto 0) ; 
    debug_led_red  : out std_logic_vector(17 downto 0) ; 
    debug_led_grn  : out std_logic_vector(5  downto 0) ; 
    debug_num_0    : out std_logic_vector(3 downto 0) ; 
    debug_num_1    : out std_logic_vector(3 downto 0) ; 
    debug_num_2    : out std_logic_vector(3 downto 0) ; 
    debug_num_3    : out std_logic_vector(3 downto 0) ; 
    debug_num_4    : out std_logic_vector(3 downto 0) ;
    debug_num_5    : out std_logic_vector(3 downto 0) 
    ------------------------------------------
  );  
end entity;


architecture main of kirsch is

    -- A function to rotate left (rol) a vector by n bits  
    function "rol" ( a : std_logic_vector; n : natural )
        return std_logic_vector
    is
    begin
        return std_logic_vector( unsigned(a) rol n );
    end function;

    signal x_pos      : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal y_pos      : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal i          : unsigned(2 downto 0) := to_unsigned(1, 3);
    
    signal a          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal b          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal c          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal d          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal e          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal f          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal g          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal h          : unsigned(7 downto 0) := to_unsigned(0, 8);
    signal i          : unsigned(7 downto 0) := to_unsigned(0, 8);
    
    signal TMP1       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP2       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP3       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP4       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP5       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP6       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP7       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP8       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP9       : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP10      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP11      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP12      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP13      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP14      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP15      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP16      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP17      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP18      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP19      : unsigned(11 downto 0) := to_unsigned(0, 12);
    signal TMP20      : unsigned(11 downto 0) := to_unsigned(0, 12);
    
     signal i2_valid  : std_logic             := '0';
    
    signal mem_1_wren : std_logic;
    signal mem_1_q    : std_logic_vector(7 downto 0);

    signal mem_2_wren : std_logic;
    signal mem_2_q    : std_logic_vector(7 downto 0);

    signal mem_3_wren : std_logic;
    signal mem_3_q    : std_logic_vector(7 downto 0);

begin  
    --instantiate the 3 instances of the memory module
    mem1 : entity work.mem(main)
     port map (
       address => std_logic_vector(x_pos),
       clock   => i_clock,
       data    => i_pixel,
       wren    => mem_1_wren,
       q       => mem_1_q
    );

    mem2 : entity work.mem(main)
     port map (
       address => std_logic_vector(x_pos),
       clock   => i_clock,
       data    => i_pixel,
       wren    => mem_2_wren,
       q       => mem_2_q
    );

    mem3 : entity work.mem(main)
     port map (
       address => std_logic_vector(x_pos),
       clock   => i_clock,
       data    => i_pixel,
       wren    => mem_3_wren,
       q       => mem_3_q
    );

    debug_num_5 <= X"E";
    debug_num_4 <= X"C";
    debug_num_3 <= X"E";
    debug_num_2 <= X"3";
    debug_num_1 <= X"2";
    debug_num_0 <= X"7";

    debug_led_red <= (others => '0');
    debug_led_grn <= (others => '0');
    
    -- Calculate the mem_x_wren signals
    -- We write data into a memory buffer all the time essentially, but we only change the write pos when we get i_valid
    -- This has the same effect as making the write-enable tied into the i_valid signal
    mem_1_wren <= '1' when i = 1 else '0';
	mem_2_wren <= '1' when i = 2 else '0';
	mem_3_wren <= '1' when i = 4 else '0';
    
    -- Stage 1 pipeline
    --     This pipeline needs to clock the data into the x_2 registers before exiting
    process(i_clock, i_reset)
    begin
        wait for rising_edge(i_clock);
        if(i_valid = '1) then
            -- Shift the data from one cell to the other, which saves on reads from the memory units
            a <= b;
            b <= c;
            h <= i;
            i <= d;
            g <= f;
            f <= e;
            
            -- e is always the most recently entered pixel: we go from [2, 2] to [255, 255] in the image processing (indexed from [0, 0])
            e <= i_pixel;
            
            -- Grab the fresh cells from the correct memory buffer depending 
            -- on the value of i (i is the active memory buffer: 
            -- if we insert into memory buffer 3, 'e' is in buffer 3 so c is in buffer 1, etc...)
            
            with i select
             d <= unsigned(mem_3_q) when when to_unsigned(1, 3),
                  unsigned(mem_1_q) when when to_unsigned(2, 3),
                  unsigned(mem_2_q) when when to_unsigned(4, 3),
                  to_unsigned(0, 8) when others;
                  
            with i select
             c <= unsigned(mem_2_q) when when to_unsigned(1, 3),
                  unsigned(mem_3_q) when when to_unsigned(2, 3),
                  unsigned(mem_1_q) when when to_unsigned(4, 3),
                  to_unsigned(0, 8) when others;                  
            
            --Increment the x_pos and possibly y_pos
            if(x_pos = 255) then
                if(y_pos = 255) then
                    --this is the last iteration of the algorithm
                    end_of_input <= '1';
                end if;
            
                y_pos <= y_pos + 1;
                i <= i rol 1;
            end if;
            x_pos <= x_pos + 1;
            
            if(y_pos >= 2 AND x_pos >= 3) then -- We can start processing data: x_pos is >=3 here because we increment x_pos before getting here
                
                TMP1 <= b + c;
                TMP2 <= MAX(A, D);
                TMP3 <= f + g;
                
                wait for rising_edge(i_clock); --Second clock boundary
                
                TMP4 <= TMP1 + TMP2;
                TMP5 <= MAX(E, H);
                TMP6 <= d + e;
                
                wait for rising_edge(i_clock); --Third clock boundary
                
                TMP7 <= TMP5 + TMP3;
                TMP8 <= MAX(C, F);
                TMP9 <= h + a;
                
                wait for rising_edge(i_clock); --Fourth clock boundary
                
                TMP10 <= TMP8 + TMP6;
                TMP11 <= MAX(g, b);
                TMP12 <= TMP1 + TMP6;   --  <- B + C + D + E
                
            end if;
        end if;
    end process;
    
    -- Stage 2 pipeline
    process(i_clock, i_reset)
    begin
        -- Need a "Stage 2 valid" signal to be generated by the first stage pipeline when it exits
    
        wait for rising_edge(i_clock); --Fifth clock boundary
                
        -- TMP13 = TMP5 + TMP3 <- F + G + H + A
        -- TMP14 = MAX TMP4, TMP10
        -- TMP15 = TMP9 + TMP11
        
        wait for rising_edge(i_clock); --Sixth clock boundary
        
        -- TMP16 = TMP13 + TMP12     <- A + B + C + D + E + F + G + H
        -- TMP17 = MAX TMP15, TMP7
        
        -- TMP18 = TMP16 ROL 1
        
        wait for rising_edge(i_clock); --Seventh clock boundary
        
        -- TMP19 = TMP18 + TMP16    <- 3(a + b)
        -- TMP19 = MAX TMP17, TMP14
        -- TMP20 = TMP19 ROL 3
        
        wait for rising_edge(i_clock); --Eighth clock boundary
        
        -- OUT = TMP20 - TMP19

    end process;
  
end architecture;