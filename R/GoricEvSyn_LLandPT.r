
#' GORIC(A) evidence synthesis based on log likelihood and penalty values
#'
#' GORIC(A) evidence synthesis (GoricEvSyn) aggregates the evidence for theory-based hypotheses from multiple studies that may use diverse designs to investigate the same central theory. There is also an interactive web application on my website to perform GoricEvSyn: \url{https://www.uu.nl/staff/RMKuiper/Websites\%20\%2F\%20Shiny\%20apps}.
#'
#' @param TypeEv The type of evidence-synthesis approach: Equal-evidence approach (0) or Added-evidence approach (1).
#' In case of an equal-evidence approach, aggregating evidence from, say, 5 studies with n=100 observations is the same as obtaining evidence from 1 study (as if it was possible) with n=500 observations (like meta-analysis does).
#' In the added-evidence approach, the aggregated evidence from, says, 5 studies is stronger than as if the data were combined (as if that was possible).
#' @param S The number of (primary) studies. That is, the results (evidence) of S studies will be aggregated.
#' @param LL A matrix with log likelihood values of size S x 'NrHypos+1', where 'NrHypos+1' stands for the number of theory-based hypotheses plus a safeguard hypothesis (the complement or unconstrained).
#' @param PT A matrix with penalty values of size S x 'NrHypos+1', where 'NrHypos+1' stands for the number of theory-based hypotheses plus a safeguard hypothesis (the complement or unconstrained).
#' @param PrintPlot Indicator whether plot of GORIC(A) weigths should be printed (TRUE; default) or not (FALSE). The GORIC(A) weights per study are plotted and the cumulative GORIC(A) weights (where those for last study are the final ones).
#' @param Name_studies Vector of S numbers or S characters to be printed at the x-axis of the plot with GORIC(A) weights. Default: Name_studies = 1:S.
#'
#' @return The output comprises, among other things, the cumulative and final evidence for the theory-based hypotheses.
#' @export
#' @examples
#'
#' S <- 4
#' # Example based on S = 4 studies and 3 hypotheses:
#' # H0 <- "beta1 == 0"
#' # Hpos <- "beta1 > 0"
#' # Hneg <- "beta1 < 0"
#' # Note that in this set the whole space is (all theories are) covered so the unconstrained is not needed as safeguard-hypothesis
#' LL <- myLLs
#' PT <- myPTs
#'
#' # Added-evidence approach
#' TypeEv <- 1
#' GoricEvSyn_LLandPT(TypeEv, S, LL, PT)
#'
#' # Equal-evidence approach
#' TypeEv <- 0
#' GoricEvSyn_LLandPT(TypeEv, S, LL, PT)
#'
#' # Change labels on x-axis in GORIC(A) weigths plot #
#' # For example, let us say that the studies come from the years 2015, 2016, 2017, 2019.
#' # Because of unequal spacing, you may want to use numbers instead of characters:
#' Name_studies <- c(2015, 2016, 2017, 2019)
#' GoricEvSyn_LLandPT(TypeEv, S, LL, PT, Name_studies)


