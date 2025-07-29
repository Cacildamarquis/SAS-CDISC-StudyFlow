# AE TLF Generation Using SDTM/ADaM Datasets (Clinical R-to-SAS Project)

This project demonstrates how to prepare SDTM and ADaM datasets using R, then analyze them using SAS to generate safety tables, listings, and figures (TLFs) for a clinical study. It also includes define documentation needed for regulatory submission.

## Project Scope

- Prepare SDTM (`dm`, `ae`) and ADaM (`adsl`, `adae`) datasets using the `clinicalfd` R package
- Export cleaned datasets to CSV
- Use SAS to:
  - Create a summary AE table (AE term by safety population)
  - Create descriptive statistics (e.g., AE onset day by safety flag)
- Provide necessary define metadata and traceability documentation

## Project Structure

clinical-tlf-ae/
├── data_preparation/
│ └── prepare_datasets.R # R script to clean and export SDTM/ADaM datasets
├── datasets/
│ ├── ae.csv # Cleaned AE dataset
│ ├── dm.csv # Cleaned DM dataset
│ └── adsl.csv # Cleaned ADSL dataset
├── sas_programs/
│ ├── tlf_ae_summary.sas # SAS code for TLFs
│ ├── define.sas # SAS code for creating Define XML
├── documents/
│ ├── define_metadata.xlsx # Metadata spreadsheet used for Define XML
└── README.md


## Tools Used

- R (`clinicalfd`, `haven`, `dplyr`)
- SAS (Base SAS procedures)
- Excel for metadata and traceability docs

## Supporting Docs
Define Metadata: Contains all variable attributes for SDTM and ADaM datasets (origin, label, type, controlled terms).


## Getting Started
Clone the repo
git clone https://github.com/yourusername/clinical-tlf-ae.git

Open prepare_datasets.R in RStudio
Run it to export the cleaned datasets.

Open tlf_ae_summary.sas in SAS
Run it to generate the AE summary table and descriptive stats.
