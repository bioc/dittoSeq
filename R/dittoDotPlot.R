#' Compact plotting of per group summaries for expression of multiple features
#' 
#' @param vars String vector (example: \code{c("gene1","gene2","gene3")}) which selects which variables, typically genes, to show.
#' @param group.by String representing the name of a metadata to use for separating the cells/samples into discrete groups.
#' @param summary.fxn.color,summary.fxn.size A function which sets how color or size will be used to summarize variables' data for each group.
#' Any function can be used as long as it takes in a numeric vector and returns a single numeric value.
#' @param scale String which sets whether the values shown with color (default: mean non-zero expression) should be centered and scaled. 
#' @param size Number which sets the dot size associated with the highest value shown by dot size (default: percent non-zero expression).
#' @param adjustment Should expression data be used directly (default) or should it be adjusted to be
#' \itemize{
#' \item{"z-score": scaled with the scale() function to produce a relative-to-mean z-score representation}
#' \item{"relative.to.max": divided by the maximum expression value to give percent of max values between [0,1]}
#' }
#' @param min.percent,max.percent Numbers between 0 and 1 which sets the minimum and maximum percent expression to show.
#' When set to NA, the minimum/maximum of the data are used.
#' @param min.color,max.color colors to use for minimum and maximum color values.
#' Default = light grey and purple.
#' @param min,max Numbers which set the values associated with the minimum and maximum colors.
#' @param ylab String which sets the y/grouping-axis label.
#' Default is \code{group.by} so it defaults to the name of the grouping information.
#' Set to \code{NULL} to remove.
#' @param xlab String which sets the x/var-axis label.
#' Set to \code{NULL} to remove.
#' @param x.labels.rotate Logical which sets whether the var-labels should be rotated.
#' @param y.labels String vector, c("label1","label2","label3",...) which overrides the names of the samples/groups.
#' @param y.reorder Integer vector. A sequence of numbers, from 1 to the number of groupings, for rearranging the order of groupings.
#'
#' Method: Make a first plot without this input.
#' Then, treating the bottom-most grouping as index 1, and the top-most as index n,
#' values of y.reorder should be these indices, but in the order that you would like them rearranged to be.
#' 
#' Recommendation for advanced users: If you find yourself coming back to this input too many times, an alternative solution that can be easier long-term
#' is to make the target data into a factor, and to put its levels in the desired order: \code{factor(data, levels = c("level1", "level2", ...))}.
#' \code{\link{metaLevels}} can be used to quickly get the identities that need to be part of this 'levels' input.
#' @param legend.color.title,legend.size.title String or \code{NULL}, sets the title displayed above legend keys.
#' @param do.hover Logical. Default = \code{FALSE}.
#' If set to \code{TRUE} the object will be converted to an interactive plotly object in which underlying data for individual dots will be displayed when you hover your cursor over them.
#'
#' @inheritParams dittoPlotVarsAcrossGroups
#' @inheritParams dittoScatterPlot
#' 
#' @return a ggplot object where dots of different colors and sizes summarize continuous data for multiple features (columns) per multiple groups (rows)
#'
#' Alternatively when \code{data.out = TRUE}, a list containing the plot ("p") and the underlying data as a dataframe ("data").
#'
#' Alternatively when \code{do.hover = TRUE}, a plotly converted version of the plot where additional data will be displayed when the cursor is hovered over the dots.
#' 
#' @details
#' This function will output a compact summary of expression of multiple genes, or of values of multiple numeric metadata, across cell/sample groups (clusters, sample identity, conditions, etc.),
#' where dot-size and dot-color are used to reflect distinct features of the data.
#' Typically, and by default, size will reflect the percent of non-zero values, and color will reflect the mean of non-zero values for each var and group pairing.
#' 
#' Internally, the data for each element of \code{vars} is obtained.
#' When elements are genes/features, \code{assay} and \code{slot} are utilized to determine which expression data to use,
#' and \code{adjustment} determines if and how the expression data might be adjusted.
#' (Note that 'adjustment' would be applied \emph{before} cells/samples subsetting, and across all groups of cells/samples.)
#'
#' Groupings are determined using \code{group.by}, and then data for each variable is summarized based on \code{summary.fxn.color} & \code{summary.fxn.size}.
#'
#' If \code{scale = TRUE} (default setting), the color summary values are centered and scaled.
#' Doing so 1) puts values for all \code{vars} in a similar range, and 2) emphasizes relative differences between groups.
#' 
#' Finally, data is plotted as dots of differing colors and sizes.
#'
#' @section Many characteristics of the plot can be adjusted using discrete inputs:
#' \itemize{
#' \item Size of the dots can be changed with \code{size}.
#' \item Subsetting to utilize only certain cells/samples can be achieved with \code{cells.use}.
#' \item Colors can be adjusted with \code{min.color} and \code{max.color}.
#' \item Displayed value ranges can be adjusted with \code{min} and \code{max} for color, or \code{min.percent} and \code{max.percent} for size.
#' \item Titles and axes labels can be adjusted with \code{main}, \code{sub}, \code{xlab}, \code{ylab}, \code{legend.color.title}, and \code{legend.size.title} arguments.
#' \item The legend can be hidden by setting \code{legend.show = FALSE}.
#' \item The color legend tick marks and associated labels can be adjusted with \code{legend.color.breaks} and \code{legend.color.breaks.labels}, respectively.
#' \item The groupings labels and order can be changed using \code{y.labels} and \code{y.reorder}
#' \item Rotation of x-axis labels can be turned off with \code{x.labels.rotate = FALSE}.
#' }
#'
#' @seealso
#' \code{\link{dittoPlotVarsAcrossGroups}} for a method of summarizing expression of multiple features across distinct groups that can be better (and more compact) when the identities of the individual genes are unimportant.
#' 
#' \code{\link{dittoPlot}} and \code{\link{multi_dittoPlot}} for plotting of expression and metadata vars, each as separate plots, on a per cell/sample basis.
#'
#' @examples
#' example(importDittoBulk, echo = FALSE)
#' myRNA
#' 
#' # These random data aren't very exciting, but we can at least add some zeros
#' #   for making slightly more interesting dot plots.
#' counts(myRNA)[1:4,1:40] <- 0
#' logcounts(myRNA)[1:4,1:40] <- 0
#' 
#' dittoDotPlot(
#'     myRNA, c("gene1", "gene2", "gene3", "gene4"),
#'     group.by = "clustering")
#'     
#' # 'size' adjusts the dot-size associated with the highest percent expression
#' dittoDotPlot(myRNA, c("gene1", "gene2", "gene3", "gene4"), "clustering",
#'     size = 12)
#' 
#' # 'scale' input can be used to control / turn off scaling of avg exp values.
#' dittoDotPlot(myRNA, c("gene1", "gene2", "gene3", "gene4"), "clustering",
#'     scale = FALSE)
#'     
#' # x-axis label rotation can be controlled with 'x.labels.rotate'
#' dittoDotPlot(myRNA, c("gene1", "gene2", "gene3", "gene4"), "clustering",
#'     x.labels.rotate = FALSE)
#' 
#' # Title are adjustable via various discrete inputs:
#' dittoDotPlot(myRNA, c("gene1", "gene2", "gene3", "gene4"), "clustering",
#'     main = "Title",
#'     sub = "Subtitle",
#'     ylab = "y-axis label",
#'     xlab = "x-axis label",
#'     legend.color.title = "Colors title",
#'     legend.size.title = "Dot size title")
#'     
#' # For certain specialized applications, it may be helpful to adjust the
#' #   functions used for summarizing the data as well. Inputs are:
#' #   summary.fxn.color & summary.fxn.size
#' #     Requirement for each: Any function that takes in a numeric vector &
#' #     returns, as output, a single numeric value.
#' dittoDotPlot(myRNA, c("gene1", "gene2", "gene3", "gene4"), "clustering",
#'     summary.fxn.color = mean,
#'     legend.color.title = "mean\nexpression\nincluding 0s",
#'     main = "scater::plotDots() defaulting recreation",
#'     x.labels.rotate = FALSE,
#'     scale = FALSE)
#' 
#' @author Daniel Bunis
#' @export
#'
dittoDotPlot <- function(
    object,
    vars,
    group.by,
    scale = TRUE,
    split.by = NULL,
    cells.use = NULL,
    size = 6,
    min.percent = 0.01,
    max.percent = NA,
    min.color = "grey90",
    max.color = "#C51B7D",
    min = "make",
    max = NA,
    summary.fxn.color = function(x) {mean(x[x!=0])},
    summary.fxn.size = function(x) {mean(x!=0)},
    assay = .default_assay(object),
    slot = .default_slot(object),
    adjustment = NULL,
    swap.rownames = NULL,
    do.hover = FALSE,
    main = NULL,
    sub = NULL,
    ylab = group.by,
    y.labels = NULL,
    y.reorder = NULL,
    xlab = NULL,
    x.labels.rotate = TRUE,
    groupings.drop.unused = TRUE,
    split.nrow = NULL,
    split.ncol = NULL,
    split.adjust = list(),
    theme = theme_classic(),
    legend.show = TRUE,
    legend.color.breaks = waiver(),
    legend.color.breaks.labels = waiver(),
    legend.color.title = "make",
    legend.size.title = "percent\nexpression",
    data.out = FALSE) {

    cells.use <- .which_cells(cells.use, object)
    
    # Fill defaults
    legend.color.title <- .leave_default_or_null(
        legend.color.title,
        default = ifelse(scale,"relative\nexpression","average\nexpression"))
    min <- .leave_default_or_null(
        min,
        default = if (scale) {NA} else {0})

    # Create data table summarizing vars data for each group
    data <- .data_gather_summarize_vars_by_groups(
        object, vars, group.by, split.by,
        list(summary.fxn.color, summary.fxn.size),
        c("color", "size"),
        cells.use, assay, slot, adjustment, swap.rownames, do.hover,
        groupings.drop.unused)
    data$var <- factor(data$var, levels = vars)
    data$grouping <-
        .rename_and_or_reorder(data$grouping, y.reorder, y.labels)
    
    if (scale) {
        
        data$pre.scale <- data$color
        
        for (i in vars) {
            
            data$color[data$var == i] <-
                # center, if multiple groups express this var, also scale
                if (sum(!is.na(data$color[data$var == i]))>1) {
                    scale(data$color[data$var == i])
                } else {
                    scale(data$color[data$var == i], scale = FALSE)
                }
        }
    }

    # Generate Plot
    p <- .ditto_dot_plot(
        data, do.hover, main, sub, ylab, xlab, x.labels.rotate, scale,
        min.color, max.color, min, max,
        size, min.percent, max.percent, theme,
        legend.color.title, legend.color.breaks, legend.color.breaks.labels,
        legend.size.title, legend.show)
    
    ### Add extra features
    if (!is.null(split.by)) {
        p <- .add_splitting(
            p, split.by, split.nrow, split.ncol, split.adjust)
    }

    if (do.hover) {
        .error_if_no_plotly()
        p <- plotly::ggplotly(p, tooltip = "text")
    }
    
    # DONE. Return
    if (data.out) {
        list(
            p = p,
            data = data)
    } else {
        p
    }
}

