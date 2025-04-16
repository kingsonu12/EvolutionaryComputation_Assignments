
# GAP Solver using Real Coded Genetic Algorithm (RCGA)

This project applies a Real Coded Genetic Algorithm (RCGA) to solve the Generalized Assignment Problem (GAP), and compares its performance to other existing methods.

## Files Included

1. **Assignment4_RCGAGapSolver.m**  
   - Processes GAP input files (`gap1.txt` to `gap12.txt`)  
   - Solves each instance using RCGA  
   - Saves the results to: `gap_results_rcga.csv`

2. **Assignment4_RCGASphereFn.m**  
   - A demonstration of the RCGA on the Sphere function optimization problem  
   - Visualizes convergence behavior of RCGA

3. **Comparison_RCGA.m**  
   - Compares the performance of Optimal, Approximation, Binary GA, and RCGA methods  
   - Focuses on `gap12`, comparing the first 5 instances  
   - Saves the comparison as: `gap12_comparison_rcga.png`

4. **gap_results_rcga.csv**  
   - Contains utility values computed by the RCGA on all GAP instances

5. **gap12_comparison_rcga.png**  
   - Bar chart visualization showing objective values for `gap12` (first 5 instances)

## Instructions

1. **Run RCGA Solver**  
   Ensure GAP input files (`gap1.txt` to `gap12.txt`) are in the same folder.  
   Then run:
   ```matlab
   processDataFiles
   ```

2. **Visualize Comparison for GAP12**  
   Make sure all necessary result files are available:  
   - `gap_results_optimal.csv`  
   - `gap_results_approx.csv`  
   - `gap_results_bcga.csv`  
   - `gap_results_rcga.csv`  
   
   Then run the script:
   ```matlab
   plotGAP12Comparison
   ```

3. **Test RCGA on Sphere Function**  
   For GA performance validation, run:
   ```matlab
   realGA_sphere
   ```

## File Paths (Update if Needed)

Default output paths are configured like:
```matlab
'C:/Users/akkid/Desktop/New Assignments/Assignment4/gap_results_rcga.csv'
'C:/Users/akkid/Desktop/New Assignments/Assignment4/gap12_comparison_rcga.png'
```
Update these paths to match your working environment.

## Visualization

The output comparison chart (`gap12_comparison_rcga.png`) helps you visually compare RCGA with other methods on the toughest benchmark, GAP12.

---
Generated automatically.

> Author: *Aniket Ranjan*  
> Date: *April 2025*

GITHUB Link: https://github.com/kingsonu12/EvolutionaryComputation_Assignments
