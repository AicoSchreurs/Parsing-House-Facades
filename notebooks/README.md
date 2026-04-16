# :house_with_garden: Parsing house facades - notebooks

## :bricks: Multiple Models, Preprocessing & Occlusion

This project investigates the automatic segmentation of Dutch residential house facades using different variants of the Segment Anything Model (SAM), SAM2, and FastSAM.

The goal of this project is to evaluate:
- which model out of the tested variants performs best
- how image preprocessing affects segmentation performance
- how occlusion impacts segmentation results

The segmentation focuses on three labels:
- **Raam** (window)  
- **Deur** (door)  
- **Zonnepaneel** (solar panel)  

All experiments are implemented in [this single unified notebook](./SAM%20project.ipynb), where the full pipeline is executed step by step.

First, multiple segmentation models are evaluated on the original dataset to determine which model performs best. This includes several variants of SAM, SAM2, and FastSAM.

After selecting the best-performing model, additional experiments are performed to analyze the impact of image preprocessing. Two preprocessing techniques are applied:
- resizing images to a fixed resolution (512×512 with padding)
- converting images to grayscale

Finally, the effect of occlusion is analyzed. The dataset is divided into two groups: occluded and not occluded images. This allows for evaluating how partial visibility of facade elements (caused by vegetation such as trees and hedges) influences segmentation performance.

Ground truth annotations are created manually using LabelMe and are used to evaluate the segmentation quality using Intersection over Union (IoU).

### Project structure
```
PARSING-HOUSE-FACADES/
├── images/
│   ├── Alles/                  # All raw source images
│   ├── Alles_JSONs/            # All LabelMe annotation JSONs
│   ├── original/               # Images + JSONs used for evaluation
│   ├── resized/                # 512×512 padded images + transformed JSONs
│   └── grayscale/              # Grayscale images + copied JSONs
│
├── checkpoints/                # Model weights
│
├── outputs/                    # Visualizations per image
├── results/                    # CSV results and plots
│
└── notebooks/
    ├── SAM project.ipynb
    └── funda scraper.ipynb
```

### Requirements
Install the required packages using the file [install.sh](../installations/install.sh) as follows:
```bash
cd installations
./install.sh
```
> If this doesn't work, try opening Git Bash inside the installations folder and run `bash install.sh` in the Git Bash GUI

