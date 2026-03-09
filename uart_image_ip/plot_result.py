import serial
import numpy as np
import matplotlib.pyplot as plt

# ----------------------------
# Parameters
# ----------------------------

PORT = "COM5"
BAUD = 9600

IMAGE_SIZE = 64
TOTAL_PIXELS = IMAGE_SIZE * IMAGE_SIZE
MEM_FILE = "image_data.mem"

# ----------------------------
# Load original image from .mem
# ----------------------------

pixels = []

with open(MEM_FILE, "r") as f:
    for line in f:
        word = int(line.strip(), 16)

        p0 = (word >> 24) & 0xFF
        p1 = (word >> 16) & 0xFF
        p2 = (word >> 8)  & 0xFF
        p3 = word & 0xFF

        pixels.extend([p0, p1, p2, p3])

orig_img = np.array(pixels[:TOTAL_PIXELS], dtype=np.uint8)
orig_img = orig_img.reshape((IMAGE_SIZE, IMAGE_SIZE))

print("Original image loaded")

# ----------------------------
# Open serial port
# ----------------------------

ser = serial.Serial(PORT, BAUD, timeout=5)

print("Receiving image from UART...")

rx_buffer = bytearray()

while len(rx_buffer) < IMAGE_SIZE*IMAGE_SIZE:

    data = ser.read(64)

    if data:
        rx_buffer.extend(data)
        print(f"RX {len(rx_buffer)} / {TOTAL_PIXELS}")

ser.close()

print("UART reception complete")

# ----------------------------
# Convert received data to image
# ----------------------------

rx_array = np.frombuffer(rx_buffer, dtype=np.uint8)
proc_img = rx_array.reshape((IMAGE_SIZE, IMAGE_SIZE))
# ----------------------------
# Save result image
# ----------------------------

plt.imsave("processed_image.png", proc_img, cmap="gray")

print("Processed image saved")

# ----------------------------
# Plot both images
# ----------------------------

plt.figure(figsize=(5,4))

plt.subplot(1,2,1)
plt.title("Original Image")
plt.imshow(orig_img, cmap='gray')
plt.axis("off")

plt.subplot(1,2,2)
plt.title("Processed Image (UART)")
plt.imshow(proc_img, cmap='gray')
plt.axis("off")

plt.tight_layout()
plt.show()
