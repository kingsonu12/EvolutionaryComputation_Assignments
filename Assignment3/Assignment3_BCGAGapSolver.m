function processDataFiles()
    totalFiles = 12;
    aggregatedResults = cell(totalFiles, 1);
    outputFileName = 'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap_results_bcga.csv';
    
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
            
            % Solve the problem using GA
            xMatrix = solveGapWithGA(serverCount, userCount, costMatrix, resourceMatrix, capacityVector);
            
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
end

function xMatrix = solveGapWithGA(m, n, c, r, b)
    % GA parameters
    popSize = 100;          % Population size
    maxGenerations = 500;   % Maximum number of generations
    crossoverProb = 0.8;    % Crossover probability
    mutationProb = 0.01;    % Mutation probability per bit
    tournamentSize = 2;     % Binary tournament size
    
    % Initialize population
    population = initializePopulation(popSize, m, n);
    
    % Evaluate initial population
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        fitness(i) = evaluateFitness(population(i,:), m, n, c, r, b);
    end
    
    % Main GA loop
    for gen = 1:maxGenerations
        % Selection (Binary tournament)
        parents = selection(population, fitness, tournamentSize);
        
        % Crossover
        offspring = crossover(parents, crossoverProb, m, n);
        
        % Mutation
        offspring = mutation(offspring, mutationProb);
        
        % Evaluate offspring
        offspringFitness = zeros(size(offspring,1), 1);
        for i = 1:size(offspring,1)
            offspringFitness(i) = evaluateFitness(offspring(i,:), m, n, c, r, b);
        end
        
        % Replacement (generational replacement with elitism)
        [population, fitness] = replacement(population, fitness, offspring, offspringFitness);
    end
    
    % Find the best solution
    [~, bestIdx] = max(fitness);
    bestSolution = population(bestIdx,:);
    
    % Convert to assignment matrix
    xMatrix = convertToMatrix(bestSolution, m, n);
end

function population = initializePopulation(popSize, m, n)
    % Initialize binary population
    % Each chromosome is a binary string of length m*n
    % Each user is represented by m bits (one for each server)
    population = zeros(popSize, m*n);
    for i = 1:popSize
        % Initialize with random assignments that satisfy the "one user per server" constraint
        for j = 1:n
            server = randi(m);  % Random server for this user
            population(i, (j-1)*m + server) = 1;
        end
    end
end

function fitness = evaluateFitness(individual, m, n, c, r, b)
    % Convert binary string to assignment matrix
    xMatrix = convertToMatrix(individual, m, n);
    
    % Calculate total utility
    totalUtility = sum(sum(c .* xMatrix));
    
    % Check constraints
    % 1. Each user assigned to exactly one server
    userAssignments = sum(xMatrix, 1);
    userConstraintViolation = sum(abs(userAssignments - 1));
    
    % 2. Server capacity constraints
    serverResources = sum(r .* xMatrix, 2);
    serverConstraintViolation = sum(max(0, serverResources - b));
    
    % Penalty for constraint violations
    penalty = 1000 * (userConstraintViolation + serverConstraintViolation);
    
    % Fitness is utility minus penalty (we want to maximize utility)
    fitness = totalUtility - penalty;
end

function xMatrix = convertToMatrix(individual, m, n)
    % Convert binary string to m x n assignment matrix
    xMatrix = reshape(individual, [m, n]);
end

function parents = selection(population, fitness, tournamentSize)
    % Binary tournament selection
    popSize = size(population, 1);
    parents = zeros(popSize, size(population, 2));
    
    for i = 1:popSize
        % Randomly select tournamentSize individuals
        contestants = randperm(popSize, tournamentSize);
        % Select the one with highest fitness
        [~, bestIdx] = max(fitness(contestants));
        parents(i,:) = population(contestants(bestIdx),:);
    end
end

function offspring = crossover(parents, crossoverProb, m, n)
    % Uniform crossover
    popSize = size(parents, 1);
    offspring = zeros(size(parents));
    
    for i = 1:2:popSize-1
        parent1 = parents(i,:);
        parent2 = parents(i+1,:);
        
        if rand() < crossoverProb
            % Perform crossover
            crossoverPoints = rand(size(parent1)) > 0.5;
            child1 = parent1;
            child1(crossoverPoints) = parent2(crossoverPoints);
            child2 = parent2;
            child2(crossoverPoints) = parent1(crossoverPoints);
            
            % Repair children to ensure each user is assigned to exactly one server
            child1 = repairIndividual(child1, m, n);
            child2 = repairIndividual(child2, m, n);
            
            offspring(i,:) = child1;
            offspring(i+1,:) = child2;
        else
            % No crossover, copy parents
            offspring(i,:) = parent1;
            offspring(i+1,:) = parent2;
        end
    end
end

function individual = repairIndividual(individual, m, n)
    % Ensure each user is assigned to exactly one server
    for j = 1:n
        userBits = individual((j-1)*m+1:j*m);
        if sum(userBits) ~= 1
            % If no server selected, pick one at random
            % If multiple servers selected, pick one at random from the selected
            selected = find(userBits);
            if isempty(selected)
                % No server selected - pick one randomly
                server = randi(m);
            else
                % Multiple servers selected - pick one randomly
                server = selected(randi(length(selected)));
            end
            % Reset all bits for this user
            individual((j-1)*m+1:j*m) = 0;
            % Set the selected server
            individual((j-1)*m + server) = 1;
        end
    end
end

function offspring = mutation(offspring, mutationProb)
    % Bit-flip mutation
    mutationMask = rand(size(offspring)) < mutationProb;
    offspring = mod(offspring + mutationMask, 2);
end

function [newPopulation, newFitness] = replacement(population, fitness, offspring, offspringFitness)
    % Generational replacement with elitism (keep best individual)
    combinedPop = [population; offspring];
    combinedFit = [fitness; offspringFitness];
    
    % Sort by fitness
    [sortedFit, sortIdx] = sort(combinedFit, 'descend');
    
    % Select top individuals
    newPopulation = combinedPop(sortIdx(1:length(fitness)),:);
    newFitness = sortedFit(1:length(fitness));
end