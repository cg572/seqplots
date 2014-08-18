#' Process genomic signal
#'
#' This function extracts and processes genomic signal from tracks and/or 
#' motif data, calculates statistics and presents the data in nested list format.
#' \code{\link{transform}} but for reordering a data frame by its columns.
#' This saves a lot of typing!
#'
#' @param tracks list or vector of track paths (BigWig) and/or motif 
#' setup structers (as \code{\link{list}})
#' @param features vector of feature file paths (BED or GFF)
#' @param refgenome the UCSC cole of refference genome, e.g. 'hg19' hor 
#' Homo sapiens
#' @param bin binning window size in base pairs, default 1L
#' @param rm0 remove 0 from mean/median calculation, default FALSE
#' @param x1 upsterem distance in base pairs, default 500L
#' @param x2 downsteram distance in base pairs, default 2000L
#' @param xm anchored distance in base pairs, default 1000L
#' @param type the type of the calculation, default, 'Point Features'
#' @param add_heatmap return the heatmap data,  default FALSE
#' @param cat3 function, that sends 1st level info to web interface, handeld by 
#' "message" in console mode
#' @param cat4 function, that sends 2nd level info to web interface, handeld by 
#' "message" in console mode
#' @param con connection to SQlite database storing genome information for files
#' @return nested list: OUT[[FEATURE]][[TRACK/MOTIF]][[VALUE]]
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' getPlotSetArray(c('track1.bw', 'track2.bw'), c('peaks.bed', 'TSS.gff'))
#' }

# Function to process genomic signal from tracks and/or motif data, 
# calculate statistics and present the data in nested list format.
###############################################################################

