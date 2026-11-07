# Prefrontal interpersonal neural synchrony during human group hunting: analysis scripts

Code for the fNIRS hyperscanning study by Yavuz et al. Results here follow the corrected analysis of November 2026.

**The bioRxiv preprint (https://doi.org/10.64898/2026.04.05.716331, posted 7 April 2026) reports the earlier analysis.** Its synchrony and speed results differ from those below.

## What was corrected
1. **Frequency bands.** Wavelet coherence ran on 25 Hz data without a sampling rate, so the bands were not in Hz. It now runs at 1 Hz with frequencies in Hz.
2. **Signal.** Synchrony and the single-brain GLM used HbO, although the Methods say CBSI. Both now use CBSI.
3. **Trial windows.** Onsets and durations are now handled in seconds.
4. **Above-chance test.** Values were compared with one threshold pooled across channels and dyads. Each dyad and channel is now compared with its own time-shifted null distribution.
5. **Speed similarity.** The original score correlated cumulative path distance, filled undefined windows with zero and was then reversed (`max - score`). It now correlates second-by-second changes in path distance over rolling 5 s windows, excluding undefined windows, and is not reversed.
6. **Distance between predators and synchrony.** Now modelled with `coherence ~ distance + (1 + distance | dyad)`.

The synchrony and GLM code is a Python implementation of the MATLAB `wcoherence` and SPM-style GLM steps, not an exact MATLAB replica.

## Main results
* **Behaviour:** distance between self and prey was the only significant predictor of time to catch the prey (beta = 3.71, 95% CI [1.40, 6.01], t = 3.15, p = .003). This is partly expected, because successful trials end close to the prey. Speed similarity was not significant (p = .447).
* **Synchrony above chance (k = 4, alpha = .18):** Hunt, high band (0.1-0.2 Hz), channels 1, 3, 7, 20 and 21 (5 channels against about 1.5 by chance, p = .015, uncorrected across the six trial type and band combinations). No other trial type or band exceeded chance. Across all bands: Hunt 12 channels against about 4.5 (p = .001), Follow 7 (p = .18).
* **Hunt > Follow:** channel 20 (right dlPFC), high band, t(8) = 5.69, FDR-corrected p = .011, in all 9 dyads.
* **Single-brain GLM:** nothing survived FDR correction.
* **Distance between predators and synchrony:** nothing survived correction (lowest FDR-corrected p = .18).

This is an exploratory study with 9 dyads in the hyperscanning analysis, so these results need replication.

## Corrected analysis scripts
| Script | Purpose |
|---|---|
| `wtc_python.py`, `rerun_wtc.py` | Wavelet coherence and 1,000 time shifts |
| `significance_per_dyad_channel.py` | Above-chance test and chance calibration |
| `wtc_trial_level.py`, `rerun_distance_henrik_model.R` | Distance between predators and synchrony |
| `rerun_glm.py` | Single-brain GLM on CBSI at 1 Hz |
| `speed_second_by_second.py` | Speed similarity as described in the Methods |
| `behaviour_model_frames.py`, `behaviour_model_second_by_second.R` | Behavioural model (Table 2) and sensitivity checks |
| `check_speed_measure_variants.py`, `check_speed_measure_model.R` | How the original speed score compares with alternatives |
| `figs.py`, `figure3_distance.py`, `fig5.py`, `figure4_brain_maps.py`, `figure5_lineplot.py` | Figures 2 to 5 (`brain_panel_source.png` and `figure2a_source.png` are their source images) |

## Still used from the original pipeline
* **Acquisition:** `Main.java`, `plugin.yml`, `pom.xml`.
* **Preprocessing and quality control:** `PreprocessingfNIRSEmre.m`, `spmfnirsflow.m`, the `spm_*` files, `Organisefolders.m`, `getfolders.m`, `Beforepreprocessingcheck.m`, `Excludetable.m`, `Confirmdateoftesting.m`.
* **Behavioural data preparation:** `PreparingbehaviourdataforfNIRS.ipynb` and `Behaviouralplotsstats.ipynb`. These still build the model frames and the outlier set. **Their `Lag Score` is the superseded speed score**, which `behaviour_model_second_by_second.R` replaces using `speed_second_by_second.py`.
* **Templates:** `CreatefNIRStemplate.ipynb`.

## Superseded
`superseded_original_analysis/` keeps the original scripts for transparency. They produced the preprint results and should not be used for the corrected analysis: `Waveletcoherenceanalysis.m`, `process_dyads.m`, `phase_scramble.m`, `block_time_scramble.m`, `fNIRSanalysis.ipynb`, `FNIRSDistancemodel.R`, `Run_GLM_snirf.m`, `singlesubjectanalysis.m`.

Not rerun in the corrected analysis: the speed similarity GLM (Design Matrix 6) and the debrief models. The manuscript reports no results from them.

## Data
Derived data only: dyads are numbered, and no raw signals or identifying information are included. Channels 24 and 25 are short-separation channels, and `Chase` means Hunt trials.

* `data/wtc_real_CBSI_1Hz.csv` and `data/wtc_null_CBSI_1Hz_1000.csv`: coherence per dyad, channel, trial type and band, for the real data and 1,000 time shifts.
* `data/wtc_significant_per_dyad_channel_CBSI_1Hz.csv`: channels passing k = 4, alpha = .18.
* `data/wtc_trial_level_CBSI_1Hz.csv`, `data/wtc_distance_lmm_random_slope_CBSI_1Hz.csv`: trial-level coherence and distance, and the model results.
* `data/speed_second_by_second.csv`, `data/table2_second_by_second.csv`: speed similarity per trial, and Table 2.
* `data/original_analysis/`: the earlier WTC data behind the preprint (HbO, not in Hz).
