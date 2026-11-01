# Prefrontal Brain-to-Brain Synchrony in Group Hunting (n=32)

[![Preprint](https://img.shields.io/badge/bioRxiv-Preprint-red)](https://doi.org/10.64898/2026.04.05.716331)

This repository contains the multimodal data pipeline and analysis scripts for the study: 
**"Prefrontal brain-to-brain synchrony during human group hunting: Evidence from fNIRS hyperscanning"** *(bioRxiv, 2026)*.

## 🔬 Key Findings
* **Behavioral Predictors**: Success in group hunting is significantly predicted by "speed-matching" and maintaining closer interpersonal distance with co-predators.
* **PFC Synchrony**: We found significantly greater brain-to-brain synchrony in the **medial and lateral Prefrontal Cortex** during hunting compared to chance levels.
* **Social Coordination**: Findings suggest the PFC plays a critical role in real-time social tracking and tactical coordination in dynamic virtual environments.

## 📁 Files

### 🛠 Minecraft Data Acquisition (Java/Maven)
* **Main.java**, **plugin.yml**, **pom.xml**, & **.gitignore**: Custom Minecraft plugin infrastructure developed to extract high-fidelity game data for behavioral analysis.

### 🧠 Neural Analysis & Synchrony (MATLAB)
* **Preprocessing & Pipeline**: `spmfnirsflow.m`, `PreprocessingfNIRSEmre.m`, `spm_fnirs_spm.m`, `spm_fnirs_spatialpreproc_ui.m`, `spm_fMRI_design.m`, `Organisefolders.m`, `getfolders.m`, and `spm_get_ons.m` handle the core brain data preprocessing workflow.
* **Synchrony Analysis**: `process_dyads.m`, `Waveletcoherenceanalysis.m`, `phase_scramble.m`, and `block_time_scramble.m` for dyadic coupling and null distribution generation.
* **Activation Analysis**: `Run_GLM_snirf.m` (creating design matrices for single-subject brain data) and `singlesubjectanalysis.m` (single-subject brain activity analysis).
* **Quality Control**: `Beforepreprocessingcheck.m`, `Excludetable.m`, and `Confirmdateoftesting.m` ensure data integrity and subject inclusion/exclusion.

### 📊 Behavioral Modeling & Visualization (Python/R)
* **Data Preprocessing**: `Behaviouralplotsstats.ipynb` and `PreparingbehaviourdataforfNIRS.ipynb` for cleaning and formatting raw behavioral data.
* **Statistical Analysis**: `fNIRSanalysis.ipynb` (Running fNIRS and physiology data stats) and `FNIRSDistancemodel.R` (Analyzing behavioral stats).
* **Visualization**: `CreatefNIRStemplate.ipynb` for fNIRS-specific data visualizations.

## 📦 Data

Derived inter-brain synchrony data for the hyperscanning analysis (9 dyads that passed fNIRS quality control, 25 prefrontal channels each). No raw signals or identifying information are included; dyads are numbered only.

* **`data/wtc_real_dyads.csv`** (450 rows): mean wavelet transform coherence (WTC) between the two predators in each dyad, per channel and trial type (`Chase` = Hunt trials, `Follow` = Follow trials), averaged within three frequency bands: low (0.02-0.03 Hz), mid (0.03-0.1 Hz) and high (0.1-0.2 Hz). `Most likely region` gives the Brodmann-atlas region for each channel. Channels 24 and 25 are short-separation channels.
* **`data/wtc_null_timeshift_1000.csv`** (450,000 rows): the same table recomputed for 1,000 time-shifted surrogates per dyad and channel (`Iteration` 1-1000), in which one partner's signal is shifted relative to the other to break temporal alignment. This is the null distribution used to test whether observed synchrony exceeds chance.

In `fNIRSanalysis.ipynb` these files are read as `FINALWTCFRAMEREALWITHNAMES.csv` and `FINALWTCFRAMENULLWITHNAMES.csv`.

## 🛠 Skills Demonstrated
* **Multimodal Sensor Fusion**: Synchronizing discrete game-engine events (Minecraft) with continuous neural streams (fNIRS) at high temporal resolution.
* **Advanced Signal Processing**: Implementing Wavelet Coherence and non-parametric permutation testing (Phase/Time scrambling) for dyadic data analysis.
* **Full-Stack Research Engineering**: Building the data acquisition tools (Java), the analysis engine (MATLAB), and the statistical modeling (R/Python).
