#!/bin/bash

set -e

pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install opencv-python numpy pandas seaborn matplotlib scipy Pillow hydra-core
