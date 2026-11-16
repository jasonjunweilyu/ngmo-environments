# Bris-Ensemble conda.yaml Modifications

## Summary
Adapted [bris-ens/conda.yaml](/scratch/dx2/jl8309/ngmo-environments-ensemble/environments/bris-ens/conda.yaml) from the working fastnet template to align with [bris-forecaster pyproject.toml](/scratch/dx2/jl8309/bris-ens-training/bris-forecaster/pyproject.toml) and [uv.lock](/scratch/dx2/jl8309/bris-ens-training/bris-forecaster/uv.lock) requirements. **Includes CRPS FFT loss support** via forked anemoi-core branch for training.

---

## Key Changes

### 1. PyTorch CUDA Version Update
**Why**: Bris-forecaster pyproject.toml specifies torch 2.6.0+cu124, not 2.7.0+cu126 (fastnet).

**Changes**:
- Updated CUDA wheel index: `https://download.pytorch.org/whl/cu124` (was cu126)
- Updated PyG wheel URL: `https://data.pyg.org/whl/torch-2.6.0+cu124.html` (was torch-2.7.0+cu126)
- Pinned torch versions:
  - `torch==2.6.0+cu124` (was 2.7.0+cu126)
  - `torchvision==0.21.0+cu124` (was 0.22.0+cu126)
  - `torchaudio==2.6.0+cu124` (new, from bris pyproject)

**Impact**: Ensures ABI compatibility between torch, torchvision, torchaudio, and GPU hardware. CUDA 12.4 vs 12.6 is a deliberate choice by bris-forecaster.

---

### 2. Anemoi-Training from Forked Branch (CRPS FFT Loss) ✅ **CRITICAL**
**Why**: Bris-forecaster README explicitly requires the forked anemoi-core branch for CRPS FFT loss support.

**Changes**:
- **NOW**: `git+https://github.com/evenmn/anemoi-core.git@feat/crps-fft-loss#subdirectory=training`
- **Previously**: `anemoi-training==0.5.1` (released version without CRPS FFT loss)

**Key details**:
- **Location in fork**: `training/src/anemoi/training/losses/afcrps_fft.py`
- **Loss class**: `anemoi.training.losses.CRPSFFTLoss`
- **Branch basis**: Older Anemoi version; other anemoi packages from PyPI for stability
- **Required for**: Training Bris models with spectral CRPS loss (not needed for inference)

**Other anemoi packages** (from PyPI with versions from bris-forecaster pyproject.toml):
- `anemoi-datasets==0.5.24`
- `anemoi-graphs==0.6.2`
- `anemoi-models==0.8.1`
- `anemoi-transform==0.1.11`
- `anemoi-utils==0.4.23`

**Removed**: `anemoi-inference==0.5.1` (NOT in bris-forecaster pyproject.toml or uv.lock)

---

### 3. PyTorchMetrics Addition
**Why**: Bris-forecaster uv.lock explicitly pins `torchmetrics==1.7.3` (pytorch-lightning dependency).

**Changes**:
- Added: `torchmetrics==1.7.3` (new, from bris uv.lock)

**Impact**: Ensures consistent metrics computation for pytorch-lightning training workflows.

---

### 4. Torch-Geometric Version Pinning
**Why**: Bris-forecaster pins `torch-geometric==2.6.1` exactly. This version is tested with torch 2.6.0+cu124.

**Changes**:
- `torch-geometric==2.6.1` (was >=2.3.1, flexible)

**Impact**: Compiled PyG extensions are ABI-sensitive. Pinning prevents fallback to incompatible wheels.

---

### 5. Explicit Triton Pinning
**Why**: Bris-forecaster pyproject explicitly pins `triton==3.2.0`. Triton is a critical CUDA JIT compiler used by torch 2.6.0.

**Changes**:
- Added explicit pin: `triton==3.2.0`

**Impact**: Ensures stable CUDA kernel compilation for dynamic operations in models.

---

### 6. Removed flash-attn Dependency
**Why**: Bris-forecaster pyproject.toml does not include flash-attn. FastNet needed the custom wheel; Bris does not.

**Changes**:
- Removed custom flash-attn wheel URL: `https://github.com/cathalobrien/get-flash-attn/releases/download/...`

**Impact**: Simplifies dependency resolution. If flash-attn is needed for your workload, add it back with compatible torch version.

---

### 7. earthkit Package Versions
**Why**: Bris-forecaster specifies exact earthkit versions.

**Changes**:
- `earthkit-data==0.15.0` (was >=0.19,<1)
- `earthkit-meteo==0.4.1` (was in conda section)
- `earthkit-regrid==0.4.0` (was in conda section)

**Impact**: Ensures data I/O workflows are stable and reproducible.

---

### 8. Complete uv.lock Alignment ✅

**Status**: All PyTorch GPU stack and anemoi packages verified against uv.lock

