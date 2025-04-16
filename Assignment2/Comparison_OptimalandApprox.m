function plotGAPComparisonFromFiles()
    % Read both result files
    optimalFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_results_optimal.csv';
    approxFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_results_approx.csv';
    
    % Read data from files
    optimalData = readcell(optimalFile);
    approxData = readcell(approxFile);
    
    % Verify files have same structure
    if ~isequal(optimalData(1,:), approxData(1,:)) || ...
       ~isequal(optimalData(:,1), approxData(:,1))
        error('File structures do not match. Cannot compare results.');
    end
    
    % Extract case numbers (remove 'Case ' prefix)
    caseNumbers = cellfun(@(x) str2double(x(6:end)), optimalData(2:end,1));
    numCases = length(caseNumbers);
    
    % Get number of problems (gap1 to gap12)
    numProblems = size(optimalData, 2) - 1;
    
    % Convert results to matrices (excluding headers)
    optimalResults = cell2mat(optimalData(2:end,2:end));
    approxResults = cell2mat(approxData(2:end,2:end));
    
    % Create data for plotting
    allInstances = [];
    allOptimal = [];
    allApprox = [];
    fileLabels = [];
    fileNames = {};
    
    for problemIdx = 1:numProblems
        % Extract data for this problem
        opt = optimalResults(:, problemIdx);
        app = approxResults(:, problemIdx);
        
        % Skip if no valid data
        if all(isnan(opt))
            continue;
        end
        
        % Create continuous instance indices
        startIndex = length(allInstances) + 1;
        endIndex = startIndex + numCases - 1;
        instances = startIndex:endIndex;
        
        % Store the data
        allInstances = [allInstances instances];
        allOptimal = [allOptimal opt'];
        allApprox = [allApprox app'];
        
        % Create file boundary markers
        if problemIdx > 1
            fileLabels = [fileLabels startIndex];
        end
        fileNames{problemIdx} = sprintf('gap%d', problemIdx);
    end
    
    % Create the comparison figure
    figure('Name', 'GAP Comparison: Optimal vs Approximation', 'Position', [100, 100, 1200, 600]);
    
    % Plot the data
    hold on;
    h1 = plot(allInstances, allOptimal, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
    h2 = plot(allInstances, allApprox, 'r-*', 'LineWidth', 2, 'MarkerSize', 8);
    
    % Add vertical lines for problem boundaries
    for i = 1:length(fileLabels)
        line([fileLabels(i) fileLabels(i)], get(gca, 'YLim'), 'Color', [0.7 0.7 0.7], 'LineStyle', '--');
        
        % Add problem name labels
        if i > 1
            text((fileLabels(i-1) + fileLabels(i))/2, ...
                max([allOptimal, allApprox]) * 1.05, fileNames{i-1}, ...
                'HorizontalAlignment', 'center');
        else
            text(fileLabels(i)/2, ...
                max([allOptimal, allApprox]) * 1.05, fileNames{i}, ...
                'HorizontalAlignment', 'center');
        end
    end
    
    % Label the last problem section
    if ~isempty(fileNames)
        text((allInstances(end) + fileLabels(end)) / 2, ...
            max([allOptimal, allApprox]) * 1.05, fileNames{end}, ...
            'HorizontalAlignment', 'center');
    end
    
    % Add labels and title
    title('Comparison of Optimal and Approximation Solutions for GAP', 'FontSize', 14);
    xlabel('Instance Index', 'FontSize', 12);
    ylabel('Objective Value', 'FontSize', 12);
    legend([h1, h2], {'Optimal Solution', 'Approximation Algorithm'}, 'Location', 'best', 'FontSize', 12);
    grid on;
    
    % Calculate and display approximation ratio stats
    validRatios = ~isnan(allOptimal) & allOptimal ~= 0;
    ratios = allApprox(validRatios) ./ allOptimal(validRatios);
    
    if ~isempty(ratios)
        meanRatio = mean(ratios);
        minRatio = min(ratios);
        maxRatio = max(ratios);
    end
    
    hold off;
    
    % Save the figure
    saveas(gcf, 'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_comparison_line_graph.png');
    fprintf('Comparison graph saved as gap_comparison_line_graph.png\n');
end