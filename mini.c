
#include <LPC17xx.h>
#include <stdio.h>
#include <string.h>
#define DATA_CTRL 0xF << 15
#define RS_CTRL 0x1 << 19
#define EN_CTRL 0x1 << 20
#define DELAY 5000000
void lcd_init(void);
void write_command(void);
void clear_disp(void);
void delay(unsigned int);
void lcd_command_send(void);

void write_data(void);
void lcd_data_send(void);
void clear_ports(void);
void lcd_puts(unsigned char *);
extern unsigned long int temp1, temp2;
unsigned long int temp1 = 0, temp2 = 0;
unsigned int space=10;
int main(void)
{
 unsigned char lcd_line_1[50] = "No. Of people";
 unsigned char lcd_line_2[50] = "";
 unsigned int sen1, sen2, flag1, flag2, count;
 SystemInit();
 SystemCoreClockUpdate();
// Set P0.21-P0.15 as LCD output
 LPC_GPIO0->FIODIR = RS_CTRL | EN_CTRL | DATA_CTRL;
 LPC_GPIO2->FIODIR=1<<11;
 lcd_init();
delay(100000);
 temp1 = 0x80
 lcd_command_send();//Command sent to write to first line of lcd
 delay(800);

 lcd_puts(&lcd_line_1[0]);
 while (1)
 {
 sen1 = (LPC_GPIO2->FIOPIN & (1<<12)) >> 12;
 sen2 = (LPC_GPIO2->FIOPIN & (1<<13)) >> 13;
/*if(!sen1 & !sen2){
continue;
}*/
 if (!sen1 & !flag2) {//if first sensor detects motion and the second sensor has not yet 
detected, flag1 is set to 1(first detector has detected motion)
 flag1 = 1;
 }
 if (!sen2 & !flag1) {//if second sensor detects motion and first sensor has not 
detected,flag2 is set to 1.
 flag2 = 1;
 }
 if (flag1 & !sen2){//if second sensor detects after first sensor has detected, person enters, 
count is increased and space is decreased.
 flag1 = flag2 = 0;//flags are reset, for subsequent iterations
 count++;
 space--;
 }
 if (flag2 & !sen1){//if first sensor detects after second sensor has detected, person leaves, 
count is decreased and space is increased.
 flag1 = flag2 = 0;//flags are subset for subsequent iterations

 count--;
 space++;
 }
if((count>0)&&(!LPC_GPIO0->FIOPIN&&1<<23)//checking if the LDR detects light in the 
day.
{
LPC_GPIO2->FIOSET=1<<11;//if there is atleast one person in the room, the light is 
switched on
}
else
{
LPC_GPIO2->FIOCLR=1<<11;//if there are no people in the room, the light is switched off.
}
 temp1 = 0xC0;
 lcd_command_send();
 delay(800);
 sprintf(lcd_line_2, " %u %u ", space, count);//printing number of people and 
space available in room
 lcd_puts(&lcd_line_2[0]);
delay(DELAY);
}
}
void lcd_init()
{
 clear_ports();
 delay(3200);
 temp2 = (0x30 << 15);
 write_command();

 delay(30000);
 temp2 = (0x30 << 15);
 write_command();
 delay(30000);
 temp2 = (0x30 << 15);
 write_command();
 delay(30000);
 temp2 = (0x20 << 15);
 write_command();
 delay(30000);
 temp1 = 0x28;
 lcd_command_send();
 delay(30000);
 temp1 = 0x0C;
 lcd_command_send();
 delay(800);
 temp1 = 0x06;
 lcd_command_send();
 delay(800);
 temp1 = 0x01;
 lcd_command_send();
 delay(10000);
 temp1 = 0x80;
 lcd_command_send();
 delay(800);
 return; }
void lcd_command_send(void) {

 temp2 = temp1 & 0xF0;
 temp2 = temp2 << 11;
 write_command();
 temp2 = temp1 & 0x0F;
 temp2 = temp2 << 15;
 write_command();
 delay(1000);
 return;
}
void write_command(void)
{
 clear_ports();
 LPC_GPIO0->FIOPIN = temp2;
 LPC_GPIO0->FIOCLR = RS_CTRL;
 LPC_GPIO0->FIOSET = EN_CTRL;
 delay(25);
 LPC_GPIO0->FIOCLR = EN_CTRL;
 return;
}
void lcd_data_send(void)
{
 temp2 = temp1 & 0xF0;
 temp2 = temp2 << 11;
 write_data();
 temp2 = temp1 & 0x0F;
 temp2 = temp2 << 15;
 write_data();
 delay(1000);
 
 return;
}
void write_data(void)
{
 clear_ports();
 LPC_GPIO0->FIOPIN = temp2;
 LPC_GPIO0->FIOSET = RS_CTRL;
 LPC_GPIO0->FIOSET = EN_CTRL;
 delay(25);
 LPC_GPIO0->FIOCLR = EN_CTRL;
 return;
}
void delay (unsigned int limit)
{
 unsigned int i;
 for (i = 0; i < limit; i++);
 return;
}
void clear_disp(void)
{
 temp1 = 0x01;
 lcd_command_send();
 delay(10000);
 return;
}
void clear_ports(void)
 
{
 LPC_GPIO0->FIOCLR = 0xF << 15;
 LPC_GPIO0->FIOCLR = RS_CTRL;
 LPC_GPIO0->FIOCLR = EN_CTRL;
 return;
}
void lcd_puts(unsigned char *buf1)
{
 unsigned int i = 0;
 while (buf1[i] != '\0')
 {
 temp1 = buf1[i++];
 lcd_data_send();
 if (i == 16)
 {
 temp1 = 0xC0;
 lcd_command_send();
 }
 }
 return;
}
