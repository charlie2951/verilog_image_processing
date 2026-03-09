import numpy as np

# Image dimensions
WIDTH = 64
HEIGHT = 64
TOTAL_PIXELS = WIDTH * HEIGHT
WORDS = TOTAL_PIXELS // 4  # 1024 words

def generate_verilog_mem(filename="image_data.mem"):
    with open(filename, 'w') as f:
        for i in range(WORDS):
            # Generate 4 distinct pixels for each 32-bit word
            # This creates a vertical gradient effect
            p_base = (i * 4) % 256
            
            p0 = (p_base)     % 256
            p1 = (p_base + 1) % 256
            p2 = (p_base + 2) % 256
            p3 = (p_base + 3) % 256
            
            # Format as a 32-bit Hex string (8 characters)
            # We pack them: [P0][P1][P2][P3]
            hex_word = f"{p0:02x}{p1:02x}{p2:02x}{p3:02x}"
            f.write(hex_word + "\n")

    print(f"File '{filename}' generated with {WORDS} hex words.")

generate_verilog_mem()
