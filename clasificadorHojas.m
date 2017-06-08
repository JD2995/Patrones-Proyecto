function clasificadorHojas(isMadeData, isFiltered)
    if(isMadeData)
        [X,T] = procesarDatos(isFiltered);
    end
    if(isFiltered)
        load('datosConDBF.mat');
    else
        load('datosSinDBF.mat');
    end
    X = X';
    T = T';
    [Xtrain, Xvalid, Ttrain, Tvalid] = generarDatosPruebas(X, T);
%     net = perceptron;
%     net.trainParam.epochs=10000;
%     net.trainParam.lr = 0.001;
%     net = train(net,Xtrain,Ttrain);
%     
%     y = net(Xvalid);
%     porcentaje = validarPorcentaje(y,Tvalid)
%     y = net(Xtrain);
%     porcentaje = validarPorcentaje(y,Ttrain)
    
    net = feedforwardnet(59);
    net.trainParam.max_fail = 10000;
    net.trainParam.epochs=10000;
    net.trainParam.min_grad = 1e-12;
    net = train(net,Xtrain,Ttrain,'useGPU', 'yes');
    y = abs(round(net(Xvalid)));
    porcentaje = validarPorcentaje(y,Tvalid)
    y = abs(round(net(Xtrain)));
    porcentaje = validarPorcentaje(y,Ttrain)
end

function porcentaje = validarPorcentaje(Y, T)
    [~, col] = size(Y);
    cantAcertadas = 0;
    for i = 1:col
        if isequal(Y(:,i),T(:,i))
           cantAcertadas = cantAcertadas + 1; 
        end
    end
    porcentaje = cantAcertadas/col;
end

function [Xtrain, Xvalid, Ttrain, Tvalid] = generarDatosPruebas(X, T)
    [~, cantDatos] = size(X);
    indRand = randperm(cantDatos);
    cantPruebas = floor(cantDatos*0.8);
    indPruebas = indRand(1:cantPruebas);
    indValidacion = indRand(cantPruebas+1:cantDatos);
    %Datos de pruebas
    Xtrain = X(:,indPruebas);
    Ttrain = T(:,indPruebas);
    %Datos de validacion
    Xvalid = X(:,indValidacion);
    Tvalid = T(:,indValidacion);
end

function [X,T] = procesarDatos(isFiltered)
    path = {'All_CR_Leaves_Cleaned\Aegiphila valerioi\';'All_CR_Leaves_Cleaned\Bauhinia ungulata\';
        'All_CR_Leaves_Cleaned\Bixa orellana\';'All_CR_Leaves_Cleaned\Ficus pumila\';
        'All_CR_Leaves_Cleaned\Morus alba\'};
    cantClases = length(path);
    X = [];
    T = [];
    for p = 1:cantClases       
        imagefiles = dir(strcat(path{p},'*.jpg'));
        nfiles = length(imagefiles);
        for i = 1:nfiles
            currentfilename = imagefiles(i).name;
            currentimage = imread(strcat(path{p},currentfilename));
            img = rgb2gray(currentimage);
            fil = 150;
            col = 375;
            img = imresize(img, [fil col]);     %Normaliza el tamanno de la imagen
            %Segmenta la imagen con Kittler
            img = Kittler(img);
            %Aplica el filtro DBF
            img = double(img);
            windowSize = 29;
            [i,j] = size(img);
            %Si se filtra con el DBF
            if(isFiltered)
                img = bilateral(img);
            end
            X = [X ; LocalBinaryPattern(img)];
            T = [T ; generarKClases(cantClases,p)];
        end 
    end
    if(isFiltered)
       save('datosConDBF.mat','X','T');
    else
       save('datosSinDBF.mat','X','T'); 
    end
end

function t = generarKClases(cantClases, clase)
    t = zeros(1,cantClases);
    t(clase) = 1;
end

    