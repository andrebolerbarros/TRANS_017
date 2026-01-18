# TRANS_017 CITE-seq Analysis Workflow Diagram

## Visual Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CELLRANGER ALIGNMENT OUTPUTS                     │
│                    (filtered_feature_bc_matrix)                     │
│                                                                     │
│  Sample 1          Sample 2          Sample 3          Sample 4     │
│  ├─ GEX data      ├─ GEX data      ├─ GEX data      ├─ GEX data     │
│  └─ ADT data      └─ ADT data      └─ ADT data      └─ ADT data     │
└───────────┬───────────────┬───────────────┬───────────────┬─────────┘
            │               │               │               │
            ▼               ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PHASE 1: PREPROCESSING                           │
│                    (00_preprocessing/)                              │
└─────────────────────────────────────────────────────────────────────┘
            │               │               │               │
            │  ┌────────────┴─────────────┐ │               │
            │  │   QUALITY CONTROL        │ │               │
            │  ├──────────────────────────┤ │               │
            │  │ • Load CellRanger data   │ │               │
            │  │ • Separate GEX/ADT       │ │               │
            │  │ • Calculate QC metrics   │ │               │
            │  │ • Visualize distributions│ │               │
            │  └────────────┬─────────────┘ │               │
            │               │               │               │
            │  ┌────────────┴────────────┐  │               │
            │  │   XENOGRAFT FILTERING   │  │               │
            │  ├─────────────────────────┤  │               │
            │  │ • Identify mouse genes  │  │               │
            │  │ • Calculate mouse %     │  │               │
            │  │ • Filter contamination  │  │               │
            │  │ • Retain only human     │  │               │
            │  └────────────┬────────────┘  │               │
            │               │               │               │
            │  ┌────────────┴────────────┐  │               │
            │  │   CELL QC FILTERING     │  │               │
            │  ├─────────────────────────┤  │               │
            │  │ • Min/max genes         │  │               │
            │  │ • Total counts          │  │               │
            │  │ • Mitochondrial %       │  │               │
            │  │ • ADT count threshold   │  │               │
            │  └────────────┬────────────┘  │               │
            │               │               │               │
            │  ┌────────────┴────────────┐  │               │
            │  │   RNA NORMALIZATION     │  │               │
            │  ├─────────────────────────┤  │               │
            │  │ • Normalize total       │  │               │
            │  │ • Log transformation    │  │               │
            │  │ • Identify HVGs         │  │               │
            │  │ • Scale data            │  │               │
            │  │ • PCA (50 components)   │  │               │
            │  └────────────┬────────────┘  │               │
            │               │               │               │
            │  ┌────────────┴────────────┐  │               │
            │  │  PROTEIN NORMALIZATION  │  │               │
            │  ├─────────────────────────┤  │               │
            │  │ • CLR normalization     │  │               │
            │  │ • Scale data            │  │               │
            │  │ • PCA (20 components)   │  │               │
            │  └────────────┬────────────┘  │               │
            │               │               │               │
            │  ┌────────────┴────────────┐  │               │
            │  │  VISUALIZATION & QC     │  │               │
            │  ├─────────────────────────┤  │               │
            │  │ • Compute neighbors     │  │               │
            │  │ • UMAP embedding        │  │               │
            │  │ • Leiden clustering     │  │               │
            │  │ • Generate QC plots     │  │               │
            │  └────────────┬────────────┘  │               │
            │               │               │               │
            ▼               ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PROCESSED SAMPLES (.h5ad)                        │
