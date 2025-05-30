library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity elevator_controller_fsm is
    Port (
        i_clk     : in  STD_LOGIC;
        i_reset   : in  STD_LOGIC;
        i_stop    : in  STD_LOGIC;
        i_up_down : in  STD_LOGIC;
        o_floor   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end elevator_controller_fsm;

architecture Behavioral of elevator_controller_fsm is

    type sm_floor is (s_floor1, s_floor2, s_floor3, s_floor4);
    signal f_Q, f_Q_next: sm_floor;

begin

    -- State Register (synchronous reset)
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                f_Q <= s_floor2;  -- Start at floor 2
            else
                f_Q <= f_Q_next;
            end if;
        end if;
    end process;

    -- Next State Logic
    f_Q_next <= f_Q when i_stop = '1' else
                s_floor2 when (f_Q = s_floor1 and i_up_down = '1') else
                s_floor3 when (f_Q = s_floor2 and i_up_down = '1') else
                s_floor4 when (f_Q = s_floor3 and i_up_down = '1') else
                s_floor3 when (f_Q = s_floor4 and i_up_down = '0') else 
                s_floor2 when (f_Q = s_floor3 and i_up_down = '0') else
                s_floor1 when (f_Q = s_floor2 and i_up_down = '0') else
                f_Q;

    -- Output Logic
    with f_Q select
        o_floor <= "0001" when s_floor1,
                   "0010" when s_floor2,
                   "0011" when s_floor3,
                   "0100" when s_floor4,
                   "0001" when others;  

end Behavioral;

