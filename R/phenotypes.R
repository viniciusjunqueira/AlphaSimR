#Adds random error to a matrix of genetic values
addError = function(gv,varE,reps=1){
  nTraits = ncol(gv)
  nInd = nrow(gv)
  if(is.matrix(varE)){
    stopifnot(isSymmetric(varE),
              ncol(varE)==nTraits)
    error = matrix(rnorm(nInd*nTraits),
                   ncol=nTraits)%*%rotMat(varE)
  }else{
    stopifnot(length(varE)==nTraits)
    error = lapply(varE,function(x){
      if(is.na(x)){
        return(rep(NA_real_,nInd))
      }else{
        return(rnorm(nInd,sd=sqrt(x)))
      }
    })
    error = do.call("cbind",error)
  }
  error = error/sqrt(rep(reps,nrow(error)))
  pheno = gv + error
  return(pheno)
}

#See setPheno documentation
calcPheno = function(pop,varE,reps,p,simParam){
  if(is.null(simParam)){
    simParam = get("SP",envir=.GlobalEnv)
  }
  if(simParam$nTraits == 0L){
    return(matrix(NA_real_,
                  nrow=pop@nInd,
                  ncol=0L))
  }
  if(is.null(p)){
    p = rep(runif(1), simParam$nTraits)
  }else if(length(p)==1){
    p = rep(p,simParam$nTraits)
  }
  stopifnot(length(p)==simParam$nTraits)
  gv = pop@gv
  if(is.null(varE)){
    varE = simParam$varE
  }
  for(i in 1:simParam$nTraits){
    if(.hasSlot(simParam$traits[[i]], "envVar")){
      stdDev = sqrt(simParam$traits[[i]]@envVar)
      gv[,i] = gv[,i]+pop@gxe[[i]]*qnorm(p[i],sd=stdDev)
    }
  }
  pheno = addError(gv=gv,varE=varE,reps=reps)
  return(pheno)
}

#' @title Set phenotypes
#' 
#' @description 
#' Sets phenotypes for all traits by adding random error 
#' from a multivariate normal distribution.
#' 
#' @param pop an object of \code{\link{Pop-class}} or 
#' \code{\link{HybridPop-class}}
#' @param varE error variances for phenotype. A vector of length 
#' nTraits for independent error or a square matrix of dimensions 
#' nTraits for correlated errors. If NULL, value in simParam is used.
#' @param reps number of replications for phenotype. See details.
#' @param fixEff fixed effect to assign to the population. Used 
#' by genomic selection models only.
#' @param p the p-value for the environmental covariate 
#' used by GxE traits. If NULL, a value is
#' sampled at random.
#' @param onlyPheno should only the phenotype be returned, see return
#' @param simParam an object of \code{\link{SimParam}}
#' 
#' @details
#' The reps parameter is for convient representation of replicated data. 
#' It is intended to represent replicated yield trials in plant 
#' breeding programs. In this case, varE is set to the plot error and 
#' reps is set to the number of plots per entry. The resulting phenotype 
#' represents entry means.
#' 
#' @return Returns an object of \code{\link{Pop-class}} or 
#' \code{\link{HybridPop-class}} if onlyPheno=FALSE, if 
#' onlyPheno=TRUE a matrix is returned
#' 
#' @examples 
#' #Create founder haplotypes
#' founderPop = quickHaplo(nInd=10, nChr=1, segSites=10)
#' 
#' #Set simulation parameters
#' SP = SimParam$new(founderPop)
#' SP$addTraitA(10)
#' 
#' #Create population
#' pop = newPop(founderPop, simParam=SP)
#' 
#' #Add phenotype with error variance of 1
#' pop = setPheno(pop, varE=1)
#' 
#' @export
setPheno = function(pop,varE=NULL,reps=1,fixEff=1L,p=NULL,
                    onlyPheno=FALSE,simParam=NULL){
  if(is.null(simParam)){
    simParam = get("SP",envir=.GlobalEnv)
  }
  pheno = calcPheno(pop=pop,varE=varE,reps=reps,p=p,
                        simParam=simParam)
  if(onlyPheno){
    return(pheno)
  }
  pop@pheno = pheno
  if(is(pop,"Pop")){
    pop@fixEff = rep(as.integer(fixEff),pop@nInd)
    pop@reps = rep(as.numeric(reps),pop@nInd)
  }
  return(pop)
}
