# each variable has its own column
# each case is its in own row (record)
# each value is in its own cell
# important for modelling and plotting
# blank spaces are know to distinguish between two objects
#EDA: for transformation and visualization (question or hypothesis generator)
# variations: spreadness, differences between the groups
#covariations: in correlations, representatives (depending on the value of correlation)

#Plan
#The genotypes dataset is in wide format (variants as rows, individuals as columns).
#We need to convert it to long format where each row represents a (variant, individual, genotype) pair.
#In R, we use pivot_longer().
#Merge with samples_metadata
#We join on the individual column to add phenotype (PHENO) information.

#What This Code Does
#pivot_longer(cols = -variant, names_to = "individual", values_to = "genotype")
#Transforms the genotype dataset from wide to long format.
#variant stays as a column.
#Individual IDs move from column names to a new individual column.
#Genotype values (0/0, 0/1, 1/1) are stored in a new genotype column.
#left_join(samples_metadata %>% select(individual, PHENO), by = "individual")
#Merges the long genotype dataset with metadata based on the individual column.
#Adds the PHENO column, allowing us to distinguish cases vs. controls.
