//int temp1,temp2;
#include <LPC17xx.h>
#include <stdio.h>
#include <string.h>

#define DATA_CTRL 0xF << 15
#define RS_CTRL 0x1 << 19
#define EN_CTRL 0x1 << 20
#define STEPPER_CTRL 0x3F << 23  // P0.23 - P0.28 for stepper motor control

#define DELAY 500000  // Delay between stepper motor steps
#define MAX_CAPACITY 20

int people_in_room = 0;
int people_entering = 0;
int people_leaving = 0;
int led_state = 0;  // Keep track of the current LED state
int temp1,temp2;
void lcd_init(void);
void write_command(void);
void clear_disp(void);
void delay(unsigned int);
void lcd_command_send(void);
void write_data(void);
void clear_ports(void);
void lcd_puts(unsigned char *);
void update_leds(void);
void control_stepper_motor(int direction);

int main(void)
{
    unsigned char lcd_line_1[50] = "PEOPLE COUNTER";
    unsigned char lcd_line_2[50] = "";
    unsigned int sen1, sen2, flag1 = 0, flag2 = 0;

    SystemInit();
    SystemCoreClockUpdate();

    // Set P0.15-P0.22 as LED output
    LPC_GPIO0->FIODIR |= 0xFF << 15;

    // Set P0.21-P0.15 as LCD output
    LPC_GPIO0->FIODIR = RS_CTRL | EN_CTRL | DATA_CTRL;

    // Set P0.23 - P0.28 as stepper motor output
    LPC_GPIO0->FIODIR |= STEPPER_CTRL;

    // Initialize LEDs and turn on the stepper motor
    LPC_GPIO0->FIOCLR = 0xFF << 15;

    lcd_init();
    delay(100000);

    temp1 = 0x80;
    lcd_command_send();
    delay(800);
    lcd_puts(&lcd_line_1[0]);

    while (1)
    {
        sen1 = (LPC_GPIO2->FIOPIN & (1 << 12)) >> 12;
        sen2 = (LPC_GPIO2->FIOPIN & (1 << 13)) >> 13;

        // Person entering
        if (!sen1 && !flag2 && people_in_room < MAX_CAPACITY)
        {
            people_entering++;
            people_in_room++;
            flag1 = 1;
            update_leds();
            control_stepper_motor(0); // Rotate stepper motor clockwise
        }

        // Person leaving
        if (!sen2 && !flag1 && people_in_room > 0)
        {
            people_leaving++;
            people_in_room--;
            flag2 = 1;
            update_leds();
            control_stepper_motor(1); // Rotate stepper motor counter-clockwise
        }

        // Reset flags when both sensors are clear
        if (sen1 && sen2)
        {
            flag1 = flag2 = 0;
        }

        temp1 = 0xC0;
        lcd_command_send();
        delay(800);
        sprintf(lcd_line_2, "In: %d, Out: %d, Capacity: %d/%d", people_entering, people_leaving, people_in_room, MAX_CAPACITY);
        lcd_puts(&lcd_line_2[0]);

        delay(DELAY);
    }
}

void update_leds(void)
{
    // Calculate the new LED state based on the number of people in the room
    led_state = people_in_room / 2;

    // Update the LED outputs
    LPC_GPIO0->FIOPIN = ((1 << led_state) - 1) << 15;
}

void control_stepper_motor(int direction) {
    // Direction: 0 = Clockwise, 1 = Counter-Clockwise
    static int step_sequence[4] = {0x1F, 0x3F, 0x2F, 0x17};
    static int step_index = 0;

    // Set the stepper motor GPIO pins based on the current step
    LPC_GPIO0->FIOPIN = (LPC_GPIO0->FIOPIN & ~STEPPER_CTRL) | (step_sequence[step_index] << 23);

    // Increment/decrement the step index based on the direction
    if (direction == 0) {
        step_index = (step_index + 1) % 4;
    } else {
        step_index = (step_index - 1) < 0 ? 3 : step_index - 1;
    }

    // Delay for the stepper motor to move to the next step
    delay(DELAY);
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
    return;
}

void lcd_command_send(void)
{
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

void delay(unsigned int limit)
{
    unsigned int i;
    for (i = 0; i < limit; i++)
        ;
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