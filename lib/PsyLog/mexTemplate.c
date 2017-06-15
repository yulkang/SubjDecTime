#include "mex.h"

void arrayProduct(double x, double *y, double *z, mwSize n)
{
    mwSize i;
    
    for (i=0; i<n; i++) {
        z[i] = x * y[i];
    }
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double multiplier;
    double *inMatrix;
    size_t ncols;
    double *outMatrix;
    
    multiplier = mxGetScalar(prhs[0]);
    inMatrix   = mxGetPr(prhs[1]);
    ncols      = mxGetN(prhs[1]);
    
    plhs[0] = mxCreateDoubleMatrix(1, (mwSize)ncols, mxREAL);
    
    outMatrix = mxGetPr(plhs[0]);
    
    arrayProduct(multiplier, inMatrix, outMatrix, (mwSize)ncols);
}