.ditto_dot_plot <- function(
    data,
    do.hover,
    main,
    sub,
    ylab,
    xlab,
    x.labels.rotate,
    scale,
    min.color,
    max.color,
    min,
    max,
    size,
    min.percent,
    max.percent,
    theme,
    legend.color.title,
    legend.color.breaks,
    legend.color.breaks.labels,
    legend.size.title,
    legend.show) {
    
    p <- ggplot(data,
            aes_string(x = "var", y = "grouping", color = "color", size = "size")) +
        theme +
        ggtitle(main, sub) + xlab(xlab) + ylab(ylab) +
        scale_size(
            name = legend.size.title,
            limits = c(min.percent, max.percent),
            range = c(0, size)) +
        scale_color_gradient(
            name = legend.color.title,
            low= min.color, high = max.color,
            limits = c(min,max),
            breaks = legend.color.breaks,
            labels = legend.color.breaks.labels)
    
    if (do.hover) {
        p <- p + suppressWarnings(
            geom_point(aes_string(text = "hover.string"), na.rm = TRUE))
    } else {
        p <- p + geom_point(na.rm = TRUE)
    }
    
    if (x.labels.rotate) {
        p <- p + theme(axis.text.x= element_text(angle=45, hjust = 1, vjust = 1))
    }
    
    if (!legend.show) {
        p <- .remove_legend(p)
    }
    
    p
}

