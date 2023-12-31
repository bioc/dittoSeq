% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GeneTargeting-doc.R
\name{GeneTargeting}
\alias{GeneTargeting}
\title{Control of Gene/Feature targeting}
\description{
Control of Gene/Feature targeting
}
\section{Overview}{

As of dittoSeq version 1.15.2, we made it possible to target genes / features from across multiple modalities.
Here, we describe intricacies of how 'assay', 'slot', and 'swap.rownames' inputs now work to allow for this purpose.

Control of gene/feature targeting in dittoSeq functions aims to blend seamlessly with how similar control works in Seurat, SingleCellExperiment (SCE), and other packages that deal with these data structures.
However, as we've built in new features into dittoSeq, and the Seurat and SCE-package maintainers extend their tools as well, some divergence was to be expected.

The way Seurat and SingleCellExperiment objects hold data from multiple modalities is quite distinct, thus it is worth describing each distinctly.

It's also important to note, that \emph{both structures utilize the term 'assay', but they utilize it for distinct meanings.}
Keep that in mind because we chose to stick with the native terminologies within dittoSeq in order maintain intuitiveness with other Seurat or SCE data accession methods.
In other words, rather than enforcing a new consistent paradigm, the native Seurat 'assay' meaning is respected for Seurat objects, and the native SCE 'assay' meaning is respected for SCE objects.
}

\section{Defaults}{

When not provided by the user, the defaults for \code{assay} and \code{slot} inputs are:
\itemize{
\item{Seurat-v3+: \code{assay} = \code{DefaultAssay(object)}, \code{slot} = "data"}
\item{Seurat-v2 (v2 pre-dates Seurat's own multi-modal capabilities): \code{assay} is not used, \code{slot} = "data"}
\item{SingleCellExperiment or SummarizedExperiment: \code{assay} = whichever of "logcounts", "normcounts", or "counts" are found to exist first, prioritized in that order, otherwise the first assay of object's top-level / primary modality; \code{slot} is not used.}
}

The default for \code{swap.rownames} is \code{NULL}, a.k.a. not used.
}

\section{Control of Gene/Feature targeting in Seurat objects}{

For Seurat objects, dittoSeq uses of its \code{assay} and \code{slot} inputs for gene/feature retrieval control, and ultimately makes use of Seurat's GetAssayData function for extracting data. (See: '?SeuratObject::GetAssayData')

To allow targeting of features across multiple modalities, we allow provision of multiple assay names to dittoSeq's version of the 'assay' input.
Internally, dittoSeq will then loop through all values of 'assay', making a separate calls to GetAssayData for each assay.

Otherwise, dittoSeq's \code{assay} and \code{slot} inputs work exactly the same as described in Seurat's documentation.

Phrased another way, it works via inputs:
\itemize{
\item \code{assay} - takes the name(s) of Seurat Assays to target. Examples: \code{"RNA"} or \code{c("RNA", "ADT")}
\item \code{slot} - "counts", "data", or "scale.data". Directs which 'slot' of data from the targeted assays to extract from. Example: \code{"data"}
}

As an example, if you wanted to plot raw counts data from 1) the CD4 gene of the RNA assay and 2) the CD4.1 marker of an ADT assay, you would:
\itemize{
\item 1. point the \code{var} or \code{vars} input of the plotter to \code{c("CD4", "CD4.1")}
\item 2. target both modalities via \code{assay = c("RNA", "ADT")} (Note that "RNA" and "ADT" are the default assay names typically used, but you do need to match with what is in your own Seurat object if your assays are named differently.)
\item 3. target the raw counts data via \code{slot = "counts"}
}
}

\section{Control of Gene/Feature targeting in SingleCellExperiment objects}{

For SCE objects, dittoSeq makes use of its \code{assay} input for both modality and data form (the meaning of 'assay' for SCEs) control, and ultimately makes use of the \code{\link[SummarizedExperiment]{assay}} and \code{\link[SingleCellExperiment]{altExp}} functions for extracting data.

Additionally, we allow use of the \code{swap.rownames} input to allow targeting & display of alternative gene/feature names. The implementation here is that rownames of the extracted assay data are swapped out for the given \code{\link[SummarizedExperiment]{rowData}} column of the object (or altExp).
When used, note that you will need to use these swapped names for targeting genes / features with \code{gene}, \code{var}, or \code{vars} inputs.

\strong{In SCE objects} themselves, the primary modality's expression data are stored in 'assay's of the SCE object.
You might have one assay containing raw data, and another containing log-normalized data.
Additional details of genes/features of this modality, possibly including alternative gene names, can be stored in the object's 'rowData' slot.
When additional modalities are collected, the way to store them is via a nested SCE object called an "alternative experiment".
Any number of these can be stored in the 'altExps' slot of the SCE object.
Each alternative experiment can contain any number of assays.
Again each will often have one representing raw data and another representing a normalized form of that data.
And, these alternative experiments might also make use of their rowData to store additional characteristics or names of each gene/feature.

\emph{The system feels a bit more complicated here, because the SCE system is itself a bit more complicated. But the hope is that this system becomes simple to work with once learned!}

To allow targeting of features across multiple modalities, dittoSeq's \code{assay} input can be given:
\itemize{
\item Simplest form: a single string or string vector where values are either the names of an assay of the primary modality OR the name of an alternative experiment to target, with 'main' as an indicator for the primary modality and 'altexp' as a shortcut for indicating "the first altExp".
In this form, when 'main', 'altexp', or the actual name of an alternative experiment are used, the first assay of that targeted modality will be used.
\item Explicit form: a named string or named vector of string values where names indicate the modality/experiment to target and values indicate what assays of those experiments to target. Here again, you can use 'main' or 'altexp' as names to mean the primary modality and "the first altExp", respectively.
\item These methods can also be combined. A few examples:
\itemize{
\item Using the simplified method only: \code{assay = c('main', 'altexp', 'hto')} will target the first assays each of the main object, of the first alternative experiment of the object, and also of an alternative experiment named 'hto'.
\item Using the explicit form only: \code{assay = c('main'='logexp', 'adt'='clr', 'altexp'='raw')} will target 1) the logexp-named assay of the main object, 2) the clr-named assay of an alternative experiment named 'adt', and 3) the raw-named assay of the first alternative experiment of the object.
\item Using a combination of the two: \code{assay = c('logexp', 'adt'='clr')} will target 1) the logexp-named assay of the primary modilty, unless there is an alternative experiment named 'logexp' which will lead to grabbing the first assay of that modality, and 2) the clr-named assay of an alternative experiment named 'adt'.
}
}

