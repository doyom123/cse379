extern int lab4(void);	
extern int pin_connect_block_setup_for_uart0(void);
extern int uart_init(void);

int main()
{ 	
   pin_connect_block_setup_for_uart0();
   uart_init();
   lab4();
   //read_character();
   //output_character();
	 
}