#include <LPC17xx.h>
#include <stdio.h>
#include <string.h>

// Pin and control definitions
#define DATA_CTRL 0xF << 15
#define RS_CTRL 0x1 << 19
#define EN_CTRL 0x1 << 20

// LED definitions
#define LED_P0_MASK ((0x3F << 23))  // P0.23 to P0.28
#define LED_P2_MASK ((0x3 << 0))    // P2.0 to P2.1

// Timing and capacity definitions
#define DELAY 500000                // Main loop delay
#define LED_UPDATE_DELAY 50000      // LED update delay
#define LED_STABLE_TIME 100000      // LED stability time
#define MAX_CAPACITY 20             // Maximum people capacity
#define SENSOR_DELAY 300000         // Sensor debouncing delay
#define BASE_STEP_DELAY 5000        // Base stepper delay (5ms)
#define MIN_STEP_DELAY 200          // Minimum stepper delay
#define MAX_SPEED_THRESHOLD 12      // Maximum speed threshold

// Stepper motor step sequence
const uint8_t step_pos[] = {0x3, 0x9, 0xC, 0x6}; // Full step sequence

// Global variables
int people_in_room = 0;
int prev_people_count = 0;
int people_entering = 0;
int people_leaving = 0;
int led_state = 0;
int temp1, temp2;
volatile uint32_t current_step = 0;

// Function prototypes
void lcd_init(void);
void write_command(void);
void clear_disp(void);
void delay(unsigned int);
void lcd_command_send(void);
void lcd_data_send(void);
void write_data(void);
void clear_ports(void);
void lcd_puts(unsigned char *);
void update_leds(void);
void delay_us(uint32_t us);
void init_timer0(void);

// Timer-based microsecond delay
void delay_us(uint32_t us) {
    LPC_TIM0->PR = 0;
    LPC_TIM0->MR0 = (SystemCoreClock / 1000000) * us - 1;
    LPC_TIM0->MCR = 0x04;
    LPC_TIM0->TCR = 0x02;
    LPC_TIM0->TCR = 0x01;
    while (LPC_TIM0->TCR & 0x01);
}

// Initialize Timer0 for continuous stepper control
void init_timer0(void) {
    uint32_t timer_count;
    
    LPC_SC->PCONP |= (1 << 1);
    
    LPC_TIM0->PR = 0;
    timer_count = (SystemCoreClock / 1000000) * BASE_STEP_DELAY;
    LPC_TIM0->MR0 = timer_count;
    LPC_TIM0->MCR = 3;
    
    NVIC_EnableIRQ(TIMER0_IRQn);
}

// Timer0 IRQ Handler - Updates stepper motor position
void TIMER0_IRQHandler(void) {
    uint32_t current_delay;
    uint32_t timer_count;
    int effective_people;
    
    LPC_TIM0->IR = 1;
    
    if (people_in_room > 0) {
        LPC_GPIO0->FIOPIN = (step_pos[current_step % 4] << 4);
        current_step++;
        
        effective_people = (people_in_room > MAX_SPEED_THRESHOLD) ? 
                         MAX_SPEED_THRESHOLD : people_in_room;
        
        current_delay = BASE_STEP_DELAY / (effective_people + 1);
        
        if (current_delay < MIN_STEP_DELAY) {
            current_delay = MIN_STEP_DELAY;
        }
        
        timer_count = (SystemCoreClock / 1000000) * current_delay;
        if (timer_count == 0) timer_count = 1;
        LPC_TIM0->MR0 = timer_count;
    } else {
        LPC_GPIO0->FIOCLR = (0x0F << 4);
    }
}

// Fixed LED control function with proper intensity
void update_leds(void) {
    uint32_t p0_leds = 0;
    uint32_t p2_leds = 0;
    int i;
    int p0_count;
    int p2_count;
    
    // Clear all LEDs first
    LPC_GPIO0->FIOCLR = LED_P0_MASK;
    LPC_GPIO2->FIOCLR = LED_P2_MASK;
    
    // Calculate number of LEDs to light
    led_state = (people_in_room > MAX_CAPACITY) ? MAX_CAPACITY : people_in_room;
    led_state = (led_state + 1) / 2;  // Convert to number of LEDs (2 people per LED)
    
    if (led_state > 0) {
        // Handle LD2-LD7 (P0.23-P0.28)
        p0_count = (led_state > 6) ? 6 : led_state;
        
        // Set all P0 LEDs at once for consistent intensity
        for (i = 0; i < p0_count; i++) {
            p0_leds |= (1u << (23 + i));
        }
        if (p0_leds) {
            LPC_GPIO0->FIOSET = p0_leds;
        }
        
        // Handle LD8-LD9 (P2.0-P2.1)
        if (led_state > 6) {
            p2_count = led_state - 6;
            if (p2_count > 2) p2_count = 2;
            
            // Set all P2 LEDs at once
            for (i = 0; i < p2_count; i++) {
                p2_leds |= (1u << i);
            }
            if (p2_leds) {
                LPC_GPIO2->FIOSET = p2_leds;
            }
        }
    }
    
    // Allow LEDs to stabilize
    delay(LED_STABLE_TIME);
}

// LCD Functions
void clear_disp(void) {
    temp1 = 0x01;
    lcd_command_send();
    delay(10000);
}

void write_command(void) {
    clear_ports();
    LPC_GPIO0->FIOPIN = temp2;
    LPC_GPIO0->FIOCLR = RS_CTRL;
    LPC_GPIO0->FIOSET = EN_CTRL;
    delay(25);
    LPC_GPIO0->FIOCLR = EN_CTRL;
}

