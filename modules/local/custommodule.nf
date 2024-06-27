process CUSTOMMODULE {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/jq:1.6':
        'biocontainers/jq:1.6' }"


    input:
    path(json)

    output:
    path "*_mqc.tsv",  emit: tsv

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    echo "# id: 'base content summary'" > gc_summary_mqc.tsv
    echo "# section_name: 'base and contigs summary statistics'" >> gc_summary_mqc.tsv
    echo "# format: 'tsv'" >> gc_summary_mqc.tsv
    echo "# plot_type: 'bargraph'" >> gc_summary_mqc.tsv
    echo "# description: 'This plot shows a brief summary of each base content/percentage in the query genomes'" >> gc_summary_mqc.tsv
    echo "# pconfig:" >> gc_summary_mqc.tsv
    echo "#    id: 'base content summary'" >> gc_summary_mqc.tsv
    echo "#    title: 'per_base content and percentage'" >> gc_summary_mqc.tsv
    echo "#    ylab: ''" >> gc_summary_mqc.tsv
    echo "id\tpercent_A\tpercent_C\tpercent_G\tpercent_T\tpercent_N\tcontig_non_ACGTN" >> gc_summary_mqc.tsv
    for i in $json
    do
        printf "\$(basename \$i .json)\t" >> gc_summary_mqc.tsv
        jq -r '[.contig_percent_a, .contig_percent_c, .contig_percent_g, .contig_percent_t, .contig_percent_n, .contig_non_acgtn] | @tsv' \$i >> gc_summary_mqc.tsv
    done

    echo "# id: 'contigs length statistics'" > contig_length_mqc.tsv
    echo "# section_name: 'base and contigs summary statistics'" >> contig_length_mqc.tsv
    echo "# format: 'tsv'" >> contig_length_mqc.tsv
    echo "# plot_type: 'heatmap'" >> contig_length_mqc.tsv
    echo "# description: 'This plot shows a short statistics abouth the length of contigs in the query genomes'" >> contig_length_mqc.tsv
    echo "# pconfig:" >> contig_length_mqc.tsv
    echo "#    id: 'contigs length statistics'" >> contig_length_mqc.tsv
    echo "#    title: 'contigs length statistics'" >> contig_length_mqc.tsv
    echo "#    ylab: 'length'" >> contig_length_mqc.tsv
    echo "id\tTOTALcontiglen\tMINcontiglen\tMAXcontiglen" >> contig_length_mqc.tsv
    for i in $json
    do
        printf "\$(basename \$i .json)\t" >> contig_length_mqc.tsv
        jq -r '[.total_contig_length, .min_contig_length, .max_contig_length] | @tsv' \$i >> contig_length_mqc.tsv
    done

    echo "# id: 'contigs number'" > contig_total_mqc.tsv
    echo "# section_name: 'base and contigs summary statistics'" >> contig_total_mqc.tsv
    echo "# format: 'tsv'" >> contig_total_mqc.tsv
    echo "# plot_type: 'heatmap'" >> contig_total_mqc.tsv
    echo "#    id: 'contigs length statistics'" >> contig_length_mqc.tsv
    echo "# description: 'This plot shows the total number of contigs in each test with threshold length'" >> contig_total_mqc.tsv
    echo "# pconfig:" >> contig_total_mqc.tsv
    echo "#    id: 'number of contigs'" >> contig_total_mqc.tsv
    echo "#    title: 'number of contigs'" >> contig_total_mqc.tsv
    echo "#    ylab: 'number'" >> contig_total_mqc.tsv
    echo "id\ttotalcontigs\tcontigs>1k\tcontigs>10k" >> contig_total_mqc.tsv
    for i in $json
    do
        printf "\$(basename \$i .json)\t" >> contig_total_mqc.tsv
        jq -r '[.total_contig, .contigs_greater_1k, .contigs_greater_10k] | @tsv' \$i >> contig_total_mqc.tsv
    done
    """
}
