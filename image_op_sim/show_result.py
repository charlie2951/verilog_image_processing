import numpy as np
import matplotlib.pyplot as plt

def parse_hex_file(file_path):
    """Reads 32-bit hex words from a file and returns a 64x64 numpy array."""
    pixels = []
    try:
        with open(file_path, 'r') as f:
            for line in f:
                word = line.strip()
                # Process only valid 8-character hex words
                if len(word) == 8:
                    # Unpack 32-bit word into four 8-bit pixels
                    p0 = int(word[0:2], 16)
                    p1 = int(word[2:4], 16)
                    p2 = int(word[4:6], 16)
                    p3 = int(word[6:8], 16)
                    pixels.extend([p0, p1, p2, p3])
        
        # Ensure we have exactly 4096 pixels for a 64x64 image
        if len(pixels) < 4096:
            pixels.extend([0] * (4096 - len(pixels)))
            
        return np.array(pixels[:4096]).reshape((64, 64))
    
    except FileNotFoundError:
        print(f"Error: {file_path} not found.")
        return np.zeros((64, 64))

def visualize_comparison(input_file, output_file):
    # Load data from both files
    original_img = parse_hex_file(input_file)
    processed_img = parse_hex_file(output_file)

    # Create subplots for comparison
    plt.subplot(1, 2, 1)
    plt.imshow(original_img, cmap='gray', vmin=0, vmax=255)
    plt.title("Original Image")
    plt.axis('off')

    plt.subplot(1, 2, 2)
    plt.imshow(processed_img, cmap='gray', vmin=0, vmax=255)
    plt.title("Processed Image")
    plt.axis('off')

    plt.tight_layout()
    plt.show()

# Run the visualization
visualize_comparison("image_data.mem", "processed_output.txt")