void write_data(void) {
    clear_ports();
    LPC_GPIO0->FIOPIN = temp2;
    LPC_GPIO0->FIOSET = RS_CTRL;
    LPC_GPIO0->FIOSET = EN_CTRL;
    delay(25);
    LPC_GPIO0->FIOCLR = EN_CTRL;
}

void lcd_command_send(void) {
    temp2 = temp1 & 0xF0;
    temp2 = temp2 << 11;
    write_command();
    temp2 = temp1 & 0x0F;
    temp2 = temp2 << 15;
    write_command();
    delay(1000);
}

void lcd_data_send(void) {
    temp2 = temp1 & 0xF0;
    temp2 = temp2 << 11;
    write_data();
    temp2 = temp1 & 0x0F;
    temp2 = temp2 << 15;
    write_data();
    delay(1000);
}

void lcd_init(void) {
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
}

void clear_ports(void) {
    LPC_GPIO0->FIOCLR = 0xF << 15;
    LPC_GPIO0->FIOCLR = RS_CTRL;
    LPC_GPIO0->FIOCLR = EN_CTRL;
}

void lcd_puts(unsigned char *buf1) {
    unsigned int i = 0;
    uint8_t len = strlen(buf1);
    
    for (i = 0; i < len && i < 16; i++) {
        temp1 = buf1[i];
        lcd_data_send();
    }
    
    for (; i < 16; i++) {
        temp1 = ' ';
        lcd_data_send();
    }
}

void delay(unsigned int limit) {
    volatile unsigned int i;
    for (i = 0; i < limit; i++);
}

int main(void) {
    // Variable declarations at the start of main
    unsigned char lcd_line_1[17] = "PEOPLE COUNTER   ";
    unsigned char lcd_line_2[17] = "";
    unsigned int sen1, sen2, flag1 = 0, flag2 = 0;
    unsigned int prev_sen1 = 1, prev_sen2 = 1;

    // System initialization
    SystemInit();
    SystemCoreClockUpdate();

    // Configure LED pins
    LPC_PINCON->PINSEL1 &= ~(0xFF << 14);  // Clear P0.23-P0.28 pin functions
    LPC_PINCON->PINSEL4 &= ~(0xF << 0);    // Clear P2.0-P2.1 pin functions
    
    // Configure drive strength and pull-up resistors
    LPC_PINCON->PINMODE1 &= ~(0xFF << 14);  // Enable pull-up for P0.23-P0.28
    LPC_PINCON->PINMODE4 &= ~(0xF << 0);    // Enable pull-up for P2.0-P2.1

    // Set directions
    LPC_GPIO0->FIODIR |= LED_P0_MASK;
    LPC_GPIO2->FIODIR |= LED_P2_MASK;
    LPC_GPIO0->FIODIR |= (0x0F << 4);  // Stepper motor outputs
    LPC_GPIO0->FIODIR |= RS_CTRL | EN_CTRL | DATA_CTRL;  // LCD outputs

    // Configure sensor inputs
    LPC_GPIO2->FIODIR &= ~((1 << 12) | (1 << 13));
    LPC_PINCON->PINMODE4 &= ~(0xF << 24);
    LPC_PINCON->PINMODE4 |= (0x5 << 24);

    // Clear all outputs initially
    LPC_GPIO0->FIOCLR = LED_P0_MASK;
    LPC_GPIO2->FIOCLR = LED_P2_MASK;
    LPC_GPIO0->FIOCLR = (0x0F << 4);
    delay(LED_STABLE_TIME);

    // Initialize peripherals
    init_timer0();
    lcd_init();
    delay(100000);

    // Initialize display
    clear_disp();
    temp1 = 0x80;
    lcd_command_send();
    delay(800);
    lcd_puts(lcd_line_1);

    // Start Timer0
    LPC_TIM0->TCR = 1;

    // Main loop
    while (1) {
        sen1 = (LPC_GPIO2->FIOPIN & (1 << 12)) >> 12;
        sen2 = (LPC_GPIO2->FIOPIN & (1 << 13)) >> 13;

        // Person entering
        if (!sen1 && prev_sen1 && !flag2 && people_in_room < MAX_CAPACITY) {
            people_entering++;
            people_in_room++;
            flag1 = 1;
            delay(SENSOR_DELAY);
        }

        // Person leaving
        if (!sen2 && prev_sen2 && !flag1 && people_in_room > 0) {
            people_leaving++;
            people_in_room--;
            flag2 = 1;
            delay(SENSOR_DELAY);
        }

        // Reset flags
        if (sen1 && sen2) {
            flag1 = flag2 = 0;
        }

        // Update LED display only when count changes
        if (people_in_room != prev_people_count) {
            update_leds();
            prev_people_count = people_in_room;
            delay(LED_UPDATE_DELAY);
        }

        // Update previous sensor states
        prev_sen1 = sen1;
        prev_sen2 = sen2;

        // Update LCD display
        temp1 = 0x80;
        lcd_command_send();
        delay(800);
        lcd_puts(lcd_line_1);
        
        temp1 = 0xC0;
        lcd_command_send();
        delay(800);
        snprintf(lcd_line_2, sizeof(lcd_line_2), "Cap: %2d/%-2d     ", 
                people_in_room, MAX_CAPACITY);
        lcd_puts(lcd_line_2);

        delay(DELAY);
    }
    
    return 0;
}