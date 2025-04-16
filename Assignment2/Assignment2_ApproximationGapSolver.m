function processDataFilesApprox()
    totalFiles = 12;
    aggregatedResults = cell(totalFiles, 1);
    outputFileName = 'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_results_approx.csv';
    
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
            
            % Solve the problem using approximation
            xMatrix = solveGapApprox(serverCount, userCount, costMatrix, resourceMatrix, capacityVector);
            
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
        fprintf('Approximation results successfully updated in %s\n', outputFileName);
    catch ME
        error('Error writing to file %s. Message: %s', outputFileName, ME.message);
    end
end

function xMatrix = solveGapApprox(m, n, c, r, b)
    % m = number of servers
    % n = number of users
    % c = utility matrix (m x n)
    % r = resource requirement matrix (m x n)
    % b = capacity vector (m x 1)
    
    xMatrix = zeros(m, n);
    remainingCapacity = b;
    
    % Calculate cost-to-resource ratio for all assignments
    ratioMatrix = c ./ r;
    ratioMatrix(r == 0) = -Inf; % Avoid division by zero
    
    % Process users in random order (you could also sort them)
    userOrder = randperm(n);
    
    for j = userOrder
        % Find all feasible servers for this user
        feasibleServers = find(r(:, j) <= remainingCapacity);
        
        if isempty(feasibleServers)
            continue; % Skip this user if no feasible assignment
        end
        
        % Among feasible servers, pick the one with best cost/resource ratio
        [~, bestServerIdx] = max(ratioMatrix(feasibleServers, j));
        bestServer = feasibleServers(bestServerIdx);
        
        % Assign user to server
        xMatrix(bestServer, j) = 1;
        remainingCapacity(bestServer) = remainingCapacity(bestServer) - r(bestServer, j);
    end
end



