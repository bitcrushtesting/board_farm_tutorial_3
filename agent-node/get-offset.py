#!/usr/bin/env python3

# Copyright © 2024 Bitcrush Testing

import sys
import subprocess
import argparse

def get_partition_offset(image_file, partition_number):
    try:
        # Run fdisk to get partition information
        result = subprocess.run(['fdisk', '-l', image_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        if result.returncode != 0:
            print(f"0")
            sys.exit(1)
        
        # Find the start sector of the specified partition
        lines = result.stdout.splitlines()
        partition_prefix = f"{partition_number}"
        for line in lines:
            if line.strip().startswith("Device"):
                continue  # Skip the header line
            parts = line.split()
            if len(parts) > 1 and parts[0].endswith(partition_prefix):
                start_sector = int(parts[1])
                break
        else:
            print("0")
            sys.exit(1)
        
        # Calculate the offset (sector size is 512 bytes)
        offset = start_sector * 512
        print(offset)
    
    except Exception as e:
        print("0")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate the offset of a partition in a Raspberry Pi OS image.")
    parser.add_argument("image_file", help="Path to the Raspberry Pi OS image file.")
    parser.add_argument("-p", "--partition", type=int, default=2, help="Partition number to calculate the offset for (default: 2).")
    
    args = parser.parse_args()
    get_partition_offset(args.image_file, args.partition)

