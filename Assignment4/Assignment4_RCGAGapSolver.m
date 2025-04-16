function processDataFiles()
    totalFiles = 12;
    aggregatedResults = cell(totalFiles, 1);
    outputFileName = 'C:/Users/akkid/Desktop/New Assignments/Assignment4/gap_results_rcga.csv';
    
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
            
            % Solve using RCGA
            xMatrix = solveGapWithRCGA(serverCount, userCount, costMatrix, resourceMatrix, capacityVector);
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

function xMatrix = solveGapWithRCGA(m, n, c, r, b)
    popSize = 100;
    maxGenerations = 500;
    crossoverProb = 0.8;
    mutationProb = 0.2;
    tournamentSize = 2;

    population = rand(popSize, m * n);

    fitness = zeros(popSize, 1);
    for i = 1:popSize
        fitness(i) = evaluateRCGAFitness(population(i,:), m, n, c, r, b);
    end

    for gen = 1:maxGenerations
        parents = selectionRCGA(population, fitness, tournamentSize);
        offspring = crossoverRCGA(parents, crossoverProb);
        offspring = mutationRCGA(offspring, mutationProb);

        offspringFitness = zeros(size(offspring, 1), 1);
        for i = 1:size(offspring, 1)
            offspringFitness(i) = evaluateRCGAFitness(offspring(i,:), m, n, c, r, b);
        end

        [population, fitness] = replacement(population, fitness, offspring, offspringFitness);
    end

    [~, bestIdx] = max(fitness);
    bestSolution = population(bestIdx,:);
    xMatrix = decodeRealChromosome(bestSolution, m, n);
end

function xMatrix = decodeRealChromosome(chromosome, m, n)
    xMatrix = zeros(m, n);
    mat = reshape(chromosome, [m, n]);
    for j = 1:n
        [~, bestServer] = max(mat(:,j));
        xMatrix(bestServer, j) = 1;
    end
end

function fitness = evaluateRCGAFitness(individual, m, n, c, r, b)
    xMatrix = decodeRealChromosome(individual, m, n);
    totalUtility = sum(sum(c .* xMatrix));
    userAssignments = sum(xMatrix, 1);
    userViolation = sum(abs(userAssignments - 1));
    serverResources = sum(r .* xMatrix, 2);
    serverViolation = sum(max(0, serverResources - b));
    penalty = 1000 * (userViolation + serverViolation);
    fitness = totalUtility - penalty;
end

function parents = selectionRCGA(population, fitness, tournamentSize)
    popSize = size(population, 1);
    chromosomeLength = size(population, 2);
    parents = zeros(popSize, chromosomeLength);
    for i = 1:popSize
        candidates = randperm(popSize, tournamentSize);
        [~, bestIdx] = max(fitness(candidates));
        parents(i,:) = population(candidates(bestIdx),:);
    end
end

function offspring = crossoverRCGA(parents, crossoverProb)
    popSize = size(parents, 1);
    offspring = zeros(size(parents));
    for i = 1:2:popSize-1
        p1 = parents(i,:);
        p2 = parents(i+1,:);
        if rand < crossoverProb
            alpha = rand();
            c1 = alpha * p1 + (1 - alpha) * p2;
            c2 = alpha * p2 + (1 - alpha) * p1;
        else
            c1 = p1;
            c2 = p2;
        end
        offspring(i,:) = c1;
        offspring(i+1,:) = c2;
    end
end

function offspring = mutationRCGA(offspring, mutationProb)
    [rows, cols] = size(offspring);
    for i = 1:rows
        for j = 1:cols
            if rand < mutationProb
                offspring(i,j) = offspring(i,j) + 0.1 * randn();
            end
        end
    end
    offspring = max(min(offspring, 1), 0);
end

function [newPopulation, newFitness] = replacement(population, fitness, offspring, offspringFitness)
    combinedPop = [population; offspring];
    combinedFit = [fitness; offspringFitness];
    [sortedFit, sortIdx] = sort(combinedFit, 'descend');
    newPopulation = combinedPop(sortIdx(1:length(fitness)),:);
    newFitness = sortedFit(1:length(fitness));
end