GoricEvSyn_LLandPT <- function(TypeEv, S, LL, PT, PrintPlot = T, Name_studies = 1:S) {

  # Checks op input
  #
  if(length(TypeEv) != 1){
    print(paste("The type of evidence-synthesis approach (TypeEv) should be a scalar; more specifically, it should be 0 or 1."))
    stop()
  }
  if(TypeEv != 1 & TypeEv != 0){
    print(paste("The type of evidence-synthesis approach (TypeEv) should be 0 or 1."))
    stop()
  }
  #
  if(length(S) != 1){
    print(paste("The number of studies (S) should be a scalar; more specifically, an integer value."))
    stop()
  }
  if(S %% 1 != 0){
    print(paste("The number of studies (S) should be an integer value."))
    stop()
  }
  #
  if(length(dim(LL)) != 2){
    print(paste0("The LL matrix should have 2 dimensions; namely, S rows and 'NrHypos+1' columns. It should not be an array with more than 2 dimensions."))
    stop()
  }
  if(dim(LL)[1] != S){
    print(paste0("The number of rows in the LL matrix (", dim(LL)[1], ") does not equal S = ", S, "."))
    stop()
  }
  if(length(dim(PT)) != 2){
    print(paste0("The PT matrix should have 2 dimensions; namely, S rows and 'NrHypos+1' columns. It should not be an array with more than 2 dimensions."))
    stop()
  }
  if(dim(PT)[1] != S){
    print(paste0("The number of rows in the PT matrix (", dim(PT)[1], ") does not equal S = ", S, "."))
    stop()
  }
  NrHypos <- dim(LL)[2] - 1
  NrHypos_PT <- dim(PT)[2] - 1
  if(NrHypos != NrHypos_PT){
    print(paste0("The number of columns in the LL matrix (", dim(LL)[2], ") does not equal the number of columns in the PT matrix (", dim(PT)[2], "). Both should equal 'NrHypos+1'."))
    stop()
  }
  #
  if(PrintPlot != T & PrintPlot != F){
    print(paste("The argument 'PrintPlot' should be TRUE or FALSE, not ", PrintPlot, "."))
    stop()
  }
  if(length(Name_studies) != S){
    print(paste("The argument 'Name_studies' should consist of S = ", S, " elements (either all numbers or all characters)."))
    stop()
    if(!all(is.numeric(Name_studies)) & !all(is.character(Name_studies))){
      print(paste("The argument 'Name_studies' should consist of either S = ", S, " numbers or S = ", S, " characters."))
      stop()
    }
  }


  #CumulativeGorica <- matrix(NA, nrow = S, ncol = (NrHypos + 1))
  #CumulativeGoricaWeights <- matrix(NA, nrow = S, ncol = (NrHypos + 1))
  #colnames(CumulativeGorica) <- colnames(CumulativeGoricaWeights) <- colnames(LL) <- colnames(PT) <- paste0("H", 1:(NrHypos + 1))
  #rownames(CumulativeGorica) <- rownames(CumulativeGoricaWeights) <- rownames(LL) <- rownames(PT) <- paste0("Study", 1:S)
  CumulativeGorica <- matrix(NA, nrow = (S+1), ncol = (NrHypos + 1))
  CumulativeGoricaWeights <- matrix(NA, nrow = (S+1), ncol = (NrHypos + 1))
  colnames(CumulativeGorica) <- colnames(CumulativeGoricaWeights) <- colnames(LL) <- colnames(PT) <- paste0("H", 1:(NrHypos + 1))
  rownames(CumulativeGorica) <- rownames(CumulativeGoricaWeights) <- rownames(LL) <- rownames(PT) <- c(paste0("Study", 1:S), "Final")


  sumLL <- 0
  sumPT <- 0
  if(TypeEv == 1){ # added-ev approach
    for(s in 1:S){
      sumLL <- sumLL + LL[s,]
      sumPT <- sumPT + PT[s,]
      CumulativeGorica[s,] <- -2 * sumLL + 2 * sumPT
      #CumulativeGoricaWeights[s,] <- exp(-0.5*CumulativeGorica[s,]) / sum(exp(-0.5*CumulativeGorica[s,]))
      minGoric <- min(CumulativeGorica[s,])
      CumulativeGoricaWeights[s,] <- exp(-0.5*(CumulativeGorica[s,]-minGoric)) / sum(exp(-0.5*(CumulativeGorica[s,]-minGoric)))
    }
    EvSyn_approach <- "Added-evidence approach"
  }else{ # equal-ev approach
    for(s in 1:S){
      sumLL <- sumLL + LL[s,]
      sumPT <- sumPT + PT[s,]
      CumulativeGorica[s,] <- -2 * sumLL + 2 * sumPT/s
      #CumulativeGoricaWeights[s,] <- exp(-0.5*CumulativeGorica[s,]) / sum(exp(-0.5*CumulativeGorica[s,]))
      minGoric <- min(CumulativeGorica[s,])
      CumulativeGoricaWeights[s,] <- exp(-0.5*(CumulativeGorica[s,]-minGoric)) / sum(exp(-0.5*(CumulativeGorica[s,]-minGoric)))
    }
    EvSyn_approach <- "Equal-evidence approach"
  }

  CumulativeGorica[(S+1),] <- CumulativeGorica[S,]
  CumulativeGoricaWeights[(S+1),] <- CumulativeGoricaWeights[S,]
  #
  #Final.GORICA <- matrix(CumulativeGorica[S,], nrow = 1)
  Final.GORICA.weights <- CumulativeGoricaWeights[S,]
  Final.rel.GORICA.weights <- Final.GORICA.weights %*% t(1/Final.GORICA.weights)
  #Final.GORICA.weights <- matrix(Final.GORICA.weights, nrow = 1)
  #rownames(Final.GORICA) <- "Final"
  #rownames(Final.GORICA.weights) <- "Final"
  rownames(Final.rel.GORICA.weights) <- c(paste0("H", 1:(NrHypos + 1)))
  colnames(Final.rel.GORICA.weights) <- c(paste0("vs H", 1:(NrHypos + 1)))


  # Plot
  if(PrintPlot == T){
    Legend <- c("per study", "cumulative", c(paste0("H", 1:(NrHypos + 1))))
    Pch <- c(1,NA,1,1)
    Col <- c(1, 1, 1:NrHypos_incl)
    Lty <- c(NA,1,1,1)
    dev.off() # to reset the graphics pars to defaults
    par(mar=c(par('mar')[1:3], 0)) # optional, removes extraneous right inner margin space
    plot.new()
    l <- legend(0, 0, bty='n', Legend,
                plot=FALSE, pch=Pch, lty=Lty, col=Col)
    # calculate right margin width in ndc
    w <- grconvertX(l$rect$w, to='ndc') - grconvertX(0, to='ndc')
    par(omd=c(0, 1-w, 0, 1))
    #
    teller_col <- 1
    #plot(1:S, weight_m[,1], pch = 1, col = teller_col, xlab = "Studies", ylab = "GORIC(A) weights", ylim = c(0,1), main = "GORIC(A) weights \n per study and cumulative")
    if(all(is.numeric(Name_studies))){
      X <- Name_studies
      plot(X, weight_m[,1], pch = 1, col = teller_col, xlab = "Studies", ylab = "GORIC(A) weights", ylim = c(0,1), main = "GORIC(A) weights \n per study and cumulative", xaxt="n")
      axis(1, at=X, labels=Name_studies)
    }else{
      X <- 1:S
      plot(X, weight_m[,1], pch = 1, col = teller_col, xlab = "Studies", ylab = "GORIC(A) weights", ylim = c(0,1), main = "GORIC(A) weights \n per study and cumulative", xaxt="n")
      axis(1, at=X, labels=Name_studies)
    }
    for(i in 2:NrHypos_incl){
      teller_col <- teller_col + 1
      points(X, weight_m[,i], pch = 1, col = teller_col)
    }
    teller_col <- 0
    for(i in 1:NrHypos_incl){
      teller_col <- teller_col + 1
      lines(X, CumulativeGoricaWeights[1:S,i], lty = 1, lwd = 1, col = teller_col)
    }
    #
    legend(par('usr')[2], par('usr')[4], bty='n', xpd=NA,
           Legend, pch=Pch, lty=Lty, col=Col)
  }


  # Ouput
  #final <- list(LL_m = LL, PT_m = PT,
  #              EvSyn_approach = EvSyn_approach, Cumulative.GORICA = CumulativeGorica, Cumulative.GORICA.weights = CumulativeGoricaWeights,
  #              Final.GORICA = Final.GORICA, Final.GORICA.weights = Final.GORICA.weights, Final.rel.GORICA.weights = Final.rel.GORICA.weights)
  final <- list(LL_m = LL, PT_m = PT,
                  EvSyn_approach = EvSyn_approach, Cumulative.GORICA = CumulativeGorica, Cumulative.GORICA.weights = CumulativeGoricaWeights,
                  Final.rel.GORICA.weights = Final.rel.GORICA.weights)
  return(final)

}
