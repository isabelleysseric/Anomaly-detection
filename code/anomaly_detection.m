% Isabelle EYSSERIC
% Matricule : 17243571
% Version Matlab : R2019b
% Systeme d'exploitation : Windows

import matlab.engine

% Nettoyage de l'espace de travail
clear all; 
close all;
clc;



% PARTIE I: INTERACTION UTILISATEUR

% 1. Lire l'image
img = imread('./data/vertebre.png');

% 2. Afficher l'image
figure; imshow(img); title('Vertebre');

% 3. Saisir les coordonn�es de la souris

    % 3.1. On a besoin d'un seul clic de souris
    [x,y] = ginput(1);
    
    % 3.2. Convertir les coordonn�es x et y de double en uint16
    x = uint16(x);
    y = uint16(y);
    
    
    
% PARTIE II: SEGMENTATION PAR CROISSANCE DE R�GION


% PR�-TRAITEMENT ET INITIALISATION DES DONN�ES

% 1. Filtrer l'image img avec un filtre m�dian
imgf = medfilt2(img, [7 7]); 
    
% 2. Cr�er un �l�ment structurant en forme de disque avec un rayon de 2
elemd2 = strel('disk', 2, 0);
    
% 3. Cr�er une image binaire seg initialis�e � z�ro qui contiendra la
%    r�gion de l'objet (ou segmentation). 
seg = imbinarize(zeros(size(img)));

% 4. Initialiser le point de d�part de la croissance de r�gion
seg(y,x) = 1;
    
% 5. Cr�er la variable seg_precedent
seg_precedent = imbinarize(zeros(size(seg)));

% Variable d'affichage
dispMat = zeros(size(img)); 


% PROCESSUS IT�RATIF DE SEGMENTATION

% Mettre la condition d'arr�t
while not(isequal(seg,seg_precedent))
    
    % 1. La variable seg est sauvegard�e dans seg_precedent avant d'�tre mise � jour
    seg_precedent = seg; 

    % 2. Calculer les moments statistiques de la r�gion segment�e

        % 2.1. Extraire les �l�ments intensite_region de l'image imgf
        intensite_region = imgf(seg == 1);

        % 2.2. Calculer la moyenne d'intensit� des �l�ments de intensite_region
        m_region = mean(intensite_region);

        % 2.3. Calculer l'�cart type des intensit�s des �l�ments de intensite_region
        std_region = std(double(intensite_region));
  
    % 3. Trouver le voisinage de la r�gion segment�e

        % 3.1. Dilater l'image seg avec l'�l�ment structurant elemd2
        seg_dilate = imdilate(seg, elemd2);

        % 3.2. Soustraire seg au r�sultat de la dilatation seg_dilate
        contour = seg_dilate - seg;

        % 3.3. Trouver les indices des �l�ments de contour
        ind = find(contour);
        
    % 4. Calculer la similarit� entre les intensit�s des pixels du voisinage
    %    et la moyenne d'intensit� de la r�gion segment�e
     delta = 12;

        % 4.1. Calculer la borne inf�rieure de l'intervalle
        binf = m_region - (std_region + delta);

        % 4.2. Calculer la borne sup�rieure de l'intervalle
        bsup = m_region + (std_region + delta);

        % 4.3. Trouver les pixels qui satisfont la condition d'inf�riorit�
        %      Parmi les pixels candidats du contour
        inf_seg = ind(imgf(ind) > binf);

        % 4.4. Trouver les pixels qui satisfont la condition de sup�riorit�
        %      Parmi les pixels candidats du contour
        sup_seg = ind(imgf(ind) < bsup);
        
        % 4.5. Trouver les indices des pixels qui satisfont les deux conditions
        %      � la fois, (c�d le crit�re de similarit�)
		candidats = intersect(inf_seg, sup_seg);
        
    % 5. Mettre � jour l'image seg, 
    %    (c�d mettre tous les pixels candidats � 1 dans la variable seg)
    seg(candidats) = 1;
    
    % 6. Afficher le r�sultat interm�diaire (optionnel) 
    dispMat = img;
    dispMat(seg) = 0;
    RGB = cat(3,uint8(seg)*255+dispMat,dispMat,dispMat);
    imshow(RGB, [])
    drawnow % Rafra�chir l'affichage

        % 6.1 Afficher l'image img
        imshow(img);

        % 6.2 Afficher le r�sultat de la r�gion � l'it�ration courante seg
        imshow(seg_precedent);
       
end


% POST-TRAITEMENT DE LA SEGMENTATION

% 1. Cr�er un �l�ment structurant disque de rayon 5
elemd5 = strel('disk', 5, 0);

% 2. Effectuer une op�ration de fermeture sur l'image seg
imclose(seg, elemd5);    

% 3. Affichage du r�sultat final
dispMat = img;
dispMat(seg) = 0;
RGB = cat(3,uint8(seg)*255+dispMat,dispMat,dispMat);
imshow(RGB, [])



% PARTIE III: MESURES ANATOMIQUES DE LA VERT�BRE

% 1. Trouver les coordonn�es [x, y] de tous les pixels appartenant � la vert�bre
[y,x] = find(seg == 1);

% 2. Calculer la coordonn�e xmin la plus petite en x
xmin = min(min(x));

% 3. Calculer la coordonn�e xmax la plus grande en x
xmax = max(max(x));

% 4. Calculer l'�cart dx entre xmax et xmin
dx = xmax - xmin;

% 5. Calculer la coordonn�e ymin la plus petite en y
ymin = min(min(y));

% 6. Calculer la coordonn�e ymax la plus grande en y
ymax = max(max(y));

% 7. Calculer l'�cart dy entre ymax et ymin
dy = ymax - ymin;

% 8. Convertir les calculs en millim�tres

    % 8.1. Pour calculer la largeur
    largeur = (dx * 0.35) / 1;
        
    % 8.2. Pour calculer la hauteur
    hauteur = (dy * 0.35) / 1;
    
% 9. Afficher les valeurs de hauteur et de largeur
fprintf('La hauteur de la vertebre est: %.2f\n...La largeur de la vertebre est: %.2f\n', hauteur, largeur);