│                                                                     │
│  sample1_processed.h5ad                                             │
│  sample2_processed.h5ad                                             │
│  sample3_processed.h5ad                                             │
│  sample4_processed.h5ad                                             │
│                                                                     │
│  Each contains:                                                     │
│  ├─ Filtered & normalized RNA                                       │
│  ├─ Filtered & normalized protein                                   │
│  ├─ QC metrics                                                      │
│  ├─ PCA/UMAP embeddings                                             │
│  └─ Initial clustering                                              │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PHASE 2: INTEGRATION                             │
│                    (01_integration/)                                │
└─────────────────────────────────────────────────────────────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  CONCATENATE SAMPLES    │
                   ├─────────────────────────┤
                   │ • Load all samples      │
                   │ • Merge (inner join)    │
                   │ • Preserve batch labels │
                   │ • Combine protein data  │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  VISUALIZE PRE-INT      │
                   ├─────────────────────────┤
                   │ • Quick PCA/UMAP        │
                   │ • Check batch effects   │
                   │ • Assess mixing         │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  PREPARE FOR TOTALVI    │
                   ├─────────────────────────┤
                   │ • Select HVGs           │
                   │ • Setup batch key       │
                   │ • Register protein data │
                   │ • Initialize model      │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │   TRAIN TOTALVI MODEL   │
                   ├─────────────────────────┤
                   │ • Neural network        │
                   │ • 30D latent space      │
                   │ • Batch correction      │
                   │ • ~400 epochs           │
                   │ • Monitor convergence   │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  EXTRACT EMBEDDINGS     │
                   ├─────────────────────────┤
                   │ • Latent representation │
                   │ • Denoised RNA          │
                   │ • Denoised protein      │
                   │ • Batch-corrected       │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  INTEGRATED ANALYSIS    │
                   ├─────────────────────────┤
                   │ • Neighbors on latent   │
                   │ • UMAP embedding        │
                   │ • Leiden clustering     │
                   │ • Multiple resolutions  │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  FIND MARKER GENES      │
                   ├─────────────────────────┤
                   │ • Differential expr.    │
                   │ • RNA markers           │
                   │ • Protein markers       │
                   │ • Per cluster           │
                   └────────────┬────────────┘
                                │
                   ┌────────────┴────────────┐
                   │  QUALITY ASSESSMENT     │
                   ├─────────────────────────┤
                   │ • Mixing score          │
                   │ • Batch composition     │
                   │ • Training history      │
                   │ • Integration plots     │
                   └────────────┬────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    INTEGRATED DATASET                               │
│                    (integrated_totalvi.h5ad)                        │
│                                                                     │
│  Combined data for all 4 samples containing:                        │
│  ├─ Batch-corrected latent representation                           │
│  ├─ Integrated UMAP embedding                                       │
│  ├─ Joint clustering across samples                                 │
│  ├─ Denoised RNA expression                                         │
│  ├─ Denoised protein expression                                     │
│  ├─ Marker genes per cluster                                        │
│  └─ Quality metrics                                                 │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DOWNSTREAM ANALYSIS                              │
│                    (Your Next Steps)                                │
│                                                                     │
│  ├─ Cell type annotation                                            │
│  ├─ Differential expression between conditions                      │
│  ├─ Trajectory/pseudotime analysis                                  │
│  ├─ Cell-cell interaction analysis                                  │
│  ├─ Compositional analysis                                          │
│  ├─ Gene set enrichment                                             │
│  └─ Integration with other datasets                                 │
└─────────────────────────────────────────────────────────────────────┘
```

## Key Decision Points

### 🔍 Quality Control Checkpoints

```
Checkpoint 1: After Loading
├─ Question: Do we have both GEX and ADT data?
├─ Check: Feature types in CellRanger output
└─ Action: Verify both modalities present

Checkpoint 2: After Mouse Filtering
├─ Question: Is mouse contamination low enough?
├─ Check: % cells with >5% mouse genes
└─ Action: Adjust threshold or investigate if high

Checkpoint 3: After Cell Filtering
├─ Question: Did we retain enough cells?
├─ Check: 60-90% retention is typical
└─ Action: Review QC plots, adjust thresholds if needed

Checkpoint 4: After Normalization
├─ Question: Do the data look reasonable?
├─ Check: UMAP shows structure, not random
└─ Action: If random, check normalization steps

