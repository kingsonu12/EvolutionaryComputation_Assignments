function plotGAP12Comparison()
    % File paths
    optimalFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment1/gap_results_optimal.csv';
    approxFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment2/gap_results_approx.csv';
    gaFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment3/gap_results_bcga.csv';
    rcgaFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment4/gap_results_rcga.csv';
    psoFile = 'C:/Users/akkid/Desktop/New Assignments/Assignment5/gap_results_pso.csv';

    try
        % Read and validate data
        optimalData = readAndValidateData(optimalFile);
        approxData = readAndValidateData(approxFile);
        gaData = readAndValidateData(gaFile);
        rcgaData = readAndValidateData(rcgaFile);
        psoData = readAndValidateData(psoFile);

        % Check structure consistency
        if ~isequal(optimalData(1,:), approxData(1,:), gaData(1,:), rcgaData(1,:), psoData(1,:)) || ...
           ~isequal(optimalData(:,1), approxData(:,1), gaData(:,1), rcgaData(:,1), psoData(:,1))
            error('File structures do not match. Cannot compare results.');
        end

        % Extract case numbers
        caseNumbers = cellfun(@(x) str2double(x(6:end)), optimalData(2:end,1));
        numCases = length(caseNumbers);
        numProblems = size(optimalData, 2) - 1;

        % Convert result data to numeric matrices
        [optimalResults, valid1] = convertToNumericMatrix(optimalData(2:end,2:end));
        [approxResults, valid2] = convertToNumericMatrix(approxData(2:end,2:end));
        [gaResults, valid3] = convertToNumericMatrix(gaData(2:end,2:end));
        [rcgaResults, valid4] = convertToNumericMatrix(rcgaData(2:end,2:end));
        [psoResults, valid5] = convertToNumericMatrix(psoData(2:end,2:end));

        if ~all(valid1(:)) || ~all(valid2(:)) || ~all(valid3(:)) || ~all(valid4(:)) || ~all(valid5(:))
            warning('Some values could not be converted to numbers. Results may be incomplete.');
        end

        %% GAP12 Comparison (first 5 instances)
        gap12Idx = 12;
        numInstancesToShow = min(5, numCases);

        gap12Optimal = optimalResults(1:numInstancesToShow, gap12Idx);
        gap12Approx = approxResults(1:numInstancesToShow, gap12Idx);
        gap12GA = gaResults(1:numInstancesToShow, gap12Idx);
        gap12RCGA = rcgaResults(1:numInstancesToShow, gap12Idx);
        gap12PSO = psoResults(1:numInstancesToShow, gap12Idx);

        % Plotting
        figure('Name', 'GAP12 Comparison (First 5 Instances)', 'Position', [100, 100, 1000, 550]);
        x = 1:numInstancesToShow;
        barData = [gap12Optimal, gap12Approx, gap12GA, gap12RCGA, gap12PSO];
        hBar = bar(x, barData, 'grouped');

        % Custom bar colors
        hBar(1).FaceColor = [0, 0.4470, 0.7410];   % Blue (Optimal)
        hBar(2).FaceColor = [0.8500, 0.3250, 0.0980]; % Orange (Approx)
        hBar(3).FaceColor = [0.4660, 0.6740, 0.1880]; % Green (BCGA)
        hBar(4).FaceColor = [0.4940, 0.1840, 0.5560]; % Purple (RCGA)
        hBar(5).FaceColor = [0.9290, 0.6940, 0.1250]; % Yellow (PSO)

        % Add value labels
        for i = 1:numInstancesToShow
            text(x(i)-0.36, gap12Optimal(i)+5, num2str(gap12Optimal(i), '%.1f'), 'FontSize', 9);
            text(x(i)-0.18, gap12Approx(i)+5, num2str(gap12Approx(i), '%.1f'), 'FontSize', 9);
            text(x(i), gap12GA(i)+5, num2str(gap12GA(i), '%.1f'), 'FontSize', 9);
            text(x(i)+0.18, gap12RCGA(i)+5, num2str(gap12RCGA(i), '%.1f'), 'FontSize', 9);
            text(x(i)+0.36, gap12PSO(i)+5, num2str(gap12PSO(i), '%.1f'), 'FontSize', 9);
        end

        % Labels & Title
        title('Performance Comparison for GAP12 (First 5 Instances)', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel('Instance Number', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Objective Value', 'FontSize', 12, 'FontWeight', 'bold');

        % X-Axis setup
        xticks(x);
        xticklabels(arrayfun(@(n) sprintf('Instance %d', n), x, 'UniformOutput', false));

        % Legend
        legend({'Optimal', 'Approximation', 'Binary Coded GA', 'Real Coded GA', 'PSO'}, ...
            'Location', 'southeast', 'FontSize', 10);

        grid on;
        set(gca, 'FontSize', 11);
        set(gcf, 'Color', 'w');

        % Adjust y-axis limits to accommodate value labels
        ylim([0 max(barData(:))*1.15]);

        % Save the figure
        savePath = 'C:/Users/akkid/Desktop/New Assignments/Assignment5/gap12_comparison_all.png';
        saveas(gcf, savePath);
        fprintf('Gap12 comparison graph saved as %s\n', savePath);

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