# TRANS_017 CITE-seq Analysis - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Set Up Environment (5-10 minutes)

**Windows (PowerShell):**
```powershell
cd workflow
.\setup_environment.ps1
```

**Mac/Linux:**
```bash
cd workflow
bash setup_environment.sh
```

This creates a conda environment with all required packages (scanpy, scvi-tools, PyTorch, etc.)

### Step 2: Activate Environment

```bash
conda activate citeseq_trans017
```

### Step 3: Update Data Paths

Edit the preprocessing notebooks to point to your CellRanger outputs:

```python
# In each sample notebook, update this line:
CELLRANGER_OUTPUT = Path("../../data/cellranger_outputs/sample1/outs/")
```

### Step 4: Run Preprocessing

```bash
cd 00_preprocessing
jupyter notebook sample1_preprocessing.ipynb
```

Or run all samples:
```bash
jupyter nbconvert --to notebook --execute sample1_preprocessing.ipynb
jupyter nbconvert --to notebook --execute sample2_preprocessing.ipynb
jupyter nbconvert --to notebook --execute sample3_preprocessing.ipynb
jupyter nbconvert --to notebook --execute sample4_preprocessing.ipynb
```

### Step 5: Run Integration

```bash
cd ../01_integration
jupyter notebook integration_totalvi.ipynb
```

---

## 📁 What You Need

### Required Input Data
Place your CellRanger outputs in this structure:
```
data/
└── cellranger_outputs/
    ├── sample1/
    │   └── outs/
    │       └── filtered_feature_bc_matrix/
    ├── sample2/
    │   └── outs/
    │       └── filtered_feature_bc_matrix/
    ├── sample3/
    │   └── outs/
    │       └── filtered_feature_bc_matrix/
    └── sample4/
        └── outs/
            └── filtered_feature_bc_matrix/
```

### What's in filtered_feature_bc_matrix?
- `barcodes.tsv.gz` - Cell barcodes
- `features.tsv.gz` - Gene and protein names
- `matrix.mtx.gz` - Count matrix

---

## 🔧 Customization Tips

### Adjust QC Parameters
In preprocessing notebooks, modify these thresholds based on your data:

```python
QC_PARAMS = {
    'min_genes': 200,           # Lower = more cells, but lower quality
    'max_genes': 6000,          # Higher = fewer doublets filtered
    'max_mito_pct': 20,         # Lower = stricter quality
    'mouse_content_max': 5,     # For xenograft filtering
}
```

### Change Integration Parameters
In integration notebook:

```python
INTEGRATION_PARAMS = {
    'n_latent': 30,             # Latent dimensions (20-40)
    'max_epochs': 400,          # Training epochs (200-500)
}
```

---

## 📊 Expected Outputs

### After Preprocessing
```
data/processed/sample1/
├── sample1_processed.h5ad              ← Main output (use this!)
├── sample1_summary.csv
├── sample1_qc_before_filtering.png
└── sample1_summary_figure.png
```

### After Integration
```
data/integrated/
├── integrated_totalvi.h5ad             ← Main output (use this!)
├── totalvi_model/                      ← Trained model
├── marker_genes.csv                    ← Cluster markers
└── integration_summary.png
```

---

## ⚡ Common Issues & Quick Fixes

### "Module not found: scanpy"
```bash
conda activate citeseq_trans017
pip install scanpy scvi-tools
```

### "No such file or directory: CellRanger output"
Update the `CELLRANGER_OUTPUT` path in the notebook to match your data location.

### "CUDA not available" (for GPU)
Integration will work on CPU (just slower). For GPU:
```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

### Memory errors
Reduce the number of genes:
```python
sc.pp.highly_variable_genes(adata, n_top_genes=2000)  # Was 3000
```

---

## 📖 Where to Look for Help

### Detailed Documentation
- Full workflow: `README_ANALYSIS.md`
- CITE-seq guide: `../docs/KnowledgeBase/CITE-seq_comprehensive_guide.md`

### In the Notebooks
- `sample1_preprocessing.ipynb` has extensive comments explaining each step
- Integration notebook has detailed method explanations

### External Resources
- scanpy tutorials: https://scanpy-tutorials.readthedocs.io/
- scvi-tools docs: https://docs.scvi-tools.org/
- CITE-seq best practices: https://www.sc-best-practices.org/

---

## 🎯 What's Special About This Pipeline?

### 1. **Xenograft-Aware**
- Automatically filters mouse contamination
- Validates human cell purity

### 2. **Multi-Modal**
- Processes RNA and protein together
- Uses totalVI for integrated analysis

### 3. **Production-Ready**
- Comprehensive QC at every step
- Reproducible with documented parameters
- Saves all intermediate results

### 4. **Well-Documented**
- Explains the "why" behind each step
- References to methodology papers
- Troubleshooting guides

---

## 🔍 How to Check if It Worked

### Good Signs After Preprocessing:
- ✅ Retained 60-90% of cells after filtering
- ✅ Clear clusters in UMAP
- ✅ Low mouse contamination (<5%)
- ✅ Reasonable number of genes per cell (1000-3000 median)

### Good Signs After Integration:
- ✅ Samples are mixed in UMAP (not completely separated)
- ✅ Mixing score >0.6
- ✅ Biologically sensible clusters
- ✅ Marker genes match expected cell types

---

## 💡 Pro Tips

1. **Start with sample1 first** - It has the most detailed annotations
2. **Review QC plots carefully** - They tell you if something is wrong
3. **Save your work often** - Notebooks auto-save, but manually save too
4. **Use version control** - Track changes to notebooks with git
5. **Document decisions** - Add markdown cells explaining parameter choices

---

## 🆘 Still Stuck?

1. Check the error message carefully
2. Look in the detailed README: `README_ANALYSIS.md`
3. Search the issue on GitHub:
   - scanpy: https://github.com/scverse/scanpy/issues
   - scvi-tools: https://github.com/scverse/scvi-tools/issues
4. Check scanpy discourse: https://discourse.scverse.org/

---

**Happy Analyzing! 🧬🔬**

*Remember: Single-cell analysis is iterative. You may need to adjust parameters and re-run - that's normal!*
