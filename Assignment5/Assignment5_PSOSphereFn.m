function pso_sphere()
    % Parameters
    nVars = 4;          % Number of variables (dimension)
    popSize = 50;       % Population size (swarm size)
    maxGen = 100;       % Maximum generations
    range = [-10, 10];  % Search range for each variable
    
    % PSO parameters
    w = 0.7;            % Inertia weight
    c1 = 1.5;           % Cognitive coefficient
    c2 = 1.5;           % Social coefficient
    
    % Initialize particles
    particles = (range(2) - range(1)) .* rand(popSize, nVars) + range(1);
    velocities = zeros(popSize, nVars);
    
    % Initialize personal bests
    personalBestPos = particles;
    personalBestFit = inf(popSize, 1);
    
    % Store best fitness per generation
    bestFitness = zeros(maxGen, 1);
    
    % Initial evaluation
    currentFit = sum(particles.^2, 2);
    personalBestFit = currentFit;
    [globalBestFit, globalBestIdx] = min(currentFit);
    globalBestPos = particles(globalBestIdx, :);
    
    for gen = 1:maxGen
        % Update velocities
        r1 = rand(popSize, nVars);
        r2 = rand(popSize, nVars);
        cognitive = c1 * r1 .* (personalBestPos - particles);
        social = c2 * r2 .* (globalBestPos - particles);
        velocities = w * velocities + cognitive + social;
        
        % Update positions
        particles = particles + velocities;
        
        % Apply bounds
        particles = max(min(particles, range(2)), range(1));
        
        % Evaluate fitness
        currentFit = sum(particles.^2, 2);
        
        % Update personal bests
        improvedIdx = currentFit < personalBestFit;
        personalBestPos(improvedIdx, :) = particles(improvedIdx, :);
        personalBestFit(improvedIdx) = currentFit(improvedIdx);
        
        % Update global best
        [minFit, minIdx] = min(currentFit);
        if minFit < globalBestFit
            globalBestFit = minFit;
            globalBestPos = particles(minIdx, :);
        end
        
        % Store best fitness
        bestFitness(gen) = globalBestFit;
    end
    
    % Display results
    fprintf('Best solution found:\n');
    fprintf('x = [');
    fprintf('%f ', globalBestPos);
    fprintf(']\n');
    fprintf('f(x) = %f\n', globalBestFit);
    
    % Plot convergence
    figure;
    plot(1:maxGen, bestFitness, 'LineWidth', 2);
    xlabel('Generation');
    ylabel('Best Fitness');
    title('Convergence of PSO on Sphere Function');
    grid on;
end