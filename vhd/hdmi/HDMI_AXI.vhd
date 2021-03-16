-- vim:ts=3:noexpandtab:
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HDMI_AXI is
		  generic (
								-- Users to add parameters here

								-- User parameters ends
								-- Do not modify the parameters beyond this line


								-- Parameters of Axi Slave Bus Interface S00_AXI
								C_S00_AXI_DATA_WIDTH		: integer	:= 32;
								C_S00_AXI_ADDR_WIDTH		: integer	:= 6;

								-- Parameters of Axi Master Bus Interface M00_AXI
								C_M00_AXI_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"10000000";
								C_M00_AXI_BURST_LEN		: integer	:= 128;
								C_M00_AXI_ID_WIDTH		: integer	:= 6;
								C_M00_AXI_ADDR_WIDTH		: integer	:= 32;
								C_M00_AXI_DATA_WIDTH		: integer	:= 64;
								C_M00_AXI_AWUSER_WIDTH	: integer	:= 0;
								C_M00_AXI_ARUSER_WIDTH	: integer	:= 0;
								C_M00_AXI_WUSER_WIDTH	: integer	:= 0;
								C_M00_AXI_RUSER_WIDTH	: integer	:= 0;
								C_M00_AXI_BUSER_WIDTH	: integer	:= 0
					 );
		  port (
								-- Users to add ports here

								-- Résultat du chargement mémoire, valide si valid. envoi de la donnée suivante
								-- Si ack est asserté.
							r						: out std_logic_vector(7 downto 0);
							g						: out std_logic_vector(7 downto 0);
							b						: out std_logic_vector(7 downto 0);
							valid : out std_logic;
							ack : in std_logic;
							
							pixel_clk : in std_logic;

								-- Signaux de debug.
							debug0 : out std_logic_vector(3 downto 0);
							debug1 : out std_logic_vector(3 downto 0);
							debug2 : out std_logic_vector(3 downto 0);
							debug3 : out std_logic_vector(3 downto 0);
							debug4 : out std_logic_vector(3 downto 0);
							debug5 : out std_logic_vector(3 downto 0);
							debug6 : out std_logic_vector(3 downto 0);
							debug7 : out std_logic_vector(3 downto 0);
							debug8 : out std_logic_vector(3 downto 0);

								-- Signal de reset de la mémoire. reset_mem_ack est asserté quand le reset 
								-- c'est bien passé.
							reset_mem : in std_logic;
							reset_mem_ack : out std_logic;

								-- GENERATED FIFO INTERFACE
							fifo_prog_full : in std_logic;
							fifo_valid : in std_logic;
							fifo_empty : in std_logic;

							fifo_din : out std_logic_vector(63 downto 0 );
							fifo_wr_en : out std_logic;

							fifo_dout : in std_logic_vector(63 downto 0 );
							fifo_rd_en : out std_logic;
							-- User ports ends

							-- Do not modify the ports beyond this line

							-- Ports of Axi Slave Bus Interface S00_AXI
							s00_axi_aclk	: in std_logic;
							s00_axi_aresetn	: in std_logic;
							s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
							s00_axi_awprot	: in std_logic_vector(2 downto 0);
							s00_axi_awvalid	: in std_logic;
							s00_axi_awready	: out std_logic;
							s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
							s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
							s00_axi_wvalid	: in std_logic;
							s00_axi_wready	: out std_logic;
							s00_axi_bresp	: out std_logic_vector(1 downto 0);
							s00_axi_bvalid	: out std_logic;
							s00_axi_bready	: in std_logic;
							s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
							s00_axi_arprot	: in std_logic_vector(2 downto 0);
							s00_axi_arvalid	: in std_logic;
							s00_axi_arready	: out std_logic;
							s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
							s00_axi_rresp	: out std_logic_vector(1 downto 0);
							s00_axi_rvalid	: out std_logic;
							s00_axi_rready	: in std_logic;

							-- Ports of Axi Master Bus Interface M00_AXI
							m00_axi_aclk	: in std_logic;
							m00_axi_aresetn	: in std_logic;
							m00_axi_arid	: out std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
							m00_axi_araddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
							m00_axi_arlen	: out std_logic_vector(7 downto 0);
							m00_axi_arsize	: out std_logic_vector(2 downto 0);
							m00_axi_arburst	: out std_logic_vector(1 downto 0);
							m00_axi_arlock	: out std_logic;
							m00_axi_arcache	: out std_logic_vector(3 downto 0);
							m00_axi_arprot	: out std_logic_vector(2 downto 0);
							m00_axi_arqos	: out std_logic_vector(3 downto 0);
							m00_axi_aruser	: out std_logic_vector(C_M00_AXI_ARUSER_WIDTH-1 downto 0);
							m00_axi_arvalid	: out std_logic;
							m00_axi_arready	: in std_logic;
							m00_axi_rid	: in std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
							m00_axi_rdata	: in std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
							m00_axi_rresp	: in std_logic_vector(1 downto 0);
							m00_axi_rlast	: in std_logic;
							m00_axi_ruser	: in std_logic_vector(C_M00_AXI_RUSER_WIDTH-1 downto 0);
							m00_axi_rvalid	: in std_logic;
							m00_axi_rready	: out std_logic
				 );
