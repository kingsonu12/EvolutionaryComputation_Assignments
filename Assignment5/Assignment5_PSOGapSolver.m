function processDataFilesPSO()
    totalFiles = 12;
    aggregatedResults = cell(totalFiles, 1);
    outputFileName = 'C:/Users/akkid/Desktop/New Assignments/Assignment5/gap_results_pso.csv';
    
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
        
        totalCases = fscanf(fileId, '%d', 1);
        caseResults = cell(totalCases, 1);
        
        for caseIndex = 1:totalCases
            dimensions = fscanf(fileId, '%d', 2);
            serverCount = dimensions(1);
            userCount = dimensions(2);
            
            costMatrix = zeros(serverCount, userCount);
            for i = 1:serverCount
                costMatrix(i, :) = fscanf(fileId, '%d', [1, userCount]);
            end
            
            resourceMatrix = zeros(serverCount, userCount);
            for i = 1:serverCount
                resourceMatrix(i, :) = fscanf(fileId, '%d', [1, userCount]);
            end
            
            capacityVector = fscanf(fileId, '%d', [serverCount, 1]);
            
            % Solve using PSO
            xMatrix = solveGapWithPSO(serverCount, userCount, costMatrix, resourceMatrix, capacityVector);
            totalUtility = sum(sum(costMatrix .* xMatrix));
            caseResults{caseIndex} = round(totalUtility);
        end
        
        fclose(fileId);
        aggregatedResults{fileIndex} = caseResults;
    end

    maxCases = max(cellfun(@length, aggregatedResults));
    newData = cell(maxCases + 1, totalFiles + 1);
    newData{1,1} = 'Case';
    for fileIndex = 1:totalFiles
        newData{1, fileIndex+1} = sprintf('gap%d', fileIndex);
    end

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

    if exist(outputFileName, 'file')
        try
            existingData = readcell(outputFileName);
            if size(existingData, 2) ~= size(newData, 2) || ...
               ~isequal(existingData(1,:), newData(1,:)) || ...
               ~isequal(existingData(:,1), newData(:,1))
                warning('Existing file structure mismatch. Overwriting file.');
                existingData = newData;
            else
                for row = 2:size(newData, 1)
                    for col = 2:size(newData, 2)
                        if ~isempty(newData{row,col})
                            existingData{row,col} = newData{row,col};
                        end
                    end
                end
            end
        catch
            warning('Error reading existing file. Creating new one.');
            existingData = newData;
        end
    else
        existingData = newData;
    end

    try
        writecell(existingData, outputFileName);
        fprintf('Results successfully saved in %s\n', outputFileName);
    catch ME
        error('Error writing to file %s. Message: %s', outputFileName, ME.message);
    end
end

function xMatrix = solveGapWithPSO(m, n, c, r, b)
    % PSO parameters
    swarmSize = 100;
    maxIterations = 500;
    w = 0.729; % inertia weight
    c1 = 1.49445; % cognitive coefficient
    c2 = 1.49445; % social coefficient
    
    % Problem dimensions
    dim = m * n;
    
    % Initialize particles
    particles = rand(swarmSize, dim);
    velocities = zeros(swarmSize, dim);
    
    % Initialize personal bests
    personalBestPositions = particles;
    personalBestValues = zeros(swarmSize, 1);
    
    % Evaluate initial population
    for i = 1:swarmSize
        personalBestValues(i) = evaluatePSOFitness(particles(i,:), m, n, c, r, b);
    end
    
    % Initialize global best
    [globalBestValue, globalBestIdx] = max(personalBestValues);
    globalBestPosition = personalBestPositions(globalBestIdx, :);
    
    % PSO main loop
    for iter = 1:maxIterations
        % Update each particle
        for i = 1:swarmSize
            % Update velocity
            r1 = rand(1, dim);
            r2 = rand(1, dim);
            velocities(i,:) = w * velocities(i,:) + ...
                             c1 * r1 .* (personalBestPositions(i,:) - particles(i,:)) + ...
                             c2 * r2 .* (globalBestPosition - particles(i,:));
            
            % Update position
            particles(i,:) = particles(i,:) + velocities(i,:);
            
            % Ensure positions stay within [0,1] bounds
            particles(i,:) = max(min(particles(i,:), 1), 0);
            
            % Evaluate new position
            currentFitness = evaluatePSOFitness(particles(i,:), m, n, c, r, b);
            
            % Update personal best
            if currentFitness > personalBestValues(i)
                personalBestPositions(i,:) = particles(i,:);
                personalBestValues(i) = currentFitness;
                
                % Update global best if needed
                if currentFitness > globalBestValue
                    globalBestValue = currentFitness;
                    globalBestPosition = particles(i,:);
                end
            end
        end
        
        % Optional: adaptive inertia weight
        % w = w * 0.99;
    end
    
    % Decode the best solution found
    xMatrix = decodeRealChromosome(globalBestPosition, m, n);
end

function fitness = evaluatePSOFitness(individual, m, n, c, r, b)
    xMatrix = decodeRealChromosome(individual, m, n);
    totalUtility = sum(sum(c .* xMatrix));
    
    % Calculate constraint violations
    userAssignments = sum(xMatrix, 1);
    userViolation = sum(abs(userAssignments - 1));
    
    serverResources = sum(r .* xMatrix, 2);
    serverViolation = sum(max(0, serverResources - b));
    
    % Apply penalty
    penalty = 1000 * (userViolation + serverViolation);
    fitness = totalUtility - penalty;
end

function xMatrix = decodeRealChromosome(chromosome, m, n)
    xMatrix = zeros(m, n);
    mat = reshape(chromosome, [m, n]);
    for j = 1:n
        [~, bestServer] = max(mat(:,j));
        xMatrix(bestServer, j) = 1;
    end
end