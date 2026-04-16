#!/bin/bash

set -e

# PyTorch (CUDA 12.1)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# General packages
pip install opencv-python numpy pandas seaborn matplotlib scipy Pillow hydra-core

# Web scraping
pip install requests selenium

# SAM1
pip install git+https://github.com/facebookresearch/segment-anything.git

# FastSAM
pip install ultralytics
