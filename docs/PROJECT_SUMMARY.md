# TRANS_017 CITE-seq Analysis Pipeline
## Created: January 2026

---

## 📦 What Was Created

### Folder Structure
```
workflow/
├── 00_preprocessing/
│   ├── sample1_preprocessing.ipynb    [Detailed, annotated]
│   ├── sample2_preprocessing.ipynb    [Streamlined]
│   ├── sample3_preprocessing.ipynb    [Streamlined]
│   └── sample4_preprocessing.ipynb    [Streamlined]
│
├── 01_integration/
│   └── integration_totalvi.ipynb      [Complete integration pipeline]
│
├── README_ANALYSIS.md                 [Comprehensive documentation]
├── QUICKSTART.md                      [Quick start guide]
├── setup_environment.sh               [Linux/Mac setup]
├── setup_environment.ps1              [Windows setup]
└── PROJECT_SUMMARY.md                 [This file]
```

---

## 🎯 Pipeline Overview

### Phase 1: Preprocessing (4 notebooks)
**Purpose**: Individual sample QC and processing

**Key Features**:
- ✅ Xenograft-aware (filters mouse contamination)
- ✅ Dual-modality processing (RNA + Protein)
- ✅ Comprehensive QC with visualizations
- ✅ CLR normalization for ADT data
- ✅ HVG selection and dimensionality reduction
- ✅ Initial clustering for quality check

**Input**: CellRanger filtered_feature_bc_matrix
**Output**: Processed .h5ad files ready for integration

### Phase 2: Integration (1 notebook)
**Purpose**: Multi-sample integration and joint analysis

**Key Features**:
- ✅ totalVI deep learning integration (scVI-tools)
- ✅ Batch effect removal while preserving biology
- ✅ Joint RNA+protein embedding
- ✅ Integrated clustering across samples
- ✅ Differential expression analysis
- ✅ Quality metrics and validation

**Input**: All preprocessed samples
**Output**: Integrated dataset with batch-corrected embeddings

---

## 🔬 Methods & Tools

### Core Technologies
- **scanpy** (v1.9+): Single-cell analysis framework
- **scvi-tools** (v0.20+): Deep learning for single-cell genomics
- **totalVI**: State-of-the-art CITE-seq integration
- **PyTorch**: Neural network backend (GPU-accelerated)

### Analysis Workflow
```
Raw Data (CellRanger)
    ↓
[Preprocessing]
    ├─ Load & separate GEX/ADT
    ├─ Calculate QC metrics
    ├─ Filter mouse genes (xenograft)
    ├─ Filter low-quality cells
    ├─ Normalize RNA (log1p)
    ├─ Normalize protein (CLR)
    ├─ PCA & UMAP
    └─ Initial clustering
    ↓
Processed Samples (.h5ad)
    ↓
[Integration]
    ├─ Concatenate samples
    ├─ Train totalVI model
    ├─ Extract latent representation
    ├─ Joint clustering
    ├─ Find marker genes
    └─ Quality assessment
    ↓
Integrated Dataset
```

---

## 📊 Key Features

### 1. Xenograft-Specific Processing
```python
# Automatically identifies and filters mouse genes
adata_gex.var['mouse'] = adata_gex.var_names.str.match(r'^[a-z]')
adata_gex = adata_gex[adata_gex.obs['pct_counts_mouse'] < 5%, :]
```

Human genes: Uppercase (CD3D, IL2RA)
Mouse genes: Lowercase (Cd3d, Il2ra)

### 2. Multi-Modal Integration
- **RNA data**: Log-normalized, HVG-focused
- **Protein data**: CLR-normalized, all features used
- **Joint embedding**: totalVI learns shared representation
- **Advantage**: Protein validates RNA-based cell types

### 3. Comprehensive Quality Control
```python
QC Metrics Tracked:
├── Genes per cell (detect low-quality cells)
├── Total counts (detect doublets)
├── Mitochondrial % (detect dying cells)
├── Mouse contamination % (xenograft specific)
└── ADT counts (CITE-seq quality)
```

### 4. Robust Batch Correction
- **Method**: totalVI (probabilistic deep learning)
- **Benefits**: 
  - Removes technical variation (batch effects)
  - Preserves biological variation
  - Handles dropout in scRNA-seq
  - Denoises protein measurements

### 5. Reproducibility
- Fixed random seeds
- Documented parameters
- Version-controlled environment
- Saved intermediate results

---

## 📈 Expected Results

### Preprocessing (per sample)
| Metric | Typical Value |
|--------|---------------|
| Cells retained | 60-90% of raw |
| Median genes/cell | 1000-3000 |
| Median counts/cell | 5000-15000 |
| Mouse contamination | <5% |
| Clusters identified | 5-15 |

### Integration
| Metric | Good | Acceptable | Poor |
|--------|------|------------|------|
| Mixing score | >0.8 | 0.6-0.8 | <0.6 |
| Training loss | Decreasing | Plateaus | Increasing |
| Sample separation | Mixed | Partially mixed | Separated |
| Cluster coherence | Clear | Some overlap | Scattered |

---

## 🔧 Customization Points

### Easy Adjustments
```python
# QC thresholds (00_preprocessing)
QC_PARAMS = {
    'min_genes': 200,          # Stricter = fewer cells
    'max_mito_pct': 20,        # Lower = higher quality
    'mouse_content_max': 5,    # Xenograft threshold
}

# Integration parameters (01_integration)
INTEGRATION_PARAMS = {
    'n_latent': 30,            # 20-40 typical
    'max_epochs': 400,         # More = better fit, slower
}

# Clustering resolution (both)
resolutions = [0.4, 0.6, 0.8, 1.0]  # Lower = broader types
```