Install SAM2 using the [official instructions](https://github.com/facebookresearch/segment-anything-2).
> The sam2 directory is already mainly available here (except the checkpoints) in this project, so normally you can skip this installation

Download the SAM2 checkpoints:
```bash
cd checkpoints
./download_ckpts.sh
```
> If this doesn't work, try opening Git Bash inside the checkpoints folder and run `bash download_ckpts.sh` in the Git Bash GUI

The notebook uses the **different** checkpoints. If you want to use a different model or size, update **SELECTED_MODEL** constant at the top of the notebook:

```python
BENCHMARK_MODELS = [
    "sam_vit_b",
    "sam_vit_l",
    "sam_vit_h",
    "sam2_small",
    "sam2_base_plus",
    "sam2_large",
    "fastsam_s",
    "fastsam_x",
]
SELECTED_MODEL = "fastsam_x"
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

#### 4. SAM model loading
Builds the SAM2 model and creates an `SAMAutomaticMaskGenerator` with the following key settings:

| Parameter | Value | Effect |
|---|---|---|
| `points_per_side` | 16 | Fewer sample points → fewer masks generated |
| `pred_iou_thresh` | 0.75 | Only high-confidence masks are kept |
| `stability_score_thresh` | 0.9 | Filters unstable masks |
| `min_mask_region_area` | 250 | Removes very small noise segments |

#### 5. FastSAM model loading
Builds the FastSAM model and creates an `FastSAM` object.


#### 5. Helper functions
Defines all core functions used in the evaluation pipeline:

| Function | Description |
|---|---|
| `find_labelme_json_files` | Searches a directory and returns all LabelMe JSON files. Used to iterate over the dataset. |
| `resolve_image_path` | Finds the corresponding image file for a given JSON annotation. Ensures correct pairing of data. |
| `load_image_rgb` | Loads an image from disk and converts it to RGB format, which is required for all models. |
| `polygon_to_mask` | Converts a polygon annotation from LabelMe into a binary mask. |
| `circle_to_mask` | Converts a circle annotation (center + edge) into a binary mask. |
| `rectangle_to_mask` | Converts a rectangle annotation into a binary mask. |
| `load_gt_masks` | Loads all annotations from a LabelMe JSON file and converts them into binary masks with labels. |
| `compute_iou` | Calculates Intersection over Union (IoU) between two masks. Main evaluation metric. |
| `compute_dice` | Calculates Dice score between two masks. Used as additional evaluation metric. |
| `filter_masks_by_annotation_overlap` | Filters predicted masks by checking if they overlap with a ground truth object above a threshold. |
| `match_predictions` | Matches predicted masks to ground truth masks based on highest IoU. |
| `score_gt_objects_against_predictions` | Calculates IoU and Dice per ground truth object. Used for detailed evaluation. |
| `combine_predictions_per_gt` | Combines multiple predicted masks for the same object into one. Reduces duplicate detections. |
| `reproject_mask_to_original` | Maps masks from resized images back to original resolution for fair comparison. |
| `run_model_on_image` | Runs the selected segmentation model (SAM, SAM2, or FastSAM) on an image and returns masks. |
| `save_masked_visualization` | Creates and saves a side-by-side visualization of ground truth and predictions. |
| `get_cache_path` | Generates a file path for caching results per image/model. |
| `load_from_cache` | Loads cached results if they exist to avoid recomputation. |
| `save_to_cache` | Saves results to disk for faster future runs. |
| `cleanup_memory` | Clears memory after processing an image to prevent memory issues. |

#### 6. Evaluation loop
Iterates over all annotated images and runs the full pipeline for eacht of the three conditions:

**Original** - SAM runs on the unmodified image. Filtered masks are stored as the reference baseline.

**Resized** - SAM runs on the 512x512 padded image. Filtered masks are reprojected back to the original resolution before being compared to the original masks via IoU.

**Grayscale** - SAM runs on the grayscale image (loaded as RGB with repeated channels). Filtered masks are compared directly to the original masks via IoU since the resolution is unchanged.

All results are saved to `results_conditions/condition_instance_results.csv` with columns:
| Column | Description |
|--------|------------|
| `model` | Model used for segmentation |
| `condition` | Image condition (original / resized / grayscale) |
| `file` | Image filename |
| `json_file` | Annotation file |
| `label` | Object label (raam, deur, zonnepaneel) |
| `gt_index` | Ground truth object index |
| `iou` | Intersection over Union score |
| `dice` | Dice score |
| `n_gt_objects` | Number of ground truth objects |
| `n_gt_matched` | Number of matched objects |
| `n_gt_missed` | Number of missed objects |
| `n_generated_masks` | Total masks generated by model |
| `n_filtered_masks` | Masks after filtering |
| `runtime_sec` | Runtime per image |
| `image_mean_iou` | Mean IoU per image |
| `image_mean_dice` | Mean Dice per image |
| `points_per_batch_used` | SAM batching parameter used |
| `overlap_mode` | Overlap strategy used |

#### 7. Analysis &amp; visualisation

- **Summary table**: mean, std, and count of IoU per condition per label.
- **Bar chart**: mean IoU grouped by label and condition.
- **Wilcoxon signed-rank tests**: statistical significance of the difference between original and each alternative condition (paied per file + label).
- **Relative IoU drop**: percentage change in mean IoU for resized and grayscale relative to original, per label


### Outputs

| File | Description |
|---|---|
| `results_benchmark/cache/<name>_<model>.csv` | raw meta score of each image + label |
| `visuals_benchmark/<name>_<model>.jpg` | Visualization: ground truth + every model masks on image |
| `results_benchmark/benchmark_instance_results.csv` | Raw meta scores per model, file, label and other meta data |
| `results_conditions/cache/<name>_<method>_<model>.csv` | raw meta score of each image + label |
| `visuals_conditions/<name>_<method>_<model>.jpg` | Visualization: ground truth + SAM each method masks on image |
| `results_conditions/condition_instance_results.csv` | Raw meta scores per model, condition, file, label and other meta data |



### Design choices

**Why use original as reference instead of ground truth for image resizing and grascale conversion?**<br>
The LabelMe annotations were drawn slightly larger than the actual objects (e.g. a window annotation includes a small border of brickwork) to give SAM2 room to find the precise boudnary. Because of this, the annotations are not strict ground truth. Instead, original SAM2 masks serve as the reference baseline, and resized/grayscale masks are compared against them.

**Why reproject resized masks?**<br>
Resized images are 512x512 while originals vary in resolution. To compute meaningful IoU values, resized masks are first stripped of their black padding and then upscaled back to the original resolution using nearest-neighbour interpolation to preserve binary values.

**Why load grayscale images as RGB?**<br>
SAM2 requires 3-channel output. Grayscale images are loaded via `PIL.Image.convert("RGB")`, which repeats the grayscale channel across R, G, and B. This means SAM2 still receives valid 3-channel input, but without any colour information - exactly the condition being tested.
