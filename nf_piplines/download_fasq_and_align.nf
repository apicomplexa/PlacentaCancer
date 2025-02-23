nextflow.enable.dsl=2

params.dir = "/mnt/e/Projects/03_Education/PlacentaCancer"
params.kallisto_index = "${params.dir}/data/human_index_standard/index.idx"
params.tools_dir = "${params.dir}/tools"

process DownloadFastQ {
    tag "$sra"
    maxForks 2

    input: 
        val sra
    output:
        path "reads/*.fastq", emit: reads

    script:
        """
        ${params.tools_dir}/sratoolkit/bin/fasterq-dump ${params.dir}/data/reads/${sra} -O reads
        """
}

process FastQC {
    tag "$sra"
    publishDir "qc", mode: 'copy'

    input: 
        val sra
        path reads

    output: 
        path "*"

    script:
        """
        ${params.tools_dir}/FastQC/fastqc -o . ${reads}
        """
}

process MultiQC {
    publishDir "${params.results_dir}"

    input:
        path qc_reports
        path kallisto_logs
    output: 
        path "multiqc_report.html"

    script:
        """
        multiqc .
        """  
}

process KallistoQuant {
    tag "$sra"
    publishDir "quant/", mode: 'copy'

    input: 
        val sra 
        path reads

    output:
        path "*"

    script: 
        """
        ${params.tools_dir}/kallisto/build/src/kallisto quant -i ${params.kallisto_index} -o . ${reads}
        mv abundance.tsv ${sra}_abundance.tsv
        mv run_info.json ${sra}_run_info.json
        """
}

process CleanUp {
    tag "${sra}"

    input:
        val sra
        path reads
        val qcSignal
        val quantSignal

    script:
    """
    echo ${reads}
    rm -f \$(readlink ${reads})
    """
}

workflow {
    main:
        sra = Channel.from(params.sras.tokenize(','))

        DownloadFastQ(sra)

        FastQC(sra, DownloadFastQ.out.reads)
        KallistoQuant(sra, DownloadFastQ.out.reads)

        CleanUp(sra, DownloadFastQ.out.reads, FastQC.out, KallistoQuant.out)
}
