function processDataFiles()
    totalFiles = 12;
    aggregatedResults = cell(totalFiles, 1);
    outputFileName = 'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_results_optimal.csv';
    
    % Create directory if it doesn't exist
    [filepath,~,~] = fileparts(outputFileName);
    if ~isfolder(filepath)
        mkdir(filepath);
    end
    
    % Iterate through gap1 to gap12
    for fileIndex = 1:totalFiles
        fileName = sprintf('gap%d.txt', fileIndex);
        fileId = fopen(fileName, 'r');
        
        if fileId == -1
            error('Error opening file %s.', fileName);
        end
        
        % Read the number of test cases
        totalCases = fscanf(fileId, '%d', 1);
        caseResults = cell(totalCases, 1);
        
        for caseIndex = 1:totalCases
            % Read input parameters
            dimensions = fscanf(fileId, '%d', 2);
            serverCount = dimensions(1);
            userCount = dimensions(2);
            
            % Read utility matrix (cost matrix)
            costMatrix = zeros(serverCount, userCount);
            for i = 1:serverCount
                costMatrix(i, :) = fscanf(fileId, '%d', [1, userCount]);
            end
            
            % Read resource requirement matrix
            resourceMatrix = zeros(serverCount, userCount);
            for i = 1:serverCount
                resourceMatrix(i, :) = fscanf(fileId, '%d', [1, userCount]);
            end
            
            % Read server capacities
            capacityVector = fscanf(fileId, '%d', [serverCount, 1]);
            
            % Solve the problem
            xMatrix = solveGapMax(serverCount, userCount, costMatrix, resourceMatrix, capacityVector);
            
            % Calculate total utility
            totalUtility = sum(sum(costMatrix .* xMatrix));
            
            % Store formatted output
            caseResults{caseIndex} = round(totalUtility);
        end
        
        % Close file
        fclose(fileId);
        aggregatedResults{fileIndex} = caseResults;
    end
    
    % Determine the maximum number of cases across all files
    maxCases = max(cellfun(@length, aggregatedResults));
    
    % Prepare new data for CSV
    newData = cell(maxCases + 1, totalFiles + 1); % +1 for headers and case numbers
    
    % Set headers
    newData{1,1} = 'Case';
    for fileIndex = 1:totalFiles
        newData{1, fileIndex+1} = sprintf('gap%d', fileIndex);
    end
    
    % Fill in the new data
    for caseIndex = 1:maxCases
        newData{caseIndex+1, 1} = sprintf('Case %d', caseIndex);
        for fileIndex = 1:totalFiles
            if caseIndex <= length(aggregatedResults{fileIndex})
                newData{caseIndex+1, fileIndex+1} = aggregatedResults{fileIndex}{caseIndex};
            else
                newData{caseIndex+1, fileIndex+1} = '';
            end
        end
    end
    
    % Check if file exists and read existing data if it does
    if exist(outputFileName, 'file')
        % Read existing CSV data
        try
            existingData = readcell(outputFileName);
            
            % Verify the structure matches
            if size(existingData, 2) ~= size(newData, 2) || ...
               ~isequal(existingData(1,:), newData(1,:)) || ...
               ~isequal(existingData(:,1), newData(:,1))
                warning('Existing file structure does not match. Overwriting file.');
                existingData = newData;
            else
                % Update only the values (not headers or case numbers)
                for row = 2:size(newData, 1)
                    for col = 2:size(newData, 2)
                        if ~isempty(newData{row,col})
                            existingData{row,col} = newData{row,col};
                        end
                    end
                end
            end
        catch
            warning('Error reading existing file. Creating new file.');
            existingData = newData;
        end
    else
        % File doesn't exist, use new data
        existingData = newData;
    end
    
    % Write to CSV file
    try
        writecell(existingData, outputFileName);
        fprintf('Results successfully updated in %s\n', outputFileName);
    catch ME
        error('Error writing to file %s. Message: %s', outputFileName, ME.message);
    end
    
    % Create comparison plot of all gap files
    createComparisonPlot(aggregatedResults, maxCases, totalFiles);
