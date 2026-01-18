# TRANS_017 CITE-seq Analysis Workflow

## Overview
Comprehensive analysis pipeline for CITE-seq data from 4 xenograft samples (human cells in mouse). This workflow processes both RNA (Gene Expression) and protein (Antibody-Derived Tags) modalities using state-of-the-art single-cell analysis tools.

## Folder Structure

```
workflow/
├── 98_notebooks/
│   ├── 00_preprocessing/          # Individual sample preprocessing
│   │   ├── sample1_preprocessing.ipynb
│   │   ├── sample2_preprocessing.ipynb
│   │   ├── sample3_preprocessing.ipynb
│   │   └── sample4_preprocessing.ipynb
│   │
│   └── 01_integration/           # Multi-sample integration
│       └── integration_totalvi.ipynb
│
└── 97_containers/                # Container definitions
```

## Analysis Pipeline

### Phase 1: Preprocessing (00_preprocessing/)

**Purpose**: Process each sample individually to ensure quality and prepare for integration.

**Key Steps**:
1. **Load CellRanger outputs** - Import aligned data
2. **Quality Control** - Filter low-quality cells and genes
3. **Xenograft filtering** - Remove mouse contamination (human cells in mouse)
4. **RNA normalization** - Log-normalization and HVG selection
5. **Protein normalization** - CLR normalization for ADT data
6. **Dimensionality reduction** - PCA and UMAP
7. **Clustering** - Initial cell population identification
8. **Save processed data** - Ready for integration

**Critical for xenografts**: Each notebook filters out mouse genes (lowercase gene names) to ensure pure human cell analysis.

**Input**: CellRanger output directories
- `data/cellranger_outputs/sample[1-4]/outs/filtered_feature_bc_matrix/`

**Output**: Processed .h5ad files
- `data/processed/sample[1-4]/sample[1-4]_processed.h5ad`

**Notebooks**:
- `sample1_preprocessing.ipynb` - Detailed annotations explaining each step
- `sample2-4_preprocessing.ipynb` - Streamlined versions for additional samples

### Phase 2: Integration (01_integration/)

**Purpose**: Combine all samples, remove batch effects, and perform joint analysis.

**Method**: totalVI (scVI-tools)
- Deep learning-based integration
- Handles RNA + protein simultaneously
- Probabilistic framework for robust batch correction

**Key Steps**:
1. **Load all preprocessed samples**
2. **Merge and harmonize data**
3. **Train totalVI model** - Neural network learns integrated representation
4. **Extract latent space** - Batch-corrected embeddings
5. **Joint clustering** - Identify cell types across all samples
6. **Differential expression** - Find marker genes
7. **Quality metrics** - Assess integration success
8. **Cell type annotation** - Biological interpretation

**Input**: Preprocessed samples from Phase 1
**Output**: 
- `data/integrated/integrated_totalvi.h5ad` - Integrated dataset
- `data/integrated/totalvi_model/` - Trained model (reusable)
- `data/integrated/marker_genes.csv` - Cluster marker genes
- Summary statistics and visualizations

## Requirements

### Software
```bash
# Create conda environment
conda create -n citeseq python=3.9
conda activate citeseq

# Install packages
pip install scanpy scvi-tools
pip install numpy pandas matplotlib seaborn
pip install jupyter
```

### Key Packages
- **scanpy** (>=1.9.0) - Single-cell analysis toolkit
- **scvi-tools** (>=0.20.0) - Deep learning for single-cell genomics
- **anndata** - Data structure for single-cell data
- **PyTorch** - Deep learning backend (GPU recommended for large datasets)

### Hardware Recommendations
- **Preprocessing**: 16GB RAM minimum, 32GB recommended
- **Integration**: GPU recommended (CUDA-compatible) for >50k cells
- **Storage**: ~500MB per sample for processed data

## Data Requirements

### Expected CellRanger Structure
```
data/cellranger_outputs/
└── sample[1-4]/
    └── outs/
        ├── filtered_feature_bc_matrix/
        │   ├── barcodes.tsv.gz
        │   ├── features.tsv.gz
        │   └── matrix.mtx.gz
        └── ...
```

### Feature Types
- **Gene Expression**: Human genes (uppercase names, e.g., CD3D)
- **Antibody Capture**: Surface proteins (e.g., CD3-TotalSeqC)
- **Note**: Mouse genes (lowercase) will be filtered during preprocessing

## Quality Control Parameters

### Default QC Thresholds (adjustable in notebooks)
```python
QC_PARAMS = {
    'min_genes': 200,           # Min genes per cell
    'max_genes': 6000,          # Max genes per cell (doublet filter)
    'max_counts': 30000,        # Max RNA counts per cell
    'max_mito_pct': 20,         # Max mitochondrial %
    'mouse_content_max': 5,     # Max mouse gene % (xenograft)
    'adt_min_counts': 100,      # Min protein counts per cell
    'min_cells': 3,             # Min cells expressing a gene
}
```

**Important**: Adjust thresholds based on:
- Your specific experimental design
- QC plots generated in notebooks
- Expected cell type characteristics

## Running the Analysis

### Step-by-Step Workflow

1. **Verify data paths**
   - Update `CELLRANGER_OUTPUT` paths in preprocessing notebooks
   - Ensure CellRanger outputs are accessible

2. **Run preprocessing (in order)**
   ```bash
   # Option 1: Run in Jupyter
   jupyter notebook
   # Then open and run each sample notebook
   
   # Option 2: Run from command line
   jupyter nbconvert --to notebook --execute sample1_preprocessing.ipynb
   jupyter nbconvert --to notebook --execute sample2_preprocessing.ipynb
   jupyter nbconvert --to notebook --execute sample3_preprocessing.ipynb
   jupyter nbconvert --to notebook --execute sample4_preprocessing.ipynb
   ```

