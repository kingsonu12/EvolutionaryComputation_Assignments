# GAP Optimal Solution Comparison

This project compares the **optimal objective values** obtained for different GAP (Generalized Assignment Problem) instances (`gap1.txt` to `gap12.txt`) across multiple test cases. The aim is to visually and analytically assess the performance and variation of optimal solutions across test runs.

## Files Included

### 1. `Assignment1_OptimalGapSolver.m`
MATLAB script that:
- Loads GAP problem instances (`gap1.txt` to `gap12.txt`)
- Solves each using exact optimization
- Records the optimal objective values for multiple test cases (runs)
- Outputs the results in CSV format

### 2. `gap_results_optimal.csv`
CSV file containing the **optimal objective values** for each GAP instance across 5 test runs. Each row corresponds to a GAP instance, and each column corresponds to a test case number.

### 3. `gap_comparison_line_graph.png`
A line graph visualizing the **optimal solutions** across test cases for each GAP instance:
- X-axis: Test Case Number (1–5)
- Y-axis: Optimal Objective Value
- Legend: GAP instances (`gap1` to `gap12`)

## Path Information (Update for Script)
Make sure the script `Assignment1_OptimalGapSolver.m` reads and writes to the appropriate file paths:

```matlab
% Update your script paths accordingly
inputFolder = 'Dataset/'; % Assuming input files like 'gap1.txt' are stored here
outputCSV = 'gap_results_optimal.csv';
outputImage = 'gap_comparison_line_graph.png';
```

## How to Run

1. Place all `gap*.txt` files into a folder named `Dataset/`.
2. Ensure MATLAB has access to that directory.
3. Run the script:
   ```matlab
   Assignment1_OptimalGapSolver
   ```
4. Results will be saved in `gap_results_optimal.csv` and visualized in `gap_comparison_line_graph.png`.

## Visualization Highlight

The chart helps identify:
- Variability in results across runs
- Relative difficulty or complexity of GAP instances
- Which instances consistently yield higher or lower optimal values

The label **"Optimal Solution"** marks the region of interest in the upper value range.

---

> Author: *Aniket Ranjan*  
> Date: *April 2025*

GITHUB Link: https://github.com/kingsonu12/EvolutionaryComputation_Assignments
