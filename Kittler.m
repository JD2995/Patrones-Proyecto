function umbralizada = Kittler(imagen)
    hist = histograma(imagen);
    arrVerosi = zeros(1,255);
    for i=1:255
        arrVerosi(i) = verosimilitud(hist,i);
    end
    minimo = min(arrVerosi);
    minimos = find(ismember(arrVerosi,minimo));
    result = minimos(1);
    desv1 = varianza(hist,result,1);
    desv2 = varianza(hist,result,2);
    med1 = media(hist,result,1);
    med2 = media(hist,result,2);
    umbralizada = umbralizacion(imagen,result);
    umbralizada = imagen.*uint8(umbralizada);
end

function result = umbralizacion(imagen,T)
    result = imagen < T;
end

function histo = histograma(imagen)
    histo = zeros(1,256);
    imagen = imagen(:);
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