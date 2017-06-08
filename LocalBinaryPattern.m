function histo = LocalBinaryPattern(img)
    windowsSize = 3;
    %img = padding(windowsSize,img,fil,col);     %Agrega el padding necesario
    [fil, col] = size(img);
    img = padding(windowsSize, img, fil, col);
    [fil, col] = size(img);
    result = zeros(fil-2,col-2);
    for i = 2:fil-1
       for j = 2:col-1
          neighborhood = img(i-1:i+1, j-1:j+1);
          center = neighborhood(5);
          neighborhood = neighborhood';
          neighborhood = neighborhood(:)';
          neighborhood(5) = []; %Elimina del vector al elemento del centro
          neighborhood = neighborhood >= center;    %Realiza comparacion del centro con elementos
          powers2 = [7 6 5 0 4 1 2 3];
          powers2 = 2.^powers2';
          pixelValue = neighborhood*powers2;
          result(i-1,j-1) = pixelValue;
       end
    end
    histo = histograma(result);
    colormap('Gray');
    imagesc(result);
end

function histo = histograma(imagen)
    uniformes = [0; 1; 2; 3; 4; 6
        ;7; 8; 12; 14; 15; 16; 24; 28; 30
        ; 31; 32; 48; 56; 60; 62;63
        ; 64; 96; 112; 120; 124; 126; 127
        ; 128; 129; 131; 135;143; 159; 191; 192; 
        193; 195; 199; 207; 223; 224; 225;227; 231
        ; 239; 240; 241; 243; 247; 248; 249; 251
        ; 252;253; 254;255];
    histo = zeros(1,59);
    imagen = imagen(:);
    tamano = size(imagen);
    for i=1:tamano(1)
        if(any(imagen(i) == uniformes))
            histo(find(uniformes == imagen(i),1)) = histo(find(uniformes == imagen(i),1)) + 1;
        else
            histo(59) = histo(59) + 1;
        end
    end
    histo = histo./tamano(1);
end

function padding = padding(N, img, i, j)
    paddingI = double(zeros(i,(N-1)/2)); 
    imgPaddingI = [paddingI,img,paddingI];
    paddingJ = double(zeros((N-1)/2, j+(N-1)));
    padding = [paddingJ;imgPaddingI;paddingJ];
end