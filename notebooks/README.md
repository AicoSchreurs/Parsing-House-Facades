# :house_with_garden: Parsing house facades - notebooks

## :bricks: Color transformation &amp; image resizing
This [notebook](./color-resizing-kyana.ipynb) investigates the impact of image resizing and grayscale conversion on the segmentation performance of SAM2 (Segment Anything Model 2) applied to house facade images. Ground truth annotations were created manually using LabelMe with three semantic labels: **Raam** (window), **Deur** (door) and **Zonnepaneel** (solar panel).

### Project structure
```
PARSING-HOUSE-FACADES/
├── images/
│   ├── Alles/                  # All raw source images
│   ├── Alles_JSONs/            # All LabelMe annotation JSONs
│   ├── original/               # Images + JSONs used for evaluation (copied from above)
│   ├── resized/                # 512×512 padded images + transformed JSONs
│   └── grayscale/              # Grayscale images + copied JSONs
├── installations/
│   └── install.sh
├── sam2/
│   └── checkpoints/
│       └── sam2.1_hiera_small.pt
├── outputs/                    # Visualizations per image per condition
├── results/                    # CSV output and analysis plots
└── notebooks/
    └── color-resizing-kyana.ipynb
```

### Requirements
Install the required packages using the file [install.sh](../installations/install.sh).

Install SAM2 using the [official instructions](https://github.com/facebookresearch/segment-anything-2).
> The sam2 directory is already mainly available here in this project

Download the SAM2 checkpoints:
```bash
cd checkpoints
./download_ckpts.sh
```

The notebook uses the **small** checkpoint (`sam2.1_hiera_small.pt`). If you want to use a different model size, update these two constants at the top of the notebook:

```python
SAM2_CHECKPOINT_PATH = "../sam2/checkpoints/sam2.1_hiera_small.pt"
SAM2_MODEL_CONFIG_PATH = "configs/sam2.1/sam2.1_hiera_s.yaml"
```


### How to run
Run all cells in order. The notebook is structured in the following logical blocks:

#### 1. Setup &amp; configuration
Sets device (CUDA / MPS / CPU), defines all directory paths, label colors, and SAM2 hyperparameters.

#### 2. Data preparation
Copies images and their corresponding LabelMe JSON annotation files from `images/Alles/` and `images/Alles_JSONs/` into `images/original/`.

#### 3. Image preprocessing
Generates the thwo alternative mage conditions:
- **Resized**: aspect-ratio-preserving resize to 512x512 with black padding. Annotation coordinates are transformed accordingly (scaled + shifted to match the padding).
- **Grayscale**: BGR-to-grayscale conversion. Annotation coordinates remain unchanged since the resolution does not change.

#### 4. SAM2 model loading
Builds the SAM2 model and creates an `SAM2AutomaticMaskGenerator` with the following key settings:

| Parameter | Value | Effect |
|---|---|---|
| `points_per_side` | 16 | Fewer sample points → fewer masks generated |
| `pred_iou_thresh` | 0.75 | Only high-confidence masks are kept |
| `stability_score_thresh` | 0.9 | Filters unstable masks |
| `min_mask_region_area` | 250 | Removes very small noise segments |

#### 5. Helper functions
Defines all core functions used in the evaluation pipeline:

| Function | Description |
|---|---|
| `polygon_to_mask` | Converts a LabelMe polygon to a binary mask |
| `circle_to_mask` | Converts a LabelMe circle (center + edge point) to a binary mask |
| `rectangle_to_mask` | Converts a LabelMe rectangle (two corner points) to a binary mask |
| `load_gt_masks` | Loads all shapes from a LabelMe JSON into binary masks |
| `compute_iou` | Computes Intersection over Union between two binary masks |
| `filter_masks_by_annotation` | Keeps only SAM2 masks that overlap sufficiently with an annotation zone (default IoU threshold: 0.3) |
| `reproject_mask_to_original` | Maps a resized mask back to the original image resolution for fair comparison |
| `match_and_score` | For each original mask, finds the best-matching mask from another condition by label and IoU |
| `save_masked_visualization` | Saves a side-by-side figure showing ground truth annotations and SAM2 masks |

#### 6. Evaluation loop
Iterates over all annotated images and runs the full pipeline for eacht of the three conditions:

**Original** - SAM2 runs on the unmodified image. Filtered masks are stored as the reference baseline.

**Resized** - SAM2 runs on the 512x512 padded image. Filtered masks are reprojected back to the original resolution before being compared to the original masks via IoU.

**Grayscale** - SAM2 runs on the grayscale image (loaded as RGB with repeated channels). Filtered masks are compared directly to the original masks via IoU since the resolution is unchanged.

All results are saved to `results/sam2_results.csv` with columns:
`Condition`, `File`, `Label`, `IoU`.

#### 7. Analysis &amp; visualisation
Loads `sam2_results.csv` adn produces:

- **Summary table** (`iou_summary.csv`): mean, std, and count of IoU per condition per label.
- **Bar chart** (`iou_per_label.png`): mean IoU grouped by label and condition.
- **Wilcoxon signed-rank tests**: statistical significance of the difference between original and each alternative condition (paied per file + label).
- **Relative IoU drop**: percentage change in mean IoU for resized and grayscale relative to original, per label


### Outputs

| File | Description |
|---|---|
| `outputs/<name>_original.png` | Visualization: ground truth + SAM2 masks on original image |
| `outputs/<name>_resized.png` | Visualization: ground truth + SAM2 masks on resized image |
| `outputs/<name>_grayscale.png` | Visualization: ground truth + SAM2 masks on grayscale image |
| `results/sam2_results.csv` | Raw IoU scores per condition, file, and label |
| `results/iou_summary.csv` | Aggregated mean/std IoU per condition per label |
| `results/iou_per_label.png` | Bar chart of mean IoU per label per condition |


### Design choices

**Why use original as reference instead of ground truth?**<br>
The LabelMe annotations were drawn slightly larger than the actual objects (e.g. a window annotation includes a small border of brickwork) to give SAM2 room to find the precise boudnary. Because of this, the annotations are not strict ground truth. Instead, original SAM2 masks serve as the reference baseline, and resized/grayscale masks are compared against them.

**Why reproject resized masks?**<br>
Resized images are 512x512 while originals vary in resolution. To compute meaningful IoU values, resized masks are first stripped of their black padding and then upscaled back to the original resolution using nearest-neighbour interpolation to preserve binary values.

**Why load grayscale images as RGB?**<br>
SAM2 requires 3-channel output. Grayscale images are loaded via `PIL.Image.convert("RGB")`, which repeats the grayscale channel across R, G, and B. This means SAM2 still receives valid 3-channel input, but without any colour information - exactly the condition being tested.