Checkpoint 5: After Integration
├─ Question: Are samples mixing appropriately?
├─ Check: Mixing score >0.6, visual inspection
└─ Action: Adjust integration parameters if needed
```

## Data Flow Detail

### What Gets Preserved vs. Transformed

```
Raw CellRanger Output
├─ matrix.mtx.gz (sparse matrix)         → .X (counts)
├─ features.tsv.gz (gene/protein names)  → .var (feature metadata)
└─ barcodes.tsv.gz (cell IDs)           → .obs (cell metadata)

After Preprocessing
├─ .X                → Normalized expression
├─ .layers['counts'] → Original counts (preserved!)
├─ .layers['log_normalized'] → Log-transformed
├─ .obsm['protein_clr'] → Normalized proteins
├─ .obsm['X_pca']   → PCA coordinates
└─ .obsm['X_umap']  → UMAP coordinates

After Integration
├─ .obsm['X_totalvi'] → Integrated latent space
├─ .obsm['X_umap']    → Integrated UMAP
├─ .layers['totalvi_normalized'] → Denoised expression
└─ .obs['leiden_integrated'] → Joint clusters
```

## Computational Resource Usage

```
Phase 1: Preprocessing (per sample)
Memory: ████████░░░░░░░░░░ 16GB recommended
CPU:    ████████░░░░░░░░░░ 4-8 cores utilized
GPU:    ░░░░░░░░░░░░░░░░░░ Not required
Time:   ▓▓▓▓▓▓▓▓▓▓░░░░░░░░ 10-20 minutes

Phase 2: Integration (all samples)
Memory: ████████████████░░ 32GB recommended
CPU:    ████████████░░░░░░ 8+ cores utilized
GPU:    ████████████████░░ Recommended (optional)
Time:   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░ 15-45 minutes
        (CPU: longer, GPU: shorter)
```

## File Size Expectations

```
Per Sample:
├─ Raw CellRanger output:     ~500MB - 2GB
├─ Processed .h5ad:            ~100MB - 500MB
├─ QC plots (PNG):             ~5MB total
└─ Summary files (CSV):        <1MB

Integration:
├─ Integrated .h5ad:           ~500MB - 2GB
├─ totalVI model:              ~100MB - 500MB
├─ Plots and summaries:        ~10MB total
└─ Marker gene tables:         ~5MB
```

## Success Criteria

### ✅ Good Results Look Like:

```
Preprocessing:
├─ ✓ 60-90% cells retained after QC
├─ ✓ Clear cluster structure in UMAP
├─ ✓ <5% mouse contamination
├─ ✓ Reasonable gene/count distributions
└─ ✓ Proteins show expected patterns

Integration:
├─ ✓ Mixing score >0.6
├─ ✓ Samples mixed but not completely homogeneous
├─ ✓ Training loss converged
├─ ✓ Biologically meaningful clusters
├─ ✓ Marker genes make sense
└─ ✓ Protein expression validates RNA clusters
```

### ⚠️ Warning Signs:

```
Preprocessing:
├─ ✗ >50% cells lost in filtering
├─ ✗ No clear structure in UMAP
├─ ✗ High mouse contamination (>10%)
├─ ✗ Bimodal count distributions
└─ ✗ Very low ADT signal

Integration:
├─ ✗ Samples completely separated
├─ ✗ Mixing score <0.4
├─ ✗ Training loss increases
├─ ✗ Random cluster patterns
└─ ✗ Marker genes are housekeeping genes
```

---

## Quick Reference Commands

```bash
# Activate environment
conda activate citeseq_trans017

# Run preprocessing
jupyter nbconvert --execute --to notebook sample1_preprocessing.ipynb

# Run integration
jupyter nbconvert --execute --to notebook integration_totalvi.ipynb

# Check GPU availability
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"

# Launch Jupyter Lab
jupyter lab

# Check package versions
python -c "import scanpy as sc; import scvi; print(f'scanpy: {sc.__version__}, scvi: {scvi.__version__}')"
```

---

**Navigate**: [QUICKSTART.md](QUICKSTART.md) | [README_ANALYSIS.md](README_ANALYSIS.md) | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
