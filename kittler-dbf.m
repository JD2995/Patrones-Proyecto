function Ejercicio1()
    %Kittler('test1.jpg');
    Kittler('test3.jpg');
    %Kittler('test3.bmp');
    %Kittler('test4.jpg');
    %Kittler('test5.bmp');
    %Kittler('test6.jpg');
    %Kittler('test8.jpg');
end

function Kittler(pathImagen)
    imagenOriginal = imread(pathImagen);
    imagen = rgb2gray(imagenOriginal);
    imagen = double(imagen);
    figure;
    imagesc(uint8(imagen));
    hist = histograma(imagen);
    figure;
    plot(hist);
    arrVerosi = zeros(1,255);
    for i=1:255
        arrVerosi(i) = verosimilitud(hist,i);
    end
    figure;
    bar(arrVerosi);
    minimo = min(arrVerosi);
    disp(minimo);
    minimos = find(ismember(arrVerosi,minimo));
    result = minimos(1);
    desv1 = varianza(hist,result,1);
    desv2 = varianza(hist,result,2);
    med1 = media(hist,result,1);
    med2 = media(hist,result,2);
    mitad1 = sum(hist(1:result));
    mitad2 = sum(hist(result:255));
    if(mitad1<mitad2)
        umbralizada = umbralizacion(imagen,result,1);
    else
        umbralizada = umbralizacion(imagen,result,2);
    end
    figure;
    imshow(umbralizada);
    figure;
    imagenOriginal(:,:,1) = imagenOriginal(:,:,1) .* uint8(umbralizada);
    imagenOriginal(:,:,2) = imagenOriginal(:,:,2) .* uint8(umbralizada);
    imagenOriginal(:,:,3) = imagenOriginal(:,:,3) .* uint8(umbralizada);
    imshow(imagenOriginal);
    imagen = rgb2gray(imagenOriginal);
    imagen = double(imagen);
    windowSize = 29;
    [i,j] = size(imagen);
    imagen = bilateral(imagen, windowSize, i, j);
    imagesc(uint8(imagen));
end

function result = umbralizacion(imagen,T,mitad)
    if(mitad == 1)
        result = imagen < T;
    else
        result = imagen > T;
    end
end

function histo = histograma(imagen)
    histo = zeros(1,256);
    imagen = imagen(:);
    imagen = round(imagen);
    imagen = uint32(imagen);
    tamano = size(imagen);
    for i=1:tamano(1)
        histo(imagen(i)+1) = histo(imagen(i)+1)+1;
    end
    histo = histo./tamano(1);
end

function result = verosimilitud(hist,T)
    p1 = pMarginal(hist,T,1);
    p2 = pMarginal(hist,T,2);
    desv1 = sqrt(varianza(hist,T,1));
    desv2 = sqrt(varianza(hist,T,2));
    result = 1+2*(p1*log(desv1+eps)+p2*log(desv2+eps)) -2*(p1*log(p1)+p2*log(p2));
end

function result = pMarginal(hist,T,i)
    if(i == 1)
       seccion = hist(1:T+1);
    else
        seccion = hist(T:256);
    end
    result = sum(seccion);
end

function result = varianza(hist,T,i)
    if(i == 1)
        a = 1;
        b = T+1;
    else
        a = T;
        b = 256;
    end
    seccion = hist(a:b).*(((a-1:b-1)-media(hist,T,i)).^2);
    result = sum(seccion)/pMarginal(hist,T,i);
end

function result = media(hist,T,i)
    if(i == 1)
        a = 1;
        b = T+1;
    else
        a = T;
        b = 256;
    end
    seccion = hist(a:b).*(a-1:b-1);
    result = sum(seccion)/pMarginal(hist,T,i);
end




function imgFDB = bilateral(img, windowSize, i, j)
    colormap('Gray');
    imgPadding = padding(windowSize, img, i, j);
    imgFDB = filtroDeceivedBilateral(windowSize, imgPadding, 12, i, j);
    imagesc(uint8(imgFDB));
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