The \code{swap.rownames} input allows swapping to alternative names for genes/features via provision of a column name of rowData(object).
The values of that rowData column are then used to identify and label features of the moadilty's assays instead of the original rownames of the assays.
To allow swap.rownames to also work with the multi-modality access system in the most simplified way, the swap.rownames input also has both a simple and an explicit provision system:
\itemize{
\item Simple form: a single string or string vector where all modalities will be checked for the presence of a these values in colnames of their rowData. If multiple matches are found, priority goes to the earlier value.
Values of matched rowData columns are then set (internally to dittoSeq only) as the rownames of the modality.
\item Explicit form: similar to the explicit assay use, a named string or named vector of string values where names indicate the modality/experiment to target and values indicate columns to look for among the given modality's rowData.
'main' should be used as the name / indicator for the primary modality, and 'altexp' can be used as a shortcut for indicating "the first altExp".
\item Examples:
\itemize{
\item Simplified1: Using \code{assay = c('main', 'altexp'), swap.rownames = "SYMBOL"} with an object where the primary modality rowData has a SYMBOL column and the first alternative experiment's rowData is empty, will lead to swapping to the SYMBOL values for main modality features and use of original rownames for the alternative experiment's features.
(You will also see a warning indicating that the rownames were not swapped for the alternative experiment.)
\item Simplified2: Using \code{assay = c('main', 'altexp'), swap.rownames = "SYMBOL"} with an object where both modalities' rowData have a SYMBOL column, will lead to swapping to the SYMBOL values both modalities (and no warning).
\item Explicit: Using \code{assay = c('main', 'altexp'), swap.rownames = c(main="SYMBOL")} with an object where both modalities' rowData have a SYMBOL column, will lead to swapping to the SYMBOL values for main modality only.
}
}

As a full example, if you wanted to plot from 1) the raw 'counts' assay for a CD4 gene of the primary modality and 2) the normalized 'logexp' assay for a CD4.1 marker of an alternative experiment assay named 'ADT', but where 3) the rownames of these modalities are Ensembl ids while gene symbol names are held in a rowData column of both modalities that is named "symbols", the simplest provision method is:
\itemize{
\item 1. point the \code{var} or \code{vars} input of the plotter to \code{c("CD4", "CD4.1")}
\item 2. target the counts assay of the primary modality and logexp assay of the ADT alternative experiment via \code{assay = c('counts', ADT = 'logexp')}
\item 3. swap to the symbol names of features from both modlities by also giving \code{swap.rownames = "symbols"}
}
}

\section{Some edge-cases for SingleCellExperiment objects}{

Some choices within dittoSeq's multi-modality implementation for SCEs were made with a prioritization of ease over creation of edge-cases.
Thus, a few known edge-cases exist:
\itemize{
\item Avoid naming alternative experiments as 'main' or 'altexp'.
Because these tokens have been chosen as indicators of "top-level data", and "the first alternative experiment", respectively, any alternative experiment given one of these names will not be able to be reliably accessed via dittoSeq's system.
\item Explicit-path is required for top-level assays named 'altexp'
Use \code{assay = c(main='altexp')} for a top-level assay named 'altexp'.
Because we think the "simple path" is usefully simpler for cases where it works, \code{assay = 'altexp'} and \code{assay = c('main'='altexp')} are not equivalent.
The explicit method MUST be used to extract from an assay named 'altexp' because \code{assay = 'altexp'} will instead target the first assay of the first altExp of the SCE.
}
}

\author{
Dan Bunis
}
