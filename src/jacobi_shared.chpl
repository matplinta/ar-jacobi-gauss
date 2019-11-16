use Time;

config const n = 6;
config const epsilon = 1.0e-5;
config const C: real = 0.2; // p*d^2/T -> constant value
config const show = false;

proc get_num_cores() : int
{
  var result = 0;
  for loc in Locales do
    on loc
    {
      result += here.maxTaskPar;
    }
  return result;
}

const fullDom = {0..n+1, 0..n+1};
const solveDom = fullDom[1..n, 1..n];

var A, Temp : [fullDom] real;
var t: Timer;
// init table
// if even, set four centre pieces
if (n % 2 == 0){
    var lowBound: int = n/2;
    var highBound: int = lowBound + 1;

    A[lowBound..highBound, lowBound..highBound] = 1.0;
}
// if odd, set one centre piece
else{
    var centre: int = n/2 + 1;
    A[centre, centre] = 1.0;

}
// writeln(A, "\n");

var iterations = 0;
t.start();
do {
    iterations += 1;
	forall (i,j) in solveDom do
		Temp[i,j] = (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1] + C) / 4;

	const delta = max reduce abs(A[solveDom] - Temp[solveDom]);
	A[solveDom] = Temp[solveDom];

    // writeln("delta = ", delta, "\n");
} while (delta > epsilon);
t.stop();

if (show){
    writeln(A, "\n");
}

writeln("Jacobi,", iterations, ",", n, ",", numLocales, ",", get_num_cores(), ",", here.maxTaskPar, ",", t.elapsed(TimeUnits.seconds)); 


