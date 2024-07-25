% Genera dimensioni casuali per la matrice
rows = randi([1, 100]);  % Numero di righe casuale tra 1 e 10
cols = randi([1, 100]);  % Numero di colonne casuale tra 1 e 10

% Crea una matrice casuale di interi
A = randi([1, 100], rows, cols);  % Matrice con valori casuali tra 1 e 100
filename = 'matriceA.txt';

% Specifica il nome del file di output
fileID = fopen(filename, 'w');

% Scrivi ogni elemento della matrice su una riga separata
for i = 1:rows
    for j = 1:cols
        fprintf(fileID, '%d\n', A(i, j));
    end
end

% Chiudi il file
fclose(fileID);

% Messaggio di conferma
disp(['Matrice A casuale di dimensioni ', num2str(rows), 'x', num2str(cols), ' salvata nel file ', filename]);
B = randi([1, 100], rows, cols);  % Matrice con valori casuali tra 1 e 100

% Specifica il nome del file di output
filename = 'matriceB.txt';

% Scrive la matrice su un file di testo
fileID = fopen(filename, 'w');
for i = 1:rows
    for j = 1:cols
        fprintf(fileID, '%d\n', B(i, j));
    end
end
% Messaggio di conferma
disp(['Matrice B casuale di dimensioni ', num2str(rows), 'x', num2str(cols), ' salvata nel file ', filename]);