end HDMI_AXI;

architecture arch_imp of HDMI_AXI is

		  component HDMI_AXI_Slave is
					 generic (
										  C_S_AXI_MBURST_LEN	: integer	:= 16; -- Strange but I need it!
										  C_S_AXI_DATA_WIDTH	: integer	:= 32;
										  C_S_AXI_ADDR_WIDTH	: integer	:= 6
								);
					 port (

									  master_base_address : out std_logic_vector(31 downto 0);
									  master_burst_nb : out std_logic_vector(31 downto 0);

									  master_start_read			: out std_logic;
									  master_busy				: in std_logic;
									  master_sensor			: in std_logic_vector(31 downto 0);  -- For various debug signals
									  reset_mem : in std_logic;

									  S_AXI_ACLK	: in std_logic;
									  S_AXI_ARESETN	: in std_logic;
									  S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
									  S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
									  S_AXI_AWVALID	: in std_logic;
									  S_AXI_AWREADY	: out std_logic;
									  S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
									  S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
									  S_AXI_WVALID	: in std_logic;
									  S_AXI_WREADY	: out std_logic;
									  S_AXI_BRESP	: out std_logic_vector(1 downto 0);
									  S_AXI_BVALID	: out std_logic;
									  S_AXI_BREADY	: in std_logic;
									  S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
									  S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
									  S_AXI_ARVALID	: in std_logic;
									  S_AXI_ARREADY	: out std_logic;
									  S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
									  S_AXI_RRESP	: out std_logic_vector(1 downto 0);
									  S_AXI_RVALID	: out std_logic;
									  S_AXI_RREADY	: in std_logic
							);
		  end component HDMI_AXI_Slave;

		  component HDMI_AXI_Master is
					 generic (
										  C_M_AXI_BURST_LEN		: integer	:= 16;
										  C_M_AXI_ID_WIDTH		: integer	:= 1;
										  C_M_AXI_ADDR_WIDTH	: integer	:= 32;
										  C_M_AXI_DATA_WIDTH	: integer	:= 32;
										  C_M_AXI_AWUSER_WIDTH	: integer	:= 0;
										  C_M_AXI_ARUSER_WIDTH	: integer	:= 0;
										  C_M_AXI_WUSER_WIDTH	: integer	:= 0;
										  C_M_AXI_RUSER_WIDTH	: integer	:= 0;
										  C_M_AXI_BUSER_WIDTH	: integer	:= 0
								);
					 port (

									  master_base_address : in std_logic_vector(31 downto 0);
									  master_burst_nb : in std_logic_vector(31 downto 0);
									  master_start_read : in std_logic;
									  master_busy   : out std_logic;
									  master_sensor : out std_logic_vector(31 downto 0);  -- For various debug signals

									  prog_full : in std_logic;

									  fifo_din : out std_logic_vector(63 downto 0);
									  fifo_wr_en   : out std_logic;

									  M_AXI_ACLK	: in std_logic;
									  M_AXI_ARESETN	: in std_logic;
									  M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
									  M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
									  M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
									  M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
									  M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
									  M_AXI_ARLOCK	: out std_logic;
									  M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
									  M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
									  M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
									  M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
									  M_AXI_ARVALID	: out std_logic;
									  M_AXI_ARREADY	: in std_logic;
									  M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
									  M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
									  M_AXI_RRESP	: in std_logic_vector(1 downto 0);
									  M_AXI_RLAST	: in std_logic;
									  M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
									  M_AXI_RVALID	: in std_logic;
									  M_AXI_RREADY	: out std_logic
							);
		  end component HDMI_AXI_Master;

		  signal master_base_address		: std_logic_vector(31 downto 0);
		  signal master_burst_nb	: std_logic_vector(31 downto 0);
		  signal master_start_read			: std_logic;
		  signal master_busy		  		: std_logic;
		  signal master_sensor			: std_logic_vector(31 downto 0);

		  signal odd : std_logic;
		  signal odd_dout : std_logic_vector(31 downto 0);

		  signal reset_mem_ack_d : std_logic;

		  signal pixel : std_logic_vector(31 downto 0);

