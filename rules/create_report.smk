rule createReport:
    input:
        trimmed_read_length = os.path.join(DATAFOLDER["trimmed"], "merged_length.tsv"),
        coverage = expand(os.path.join(DATAFOLDER["mapping_stats"], "{sample}", "{sample}.coverage.tsv"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        frag_size  = expand(os.path.join(DATAFOLDER["mapping_stats"], "{sample}", "{sample}.fragsize.tsv"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        mapping_statistics = expand(os.path.join(DATAFOLDER["mapping_stats"], "{sample}", "{sample}.bamstats.txt"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        mapping_statistics_forR = expand(os.path.join(DATAFOLDER["mapping_stats"], "{sample}", "{sample}.bamstats.pipe.txt"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        bam_stats_forR = expand(os.path.join(DATAFOLDER["mapping_stats"], "{sample}", "{sample}.bamstats.pipe.txt"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        version = os.path.join(PROJFOLDER, "pipeline.version"),
        dedupe_metric = expand(os.path.join(DATAFOLDER["mapping"], "{sample}", "{sample}.dedup.txt"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")]),
        consensus= expand(os.path.join(IUPAC_CNS_FOLDER, "{sample}.iupac_consensus.fasta"), sample = [sample for sample in SAMPLES.keys() if not sample.startswith("NPC")])
    output:
        report = os.path.join(PROJFOLDER, "qc_report.html")
    params:
        p_folder = PROJFOLDER,
        l_folder = os.path.join(PROJFOLDER, "intermediate_data", "08_reporting"),
        run_id = REPORT_RUNID,
        min_cov = CNS_MIN_COV,
        template = srcdir("../flupipe.Rmd")
    log:
        os.path.join(DATAFOLDER["logs"], "reporting", "reporting.log")
    conda:
        "../envs/r.yaml"
    threads:
        1
    shell:
        r"""
        # Debugging: print PROJFOLDER and l_folder to log
        echo "PROJFOLDER is: {params.p_folder}" >> {log}
        echo "l_folder is: {params.l_folder}" >> {log}

        # Create the report folder if it doesn't exist
        mkdir -p {params.p_folder}
        mkdir -p {params.l_folder}

        # Log the start of report generation
        echo "####### compiling report" >> {log}

        # Read the version from the file
        VERSION=$(cat {input.version})

        # Run R script to generate the report
        Rscript -e "rmarkdown::render('{params.template}',
                                       params=list(proj_folder='{params.p_folder}', 
                                                   list_folder='{params.l_folder}', 
                                                   run_name='{params.run_id}', 
                                                   min_cov='{params.min_cov}', 
                                                   version='$VERSION'),
                                       output_file='{output.report}')" &> {log}
        """
