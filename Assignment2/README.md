
# GAP Approximation vs Optimal Solution

This project provides a comparison between optimal and approximation solutions for the Generalized Assignment Problem (GAP). It includes scripts to process GAP instance files, generate results, and visualize performance using a line graph.

## Files Included

1. **Assignment2_ApproximationGapSolver.m**  
   - Reads `.txt` GAP instance files (`gap1.txt` to `gap12.txt`)
   - Solves each using a greedy approximation algorithm
   - Saves results to: `gap_results_approx.csv`

2. **Comparison_OptimalandApprox.m**  
   - Compares the results of the approximation algorithm against precomputed optimal results (`gap_results_optimal.csv`)
   - Plots the results and highlights performance differences
   - Saves the graph to: `gap_comparison_line_graph.png`

3. **gap_results_approx.csv**  
   - Contains the output from the approximation algorithm

4. **gap_comparison_line_graph.png**  
   - Visual comparison of all instances across 12 GAP benchmarks

## Instructions

1. **Run Approximation Solver**  
   Ensure all GAP input files (`gap1.txt` to `gap12.txt`) are in the working directory.  
   Then run the MATLAB script:
   ```matlab
   processDataFilesApprox
   ```

2. **Generate Comparison Plot**  
   Make sure both `gap_results_approx.csv` and `gap_results_optimal.csv` exist.  
   Then run:
   ```matlab
   plotGAPComparisonFromFiles
   ```

## File Paths (Update Accordingly)

In both `.m` files, update paths like the following if necessary:
```matlab
'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_results_approx.csv'
'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_results_optimal.csv'
```

Set these to your actual working directory if not using the same setup.

## Visualization

The resulting plot shows objective values for each test case and problem set (`gap1` to `gap12`). Blue lines represent optimal solutions while red lines show approximation results.

---
Generated automatically.

> Author: *Aniket Ranjan*  
> Date: *April 2025*

GITHUB Link: https://github.com/kingsonu12/EvolutionaryComputation_Assignments