3. **Review preprocessing outputs**
   - Check QC plots in `data/processed/sample[1-4]/`
   - Verify cell retention rates in summary files
   - Adjust QC parameters if needed and re-run

4. **Run integration**
   ```bash
   jupyter nbconvert --to notebook --execute integration_totalvi.ipynb
   ```
   - Training takes 10-30 minutes depending on dataset size
   - GPU strongly recommended for >50k cells

5. **Examine integration quality**
   - Check mixing score (>0.6 is good)
   - Verify samples are mixed in UMAP
   - Review marker genes for biological sense

## Output Files

### Preprocessing Outputs (per sample)
```
data/processed/sample[1-4]/
├── sample[1-4]_processed.h5ad       # Main processed data
├── sample[1-4]_summary.csv          # Statistics
├── sample[1-4]_qc_before_filtering.png
├── sample[1-4]_clustering.png
└── sample[1-4]_summary_figure.png
```

### Integration Outputs
```
data/integrated/
├── integrated_totalvi.h5ad          # Integrated dataset (main output)
├── totalvi_model/                   # Trained model directory
├── integration_summary.csv          # Summary statistics
├── marker_genes.csv                 # Cluster markers
├── cluster_statistics.csv           # Per-cluster stats
├── before_integration.png           # Pre-integration UMAP
├── integration_summary.png          # Comprehensive figure
└── training_history.png             # Model training curves
```

## Key Analysis Objects

### AnnData Structure (after integration)
```python
adata_totalvi
├── .X                              # Gene expression (raw counts)
├── .obs                            # Cell metadata
│   ├── sample                      # Sample identity
│   ├── leiden_integrated           # Integrated clusters
│   ├── n_genes_by_counts          # QC metrics
│   └── ...
├── .var                            # Gene metadata
├── .obsm                           # Embeddings
│   ├── X_totalvi                   # Integrated latent space
│   ├── X_umap                      # UMAP coordinates
│   ├── protein_counts              # Raw protein counts
│   └── protein_clr                 # Normalized proteins
├── .layers
│   ├── counts                      # Raw RNA counts
│   ├── log_normalized              # Log-normalized RNA
│   └── totalvi_normalized          # totalVI-denoised expression
└── .uns                            # Unstructured data
    ├── protein_names               # List of proteins
    └── rank_genes_integrated       # Marker gene results
```

## Troubleshooting

### Common Issues

**1. Memory errors during preprocessing**
- Reduce `n_top_genes` parameter (e.g., 2000 → 1500)
- Process samples on separate machines
- Use sparse matrix operations

**2. Integration fails or doesn't mix well**
- Check if samples have very different cell compositions (expected!)
- Try different `n_latent` dimensions (20-40)
- Increase `max_epochs` for better convergence
- Ensure preprocessing was consistent across samples

**3. Mouse contamination still present**
- Verify gene naming convention in your CellRanger reference
- Adjust `mouse_content_max` threshold (try 2% instead of 5%)
- Check specific genes causing issues

**4. GPU not detected for totalVI**
```python
import torch
print(torch.cuda.is_available())  # Should be True
```
- CPU training works but is slower (~5-10x)
- Consider cloud computing (Google Colab, AWS)

**5. Different number of proteins across samples**
- Ensure same antibody panel was used
- Check CellRanger configuration
- May need to subset to common proteins

## Next Steps After Integration

### 1. Cell Type Annotation
- Use marker genes from `marker_genes.csv`
- Cross-reference with protein expression
- Consult literature for your tissue type
- Consider automated annotation tools (CellTypist, scType)

### 2. Differential Expression
```python
# Example: Compare conditions
sc.tl.rank_genes_groups(
    adata,
    groupby='condition',
    method='wilcoxon'
)
```

### 3. Trajectory Analysis
- For developmental or differentiation processes
- Use PAGA, Monocle3, or RNA velocity

### 4. Cell-Cell Interactions
- CellPhoneDB or similar tools
- Leverage protein data for validation

### 5. Compositional Analysis
- Statistical testing for cell type proportions
- Between conditions/samples

## Key References

### Methods
- **CITE-seq**: Stoeckius et al., Nat Methods 2017
- **scanpy**: Wolf et al., Genome Biol 2018
- **scVI**: Lopez et al., Nat Methods 2018
- **totalVI**: Gayoso et al., Nat Methods 2021

### Tutorials
- scanpy tutorials: https://scanpy-tutorials.readthedocs.io/
- scvi-tools documentation: https://docs.scvi-tools.org/
- CITE-seq analysis: https://www.sc-best-practices.org/

## Notes

### Xenograft-Specific Considerations
1. **Always check mouse contamination** - Even with species-specific alignment
2. **Ribosomal/mitochondrial genes** - May show different patterns
3. **Microenvironment effects** - Consider mouse stroma influence
4. **Validation** - Cross-check cell types with known markers

### Best Practices
- **Run samples consistently** - Use same QC thresholds
- **Save intermediate results** - Disk space is cheap, re-analysis is expensive
- **Document decisions** - Note why you chose specific parameters
- **Version control** - Track notebook versions and results
- **Validate findings** - Use orthogonal methods (flow cytometry, IF)

## Contact & Support

For issues specific to this analysis:
- Check notebook comments and markdown cells
- Review QC plots carefully
- Consult the CITE-seq comprehensive guide in `docs/KnowledgeBase/`

For tool-specific issues:
- scanpy: https://github.com/scverse/scanpy
- scvi-tools: https://github.com/scverse/scvi-tools

---

**Version**: 1.0
**Last updated**: January 2026
**Author**: Analysis pipeline for TRANS_017 project
