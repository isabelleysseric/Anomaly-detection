% Version Matlab : R2019b
% Systeme d'exploitation : Windows


% Nettoyage de l'espace de travail
clear all; 
close all;
clc;



% PARTIE I: INTERACTION UTILISATEUR

% 1. Lire l'image
img = imread('vertebre.png');

% 2. Afficher l'image
figure; imshow(img); title('Vertebre');

% 3. Saisir les coordonnées de la souris

    % 3.1. On a besoin d'un seul clic de souris
    [x,y] = ginput(1);
    
    % 3.2. Convertir les coordonnées x et y de double en uint16
    x = uint16(x);
    y = uint16(y);
    
    
    
% PARTIE II: SEGMENTATION PAR CROISSANCE DE RÉGION


% PRÉ-TRAITEMENT ET INITIALISATION DES DONNÉES

% 1. Filtrer l'image avec un filtre médian
imgf = medfilt2(img, [7 7]); 
    
% 2. Créer un élément structurant en forme de disque avec un rayon de 2
elemd2 = strel('disk', 2, 0);
    
% 3. Créer une image binaire seg initialisée à zéro qui contiendra la région de l'objet (ou segmentation). 
seg = imbinarize(zeros(size(img)));

% 4. Initialiser le point de départ de la croissance de région
seg(y,x) = 1;
    
% 5. Créer la variable 
seg_precedent = imbinarize(zeros(size(seg)));

% Variable d'affichage
dispMat = zeros(size(img)); 


% PROCESSUS ITÉRATIF DE SEGMENTATION

% Mettre la condition d'arrêt
while not(isequal(seg,seg_precedent))
    
    % 1. La variable seg est sauvegardée dans seg_precedent avant d'être mise à jour
    seg_precedent = seg; 

    % 2. Calculer les moments statistiques de la région segmentée

        % 2.1. Extraire les éléments intensite_region de l'image imgf
        intensite_region = imgf(seg == 1);

        % 2.2. Calculer la moyenne d'intensité des éléments de intensite_region
        m_region = mean(intensite_region);

        % 2.3. Calculer l'écart type des intensités des éléments de intensite_region
        std_region = std(double(intensite_region));
  
    % 3. Trouver le voisinage de la région segmentée

        % 3.1. Dilater l'image seg avec l'élément structurant elemd2
        seg_dilate = imdilate(seg, elemd2);

        % 3.2. Soustraire seg au résultat de la dilatation seg_dilate
        contour = seg_dilate - seg;

        % 3.3. Trouver les indices des éléments de contour
        ind = find(contour);
        
    % 4. Calculer la similarité entre les intensités des pixels du voisinage et la moyenne d'intensité de la région segmentée
     delta = 12;

        % 4.1. Calculer la borne inférieure de l'intervalle
        binf = m_region - (std_region + delta);

        % 4.2. Calculer la borne supérieure de l'intervalle
        bsup = m_region + (std_region + delta);

        % 4.3. Trouver les pixels qui satisfont la condition d'infériorité
        %      Parmi les pixels candidats du contour
        inf_seg = ind(imgf(ind) > binf);

        % 4.4. Trouver les pixels qui satisfont la condition de supériorité parmi les pixels candidats du contour
        sup_seg = ind(imgf(ind) < bsup);
        
        % 4.5. Trouver les indices des pixels qui satisfont les deux conditions à la fois, (càd le critère de similarité)
		candidats = intersect(inf_seg, sup_seg);
        
    % 5. Mettre à jour l'image seg, (càd mettre tous les pixels candidats à 1 dans la variable seg)
    seg(candidats) = 1;
    
    % 6. Afficher le résultat intermédiaire (optionnel) 
    dispMat = img;
    dispMat(seg) = 0;
    RGB = cat(3,uint8(seg)*255+dispMat,dispMat,dispMat);
    imshow(RGB, [])
    drawnow % Rafraîchir l'affichage

        % 6.1 Afficher l'image
        imshow(img);

        % 6.2 Afficher le résultat de la région à l'itération courante seg
        imshow(seg_precedent);
       
end


% POST-TRAITEMENT DE LA SEGMENTATION

% 1. Créer un élément structurant disque de rayon 5
elemd5 = strel('disk', 5, 0);

% 2. Effectuer une opération de fermeture sur l'image seg
imclose(seg, elemd5);    

% 3. Affichage du résultat final
dispMat = img;
dispMat(seg) = 0;
RGB = cat(3,uint8(seg)*255+dispMat,dispMat,dispMat);
imshow(RGB, [])



% PARTIE III: MESURES ANATOMIQUES DE LA VERTÈBRE

% 1. Trouver les coordonnées [x, y] de tous les pixels appartenant à la vertèbre
[y,x] = find(seg == 1);

% 2. Calculer la coordonnée xmin la plus petite en x
xmin = min(min(x));

% 3. Calculer la coordonnée xmax la plus grande en x
xmax = max(max(x));

% 4. Calculer l'écart dx entre xmax et xmin
dx = xmax - xmin;

% 5. Calculer la coordonnée ymin la plus petite en y
ymin = min(min(y));

% 6. Calculer la coordonnée ymax la plus grande en y
ymax = max(max(y));

% 7. Calculer l'écart dy entre ymax et ymin
dy = ymax - ymin;

% 8. Convertir les calculs en millimètres

    % 8.1. Pour calculer la largeur
    largeur = (dx * 0.35) / 1;
        
    % 8.2. Pour calculer la hauteur
    hauteur = (dy * 0.35) / 1;
    
% 9. Afficher les valeurs de hauteur et de largeur
fprintf('La hauteur de la vertebre est: %.2f\n...La largeur de la vertebre est: %.2f\n', hauteur, largeur);
