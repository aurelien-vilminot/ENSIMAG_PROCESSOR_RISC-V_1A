/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
#define WIDTH 1920
#define HEIGHT 1080

#include "stdint.h"
void four_colors(uint32_t* addr, int x, int y)
{
	if(x % 4 == 0) {
		*addr = 0x0000ffff;
	}
	if(x % 4 == 1) {
		*addr = 0x00ff0000;
	}
	if(x % 4== 2) {
		*addr = 0x0000ff00;
	}
	if(x % 4== 3) {
		*addr = 0x00ffff00;
	}
}
void invisible_colors(uint32_t* addr, int x, int y){
	if(x % 4== 2) {
			*addr = 0x00ffffff;
		}
		if(x % 4== 3) {
			*addr = 0x00ffff00;
		}
}
void eight_colors(uint32_t* addr, int x, int y)
{
	*addr = 0x00000000;
	if(x % 8 == 0) {
		*addr = 0x0000ffff;
	}
	if(x % 8 == 1) {
		*addr = 0x00ff0000;
	}
	if(x % 8 == 2) {
		*addr = 0x0000ff00;
	}
	if(x % 8 == 3) {
		*addr = 0x00ffff00;
	}
}

void line_gradient(uint32_t* addr, int x, int y, int hres)
{
	*addr = (((x + y * 1920) % (1920 / hres)) * 255/ (1920/hres)) << 8;
}

void mandelbrot(int move){
	float prop = (float)move / 10.0;
	float x1 = -1.5;
	float x2 = 1.5;
	float y1 = -1.5;
	float y2 = 1.5;
	float zoom_x = 1920.0 / (x2 - x1);
	float zoom_y = 1080.0 / (y2 - y1);

	int max_i = 50;

	for (int x = 0; x < WIDTH; x++) {
		for (int y = 0; y < HEIGHT; y++) {
			uint32_t* addr = (uint32_t*)(0x80000000 + 4*(x + y * 1920));

			float c_r = + prop * 1;
			float c_i = prop * 1;
			float z_r =  x / zoom_x + x1;
			float z_i =  y / zoom_y + y1;
			int i = 0;

			do {
				float tmp = z_r;
				z_r = z_r*z_r - z_i*z_i + c_r;
				z_i = 2*z_i*tmp + c_i;
				i++;
			} while (z_r*z_r + z_i*z_i < 4 && i < max_i);

			if(i == max_i) {
				*addr = 0;
			}
			else {
				*addr = (((int)(i * 255/ max_i )) << 8);
			}
		}
	}

}
int main()
{
    int i = 0;
    while (1){

		mandelbrot(i);
		i++;
		i = i%10;

    }

    return 0;
}
