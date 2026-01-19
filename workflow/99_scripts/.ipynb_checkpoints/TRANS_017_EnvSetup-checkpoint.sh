# pick a location you own; default is usually fine if your conda is user-installed
mamba create -n py_scrnaseq -c conda-forge python=3.10 scanpy scvi-tools jupyterlab ipykernel
conda activate py_scrnaseq
python -m ipykernel install --user --name scrnaseq --display-name "scRNASeq - Python"
