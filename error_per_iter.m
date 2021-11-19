function [errors, times] = error_per_iter(originalModel, transformedModel, triesPerIter, maxTraslation, maxRotation, maxIterationsVector)
    errors = zeros(triesPerIter, length(maxIterationsVector));
    times = zeros(triesPerIter, length(maxIterationsVector));
    for t = 1:triesPerIter
        rotX = round(rand(1, maxRotation), 0);
        rotY = round(rand(1, maxRotation), 0);
        rotZ = round(rand(1, maxRotation), 0);

        trsX = rand(1, maxTraslation);
        trsY = rand(1, maxTraslation);
        trsZ = rand(1, maxTraslation);

        columnIndex = 1;
        for maxIter = maxIterationsVector
            fprintf('Try:%d MaxIteration:%d  \n', t, maxIter);
            fprintf('ROTATION x:%f° y:%f° z:%f° \n', rotX, rotY, rotZ);
            fprintf('TRASLATION x:%3f y:%3f z:%3f \n', trsX, trsY, trsZ);

            originalCloud = pcread(originalModel);
            transformedCloud = pcread(transformedModel);

            initialTransformation = transformation_matrix(deg2rad(rotX), deg2rad(rotY), deg2rad(rotZ), trsX, trsY, trsZ);
            ptCloudTransformed = pctransform(transformedCloud, initialTransformation);
            
            tic;
            [~, ~, rmse] = pcregistericp(ptCloudTransformed, originalCloud, 'Metric', 'pointToPoint', 'MaxIterations', maxIter, 'Tolerance', [0.0001, 0.0005]);
            elapsedTime = toc;
            % tic + toc return elapsed time in seconds
            elapsedTime = elapsedTime * 1000;

            fprintf('Error: %f Time[ms]: %f \n\n', rmse, elapsedTime);
            errors(t, columnIndex) = rmse;
            times(t, columnIndex) = elapsedTime;
            columnIndex = columnIndex + 1;
        end
    end
end