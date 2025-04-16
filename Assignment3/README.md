
# GAP Solver using Binary Coded Genetic Algorithm (BCGA)

This project implements a Binary Coded Genetic Algorithm (BCGA) for solving the Generalized Assignment Problem (GAP), and compares its performance with other methods.

## Files Included

1. **Assignment3_BCGAGapSolver.m**  
   - Reads GAP instance files (`gap1.txt` to `gap12.txt`)
   - Solves each case using a BCGA-based approach
   - Saves results to: `gap_results_bcga.csv`

2. **Assignment3_BCGASphereFn.m**  
   - Demonstrates the BCGA on a standard Sphere optimization function
   - Useful for understanding the genetic algorithm behavior in a simpler setting

3. **Comparison_BCGA.m**  
   - Compares results from three methods: Optimal, Approximation, and BCGA for GAP12
   - Plots a bar chart for the first five instances of `gap12`
   - Saves the plot to: `gap12_comparison.png`

4. **gap_results_bcga.csv**  
   - Contains the output of the BCGA on GAP test cases

5. **gap12_comparison.png**  
   - Visual comparison of GAP12 across Optimal, Approximation, and BCGA methods

## Instructions

1. **Run BCGA Solver**  
   Ensure the files `gap1.txt` to `gap12.txt` are in the working directory.  
   Execute in MATLAB:
   ```matlab
   processDataFiles
   ```

2. **Visualize Comparison for GAP12**  
   Make sure the result files for all three methods are available (`gap_results_optimal.csv`, `gap_results_approx.csv`, and `gap_results_bcga.csv`).  
   Then run:
   ```matlab
   plotGAP12Comparison
   ```

3. **Optional: Run BCGA on Sphere Function**  
   Run the GA visualization example with:
   ```matlab
   binaryGA_sphere
   ```

## File Paths (Update as Needed)

Default file paths are configured as:
```matlab
'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap_results_bcga.csv'
'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap12_comparison.png'
```
Modify them based on your working directory.

## Visualization

The comparison plot (`gap12_comparison.png`) shows how the BCGA stacks up against traditional methods for the most complex GAP benchmark.

---
Generated automatically.
