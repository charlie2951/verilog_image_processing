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
