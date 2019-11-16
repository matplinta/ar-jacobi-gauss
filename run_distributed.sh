#!/bin/bash -l
##Nazwa zlecenia
#SBATCH -J Proj1AR
## Liczba alokowanych węzłów
#SBATCH -N 12
## Liczba zadań per węzeł (domyślnie jest to liczba alokowanych rdzeni na węźle)
#SBATCH --ntasks-per-node=1
## Ilość pamięci przypadającej na jeden rdzeń obliczeniowy (domyślnie 4GB na rdzeń)
#SBATCH --mem-per-cpu=1GB
## Maksymalny czas trwania zlecenia (format HH:MM:SS)
#SBATCH --time=20:0:0 
## Nazwa grantu do rozliczenia zużycia zasobów
## Specyfikacja partycji
#SBATCH -p plgrid
## Plik ze standardowym wyjściem
#SBATCH --output="distributed.csv"
## Plik ze standardowym wyjściem błędów
#SBATCH --error="dist_error.err"
 
module load plgrid/tools/chapel/1.20.0
export  GASNET_PHYSMEM_MAX='128MB'

## go to execution dir
cd $SLURM_SUBMIT_DIR

chpl -o jacobi_distributed jacobi_distributed.chpl
chpl -o gauss_distributed gauss_distributed.chpl

echo "method,iterations,problem,locales,tasks,tasksPerLocale,time"

for n_nodes in {1..12}
do
    for i in 100 150 200
    do
        ./jacobi_distributed -nl $n_nodes --n=$i
        ./gauss_distributed -nl $n_nodes --n=$i
    done
done


