#!/bin/bash -l
##Nazwa zlecenia
#SBATCH -J Proj1AR
## Liczba alokowanych węzłów
#SBATCH -N 1
## Liczba zadań per węzeł (domyślnie jest to liczba alokowanych rdzeni na węźle)
#SBATCH --ntasks-per-node=12
## Ilość pamięci przypadającej na jeden rdzeń obliczeniowy (domyślnie 4GB na rdzeń)
#SBATCH --mem-per-cpu=1GB
## Maksymalny czas trwania zlecenia (format HH:MM:SS)
#SBATCH --time=3:0:0 
## Nazwa grantu do rozliczenia zużycia zasobów
## Specyfikacja partycji
#SBATCH -p plgrid
## Plik ze standardowym wyjściem
#SBATCH --output="shared.csv"
## Plik ze standardowym wyjściem błędów
#SBATCH --error="shared_error.err"
 
module load plgrid/tools/chapel/1.20.0
export  GASNET_PHYSMEM_MAX='128MB'

## go to execution dir
cd $SLURM_SUBMIT_DIR

chpl -o jacobi_shared jacobi_shared.chpl
chpl -o gauss_shared gauss_shared.chpl

echo "method,iterations,problem,locales,tasks,tasksPerLocale,time"

for n_cores in {1..12}
do
    for i in 100 150 200
    do
        export CHPL_RT_NUM_THREADS_PER_LOCALE=$n_cores
        ./jacobi_shared -nl 1 --n=$i
        ./gauss_shared -nl 1 --n=$i
    done
done


