function imgFDB = bilateral(imgGS)
    windowSize = 29;
    [i,j] = size(imgGS);
    imgPadding = padding(windowSize, imgGS, i, j);
    imgFDB = filtroDeceivedBilateral(windowSize, imgPadding, 12, i, j);
%     maxx = max(imgFDB(:));
%     imgFDB = imgFDB/maxx;
%     imgFDB = imgFDB*255;
    imgFDB = uint8(imgFDB);
end

function imgUSM = USM(img, lambda)
    kernelLaplaciano = [-1 -1 -1; -1 8 -1 ; -1 -1 -1];
    convImg = conv2(img, kernelLaplaciano, 'same');
    imgUSM = img + lambda*convImg;    
end

function padding = padding(N, img, i, j)
    paddingI = double(zeros(i,(N-1)/2)); 
    imgPaddingI = [paddingI,img,paddingI];
    paddingJ = double(zeros((N-1)/2, j+(N-1)));
    padding = [paddingJ;imgPaddingI;paddingJ];
end

function bilateralImg = filtroDeceivedBilateral(N, img, sigmaR, imgSizeI, imgSizeJ)
    bilateralImg = double(zeros(imgSizeI, imgSizeJ));
    sigmaS = (N-1)/4;
    minI = (N-1)/2 + 1;
    maxI = imgSizeI+minI-1;
    minJ = (N-1)/2 + 1;
    maxJ = imgSizeJ+minJ-1;
    space = spaceDimWeight((N-1)/2, sigmaS);
    for i = minI:maxI
        for j = minJ:maxJ
            intensityDimension = img(i-(minI-1):i+(minI-1), j-(minJ-1):j+(minJ-1));
            imgUSM = USM(intensityDimension, 2);
            bilateralPixel = pixelFiltering(img(i,j), intensityDimension, space, sigmaR, imgUSM);
            bilateralImg(i-(minI-1), j-(minJ-1)) = bilateralPixel;
        end
    end
    
end


function pixelBilateral = pixelFiltering(pixel, windowI, spaceWeight, sigmaR, windowUSM)
    intensity = intensityWeight(pixel, windowI, sigmaR);
    weight = spaceWeight .* intensity;
    pixelBilateral = sum(sum(windowUSM .* weight));
    pixelBilateral = pixelBilateral / sum(sum(weight));
end

function spaceDim = spaceDimWeight(N, sigmaS)
    [X,Y] = meshgrid(-N:N, -N:N);
    argumento = -(X.^2 + Y.^2);
    spaceDim = exp(argumento/(2*(sigmaS)^2));
end

function intensityDim = intensityWeight(pixelImg, intensityWindow, sigmaR)
    pixelDistance = -(intensityWindow - pixelImg).^2;
    intensityDim = exp(pixelDistance/(2*(sigmaR)^2));
end
