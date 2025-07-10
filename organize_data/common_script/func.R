###########################################################
# Filename: func.R
# Purpose : Handy functions 
# Author  : Austin Liu
# Date    : 2025/06/14
###########################################################

library(MASS)         # for kde2d()
library(fields)       # For image.plot (better legends)
library(RColorBrewer) # For color palette
library(grDevices)    # For colorRampPalette

jet.colors <- colorRampPalette(
    c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", 
      "#FF7F00", "red", "#7F0000"))

kernel_smooth_grid <- function(xo1, xo2, y, xn1, xn2, h1, h2) {
  z_mat <- matrix(NA, nrow=length(xn1), ncol=length(xn2))

  for (i in seq_along(xn1)) {
    for (j in seq_along(xn2)) {
      dx1 <- dnorm((xn1[i] - xo1) / h1)
      dx2 <- dnorm((xn2[j] - xo2) / h2)
      w <- dx1 * dx2
      w <- w / sum(w)

      z_mat[i, j] <- sum(w * y)
    }
  }
  return(z_mat)
}


plot2d <- function (x, y, z, 
                    xlcd, ylcd, zlcd=range(z, finite=TRUE), 
                    grid.size=200, ke=TRUE) {

    dens <- list(x=x, y=y, z=z)

    if (ke) {
        # Prediction grid
        grid.x <- seq(xlcd[1], xlcd[2], length.out=grid.size)
        grid.y <- seq(ylcd[1], ylcd[2], length.out=grid.size)
        grid.coords <- expand.grid(grid.x, grid.y)
        colnames(grid.coords) <- c("x", "y")
        z.matrix <- kernel_smooth_grid(x, y, z, grid.x, grid.y, 0.2, 0.2)

        dens <- list(
            x=grid.x,
            y=grid.y,
            z=z.matrix
        )
    }

    # Plot with a square aspect ratio and a tall legend
    par(mar = c(4.5, 4.5, 0.5, 6))  # Extra space on right for the legend

    # draw the image without the legend
    image(dens$x, dens$y, dens$z,
          col = jet.colors(100),
          xlab = "u", ylab = "", main = "",
          las = 1, yaxt="n",
          cex.axis=1.7, cex.lab=1.9,
          xlim=xlcd, ylim=ylcd, zlim=zlcd)

    image.plot(dens,
           legend.only=TRUE,
           col = jet.colors(100),
           legend.width = 2,        # Make legend longer
           legend.mar = 5,
           legend.shrink = 1.0,       # Don't shrink legend
           axis.args=list(cex.axis=1.7),  # change legend number size
           xlab = "u", ylab = "", main = "", 
           las = 1, yaxt="n",
           cex.axis=1.7, cex.lab=1.9,
           xlim=xlcd, ylim=ylcd, zlim=zlcd)

    # custom y-axis labels and axis
    axis(2, las=1, cex.axis=1.7)
    mtext("v", side=2, line=2.5, cex=1.9) 

    # Add contour lines if desired
    contour(dens, add = TRUE, drawlabels = FALSE, col = "black", lwd = 0.5)
}


# Inverse distance matrix
invDist <- function (mtx) {
    mtx <- 1/mtx
    diag(mtx) <- 0
    return(mtx)
}
