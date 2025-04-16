
# GAP Solver using Particle Swarm Optimization (PSO)

This project uses Particle Swarm Optimization (PSO) to solve the Generalized Assignment Problem (GAP) and evaluates its performance in comparison to multiple other metaheuristic and exact algorithms.

## Files Included

1. **Assignment5_PSOGapSolver.m**  
   - Loads GAP instances (`gap1.txt` to `gap12.txt`)  
   - Solves each instance using PSO  
   - Stores results in: `gap_results_pso.csv`

2. **Assignment5_PSOSphereFn.m**  
   - Demonstrates the PSO algorithm on a classical Sphere function optimization task  
   - Shows convergence behavior visually

3. **Comparison_PSO.m**  
   - Compares results from five different solvers: Optimal, Approximation, BCGA, RCGA, and PSO  
   - Focused comparison of the top 5 instances in `gap12`  
   - Saves the bar chart to: `gap12_comparison_all.png`

4. **gap_results_pso.csv**  
   - Contains objective values for each test case solved using PSO

5. **gap12_comparison_all.png**  
   - Visual plot comparing GAP12 solutions across all solvers

## Instructions

1. **Run PSO Solver for GAP**  
   Ensure all input files (`gap1.txt` to `gap12.txt`) are in your working directory.  
   Execute in MATLAB:
   ```matlab
   processDataFilesPSO
   ```

2. **Plot Comparative Results for GAP12**  
   Make sure all results are present:  
   - `gap_results_optimal.csv`  
   - `gap_results_approx.csv`  
   - `gap_results_bcga.csv`  
   - `gap_results_rcga.csv`  
   - `gap_results_pso.csv`  
   
   Then run:
   ```matlab
   plotGAP12Comparison
   ```

3. **Try PSO on Sphere Function**  
   For algorithm behavior understanding, run:
   ```matlab
   pso_sphere
   ```

## File Paths (Modify as Needed)

Predefined output paths include:
```matlab
'C:/Users/akkid/Desktop/New Assignments/Assignment5/gap_results_pso.csv'
'C:/Users/akkid/Desktop/New Assignments/Assignment5/gap12_comparison_all.png'
```
Change these paths if your setup differs.

## Visualization

The comparison chart (`gap12_comparison_all.png`) provides a visual evaluation of how PSO stacks up against other methods on the most complex GAP benchmark.

---
Generated automatically.

> Author: *Aniket Ranjan*  
> Date: *April 2025*

GITHUB Link: https://github.com/kingsonu12/EvolutionaryComputation_Assignments