begin

		  -- Instantiation of Axi Bus Interface S00_AXI
		  HDMI_AXI_Slave_inst : HDMI_AXI_Slave
		  generic map (
									 C_S_AXI_MBURST_LEN	=> C_M00_AXI_BURST_LEN,
									 C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
									 C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
						  )
		  port map (

								 master_base_address => master_base_address,
								 master_burst_nb => master_burst_nb,
								 master_start_read => master_start_read,
								 master_busy   => master_busy,
								 master_sensor => master_sensor,

								 reset_mem => reset_mem,



								 S_AXI_ACLK	=> s00_axi_aclk,
								 S_AXI_ARESETN	=> s00_axi_aresetn,
								 S_AXI_AWADDR	=> s00_axi_awaddr,
								 S_AXI_AWPROT	=> s00_axi_awprot,
								 S_AXI_AWVALID	=> s00_axi_awvalid,
								 S_AXI_AWREADY	=> s00_axi_awready,
								 S_AXI_WDATA	=> s00_axi_wdata,
								 S_AXI_WSTRB	=> s00_axi_wstrb,
								 S_AXI_WVALID	=> s00_axi_wvalid,
								 S_AXI_WREADY	=> s00_axi_wready,
								 S_AXI_BRESP	=> s00_axi_bresp,
								 S_AXI_BVALID	=> s00_axi_bvalid,
								 S_AXI_BREADY	=> s00_axi_bready,
								 S_AXI_ARADDR	=> s00_axi_araddr,
								 S_AXI_ARPROT	=> s00_axi_arprot,
								 S_AXI_ARVALID	=> s00_axi_arvalid,
								 S_AXI_ARREADY	=> s00_axi_arready,
								 S_AXI_RDATA	=> s00_axi_rdata,
								 S_AXI_RRESP	=> s00_axi_rresp,
								 S_AXI_RVALID	=> s00_axi_rvalid,
								 S_AXI_RREADY	=> s00_axi_rready
					  );

		  -- Instantiation of Axi Bus Interface M00_AXI
		  HDMI_AXI_Master_inst : HDMI_AXI_Master
		  generic map (
									 C_M_AXI_BURST_LEN		=> C_M00_AXI_BURST_LEN,
									 C_M_AXI_ID_WIDTH		=> C_M00_AXI_ID_WIDTH,
									 C_M_AXI_ADDR_WIDTH	=> C_M00_AXI_ADDR_WIDTH,
									 C_M_AXI_DATA_WIDTH	=> C_M00_AXI_DATA_WIDTH,
									 C_M_AXI_AWUSER_WIDTH	=> C_M00_AXI_AWUSER_WIDTH,
									 C_M_AXI_ARUSER_WIDTH	=> C_M00_AXI_ARUSER_WIDTH,
									 C_M_AXI_WUSER_WIDTH	=> C_M00_AXI_WUSER_WIDTH,
									 C_M_AXI_RUSER_WIDTH	=> C_M00_AXI_RUSER_WIDTH,
									 C_M_AXI_BUSER_WIDTH	=> C_M00_AXI_BUSER_WIDTH
						  )
		  port map (

								 master_base_address => master_base_address,

								 master_burst_nb => master_burst_nb,

								 master_start_read => master_start_read,
								 master_busy   => master_busy,
								 master_sensor => master_sensor,

								 prog_full => fifo_prog_full,

								 fifo_din => fifo_din,
								 fifo_wr_en => fifo_wr_en,

								 M_AXI_ACLK	=> m00_axi_aclk,
								 M_AXI_ARESETN	=> m00_axi_aresetn,
								 M_AXI_ARID	=> m00_axi_arid,
								 M_AXI_ARADDR	=> m00_axi_araddr,
								 M_AXI_ARLEN	=> m00_axi_arlen,
								 M_AXI_ARSIZE	=> m00_axi_arsize,
								 M_AXI_ARBURST	=> m00_axi_arburst,
								 M_AXI_ARLOCK	=> m00_axi_arlock,
								 M_AXI_ARCACHE	=> m00_axi_arcache,
								 M_AXI_ARPROT	=> m00_axi_arprot,
								 M_AXI_ARQOS	=> m00_axi_arqos,
								 M_AXI_ARUSER	=> m00_axi_aruser,
								 M_AXI_ARVALID	=> m00_axi_arvalid,
								 M_AXI_ARREADY	=> m00_axi_arready,
								 M_AXI_RID	=> m00_axi_rid,
								 M_AXI_RDATA	=> m00_axi_rdata,
								 M_AXI_RRESP	=> m00_axi_rresp,
								 M_AXI_RLAST	=> m00_axi_rlast,
								 M_AXI_RUSER	=> m00_axi_ruser,
								 M_AXI_RVALID	=> m00_axi_rvalid,
								 M_AXI_RREADY	=> m00_axi_rready
					  );

		  -- La FIFO est de taille 64 bit, on récupère donc 2 pixels à la fois.
		  pixel <= fifo_dout(63 downto 32) when odd = '0' else fifo_dout(31 downto 0);

		  process (pixel_clk)
		  begin
					 if rising_edge(pixel_clk) then
								if s00_axi_aresetn = '0' then
										  odd <= '0';
								else
										  if ack = '1' then
													 odd <= not odd;
										  end if;
								end if;

								reset_mem_ack <= reset_mem_ack_d;
					 end if;
		  end process;
		  
		  fifo_rd_en <= '1' when ack = '1' and odd = '0' else '0';
		  valid <= not fifo_empty;
		  
		  reset_mem_ack_d <=  fifo_empty; -- Le reset a bien été effectué si la FIFO est vide. 

		  -- Signaux de debug.
		  debug0 <= master_sensor(3 downto 0);
		  debug1 <= master_sensor(7 downto 4);
		  debug2 <= master_sensor(11 downto 8);
		  debug3 <= master_sensor(15 downto 12);
		  debug4 <= master_sensor(19 downto 16);
		  debug5 <= master_sensor(23 downto 20);
		  debug6 <= master_sensor(27 downto 24);
		  debug7 <= master_sensor(31 downto 28);
		  debug8 <= fifo_prog_full & fifo_empty & "0" & ack;


		  r <= pixel(23 downto 16);
		  g <= pixel(15 downto 8);
		  b <= pixel(7 downto 0);
--
-- User logic ends
--
end arch_imp;
