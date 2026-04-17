#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.

# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

# Use either wget or curl to download the checkpoints
if command -v wget &> /dev/null; then
    CMD="wget"
elif command -v curl &> /dev/null; then
    CMD="curl -L -O"
else
    echo "Please install wget or curl to download the checkpoints."
    exit 1
fi

# Define the URLs for SAM 2 checkpoints
# SAM2_BASE_URL="https://dl.fbaipublicfiles.com/segment_anything_2/072824"
# sam2_hiera_t_url="${SAM2_BASE_URL}/sam2_hiera_tiny.pt"
# sam2_hiera_s_url="${SAM2_BASE_URL}/sam2_hiera_small.pt"
# sam2_hiera_b_plus_url="${SAM2_BASE_URL}/sam2_hiera_base_plus.pt"
# sam2_hiera_l_url="${SAM2_BASE_URL}/sam2_hiera_large.pt"

# Download each of the four checkpoints using wget
# echo "Downloading sam2_hiera_tiny.pt checkpoint..."
# $CMD $sam2_hiera_t_url || { echo "Failed to download checkpoint from $sam2_hiera_t_url"; exit 1; }

# echo "Downloading sam2_hiera_small.pt checkpoint..."
# $CMD $sam2_hiera_s_url || { echo "Failed to download checkpoint from $sam2_hiera_s_url"; exit 1; }

# echo "Downloading sam2_hiera_base_plus.pt checkpoint..."
# $CMD $sam2_hiera_b_plus_url || { echo "Failed to download checkpoint from $sam2_hiera_b_plus_url"; exit 1; }

# echo "Downloading sam2_hiera_large.pt checkpoint..."
# $CMD $sam2_hiera_l_url || { echo "Failed to download checkpoint from $sam2_hiera_l_url"; exit 1; }

# Define the URLs for SAM 2.1 checkpoints
SAM2p1_BASE_URL="https://dl.fbaipublicfiles.com/segment_anything_2/092824"
sam2p1_hiera_t_url="${SAM2p1_BASE_URL}/sam2.1_hiera_tiny.pt"
sam2p1_hiera_s_url="${SAM2p1_BASE_URL}/sam2.1_hiera_small.pt"
sam2p1_hiera_b_plus_url="${SAM2p1_BASE_URL}/sam2.1_hiera_base_plus.pt"
sam2p1_hiera_l_url="${SAM2p1_BASE_URL}/sam2.1_hiera_large.pt"

# Define the URLs for SAM vit checkpoints
sam_vit_b_url="https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"
sam_vit_l_url="https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth"
sam_vit_h_url="https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth"

# Define the URLs for FastSAM checkpoints
fastsam_x="https://github.com/ultralytics/assets/releases/download/v8.4.0/FastSAM-x.pt"
fastsam_s="https://github.com/ultralytics/assets/releases/download/v8.4.0/FastSAM-s.pt"


# SAM 2.1 checkpoints
echo "Downloading sam2.1_hiera_tiny.pt checkpoint..."
$CMD $sam2p1_hiera_t_url || { echo "Failed to download checkpoint from $sam2p1_hiera_t_url"; exit 1; }

echo "Downloading sam2.1_hiera_small.pt checkpoint..."
$CMD $sam2p1_hiera_s_url || { echo "Failed to download checkpoint from $sam2p1_hiera_s_url"; exit 1; }

echo "Downloading sam2.1_hiera_base_plus.pt checkpoint..."
$CMD $sam2p1_hiera_b_plus_url || { echo "Failed to download checkpoint from $sam2p1_hiera_b_plus_url"; exit 1; }

echo "Downloading sam2.1_hiera_large.pt checkpoint..."
$CMD $sam2p1_hiera_l_url || { echo "Failed to download checkpoint from $sam2p1_hiera_l_url"; exit 1; }


# SAM vit checkpoints
echo "Downloading sam_vit_b_01ec64.pth checkpoint..."
$CMD $sam_vit_b_url || { echo "Failed to download checkpoint from $sam_vit_b_url"; exit 1; }

echo "Downloading sam_vit_l_0b3195.pth checkpoint..."
$CMD $sam_vit_l_url || { echo "Failed to download checkpoint from $sam_vit_l_url"; exit 1; }

echo "Downloading sam_vit_h_4b8939.pth checkpoint..."
$CMD $sam_vit_h_url || { echo "Failed to download checkpoint from $sam_vit_h_url"; exit 1; }

mv sam_vit_b_01ec64.pth sam_vit_b.pth
mv sam_vit_l_0b3195.pth sam_vit_l.pth
mv sam_vit_h_4b8939.pth sam_vit_h.pth

# FastSAM checkpoints
echo "Downloading FastSAM-x.pt checkpoint..."
$CMD $fastsam_x || { echo "Failed to download checkpoint from $fastsam_x"; exit 1; }

echo "Downloading FastSAM-s.pt checkpoint..."
$CMD $fastsam_s || { echo "Failed to download checkpoint from $fastsam_s"; exit 1; }


echo "All checkpoints are downloaded successfully."
