process LAST_TRAIN {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/last:1542--h43eeafb_1' :
        'biocontainers/last:1542--h43eeafb_1' }"

    input:
    tuple val(meta), path(fastx)
    path  index

    output:
    tuple val(meta), path("*.train"), emit: param_file
    tuple val(meta), path("*_mqc.tsv")  , emit: tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    INDEX_NAME=\$(basename \$(ls $index/*.des) .des)

    last-train \\
        $args \\
        -P $task.cpus \\
        ${index}/\$INDEX_NAME \\
        $fastx \\
        > ${prefix}.\$INDEX_NAME.train

    echo "# id: 'alignment parameters'" > ${prefix}_mqc.tsv
    echo "# section_name: 'Alignment parameters and summary'" >> ${prefix}_mqc.tsv
    echo "# format: 'tsv'" >> ${prefix}_mqc.tsv
    echo "# plot_type: 'table'" >> ${prefix}_mqc.tsv
    echo "# description: 'This plot shows the last alignment parameters'" >> ${prefix}_mqc.tsv
    echo "# pconfig:" >> ${prefix}_mqc.tsv
    echo "#    id: 'alingment parameters'" >> ${prefix}_mqc.tsv
    echo "#    title: 'alingment parameters'" >> ${prefix}_mqc.tsv
    echo "#    ylab: ''" >> ${prefix}_mqc.tsv
    echo "id\tsubstitution_percent_identity\tlast -t\tlast -a\tlast -A\tlast -b\tlast -B\tlast -S" >> ${prefix}_mqc.tsv
    printf "\$(basename ${prefix}.\$INDEX_NAME.train .target.train)\t" >> ${prefix}_mqc.tsv
    grep 'substitution percent identity' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$5}' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -t' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$2}' | sed -e 's/-t//' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -a' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$3}' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -A' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$3}' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -b' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$3}' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -B' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$3}' | tr '\n' '\t' >> ${prefix}_mqc.tsv
    grep 'last -S' ${prefix}.\$INDEX_NAME.train | tail -n 1 | awk '{print \$3}' >> ${prefix}_mqc.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        last: \$(lastdb --version | sed 's/lastdb //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    INDEX_NAME=STUB
    touch ${prefix}.\$INDEX_NAME.train

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        last: \$(lastdb --version | sed 's/lastdb //')
    END_VERSIONS
    """
}
