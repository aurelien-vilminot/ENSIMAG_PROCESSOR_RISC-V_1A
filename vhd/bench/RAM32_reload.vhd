library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

use work.PKG.all;
use work.txt_util.all;


entity RAM32 is
    generic (
        -- Memory configuration
        MEMORY_SIZE : positive ;

        -- Memory initialization
        FILE_NAME   : string   := "none"
    );
    port (
        -- Clock
        clk  : in  std_logic ;
        rst  : in  std_logic ;

        -- Memory slave interface
        addr : in  waddr ;
        size : in  RF_SIZE_select ;
        do   : out w32 ;
        di   : in  w32 ;
        ce   : in  std_logic ;
        we   : in  std_logic
    );
end entity;


architecture behavioral of RAM32 is
    function log2ceil (x:positive) return natural is
        variable i : natural := x-1 ;
        variable n : natural := 0 ;
    begin
        while i > 0 loop
            n := n + 1; i := i / 2;
        end loop;
        return n;
    end function;

    -- Constants
    constant N_BIT        : natural := log2ceil( MEMORY_SIZE ) ;
    constant ADDRESS_MASK : waddr   := to_unsigned( 2**N_BIT - 1, waddr'length ) ;

    -- Type
    type     memory_type is array (natural range 0 to MEMORY_SIZE-1) of w32;
    signal   internal_memory : memory_type := (others => w32_zero);

    -- Procedure to initilize a memory container from a ".mem" file
    procedure memory_initialize_from_file (
                 file_name    : in  string ;
        signal   memory       : out memory_type ;
        constant MEMORY_SIZE  : in  positive
    ) is
        file data_file : text open read_mode is file_name ;
        variable line_input : line ;
        variable data_line : std_logic_vector(31 downto 0);
        variable write_index : integer := 0;
        variable c : character;
    begin
        while not endfile(data_file) loop
            readline(data_file, line_input);
            if line_input(1)='@' then -- read an address
                read(line_input, c);
                hread(line_input, data_line);
                write_index := to_integer( unsigned( data_line ) );
                report "@ " & hstr(data_line) & " = " & integer'image(write_index) severity note;
            elsif 0<=write_index and write_index < MEMORY_SIZE/4 then
                hread(line_input, data_line);
                memory(write_index) <= w32(data_line);
                report "memory[" & integer'image(write_index) & "] = " & hstr(data_line) severity note;
                write_index := write_index + 1;
            end if;
        end loop;
    end procedure;

    -- Internal signals
    signal internal_address : waddr;
    signal internal_index   : integer;

    -- Signaux pour les stores
    signal we_0, we_1, we_2, we_3 : std_logic := '0';
    signal DATA_tmp : w32 := w32_zero;
begin

    process (addr, internal_address)
    begin
        internal_address <= addr and ADDRESS_MASK ;
        internal_index   <= to_integer(internal_address) / 4 ;
    end process;

    store : process(clk, we)
    begin
        DATA_tmp <= di;
        -- Le we ce fait sur 4 bit afin de pouvoir choisir
        -- le we sur chaque sous octet du mot
        if addr(1) = '0' then
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_word =>
                        we_0 <= we;
                        we_1 <= we;
                        we_2 <= we;
                        we_3 <= we;
                    when RF_SIZE_half =>
                        we_0 <= we;
                        we_1 <= we;
                    when RF_SIZE_byte =>
                        we_0 <= we;
                    when others => 
			we_0 <= we;
                        we_1 <= we;
                        we_2 <= we;
                        we_3 <= we;
                end case;
            else
                if size = RF_SIZE_byte then
                    we_1 <= we;
                    DATA_tmp( 15 downto 8 ) <= di( 7 downto 0 );
                end if;
            end if;
        else
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_half =>
                        we_2 <= we;
                        we_3 <= we;
                        DATA_tmp( 31 downto 16 ) <= di( 15 downto 0 );
                    when RF_SIZE_byte =>
                        we_2 <= we;
                        DATA_tmp( 23 downto 16 ) <= di( 7 downto 0 );
                    when others => null;
                end case;
            else
                if size = RF_SIZE_byte then
                    we_3 <= we;
                    DATA_tmp( 31 downto 24 ) <= di( 7 downto 0 );
                end if;
            end if;
        end if;
    end process store;

    process(clk, internal_memory, internal_index, di)
        variable ram_init : boolean := false;
    begin

        if rising_edge(clk) then
            -- Initialize memory
            if (file_name/="none" and not ram_init)  then
                memory_initialize_from_file(FILE_NAME, internal_memory, MEMORY_SIZE);
                ram_init := true;
            end if;

            -- Memory behavior (Read First)
            if ce = '1'  then
                -- Check that we is properly set when doing a read
                if we = '0' then
                    do <= internal_memory(internal_index); -- Read
                else
                    do <= (others => 'U');
                end if;
                if we_0='1' then
                    internal_memory(internal_index)( 7 downto 0 )  <= DATA_tmp( 7 downto 0 ); -- Write
                end if;
                if we_1='1' then
                    internal_memory(internal_index)( 15 downto 8 )  <= DATA_tmp( 15 downto 8 ); -- Write
                end if;
                if we_2='1' then
                    internal_memory(internal_index)( 23 downto 16 )  <= DATA_tmp( 23 downto 16 ); -- Write
                end if;
                if we_3='1' then
                    internal_memory(internal_index)( 31 downto 24 )  <= DATA_tmp( 31 downto 24 ); -- Write
                end if;
            end if;
        end if;

    end process;

end architecture;
