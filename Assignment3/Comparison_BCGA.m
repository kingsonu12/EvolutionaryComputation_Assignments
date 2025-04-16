function plotGAP12Comparison()
    % Read all result files
    optimalFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_results_optimal.csv';
    approxFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_results_approx.csv';
    gaFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap_results_bcga.csv';
    
    try
        % Read data from files with error checking
        optimalData = readAndValidateData(optimalFile);
        approxData = readAndValidateData(approxFile);
        gaData = readAndValidateData(gaFile);
        
        % Verify files have same structure
        if ~isequal(optimalData(1,:), approxData(1,:)) || ...
           ~isequal(optimalData(:,1), approxData(:,1)) || ...
           ~isequal(optimalData(1,:), gaData(1,:)) || ...
           ~isequal(optimalData(:,1), gaData(:,1))
            error('File structures do not match. Cannot compare results.');
        end
        
        % Extract case numbers (remove 'Case ' prefix)
        caseNumbers = cellfun(@(x) str2double(x(6:end)), optimalData(2:end,1));
        numCases = length(caseNumbers);
        
        % Get number of problems (gap1 to gap12)
        numProblems = size(optimalData, 2) - 1;
        
        % Convert results to matrices (excluding headers)
        [optimalResults, optimalValid] = convertToNumericMatrix(optimalData(2:end,2:end));
        [approxResults, approxValid] = convertToNumericMatrix(approxData(2:end,2:end));
        [gaResults, gaValid] = convertToNumericMatrix(gaData(2:end,2:end));
        
        % Check for conversion issues
        if ~all(optimalValid(:)) || ~all(approxValid(:)) || ~all(gaValid(:))
            warning('Some values could not be converted to numbers. Results may be incomplete.');
        end
        
        %% Create focused plot for gap12 (first 5 instances)
        gap12Idx = 12; % gap12 is the 12th column
        numInstancesToShow = min(5, numCases); % Show up to 5 instances
        
        % Get the data for gap12
        gap12Optimal = optimalResults(1:numInstancesToShow, gap12Idx);
        gap12Approx = approxResults(1:numInstancesToShow, gap12Idx);
        gap12GA = gaResults(1:numInstancesToShow, gap12Idx);
        
        % Create the figure
        figure('Name', 'GAP12 Comparison (First 5 Instances)', 'Position', [100, 100, 800, 500]);
        
        % Create bar plot
        x = 1:numInstancesToShow;
        barData = [gap12Optimal, gap12Approx, gap12GA];
        hBar = bar(x, barData);
        
        % Customize bar colors
        hBar(1).FaceColor = [0, 0.4470, 0.7410]; % Blue
        hBar(2).FaceColor = [0.8500, 0.3250, 0.0980]; % Orange
        hBar(3).FaceColor = [0.4660, 0.6740, 0.1880]; % Green
        
        % Add values on top of bars
        for i = 1:numInstancesToShow
            text(x(i)-0.25, gap12Optimal(i)+5, num2str(gap12Optimal(i), '%.1f'), ...
                'FontSize', 10, 'HorizontalAlignment', 'center');
            text(x(i), gap12Approx(i)+5, num2str(gap12Approx(i), '%.1f'), ...
                'FontSize', 10, 'HorizontalAlignment', 'center');
            text(x(i)+0.25, gap12GA(i)+5, num2str(gap12GA(i), '%.1f'), ...
                'FontSize', 10, 'HorizontalAlignment', 'center');
        end
        
        % Add labels and title
        title('Performance Comparison for GAP12 (First 5 Instances)', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel('Instance Number', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Objective Value', 'FontSize', 12, 'FontWeight', 'bold');
        
        % Customize x-axis ticks
        xticks(x);
        xticklabels(arrayfun(@(n) sprintf('Instance %d', n), x, 'UniformOutput', false));
        
        % Add legend
        legend({'Optimal Solution', 'Approximation Algorithm', 'Binary Coded Genetic Algorithm'}, ...
               'Location', 'southeast', 'FontSize', 11);
        
        % Improve grid and overall appearance
        grid on;
        set(gca, 'FontSize', 11);
        set(gcf, 'Color', 'w'); % White background
        
        % Save the figure
        saveas(gcf, 'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap12_comparison.png');
        fprintf('Gap12 comparison graph saved as gap12_comparison.png\n');
        
    catch ME
        fprintf('Error occurred: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('File: %s\nName: %s\nLine: %d\n', ...
                   ME.stack(k).file, ME.stack(k).name, ME.stack(k).line);
        end
    end
end

function data = readAndValidateData(filename)
    % Read data from file with validation
    if ~exist(filename, 'file')
        error('File not found: %s', filename);
    end
    
    try
        data = readcell(filename);
    catch
        error('Could not read file: %s', filename);
    end
    
    if isempty(data)
        error('File is empty: %s', filename);
    end
end

function [numericMatrix, validMask] = convertToNumericMatrix(cellData)
    % Convert cell array to numeric matrix with validation
    numericMatrix = zeros(size(cellData));
    validMask = true(size(cellData));
    
    for i = 1:size(cellData, 1)
        for j = 1:size(cellData, 2)
            if isnumeric(cellData{i,j})
                numericMatrix(i,j) = cellData{i,j};
            elseif ischar(cellData{i,j}) || isstring(cellData{i,j})
                numericMatrix(i,j) = str2double(cellData{i,j});
                if isnan(numericMatrix(i,j))
                    validMask(i,j) = false;
                end
            else
                numericMatrix(i,j) = NaN;
                validMask(i,j) = false;
            end
        end
    end
end