end

function xMatrix = solveGapMax(m, n, c, r, b)
    % m = number of servers
    % n = number of users
    % c = utility matrix (m x n)
    % r = resource requirement matrix (m x n)
    % b = capacity vector (m x 1)
    
    % Flatten c matrix for objective function
    f = -reshape(c, [], 1); % Negative for maximization
    
    % Constraint 1: Each user assigned to exactly one server
    AeqUsers = zeros(n, m*n);
    for j = 1:n
        for i = 1:m
            AeqUsers(j, (j-1)*m + i) = 1;
        end
    end
    beqUsers = ones(n, 1);
    
    % Constraint 2: Server capacity constraints
    AineqServers = zeros(m, m*n);
    for i = 1:m
        for j = 1:n
            AineqServers(i, (j-1)*m + i) = r(i, j);
        end
    end
    bineqServers = b;
    
    % Define variable bounds (binary decision variables)
    lb = zeros(m*n, 1);
    ub = ones(m*n, 1);
    intcon = 1:(m*n);
    
    % Solve using intlinprog
    options = optimoptions('intlinprog', 'Display', 'off');
    x = intlinprog(f, intcon, AineqServers, bineqServers, AeqUsers, beqUsers, lb, ub, options);
    
    % Reshape into m × n matrix (servers × users)
    xMatrix = reshape(x, [m, n]);
end

function createComparisonPlot(resultsData, maxCases, totalFiles)
    % Prepare data for plotting
    plotData = zeros(maxCases, totalFiles);
    gapNames = cell(1, totalFiles);
    
    for fileIndex = 1:totalFiles
        currentFileResults = resultsData{fileIndex};
        for caseIndex = 1:length(currentFileResults)
            plotData(caseIndex, fileIndex) = currentFileResults{caseIndex};
        end
        gapNames{fileIndex} = sprintf('gap%d', fileIndex);
    end
    
    % Create figure with white background
    fig = figure('Name', 'GAP Solutions Comparison', 'NumberTitle', 'off', 'Color', 'w');
    set(fig, 'Position', [100, 100, 1000, 600]);
    
    % Create a color palette
    colors = lines(totalFiles); % MATLAB's built-in colormap
    
    % Create line plot
    hold on;
    for i = 1:totalFiles
        plot(1:maxCases, plotData(:,i), ...
            'LineWidth', 2.5, ...
            'Color', colors(i,:), ...
            'Marker', 'o', ...
            'MarkerSize', 8, ...
            'MarkerFaceColor', colors(i,:));
    end
    hold off;
    
    % Customize plot appearance
    title('Comparison of Optimal Solutions Across GAP Instances', ...
        'FontSize', 16, 'FontWeight', 'bold');
    xlabel('Test Case Number', 'FontSize', 14);
    ylabel('Optimal Objective Value', 'FontSize', 14);
    
    % Add legend
    legend(gapNames, 'Location', 'eastoutside', 'FontSize', 10);
    
    % Adjust axes
    xlim([0.5, maxCases+0.5]);
    ylim([0, max(plotData(:))*1.1]);
    xticks(1:maxCases);
    grid on;
    box on;
    set(gca, 'FontSize', 12, 'LineWidth', 1.5);
    
    % Add annotation for optimal solutions
    annotation('textbox', [0.15, 0.85, 0.2, 0.05], ...
        'String', 'Optimal Solution', ...
        'FontSize', 12, ...
        'EdgeColor', 'none', ...
        'FontWeight', 'bold');
    
    % Save the plot
    savePath = 'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_comparison_line_graph.png';
    exportgraphics(fig, savePath, 'Resolution', 300);
    fprintf('Comparison plot saved to: %s\n', savePath);
end