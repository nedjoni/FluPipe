#singularity: "docker://rkibioinf/general:3.6.0--53569a8"
# cd ${params.sd} command problematic in container

rule getVersion:
    output:
        os.path.join(PROJFOLDER, "pipeline.version")
    log:
        os.path.join(DATAFOLDER["logs"], "version", "pipeline.version.log")
    shell:
        r"""
            # Change to the parent directory where the Git repo is located
            cd {config[parent_folder]}  # This refers to the parent folder defined in the config

            # Try to get the Git version
            git describe --tags > {output} 2> {log} || echo 'unknown_version' > {output} 2> {log}
        """

