from PIL import Image
import numpy as np

def convert_image_to_verilog_mem(input_image_path, output_filename="image_data.mem"):
    try:
        # 1. Open the image and convert to grayscale ('L' mode)
        img = Image.open(input_image_path).convert('L')
        
        # 2. Resize to exactly 64x64 using high-quality resampling
        img = img.resize((64, 64), Image.Resampling.LANCZOS)
        
        # 3. Convert image pixels to a flat list
        pixels = list(img.getdata())
        
        # 4. Process and pack into 32-bit hex words
        # 4096 pixels total / 4 pixels per word = 1024 words
        with open(output_filename, 'w') as f:
            for i in range(0, len(pixels), 4):
                # Grab 4 pixels at a time
                p0 = pixels[i]
                p1 = pixels[i+1]
                p2 = pixels[i+2]
                p3 = pixels[i+3]
                
                # Format as [P0][P1][P2][P3]
                hex_word = f"{p0:02x}{p1:02x}{p2:02x}{p3:02x}"
                f.write(hex_word + "\n")
        
        print(f"Success! '{input_image_path}' converted to '{output_filename}'.")
        print(f"Total pixels processed: {len(pixels)} (1024 words)")

    except Exception as e:
        print(f"An error occurred: {e}")

# Usage: replace 'my_photo.jpg' with your actual image file
convert_image_to_verilog_mem("lena.jpg")