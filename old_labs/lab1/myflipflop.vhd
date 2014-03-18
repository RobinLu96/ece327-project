library ieee;
use ieee.std_logic_1164.all;

entity myflipflop is
  port(  i_clock   -- clock
       , i_d       -- flip-flop input
       , i_ce      -- flip-flop chip enable
       , i_reset   -- flip-flop reset
       , i_sel     -- mux selector 
       , i_d2      -- the second data input
       : in std_logic; 
         o_q       -- flip-flop output for basic flop
       , o_q_a     -- flip-flop output for part (a)
       , o_q_b     -- flip-flop output for part (b)
       , o_q_c     -- flip-flop output for part (c)
       , o_q_d     -- flip-flop output for part (d)
       : out std_logic 
  );
end myflipflop;

architecture main of myflipflop is

signal proc_b_intermediary, proc_c_intermediary, proc_d_intermediary : std_logic;

begin

  basic : process
  begin
      wait until rising_edge(i_clock);
      o_q <= i_d;
  end process; 

  proc_a : process
  begin
      wait until rising_edge(i_clock);
      o_q_a <= i_d and (not i_reset);
  end process;

  proc_b : process
  begin
      proc_b_intermediary <= (i_clock and i_ce);
      wait until rising_edge(proc_b_intermediary);
      o_q_b <= i_d;
  end process;

  proc_c : process
  begin
      wait until rising_edge(i_clock);      
      if (i_sel = '0') then
        o_q_c <= i_d;
      else
        o_q_c <= i_d2;
      end if;
  end process;

  proc_d : process
  begin
      wait until rising_edge(i_clock);      
      if (i_sel = '0') then
        proc_d_intermediary <= i_d;
      else
        proc_d_intermediary <= (not proc_d_intermediary);
      end if;

      o_q_d <= proc_d_intermediary;
  end process;

end architecture;