### Advanced Modifications
- Add regression of technical covariates
- Alternative integration methods (Harmony, scVI alone)
- Different clustering algorithms (Louvain, hierarchical)
- Custom cell type annotation workflows

---

## 📚 Documentation Hierarchy

1. **QUICKSTART.md** (START HERE!)
   - 5-minute setup guide
   - Minimal instructions to get running
   - Common issues & quick fixes

2. **README_ANALYSIS.md** (Deep Dive)
   - Complete methodology
   - Detailed troubleshooting
   - Hardware requirements
   - Output file descriptions

3. **Notebooks** (Implementation)
   - sample1_preprocessing.ipynb: Extensively annotated
   - integration_totalvi.ipynb: Method explanations
   - Other samples: Streamlined versions

4. **Setup Scripts** (Environment)
   - setup_environment.sh: Linux/Mac
   - setup_environment.ps1: Windows
   - Automated package installation

---

## 🎓 Learning Resources

### Included Documentation
- `README_ANALYSIS.md`: Full analysis guide
- `QUICKSTART.md`: Quick start guide
- `sample1_preprocessing.ipynb`: Annotated example
- `integration_totalvi.ipynb`: Integration theory

### External Resources
- scanpy tutorials: https://scanpy-tutorials.readthedocs.io/
- scvi-tools docs: https://docs.scvi-tools.org/
- CITE-seq guide: `../docs/KnowledgeBase/CITE-seq_comprehensive_guide.md`
- Best practices: https://www.sc-best-practices.org/

### Key Papers
- **CITE-seq**: Stoeckius et al., Nat Methods 2017
- **scanpy**: Wolf et al., Genome Biol 2018
- **scVI**: Lopez et al., Nat Methods 2018
- **totalVI**: Gayoso et al., Nat Methods 2021

---

## ⚠️ Important Notes

### Before You Start
1. ✅ Ensure CellRanger outputs are properly formatted
2. ✅ Check that you have both GEX and ADT data
3. ✅ Verify enough disk space (~500MB per sample)
4. ✅ Consider GPU availability for integration (optional but faster)

### Data Requirements
- **File format**: 10X MEX (CellRanger output)
- **Features**: Gene Expression + Antibody Capture
- **Genome**: Mixed species (human/mouse) for xenografts
- **Samples**: 4 samples (can adapt for more/fewer)

### Computational Requirements
| Task | CPU | RAM | GPU | Time |
|------|-----|-----|-----|------|
| Preprocessing | 4+ cores | 16GB | No | 10-20 min/sample |
| Integration | 8+ cores | 32GB | Optional | 15-45 min |

### Known Limitations
- Assumes consistent antibody panel across samples
- Requires proper species labeling in CellRanger
- Integration quality depends on biological similarity
- Cell type annotation requires manual curation

---

## 🚀 Next Steps After Running Pipeline

### 1. Cell Type Annotation
```python
# Manual annotation based on markers
cluster_annotations = {
    '0': 'CD4+ T cells',
    '1': 'CD8+ T cells',
    '2': 'B cells',
    # ... etc
}
```

### 2. Downstream Analyses
- Differential expression between conditions
- Trajectory/pseudotime analysis
- Cell-cell interaction analysis
- Compositional analysis (cell type proportions)
- Integration with spatial data (if available)

### 3. Validation
- Flow cytometry
- Immunofluorescence
- Functional assays
- Literature comparison

---

## 🤝 Contributing & Feedback

### Found an Issue?
1. Check documentation first (README_ANALYSIS.md)
2. Review QC plots for data quality issues
3. Try adjusting parameters
4. Check external tool documentation

### Want to Improve?
- Add cell type annotation module
- Implement automated QC threshold selection
- Add alternative integration methods
- Create visualization dashboard

---

## 📝 Citation & Acknowledgments

### If you use this pipeline, please cite:
- **scanpy**: Wolf et al., Genome Biology 2018
- **scvi-tools**: Gayoso et al., Nature Biotechnology 2022
- **totalVI**: Gayoso et al., Nature Methods 2021

### Pipeline Information
- **Version**: 1.0
- **Created**: January 2026
- **Project**: TRANS_017
- **Data Type**: CITE-seq (10X Genomics)
- **Organism**: Human cells (xenograft)

---

## 📞 Support & Resources

### Tool-Specific Help
- scanpy: https://discourse.scverse.org/
- scvi-tools: https://github.com/scverse/scvi-tools/discussions
- PyTorch: https://discuss.pytorch.org/

### Single-Cell Community
- Biostars: https://www.biostars.org/
- SEQanswers: http://seqanswers.com/
- Reddit r/bioinformatics

---

## ✨ Summary

You now have a **complete, production-ready CITE-seq analysis pipeline** that:

✅ Handles xenograft data (mouse contamination filtering)
✅ Processes both RNA and protein modalities
✅ Integrates multiple samples with state-of-the-art methods
✅ Provides comprehensive quality control
✅ Is fully documented and reproducible
✅ Includes troubleshooting guides
✅ Ready to run out-of-the-box

**Get started with QUICKSTART.md and happy analyzing! 🧬**

---

*"The best analysis is a reproducible analysis."*
