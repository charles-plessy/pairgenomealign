/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { LAST_DOTPLOT as LAST_DOTPLOT_M2O          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_DOTPLOT as LAST_DOTPLOT_O2O          } from '../../../modules/nf-core/last/dotplot/main'
include { LAST_LASTAL as LAST_LASTAL_M2O           } from '../../../modules/nf-core/last/lastal/main'
include { LAST_LASTDB            } from '../../../modules/nf-core/last/lastdb/main'
include { LAST_SPLIT as LAST_SPLIT_O2O             } from '../../../modules/nf-core/last/split/main'
include { LAST_TRAIN             } from '../../../modules/nf-core/last/train/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PAIRALIGN_M2O {

    take:
    ch_target       // channel: target file read in from --target
    ch_queries      // channel: query sequences found in samplesheet read in from --input

    main:

    //
    // MODULE: lastdb
    //
    LAST_LASTDB (
        ch_target
    )

    // MODULE: last-train
    //
    LAST_TRAIN (
        ch_queries,
        LAST_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
    )

    // MODULE: lastal_lastal_m2o
    //
    LAST_LASTAL_M2O (
        ch_queries.join(LAST_TRAIN.out.param_file),
        LAST_LASTDB.out.index.map { row -> row[1] }  // Remove metadata map
    )

    // MODULE: last_dotplot_m2o
    //
    if (! (params.skip_dotplot_m2o) ) {
    LAST_DOTPLOT_M2O (
        LAST_LASTAL_M2O.out.maf,
        'png'
    )
    }

    // MODULE: last_split_o2o
    // with_arg
    //
    LAST_SPLIT_O2O (
        LAST_LASTAL_M2O.out.maf
    )

    // MODULE: last_dotplot_o2o
    //
    if (! (params.skip_dotplot_o2o) ) {
    LAST_DOTPLOT_O2O (
        LAST_SPLIT_O2O.out.maf,
        'png'
    )
    }

    emit:

    train = LAST_TRAIN.out.param_file
    m2o = LAST_LASTAL_M2O.out.maf
    o2o = LAST_SPLIT_O2O.out.maf
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