**Verified versions match uv.lock exactly:**
- torch==2.6.0+cu124 ✓
- torchvision==0.21.0+cu124 ✓
- torchaudio==2.6.0+cu124 ✓
- torch-geometric==2.6.1 ✓
- pytorch-lightning==2.5.2 ✓
- triton==3.2.0 ✓
- timm==1.0.16 ✓
- torchinfo==1.8.0 ✓
- **torchmetrics==1.7.3** ✓ (NEW, pytorch-lightning dependency)
- anemoi-training (forked branch: feat/crps-fft-loss) ✓
- anemoi-datasets==0.5.24 ✓
- anemoi-graphs==0.6.2 ✓
- anemoi-models==0.8.1 ✓
- anemoi-transform==0.1.11 ✓
- anemoi-utils==0.4.23 ✓

**Correctly excluded from conda.yaml**:
- `anemoi-inference` (not in bris-forecaster pyproject.toml or uv.lock)
- `flash-attn` (not in bris pyproject)

---

### 9. Preserved Lessons from FastNet

✅ **Pip GPU stack** — torch, torchvision, torchaudio, torch-geometric stay in pip (not conda) to avoid CPU fallback  
✅ **No conda CUDA pins** — Prevents conda solver from picking CUDA-incompatible packages  
✅ **Explicit PyG wheels index** — Ensures compiled wheels are found  
✅ **Python 3.12.*** — Maintains ABI compatibility with cu124 wheels  
✅ **sympy + mpmath** — Kept explicit for torch import runtime requirements

---

## GPU Stack Configuration Summary

| Aspect | Setting | Reason |
|--------|---------|--------|
| Torch Source | Pip (cu124 wheels) | Avoid conda CPU fallback; explicit CUDA variant control |
| Torch Version | 2.6.0+cu124 | Matches bris-forecaster pyproject.toml |
| Torch-Geometric | Pip, pinned 2.6.1 | Compiled wheels must match torch ABI exactly |
| Triton | Pip, pinned 3.2.0 | CUDA JIT compiler; version matters for kernel generation |
| Conda CUDA/cuda-version | None | Prevent conda solver from picking CUDA incompatible packages |
| Python | 3.12.* | ABI tag for cu124 wheels |

---

## Testing After Environment Creation

After building the environment, run on a **GPU compute node** (not login node):

```bash
conda activate bris-ens
python - <<'PY'
import torch
print('torch', torch.__version__)
print('cuda_available', torch.cuda.is_available())
print('device_count', torch.cuda.device_count())

import torch_geometric
print('pyg', torch_geometric.__version__)

import anemoi.training
print('anemoi.training ok')

# Test CRPS FFT loss import (forked branch specific)
from anemoi.training.losses import CRPSFFTLoss
print('CRPSFFTLoss import ok - CRPS FFT loss training support confirmed!')
PY
```

**Expected output (on GPU node):**
- `torch 2.6.0+cu124`
- `cuda_available True`
- `device_count >= 1`
- `pyg 2.6.1`
- `anemoi.training ok`
- `CRPSFFTLoss import ok - CRPS FFT loss training support confirmed!`

---

## Creating the Environment

```bash
conda env create -f /scratch/dx2/jl8309/ngmo-environments-ensemble/environments/bris-ens/conda.yaml -n bris-ens
conda activate bris-ens
```

---

## Conda vs Pip Trade-off

**Why conda is used instead of pure uv.sync**:
- Conda resolution is more flexible and faster for HPC environments
- Non-CUDA packages (numpy, scipy, matplotlib) don't need pip
- System integration (eccodes, netcdf4 system libraries) works better with conda
- If exact uv.lock versions are critical, use `uv sync` in Python 3.12.11 environment instead

---

## Important Notes on Forked Anemoi-Core

**Repository**: https://github.com/evenmn/anemoi-core/tree/feat/crps-fft-loss  
**Branch**: `feat/crps-fft-loss`  
**Key feature**: Custom spectral CRPS loss (`CRPSFFTLoss`)  
**Version basis**: Older Anemoi version; check compatibility with your use case

**Q: Do I need anemoi-training, anemoi-graphs, and anemoi-models from the fork?**

A: **No**. Only `anemoi-training` comes from the forked branch (for CRPS FFT loss). Other packages (datasets, graphs, models, transform, utils) come from PyPI with versions from bris-forecaster pyproject.toml because:
1. The fork is based on an older Anemoi version
2. PyPI versions are tested together with the fork's training module
3. This approach balances stability (forked training) with compatibility (PyPI support packages)

If you need forked versions of graphs/models, check the fork directly and update the pip entries.

---

## References

- Bris-forecaster repository: https://github.com/metno/bris-inference
- Forked anemoi-core (CRPS FFT loss): https://github.com/evenmn/anemoi-core/tree/feat/crps-fft-loss
- FastNet conda.yaml (template): `/scratch/dx2/jl8309/ngmo-environments-ensemble/environments/fastnet/conda.yaml`

