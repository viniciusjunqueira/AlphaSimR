% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pullGeno.R
\name{pullIbdHaplo}
\alias{pullIbdHaplo}
\title{Pull Identity By Descent (IBD) haplotypes}
\usage{
pullIbdHaplo(
  pop = NULL,
  chr = NULL,
  snpChip = NULL,
  pedigree = NULL,
  simParam = NULL
)
}
\arguments{
\item{pop}{an object of \code{\link{Pop-class}} or 
\code{\link{RawPop-class}}. If NULL, haplotypes for the whole
ancestral pedigree are retreived. Otherwise, haplotypes just for
the \code{pop} individuals are retreived. In both cases the base
population is controlled by \code{pedigree}.}

\item{chr}{a vector of chromosomes to retrieve. If NULL, 
all chromosomes are retrieved.}

\item{snpChip}{an integer. Indicates which SNP array loci
are retrieved. If NULL, all sites are retrieved.}

\item{pedigree}{a matrix with ancestral pedigree to set a base
population. It should be of the same form as \code{simParam$pedigree} 
(see \code{setTrackPed} in \code{\link{SimParam}}), i.e., two columns 
(mother and father) and the same number of rows as 
\code{simParam$pedigree}.Base population can be set by setting 
parents as 0. If NULL, pedigree from \code{\link{SimParam}} is taken.}

\item{simParam}{an object of \code{\link{SimParam}}}
}
\value{
Returns a matrix of haplotypes with Identity By Descent
(IBD) coding of locus alleles. The matrix colnames reflect whether
all segregagting loci (sites) are retreived or only SNP array loci.
}
\description{
Retrieves Identity By Descent (IBD) haplotype data
}
\examples{
#Create founder haplotypes
founderPop = quickHaplo(nInd=10, nChr=1, segSites=15)

#Set simulation parameters
SP = SimParam$new(founderPop)
SP$addTraitA(10)
SP$addSnpChip(5)
SP$setTrackRec(TRUE)

#Create population
pop = newPop(founderPop, simParam=SP)
pullIbdHaplo(pop, simParam=SP)

}