getPlotSetArray <- function(tracks, features, refgenome, bin=10L, rm0=FALSE, 
    ignore_strand=FALSE, x1=2000L, x2=2000L, xm=1000L, type='pf', 
    add_heatmap=TRUE, cat3=message, cat4=message, con=NULL) {
    
    if( class(tracks) == "MotifSetup" ) tracks <- tracks$data
    
    n <- 1; k <- 1;
    TSS <- list(length(features))
    GENOMES <- BSgenome:::installed.genomes(splitNameParts=TRUE)$provider_version
    if( length(GENOMES) ) 
        names(GENOMES) <- gsub('^BSgenome.', '', BSgenome:::installed.genomes())
    
    extarct_matrix <- function(track, gr, size, ignore_strand) {
        sum <- .Call(rtracklayer:::BWGFile_summary, path.expand(path(track)),
                     as.character(seqnames(gr)),
                     ranges(gr), recycleIntegerArg(size, "size", length(gr)), 'mean',
                     as.numeric(NA_real_))
        M <- do.call( rbind, sum )
        if (!ignore_strand) M[as.character(strand(gr))=='-', ] <- M[as.character(strand(gr))=='-', ncol(M):1]
        return(M)
    }
    
    for (j in features)	{
        
        file_con <- file( normalizePath(j) ); sel <- rtracklayer::import(file_con , asRangedData=FALSE); close(file_con)
        genome_ind <- refgenome
        pkg <- paste0('BSgenome.', names(GENOMES[GENOMES %in% genome_ind]))
        require(pkg, character.only = TRUE); GENOME <- get(pkg)
        remap_chr <- gsub(' ', '_',organism(GENOME)) %in% names(genomeStyles())
        
        proc <- list()
        for(i in 1:length(tracks) ) {
            
            cat3(paste('Processing:', basename(j), '@', tracks[[i]][[1]], '[', k, '/',length(features)*length(tracks), ']'))
            
            if (ignore_strand)                strand(sel) <- '*'
            if( type == 'mf' ) sel <- resize(sel, 1, fix='center')
            
            if( class(tracks[[i]]) == 'character' ) {
                track <- BigWigFile( normalizePath(tracks[[i]]) )
                if(remap_chr) { seqlevelsStyle(sel) <- seqlevelsStyle(track) }
                
            } else if ( class(tracks[[i]]) == 'list' ) {  
                pattern <- tracks[[i]]$pattern
                seq_win <- tracks[[i]]$window
                pnam    <- tracks[[i]]$name
                revcomp <- tracks[[i]]$revcomp
                if(remap_chr) { seqlevelsStyle(sel) <- seqlevelsStyle(GENOME) }
                
            }
            
            
            
            if ( (type == 'pf') | (type == 'mf') ) {
                
                gr <- GenomicRanges::promoters(sel, x1, x2)
                all_ind  <- seq(-x1, x2, by=as.numeric(bin) )
                
                if( class(tracks[[i]]) == 'character' ) {
                    M <- extarct_matrix(track, gr, length(all_ind), ignore_strand)
                    
                } else if ( class(tracks[[i]]) == 'list' ) {
                    
                    cat4("Processing genome...")
                    seqlengths(gr) <- seqlengths(GENOME)[seqlevels(gr)]
                    gr <- trim(gr)
                    
                    cat4("Searching for motif...")
                    M <- getSF(GENOME, gr, pattern, seq_win, !add_heatmap, revcomp=revcomp)
                    if (!ignore_strand) M[as.character(strand(gr))=='-', ] <- M[as.character(strand(gr))=='-', ncol(M):1]
                    
                    cat4("Binning the motif...")
                    M <-  t(apply(M, 1, function(x) approx(x, n=ceiling(ncol(M)/bin))$y ))        
                    
                }
                
            } else if (type == 'af') {
                if( class(tracks[[i]]) == 'character' ) {
                    #left
                    left_ind <- seq(-x1, -1, by=bin)
                    M.left <- extarct_matrix(track, flank(sel, x1, start=TRUE), length(left_ind), ignore_strand)
                    
                    #middle
                    mid_ind <- seq(0, xm, by=bin)			
                    M.middle <- extarct_matrix(track, sel, length(mid_ind), ignore_strand)
                    
                    #right
                    right_ind <- seq(xm+1, xm+x2, by=bin)	
                    M.right <- extarct_matrix(track, flank(sel, x2, start=FALSE), length(right_ind), ignore_strand)
                    
                    M <- cbind(M.left, M.middle, M.right)
                    all_ind <- c(left_ind, mid_ind, right_ind)
                } else if ( class(tracks[[i]]) == 'list' ) {
                    
                    #MOTIF  
                    #LEFT
                    cat4(paste0("MOTIF: Processing upsterem ", pattern, " motif..."))
                    left_ind <- seq(-x1, -1, by=bin)
                    
                    gr <- flank(sel, x1, start=TRUE); seqlengths(gr) <- seqlengths(GENOME)[seqlevels(gr)];
                    M <- getSF(GENOME, trim(gr), pattern, seq_win, !add_heatmap, revcomp=revcomp)
                    if (!ignore_strand) M[as.character(strand(gr))=='-', ] <- M[as.character(strand(gr))=='-', ncol(M):1]
                    M.left <-  t(apply(M, 1, function(x) approx(x, n=length(left_ind))$y ))
                    
                    #middle
                    cat4(paste0("MOTIF: Processing middle ", pattern, " motif..."))
                    mid_ind <- seq(0, xm, by=bin)
                    
                    gr <- sel; seqlengths(gr) <- seqlengths(GENOME)[seqlevels(gr)];		
                    M <- getSF(GENOME, trim(gr), pattern, seq_win, !add_heatmap, revcomp=revcomp)
                    if (!ignore_strand) M[as.character(strand(gr))=='-', ] <- M[as.character(strand(gr))=='-', ncol(M):1]
                    M.middle <-  t(apply(M, 1, function(x) approx(x, n=length(mid_ind))$y ))
                    
                    #right
                    cat4(paste0("MOTIF: Processing downsteream ", pattern, " motif..."))
                    right_ind <- seq(xm+1, xm+x2, by=bin)	
                    
                    gr <- flank(sel, x1, start=FALSE); seqlengths(gr) <- seqlengths(GENOME)[seqlevels(gr)];
                    M <- getSF(GENOME, trim(gr), pattern, seq_win, !add_heatmap, revcomp=revcomp)
                    if (!ignore_strand) M[as.character(strand(gr))=='-', ] <- M[as.character(strand(gr))=='-', ncol(M):1]
                    M.right <-  t(apply(M, 1, function(x) approx(x, n=length(right_ind))$y ))
                    
                    #FIN
                    M <- cbind(M.left, M.middle, M.right)
                    all_ind <- c(left_ind, mid_ind, right_ind)      
                    
                }
            }
            
            #cat4("Calculeating means/stderr/95%CIs...")
            if (rm0) M[M==0] <- NA
            means 	<- colMeans(M, na.rm=TRUE) 
            stderror<- apply(M, 2, function (n) {sd(n, na.rm=T) / sqrt( sum(!is.na(n)) )})
            conint  <- apply(M, 2, function (n) {qt(0.975, sum(!is.na(n)) ) * sd(n, na.rm=T) / sqrt( sum(!is.na(n)) )})
            
            #cat4("Exporting results...")
            proc[[i]] <- list(means=means, stderror=stderror, conint=conint, all_ind=all_ind, e=if (type == 'af') xm else NULL,
                              desc=paste(sub("\\.(bw|BW)$", "", basename(tracks[[i]][[1]])), sub("\\.(gff|GFF)$", "", basename(j)), sep="\n@"),
                              heatmap=if (add_heatmap) M else NULL)
            k <- k+1
        }		
        names(proc) <- basename( sapply(tracks, '[[', 1) )
        TSS[[n]] <- proc
        n <- n+1
    }
    names(TSS) <- features
    return( PlotSetArray(data=TSS) )
}