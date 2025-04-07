
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
 
entity elevator_controller_fsm_tb is
end elevator_controller_fsm_tb;

architecture test_bench of elevator_controller_fsm_tb is 
	
	component elevator_controller_fsm is
		Port ( i_clk 	 : in  STD_LOGIC;
			   i_reset 	 : in  STD_LOGIC; -- synchronous
			   i_stop 	 : in  STD_LOGIC;
			   i_up_down : in  STD_LOGIC;
			   o_floor 	 : out STD_LOGIC_VECTOR (3 downto 0));
	end component elevator_controller_fsm;
	
	-- test signals
	signal w_clk, w_reset, w_stop, w_up_down : std_logic := '0';
	signal w_floor : std_logic_vector(3 downto 0) := (others => '0');
  
	-- 50 MHz clock
	constant k_clk_period : time := 20 ns;
	
begin
	-- PORT MAPS ----------------------------------------

	uut_inst : elevator_controller_fsm port map (
		i_clk     => w_clk,
		i_reset   => w_reset,
		i_stop    => w_stop,
		i_up_down => w_up_down,
		o_floor   => w_floor
	);
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------
	
	-- Clock Process ------------------------------------
	clk_process : process
	begin
		w_clk <= '0';
		wait for k_clk_period/2;
		
		w_clk <= '1';
		wait for k_clk_period/2;
	end process clk_process;
	
	
	-- Test Plan Process --------------------------------
	test_process : process 
	begin
    -- i_reset into initial state (o_floor 2)
    w_reset <= '1';  
    wait for k_clk_period;
    assert w_floor = x"2" report "bad reset" severity failure;

    -- clear reset
    w_reset <= '0';

    -- go up a floor: floor 2 → 3
    w_up_down <= '1'; 
    w_stop <= '0';  
    wait for k_clk_period;
    assert w_floor = x"3" report "bad up from floor2" severity failure;

    -- try waiting on floor 3
    w_stop <= '1';  
    wait for k_clk_period * 2;
    assert w_floor = x"3" report "bad wait on floor3" severity failure;

    -- go up again: floor 3 → 4
    w_stop <= '0';
    wait for k_clk_period;
    assert w_floor = x"4" report "bad up from floor3" severity failure;

    -- go back down one floor: floor 4 → 3
    w_up_down <= '0'; 
    wait for k_clk_period;
    assert w_floor = x"3" report "bad down from floor4" severity failure;

    -- go back up to floor 4
    w_up_down <= '1'; 
    wait for k_clk_period;
    assert w_floor = x"4" report "bad up from floor3 (again)" severity failure;

    -- stop at top floor (floor 4)
    w_stop <= '1';  
    wait for k_clk_period;
    assert w_floor = x"4" report "bad wait on floor4" severity failure;

    -- go all the way down: floor 4 → 1 (takes 3 cycles)
    w_stop <= '0';
    w_up_down <= '0';
    wait for 3 * k_clk_period;
    assert w_floor = x"1" report "bad lowering to first floor" severity failure;

    wait; -- wait forever
end process;
	-----------------------------------------------------	
	
end test_bench;
