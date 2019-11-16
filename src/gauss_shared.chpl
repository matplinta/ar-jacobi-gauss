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

    Temp[lowBound..highBound, lowBound..highBound] = 1.0;
}
// if odd, set one centre piece
else{
    var centre: int = n/2 + 1;
    Temp[centre, centre] = 1.0;

}
// writeln(Temp, "\n");

var red_odd: sparse subdomain(solveDom);
var red_even: sparse subdomain(solveDom);
var red: sparse subdomain(solveDom);

red_odd += {1..n, 1..n} by 2 align (1,1);
red_even += {1..n, 1..n} by 2 align (2,2);
red += red_odd + red_even;

var black_odd: sparse subdomain(solveDom);
var black_even: sparse subdomain(solveDom);
var black: sparse subdomain(solveDom);

black_odd += {1..n, 1..n} by 2 align (1,2);
black_even += {1..n, 1..n} by 2 align (2,1);
black += black_odd + black_even;

var iterations = 0;
t.start();
do {
    iterations += 1;

    forall (i,j) in black{
        Temp[i,j] = (Temp[i-1,j] + Temp[i+1,j] + Temp[i,j-1] + Temp[i,j+1] + C) / 4;
    }
    forall (i,j) in red{
		Temp[i,j] = (Temp[i-1,j] + Temp[i+1,j] + Temp[i,j-1] + Temp[i,j+1] + C) / 4;
    }

	const delta = max reduce abs(A[solveDom] - Temp[solveDom]);
	A[solveDom] = Temp[solveDom];

	// writeln(A, "\n");
	// writeln("delta = ", delta, "\n");

} while (delta > epsilon);
t.stop();

if (show){
    writeln(A, "\n");
}

writeln("Gauss,", iterations, ",", n, ",", numLocales, ",", get_num_cores(), ",", here.maxTaskPar, ",", t.elapsed(TimeUnits.seconds)); 

