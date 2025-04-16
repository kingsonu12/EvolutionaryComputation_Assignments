function realGA_sphere()
    % Parameters
    nVars = 4;          % Number of variables (dimension)
    popSize = 50;       % Population size
    maxGen = 100;       % Maximum generations
    pc = 0.8;           % Crossover probability
    pm = 0.2;           % Mutation probability per variable
    range = [-10, 10];  % Search range for each variable

    % Initialize population (real values within range)
    pop = (range(2) - range(1)) .* rand(popSize, nVars) + range(1);
    
    % Store best fitness per generation
    bestFitness = zeros(maxGen, 1);

    for gen = 1:maxGen
        % Evaluate fitness (Sphere function)
        fitness = sum(pop.^2, 2);

        % Store best fitness
        bestFitness(gen) = min(fitness);

        % Tournament selection
        parents = tournamentSelectionReal(pop, fitness, popSize);

        % Crossover (Blend Crossover - BLX-alpha)
        offspring = blendCrossover(parents, pc, range);

        % Mutation (Gaussian mutation)
        offspring = gaussianMutation(offspring, pm, range);

        % Elitism: Keep best individual
        [~, bestIdx] = min(fitness);
        offspring(1,:) = pop(bestIdx,:);

        % Update population
        pop = offspring;
    end

    % Final evaluation
    fitness = sum(pop.^2, 2);
    [bestFit, bestIdx] = min(fitness);
    bestVars = pop(bestIdx,:);

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
    title('Convergence of Real Coded GA on Sphere Function');
    grid on;
end

function parents = tournamentSelectionReal(pop, fitness, popSize)
    parents = zeros(size(pop));
    tournamentSize = 2;

    for i = 1:popSize
        idx = randperm(popSize, tournamentSize);
        [~, bestIdx] = min(fitness(idx));
        parents(i,:) = pop(idx(bestIdx), :);
    end
end

function offspring = blendCrossover(parents, pc, range)
    alpha = 0.5;
    n = size(parents,1);
    nVars = size(parents,2);
    offspring = parents;

    for i = 1:2:n-1
        if rand < pc
            x1 = parents(i,:);
            x2 = parents(i+1,:);
            d = abs(x1 - x2);
            lower = min(x1, x2) - alpha * d;
            upper = max(x1, x2) + alpha * d;

            child1 = lower + rand(1,nVars) .* (upper - lower);
            child2 = lower + rand(1,nVars) .* (upper - lower);

            % Clamp to range
            offspring(i,:) = max(min(child1, range(2)), range(1));
            offspring(i+1,:) = max(min(child2, range(2)), range(1));
        end
    end
end

function mutated = gaussianMutation(pop, pm, range)
    sigma = 0.1 * (range(2) - range(1));  % Standard deviation
    mutationMask = rand(size(pop)) < pm;
    noise = sigma * randn(size(pop));
    mutated = pop + mutationMask .* noise;
    mutated = max(min(mutated, range(2)), range(1)); % Clamp
end
