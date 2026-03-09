# Basic Image Processing on FPGA
Output is streamed via UART to PC 
## How to use
The image_data.mem file contain 64x64 grayscale image of lena image. Program the Nexys4-DDR board using the bit file. Then Press C12 i.e. CPU Reset button. Then run the python script `plot_result.py` . When it displays status  `Receiving image`, press the N17 push button to start the reception via serial port. The original and converted image will be displayed side by side. You can select different image operation by selecting two slide switch `L16` and `J15` as follows: <p>
|L16|J15|Operation|
|----|----|----|
|0|0|Invert|
|0|1|Enhancement (brightness increase by 30)|
|1|0|Threshold|
|1|1|Simple Horizontal edge detection|