.data_gather_summarize_vars_by_groups <- function(
    object,
    vars,
    group.by,
    split.by,
    summary.fxns, # list of summaries to make
    names,        # vector of what to call those summaries
    cells.use,
    assay,
    slot,
    adjustment,
    swap.rownames,
    do.hover,
    groupings.drop.unused,
    numeric.only = TRUE) {
    
    object <- .swap_rownames(object, swap.rownames)
    groupings <- meta(group.by, object)[cells.use]

    ### Grab (and adjust) vars data per cell/sample
    # rows = cells/samples
    # cols = vars
    vars_data <- .multi_var_gather_raw(
        object, vars, assay, slot, adjustment, cells.use, numeric.only, split.by)

    # Extract or negate-away split.by data
    facet <- if (is.null(split.by)) {
        "filler"
    } else {
        do.call(paste, vars_data[,split.by, drop = FALSE])
    }
    
    ### Transformed summary data
    # rows = individual data points; each var for group1, group2, group3,...
    data <- do.call(
        rbind,
        lapply(
            unique(facet),
            function(this_facet) {
                
                # Subset data per facet
                vars_data <- vars_data[facet==this_facet, , drop = FALSE]
                groupings <- groupings[facet==this_facet]
                
                # Start the data frame
                new_data <- data.frame(
                    var = rep(vars, length(unique(groupings))),
                    grouping = rep(
                        unique(groupings), each = length(vars))
                )
                
                ### Summarize vars data per group
                # rows = vars
                # cols = groupings
                summary_data <- lapply(
                    summary.fxns, function(f) {
                        .summarize_set_by_fxn(
                            f, .data = vars_data, grps = groupings, vrs = vars)
                        })
                # Transform to 1 row per point
                for (i in seq_along(summary_data)) {
                    new_data <- cbind(new_data, unlist(summary_data[[i]]))
                }
                names(new_data) <- c("var", "grouping", names)
                
                # Add facet info
                if (!is.null(split.by)) {
                    for (by in split.by) {
                        new_data[[by]] <- vars_data[1,by]
                    }
                }
                
                new_data
            }
        )
    )
    
    # Respect factor level ordering of group.by
    data$grouping <- .keep_levels_if_factor(
        data$grouping,
        groupings,
        groupings.drop.unused)

    if (do.hover) {
        data$hover.string <- .make_hover_strings_from_df(data)
    }

    return(data)
}

