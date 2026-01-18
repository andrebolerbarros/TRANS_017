# CITE-seq: A Comprehensive Guide

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Introduction](#introduction)
3. [Goals of CITE-seq Analysis](#goals-of-cite-seq-analysis)
4. [Technology Behind CITE-seq](#technology-behind-cite-seq)
5. [Experimental Workflow](#experimental-workflow)
6. [Bioinformatics Analysis Workflow](#bioinformatics-analysis-workflow)
7. [Key Considerations and Best Practices](#key-considerations-and-best-practices)
8. [Advantages and Limitations](#advantages-and-limitations)
9. [References and Resources](#references-and-resources)

---

## Executive Summary

> **CITE-seq enables integrated single-cell RNA and surface protein profiling, leveraging antibody-derived DNA barcodes to improve cell identification and biological interpretation through a multimodal analysis workflow.**

### Technology at a Glance

CITE-seq extends standard droplet-based single-cell RNA sequencing by adding a protein readout:

1. Cells are stained with **oligonucleotide-barcoded antibodies** targeting surface proteins
2. Each antibody carries a unique DNA barcode (**Antibody-Derived Tag, ADT**)
3. During droplet encapsulation, both **cellular mRNA** and **antibody barcodes** are captured and indexed with the same cell barcode
4. Sequencing produces two synchronized libraries per cell:
   - **RNA library** → gene expression
   - **ADT library** → surface protein abundance

### Analysis Workflow Overview

| Stage | Key Steps |
|-------|-----------|
| **A. Preprocessing** | Demultiplex RNA/ADT libraries; align reads; generate count matrices; QC (RNA: library size, genes, %MT; ADT: background, isotype controls) |
| **B. Normalization** | RNA: log-normalization or variance stabilization; ADT: centered log-ratio (CLR) or dsb |
| **C. Integration** | Combine modalities via weighted/joint embeddings; PCA; neighborhood graphs; UMAP |
| **D. Clustering** | Cluster on integrated representations; annotate using RNA markers, ADT markers, or both |
| **E. Downstream** | Differential expression; trajectory analysis; condition comparisons |

---

## Introduction

CITE-seq (Cellular Indexing of Transcriptomes and Epitopes by Sequencing) is a multimodal single-cell technology that enables simultaneous measurement of gene expression (transcriptome) and cell surface protein abundance (proteome) within the same individual cells. First published in 2017 by researchers at the New York Genome Center (Stoeckius et al., *Nature Methods*), CITE-seq has become a powerful tool for comprehensive characterization of cellular phenotypes.

The core innovation of CITE-seq lies in the use of oligonucleotide-labeled antibodies, termed **Antibody-Derived Tags (ADTs)**, which allow protein detection through sequencing rather than fluorescence or mass spectrometry.

---

## Goals of CITE-seq Analysis

The primary objective of CITE-seq is to **jointly profile transcriptomic and surface protein expression at single-cell resolution**.

### Primary Objectives

1. **Improve cell-type and cell-state identification** beyond what RNA alone can provide — surface proteins serve as established markers for cell identity (e.g., CD4, CD8, CD19), helping resolve populations that may be ambiguous based on transcriptome alone.

2. **Capture post-transcriptional regulation** — since mRNA and protein levels do not always correlate (due to translational regulation, protein degradation, post-translational modifications), CITE-seq enables direct measurement of both layers.

3. **Enable robust immunophenotyping** — particularly for immune cell populations where surface markers are the gold standard for classification.

4. **Support integrative multimodal analyses** — combining RNA and protein signals for more biologically accurate interpretation, bridging decades of flow cytometry knowledge with unbiased transcriptomic profiling.

### Research Applications

- **Immunology**: Characterization of immune cell subsets, T cell activation states, immune responses to infection or vaccination
- **Cancer Research**: Tumor heterogeneity analysis, identification of tumor-infiltrating immune cells, discovery of novel cancer subtypes
- **Developmental Biology**: Tracking cell lineage and differentiation states
- **Drug Discovery**: Identifying therapeutic targets and biomarkers
- **Vaccine Development**: Understanding immune responses at single-cell resolution
- **Clinical Research**: Biomarker discovery, patient stratification, treatment response monitoring

---

## Technology Behind CITE-seq

### Core Principle

CITE-seq extends standard droplet-based single-cell RNA sequencing by adding a protein readout through oligonucleotide-barcoded antibodies:

```
┌─────────────────────────────────────────────────────────────────────┐
│  CITE-seq Technology Overview                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Cells stained with oligonucleotide-barcoded antibodies          │
│                         ↓                                           │
│  2. Droplet encapsulation captures both:                            │
│     • Cellular mRNA                                                 │
│     • Antibody barcodes (ADTs)                                      │
│                         ↓                                           │
│  3. Same cell barcode indexes both modalities                       │
│                         ↓                                           │
│  4. Sequencing produces two synchronized libraries:                 │
│     • RNA library → Gene Expression                                 │
│     • ADT library → Surface Protein Abundance                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**The result**: Two synchronized modalities per cell — RNA counts and protein counts — enabling integrated analysis.

### Antibody-Oligonucleotide Conjugates (ADTs)

The ADT structure typically contains:

1. **Antibody**: Monoclonal antibody targeting a specific cell surface protein
2. **Oligonucleotide barcode** with the following components:
   - **PCR handle/Illumina adapter**: Enables library amplification and sequencing
   - **Unique barcode sequence**: Identifies the specific antibody/target protein (typically 10-15 bp)
   - **Capture sequence**: Enables capture during droplet-based processing

### Commercial ADT Formats (TotalSeq™ from BioLegend)

| Format | Compatible Platform | Chemistry |
|--------|---------------------|-----------|
| **TotalSeq-A** | Any poly(dT) capture method (Drop-seq, REAP-seq) | Contains poly-A tail for mRNA capture mimicry |
| **TotalSeq-B** | 10x Genomics 3' v3/v3.1, Flex | Contains Capture Sequence 1 |
| **TotalSeq-C** | 10x Genomics 5' (Single Cell Immune Profiling) | Contains TSO-compatible sequence |

### Integration with Droplet-Based Platforms

CITE-seq is most commonly performed using the **10x Genomics Chromium** platform:

1. **Sample Preparation**: Cells are stained with a cocktail of ADT-conjugated antibodies
2. **Droplet Encapsulation**: Single cells are partitioned into gel beads-in-emulsion (GEMs)
3. **Barcoding**: Both mRNA and ADT oligos are captured by gel bead oligonucleotides containing:
   - Cell barcode (identifies the cell of origin)
   - UMI (Unique Molecular Identifier for counting)
4. **Library Preparation**: Separate gene expression (GEX) and ADT libraries are generated
5. **Sequencing**: Both libraries are sequenced on Illumina platforms

### Cell Hashing Extension

CITE-seq can be combined with **cell hashing** (using TotalSeq Hashtag antibodies) to:
- Multiplex multiple samples in a single experiment
- Enable "super-loading" of droplet platforms
- Detect and remove multiplets (doublets)

---

## Experimental Workflow

### Wet Lab Protocol Overview

#### 1. Sample Preparation

```
┌─────────────────────────────────────────────────────────┐
│ 1. Obtain single-cell suspension                        │
│    - Fresh tissue dissociation                          │
│    - PBMC isolation                                     │
│    - Cell line culture                                  │
│                                                         │
│ 2. Cell viability assessment (>80% recommended)         │
│                                                         │
│ 3. Cell counting and concentration adjustment           │
└─────────────────────────────────────────────────────────┘
```

#### 2. Antibody Staining

```
┌─────────────────────────────────────────────────────────┐
│ 1. Fc receptor blocking (10 min on ice)                 │
│    - TruStain FcX (human) or FcR Block (mouse)          │
│                                                         │
│ 2. Incubate with ADT antibody cocktail                  │
│    - Include isotype controls                           │
│    - Typical: 30 min on ice                             │
│                                                         │
│ 3. Wash cells (3x) to remove unbound antibodies         │
│    - Critical step for reducing background              │
│                                                         │
│ 4. Filter and resuspend for 10x loading                 │
└─────────────────────────────────────────────────────────┘
```

#### 3. Library Preparation and Sequencing

```
┌─────────────────────────────────────────────────────────┐
│ 1. 10x Chromium GEM generation                          │
│                                                         │
│ 2. Reverse transcription and cDNA amplification         │
│                                                         │
│ 3. Library construction:                                │
│    - Gene Expression (GEX) library                      │
│    - ADT (Feature Barcode) library                      │
│                                                         │
│ 4. QC: Bioanalyzer/TapeStation                          │
│    - GEX: ~300-700 bp                                   │
│    - ADT: ~180 bp                                       │
│                                                         │
│ 5. Sequencing:                                          │
│    - Pool GEX (90%) and ADT (5-10%)                     │
│    - Illumina NovaSeq/NextSeq                           │
│    - Read configuration: 28bp R1 + 90bp R2 (3' v3)      │
└─────────────────────────────────────────────────────────┘
```

---

## Bioinformatics Analysis Workflow

A standard analytical workflow consists of the following stages:

### Workflow Stages Overview

| Stage | Description | Key Considerations |
|-------|-------------|-------------------|
| **A. Preprocessing** | Demultiplex sequencing data into RNA and ADT libraries; align RNA reads; count ADT barcodes; perform QC | RNA QC: library size, detected genes, mitochondrial content. ADT QC: background signal, isotype controls, low-count antibodies |
| **B. Normalization** | Transform count data to comparable scales | RNA: log-normalization or model-based (SCTransform). ADT: centered log-ratio (CLR) or dsb |
| **C. Integration & Dim. Reduction** | Combine RNA and ADT features using weighted/joint embeddings | PCA on integrated data; compute neighborhood graphs; UMAP visualization |
| **D. Clustering & Annotation** | Cluster cells using integrated representations | Annotate using RNA markers, ADT markers, or combination of both |
| **E. Downstream Analyses** | Biological interpretation | Differential expression (RNA and/or protein); trajectory analysis; condition comparisons |

### Overview Pipeline

```
Raw FASTQ Files
      │
      ▼
┌─────────────────┐
│  Alignment &    │  Cell Ranger (10x) / CITE-seq-Count / kallisto
│  Quantification │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Quality        │  Filtering cells, genes, ADTs
│  Control        │  Doublet detection
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Normalization  │  RNA: LogNormalize/SCTransform
│                 │  ADT: CLR, dsb, or ADTnorm
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Integration    │  WNN (Weighted Nearest Neighbor)
│  (Multimodal)   │  totalVI (scvi-tools)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Downstream     │  Clustering, Visualization
│  Analysis       │  Differential Expression
└─────────────────┘
```

### Step 1: Alignment and Quantification

#### Using Cell Ranger (10x Genomics)

```bash
# Cell Ranger count with Feature Barcoding
cellranger count \
    --id=sample_name \
    --libraries=libraries.csv \
    --transcriptome=/path/to/refdata-gex-GRCh38-2020-A \
    --feature-ref=feature_reference.csv \
    --localcores=16 \
    --localmem=64
```

**libraries.csv** example:
```csv
fastqs,sample,library_type
/path/to/gex_fastqs/,sample_gex,Gene Expression
/path/to/adt_fastqs/,sample_adt,Antibody Capture
```

**feature_reference.csv** example:
```csv
id,name,read,pattern,sequence,feature_type
CD3,CD3,R2,^(BC),AACAAGACCCTTGAG,Antibody Capture
CD4,CD4,R2,^(BC),TGTTCCCGCTCAACT,Antibody Capture
CD8a,CD8a,R2,^(BC),GCTGCGCTTTCCATT,Antibody Capture
IgG1,IgG1_Isotype,R2,^(BC),CTCATTGTAACTCCT,Antibody Capture
```

#### Alternative: CITE-seq-Count

```bash
# For ADT alignment (can be used alongside Cell Ranger for RNA)
CITE-seq-Count \
    -R1 TAGS_R1.fastq.gz \
    -R2 TAGS_R2.fastq.gz \
    -t feature_barcodes.csv \
    -cbf 1 -cbl 16 \
    -umif 17 -umil 28 \
    -cells 200000 \
    -o output_directory
```

### Step 2: Loading Data into R (Seurat)

```r
# Load required libraries
library(Seurat)
library(tidyverse)
library(Matrix)

# Read Cell Ranger output (both RNA and ADT automatically detected)
data_dir <- "path/to/cellranger/outs/filtered_feature_bc_matrix/"
counts <- Read10X(data.dir = data_dir)

# Create Seurat object with RNA assay
seurat_obj <- CreateSeuratObject(
    counts = counts$`Gene Expression`,
    project = "CITE-seq_analysis",
    min.cells = 3,
    min.features = 200
)

# Add ADT assay
seurat_obj[["ADT"]] <- CreateAssayObject(
    counts = counts$`Antibody Capture`
)
```

### Step 3: Quality Control

Quality control on both modalities is essential:

- **RNA QC**: library size, detected genes, mitochondrial content
- **ADT QC**: background signal, isotype controls, low-count antibodies

```r
# Calculate QC metrics
seurat_obj[["percent.mt"]] <- PercentageFeatureSet(seurat_obj, pattern = "^MT-")
seurat_obj$log10GenesPerUMI <- log10(seurat_obj$nFeature_RNA) / log10(seurat_obj$nCount_RNA)

# ADT QC metrics
seurat_obj$nCount_ADT <- colSums(seurat_obj@assays$ADT@counts)
seurat_obj$nFeature_ADT <- colSums(seurat_obj@assays$ADT@counts > 0)

# Visualize QC metrics
VlnPlot(seurat_obj, 
        features = c("nFeature_RNA", "nCount_RNA", "percent.mt", "nCount_ADT"),
        ncol = 4)

# Filter cells
seurat_obj <- subset(seurat_obj, 
                     subset = nFeature_RNA > 200 & 
                              nFeature_RNA < 5000 & 
                              percent.mt < 20 &
                              nCount_ADT > 100)
```

### Step 4: Normalization

Normalization approaches differ between modalities:

- **RNA**: log-normalization or model-based normalization (e.g., variance stabilization via SCTransform)
- **ADT**: centered log-ratio (CLR), dsb, or similar compositional normalization

#### RNA Normalization

```r
# Standard log-normalization
DefaultAssay(seurat_obj) <- "RNA"
seurat_obj <- NormalizeData(seurat_obj)
seurat_obj <- FindVariableFeatures(seurat_obj)
seurat_obj <- ScaleData(seurat_obj)

# Alternative: SCTransform
# seurat_obj <- SCTransform(seurat_obj, verbose = FALSE)
```

#### ADT Normalization

**Option 1: Centered Log-Ratio (CLR) - Seurat default**

```r
DefaultAssay(seurat_obj) <- "ADT"
seurat_obj <- NormalizeData(seurat_obj, 
                            normalization.method = "CLR", 
                            margin = 2)  # margin=2 normalizes across cells
```

**Option 2: dsb (Denoised and Scaled by Background) - Recommended**

```r
library(dsb)

# Load raw (unfiltered) data for background estimation
raw_data <- Read10X("path/to/cellranger/outs/raw_feature_bc_matrix/")

# Define cells and background droplets
stained_cells <- colnames(counts$`Gene Expression`)
background <- setdiff(colnames(raw_data$`Gene Expression`), stained_cells)

# Extract ADT matrices
cells_adt <- raw_data$`Antibody Capture`[, stained_cells]
background_adt <- raw_data$`Antibody Capture`[, background]

# Define isotype controls
isotype_controls <- c("IgG1_Isotype", "IgG2a_Isotype", "IgG2b_Isotype")

# Normalize with dsb
adt_norm <- DSBNormalizeProtein(
    cell_protein_matrix = cells_adt,
    empty_drop_matrix = background_adt,
    denoise.counts = TRUE,
    use.isotype.control = TRUE,
    isotype.control.name.vec = isotype_controls
)

# Add normalized data to Seurat object
seurat_obj[["ADT"]] <- CreateAssayObject(data = adt_norm)
```

### Step 5: Dimensionality Reduction (Per Modality)

```r
# RNA PCA
DefaultAssay(seurat_obj) <- "RNA"
seurat_obj <- RunPCA(seurat_obj, verbose = FALSE)

# ADT PCA (use all features)
DefaultAssay(seurat_obj) <- "ADT"
VariableFeatures(seurat_obj) <- rownames(seurat_obj[["ADT"]])
seurat_obj <- ScaleData(seurat_obj)
seurat_obj <- RunPCA(seurat_obj, 
                     reduction.name = "apca",  # ADT PCA
                     verbose = FALSE)
```

### Step 6: Weighted Nearest Neighbor (WNN) Integration

**Stage C: Integration and Dimensionality Reduction**

This critical step combines RNA and ADT features using weighted or joint embeddings. The WNN approach (Hao et al., Cell 2021) learns cell-specific weights for each modality based on their informativeness, then constructs neighborhood graphs and low-dimensional projections.

```r
# Find multimodal neighbors
seurat_obj <- FindMultiModalNeighbors(
    seurat_obj,
    reduction.list = list("pca", "apca"),
    dims.list = list(1:30, 1:18),
    modality.weight.name = "RNA.weight"
)

# Run UMAP on WNN graph
seurat_obj <- RunUMAP(seurat_obj, 
                      nn.name = "weighted.nn",
                      reduction.name = "wnn.umap",
                      reduction.key = "wnnUMAP_")

# Clustering on WNN graph
seurat_obj <- FindClusters(seurat_obj, 
                           graph.name = "wsnn",
                           algorithm = 3,  # SLM algorithm
                           resolution = 0.5)
```

### Step 7: Visualization

```r
# Compare UMAP embeddings
p1 <- DimPlot(seurat_obj, reduction = "umap", label = TRUE) + 
      ggtitle("RNA UMAP")
p2 <- DimPlot(seurat_obj, reduction = "wnn.umap", label = TRUE) + 
      ggtitle("WNN UMAP")
p1 + p2

# Visualize modality weights
VlnPlot(seurat_obj, features = "RNA.weight", group.by = "seurat_clusters")

# Compare RNA and protein expression
DefaultAssay(seurat_obj) <- "ADT"
p1 <- FeaturePlot(seurat_obj, features = "CD4", 
                  reduction = "wnn.umap",
                  cols = c("lightgrey", "darkgreen")) + 
      ggtitle("CD4 Protein")

DefaultAssay(seurat_obj) <- "RNA"
p2 <- FeaturePlot(seurat_obj, features = "CD4", 
                  reduction = "wnn.umap") + 
      ggtitle("CD4 RNA")
p1 + p2

# Heatmap of ADT markers
DoHeatmap(seurat_obj, 
          features = rownames(seurat_obj[["ADT"]]),
          assay = "ADT")
```

### Step 8: Downstream Analyses (Stage E)

Once clustering and annotation are complete, several downstream analyses become possible:

- **Differential expression** (RNA and/or protein)
- **Trajectory or state-transition analysis**
- **Comparison across conditions, time points, or perturbations**

#### Differential Expression Analysis

```r
# Find markers using both modalities
DefaultAssay(seurat_obj) <- "RNA"
rna_markers <- FindAllMarkers(seurat_obj, only.pos = TRUE)

DefaultAssay(seurat_obj) <- "ADT"
adt_markers <- FindAllMarkers(seurat_obj, only.pos = TRUE)

# Compare specific clusters
cluster_markers <- FindMarkers(seurat_obj,
                               ident.1 = 0,
                               ident.2 = 1,
                               assay = "ADT")
```

---

## Key Considerations and Best Practices

### Antibody Panel Design

1. **Start with validated antibodies**: Use antibodies with proven specificity
2. **Include isotype controls**: Essential for background estimation (at least 3-4)
3. **Titrate antibodies**: Optimal concentrations reduce background; not all antibodies need the manufacturer's recommended concentration
4. **Consider panel complexity**: Start with 20-50 markers; expand as needed

### Quality Control Checkpoints

| Stage | QC Metric | Expected Value |
|-------|-----------|----------------|
| Pre-staining | Cell viability | >80% |
| Library QC | ADT peak (Bioanalyzer) | ~180 bp |
| Library QC | GEX peak | 300-700 bp |
| Post-sequencing | Sequencing saturation | >70% |
| Post-sequencing | Valid cell barcodes | >90% |
| Bioinformatics | ADT-positive cells | Variable by marker |

### ADT Normalization Method Selection

| Method | When to Use | Advantages | Limitations |
|--------|-------------|------------|-------------|
| **CLR** | Quick analysis, small panels | Simple, fast | Doesn't account for background |
| **dsb** | Recommended default | Uses empty droplets for background correction | Requires raw data with background |
| **ADTnorm** | Multi-batch integration | Batch correction, landmark-based | More complex parameter tuning |
| **totalVI** | Deep learning approach | Joint RNA-ADT model | Computationally intensive |

### Common Issues and Solutions

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| High ADT background | Insufficient washing | More stringent washes |
| Low ADT signal | Antibody degradation | Fresh reagents, proper storage |
| Poor RNA-protein correlation | Biological (expected for some genes) | Normal; interpret cautiously |
| Batch effects | Technical variation | Use ADTnorm or Harmony for integration |

---

## Advantages and Limitations

### Advantages

- **Multimodal data**: Comprehensive view of cell state from same cell
- **Scalable markers**: No practical upper limit on number of antibodies (unlike flow cytometry)
- **High throughput**: Thousands of cells per experiment
- **Established markers**: Leverage canonical surface protein markers
- **Lower dropout**: Protein detection has lower dropout than RNA

### Limitations

- **Surface proteins only**: Standard CITE-seq cannot detect intracellular proteins
- **Loss of spatial information**: Cells are dissociated
- **Antibody-dependent**: Limited by available validated antibodies
- **Cost**: Additional antibody reagents and sequencing depth
- **Background noise**: Ambient ADTs require careful normalization

### Related Technologies

| Technology | Description |
|------------|-------------|
| **REAP-seq** | Similar principle; different oligo design |
| **ECCITE-seq** | Adds TCR/BCR sequencing and sgRNA detection |
| **Spatial CITE-seq** | Maintains spatial information |
| **ASAP-seq** | Adds ATAC-seq (chromatin accessibility) |
| **TEA-seq** | Adds ATAC-seq with CITE-seq |

---

## References and Resources

### Key Publications

1. Stoeckius, M. et al. (2017). Simultaneous epitope and transcriptome measurement in single cells. *Nature Methods*, 14(9), 865-868. **[Original CITE-seq paper]**

2. Hao, Y. et al. (2021). Integrated analysis of multimodal single-cell data. *Cell*, 184(13), 3573-3587. **[WNN method, Seurat v4]**

3. Mulè, M.P. et al. (2022). Normalizing and denoising protein expression data from droplet-based single cell profiling. *Nature Communications*. **[dsb method]**

4. Ye, Z. et al. (2024). ADTnorm: Robust Integration of Single-cell Protein Measurement across CITE-seq Datasets. *Genome Biology*. **[ADTnorm method]**

### Software Resources

| Tool | Purpose | Link |
|------|---------|------|
| **Seurat** | R package for scRNA-seq/CITE-seq | https://satijalab.org/seurat/ |
| **dsb** | ADT normalization | https://github.com/niaid/dsb |
| **ADTnorm** | Multi-batch ADT normalization | https://github.com/yezhengstat/ADTnorm |
| **Cell Ranger** | 10x alignment and quantification | https://www.10xgenomics.com/support/software/cell-ranger |
| **CITE-seq-Count** | ADT alignment tool | https://github.com/Hoohm/CITE-seq-Count |
| **scvi-tools** | Deep learning (totalVI) | https://scvi-tools.org/ |
| **muon** | Python multimodal analysis | https://muon.readthedocs.io/ |

### Tutorials and Vignettes

- Seurat CITE-seq vignette: https://satijalab.org/seurat/articles/weighted_nearest_neighbor_analysis
- Broad Institute scWorkshop: https://broadinstitute.github.io/2020_scWorkshop/cite-seq.html
- OSCA Book (Bioconductor): https://bioconductor.org/books/release/OSCA.advanced/integrating-with-protein-abundance.html
- dsb end-to-end workflow: https://cran.r-project.org/web/packages/dsb/vignettes/end_to_end_workflow.html
- Tommy Tang's CITE-seq blog series: https://divingintogeneticsandgenomics.com/

---

*Document prepared: January 2026*  
*This document provides a comprehensive overview of CITE-seq technology and analysis. For the most up-to-date protocols and software versions, please consult the original documentation and publications.*
