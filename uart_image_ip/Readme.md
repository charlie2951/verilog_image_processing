# Basic Image Processing on FPGA
Basic image processing i.e. inversion, brightness and threshold and a simple edge detection on grayscale image,
## How to use
The `image_data.mem` file contain 64x64 grayscale image of lena image. Also, you can use python script `convert_image_to_mem.py` to convert any image to mem file for FPGA RAM. Program the Nexys4-DDR board using the bit file. Then Press C12 i.e. CPU Reset button. Then run the python script `plot_result.py` . When it displays status  `Receiving image`, press the N17 push button to start the reception via serial port. The original and converted image will be displayed side by side. You can select a different image operation by selecting two slide switch `L16` and `J15` as follows: <p>
|L16|J15|Operation|
|----|----|----|
|0|0|Invert|
|0|1|Enhancement (brightness increase by 30)|
|1|0|Threshold|
|1|1|Simple Horizontal edge detection|

## Sample Result
### Image Inversion
<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/07a4a819-adcb-4095-9be8-d13db9dffe51" />

### Brightness enhancement
Default value of enhancement is 30. You can change it or apply this as external input via switches. RTL code needs to be modified accordingly.<p>
<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/9d4226d1-9634-4485-a380-c2d8db9607ef" />

### Thresholding
<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/656261b0-f800-4876-806e-616ffc1edd90" />

###  Horizontal edge detection
<img width="500" height="400" alt="image" src="https://github.com/user-attachments/assets/54cbe46a-7dea-4aaf-a66d-7d9f612e1748" />

### Sample Log
Press N17 button after getting the message `Receiving image from UART`. Also Reset the board after every operation or at the beginning.

```
Original image loaded
Receiving image from UART...
RX 64 / 4096
RX 128 / 4096
RX 192 / 4096
RX 256 / 4096
RX 320 / 4096
RX 384 / 4096
RX 448 / 4096
RX 512 / 4096
RX 576 / 4096
RX 640 / 4096
RX 704 / 4096
RX 768 / 4096
RX 832 / 4096
RX 896 / 4096
RX 960 / 4096
RX 1024 / 4096
RX 1088 / 4096
RX 1152 / 4096
RX 1216 / 4096
RX 1280 / 4096
RX 1344 / 4096
RX 1408 / 4096
RX 1472 / 4096
RX 1536 / 4096
RX 1600 / 4096
RX 1664 / 4096
RX 1728 / 4096
RX 1792 / 4096
RX 1856 / 4096
RX 1920 / 4096
RX 1984 / 4096
RX 2048 / 4096
RX 2112 / 4096
RX 2176 / 4096
RX 2240 / 4096
RX 2304 / 4096
RX 2368 / 4096
RX 2432 / 4096
RX 2496 / 4096
RX 2560 / 4096
RX 2624 / 4096
RX 2688 / 4096
RX 2752 / 4096
RX 2816 / 4096
RX 2880 / 4096
RX 2944 / 4096
RX 3008 / 4096
RX 3072 / 4096
RX 3136 / 4096
RX 3200 / 4096
RX 3264 / 4096
RX 3328 / 4096
RX 3392 / 4096
RX 3456 / 4096
RX 3520 / 4096
RX 3584 / 4096
RX 3648 / 4096
RX 3712 / 4096
RX 3776 / 4096
RX 3840 / 4096
RX 3904 / 4096
RX 3968 / 4096
RX 4032 / 4096
RX 4096 / 4096
UART reception complete
Processed image saved
```