### Summarize vars data per group
# rows = summarized vars data (1 row per element of vars)
# cols = groupings
.summarize_set_by_fxn <- function(summary.fxn, .data, grps, vrs) {
    
    data.frame(
        vapply(
            unique(grps),
            function (this_group) {
                vapply(
                    vrs,
                    function(this_var) {
                        summary.fxn(.data[grps == this_group, this_var])
                    }, FUN.VALUE = numeric(1)
                )
            }, FUN.VALUE = numeric(length(vrs))
        )
    )
}

#' @importFrom stats sd
.multi_var_gather_raw <- function(
    object,
    vars,
    assay,
    slot,
    adjustment,
    cells.use,
    numeric.only,
    split.by) {
    
    gets <- c(vars, split.by)
    
    call_meta <- isMeta(gets, object, return.values = FALSE)
    meta_gets <- gets[call_meta]
    gene_gets <- isGene(gets[!call_meta], object, assay, return.values = TRUE)
    
    if (!all(gets %in% c(meta_gets, gene_gets))) {
        stop("All 'vars' and 'split.by' must be a metadata or gene/feature of the targeted assay(s)")
    }
    
    if (length(vars) <= 1) {
        stop("'vars' must be a vector of at least two elements for this function.")
    }
    
    gets_data <- if (length(meta_gets)>0) {
        getMetas(object, names.only = FALSE)[, meta_gets, drop = FALSE]
    } else {
        data.frame(row.names = .all_cells(object))
    }
    
    if (length(gene_gets)>0) {
        gene_data <- t(as.matrix(.which_data(assay,slot,object)[gene_gets, , drop = FALSE]))
        
        if (!is.null(adjustment)) {
            if (adjustment=="z-score") {
                gene_data <- apply(gene_data, 2, function(x) {(x-mean(x))/sd(x)})
            }
            if (adjustment=="relative.to.max") {
                gene_data <- apply(gene_data, 2, function(x) {x/max(x)})
            }
        }
        
        gets_data <- cbind(as.data.frame(gene_data), gets_data)
    }
    
    if (numeric.only) {
        # Only check vars, not split.by
        for (var in vars) {
            if (!is.numeric(gets_data[,var])) {
                stop("All 'vars' must be numeric. ", var, " is not numeric.")
            }
        }
    }
    
    # Trim by cells use and ensure ordering with split.by last
    gets_data[cells.use, gets]
}
