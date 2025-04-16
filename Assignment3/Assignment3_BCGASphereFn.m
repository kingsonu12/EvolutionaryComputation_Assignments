function binaryGA_sphere()
    % Parameters
    nVars = 4;          % Number of variables (dimension)
    popSize = 50;       % Population size
    maxGen = 100;       % Maximum generations
    pc = 0.8;           % Crossover probability
    pm = 0.01;          % Mutation probability per bit
    bitLength = 20;     % Bits per variable
    range = [-10, 10];  % Search range for each variable
    
    % Initialize population
    pop = randi([0 1], popSize, nVars*bitLength);
    
    % Store best fitness per generation
    bestFitness = zeros(maxGen, 1);
    
    % Main GA loop
    for gen = 1:maxGen
        % Decode and evaluate fitness
        fitness = evaluatePopulation(pop, bitLength, range);
        
        % Store best fitness
        bestFitness(gen) = min(fitness);
        
        % Selection (Tournament selection)
        parents = tournamentSelection(pop, fitness, popSize);
        
        % Crossover (Single-point crossover)
        offspring = crossover(parents, pc, bitLength);
        
        % Mutation (Bit-flip mutation)
        offspring = mutation(offspring, pm);
        
        % Elitism: Keep best individual
        [~, bestIdx] = min(fitness);
        offspring(1,:) = pop(bestIdx,:);
        
        % Update population
        pop = offspring;
    end
    
    % Final evaluation
    fitness = evaluatePopulation(pop, bitLength, range);
    [bestFit, bestIdx] = min(fitness);
    bestInd = pop(bestIdx,:);
    bestVars = binaryToReal(bestInd, bitLength, range);
    
    % Display results
    fprintf('Best solution found:\n');
    fprintf('x = [');
    fprintf('%f ', bestVars);
    fprintf(']\n');
    fprintf('f(x) = %f\n', bestFit);
    
    % Plot convergence
    figure;
    plot(1:maxGen, bestFitness, 'LineWidth', 2);
    xlabel('Generation');
    ylabel('Best Fitness');
    title('Convergence of Binary GA on Sphere Function');
    grid on;
end

function fitness = evaluatePopulation(pop, bitLength, range)
    popSize = size(pop, 1);
    nVars = size(pop, 2)/bitLength;
    fitness = zeros(popSize, 1);
    
    for i = 1:popSize
        % Convert binary to real values
        vars = binaryToReal(pop(i,:), bitLength, range);
        
        % Evaluate Sphere function
        fitness(i) = sum(vars.^2);
    end
end

function realVars = binaryToReal(binaryStr, bitLength, range)
    nVars = length(binaryStr)/bitLength;
    realVars = zeros(1, nVars);
    
    for i = 1:nVars
        % Extract bits for this variable
        bits = binaryStr((i-1)*bitLength+1 : i*bitLength);
        
        % Convert binary string to decimal integer
        intVal = bin2dec(num2str(bits));
        
        % Map to real value in specified range
        realVars(i) = range(1) + intVal*(range(2)-range(1))/(2^bitLength-1);
    end
end

function parents = tournamentSelection(pop, fitness, popSize)
    parents = zeros(size(pop));
    tournamentSize = 2; % Tournament size
    
    for i = 1:popSize
        % Randomly select tournament participants
        contestants = randperm(popSize, tournamentSize);
        
        % Find the best one
        [~, bestIdx] = min(fitness(contestants));
        parents(i,:) = pop(contestants(bestIdx),:);
    end
end

function offspring = crossover(parents, pc, bitLength)
    offspring = parents;
    nVars = size(parents, 2)/bitLength;
    
    for i = 1:2:size(parents,1)-1
        if rand < pc
            % Select crossover point (between variables)
            xPoint = randi([1 nVars-1])*bitLength;
            
            % Perform crossover
            offspring(i,:) = [parents(i,1:xPoint), parents(i+1,xPoint+1:end)];
            offspring(i+1,:) = [parents(i+1,1:xPoint), parents(i,xPoint+1:end)];
        end
    end
end

function offspring = mutation(offspring, pm)
    % Flip bits with probability pm
    mutationMask = rand(size(offspring)) < pm;
    offspring = xor(offspring, mutationMask);
end