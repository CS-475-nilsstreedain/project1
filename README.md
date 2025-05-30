# project1
## Introduction
Monte Carlo simulation is used to determine the range of outcomes for a series of parameters, each of which has a probability distribution showing how likely each option is to happen. In this project, you will take a scenario and develop a Monte Carlo simulation of it, determining how likely a particular output is to happen.

Clearly, this is very parallelizable -- it is the same computation being run on many permutations of the input parameters. You will run this with OpenMP, testing it on different numbers of threads (at least 1, 2, 4, 6, and 8).

## The Scenario
![image](https://github.com/user-attachments/assets/af7b1042-bf71-4abd-ba58-4be2ba552345)

A castle sits on top of a cliff. An amateur band of merceneries is attempting to destroy it.

Normally this would be a pretty straightforward geometric calculation, but these are amateurs. What makes them such amateurs you ask? It's because they are not very good at estimating distances, and not very good at aiming their cannon. They can only determine the 5 input parameters within certain ranges.

Your job is to figure out the probability that these doofuses will actually hit the castle. This is a job for multicore Monte Carlo simulation!

## Requirements:
1. The ranges are:
Variable | Meaning | Range
-|-|-
g | Ground distance to the cliff face | 10. - 20.
h | Height of the cliff face | 20. - 30.
d | Upper deck distance to the castle | 10. - 20.
v | Cannonball initial velocity | 20. - 30.
θ | Cannon firing angle in degrees | 70. - 80.
2. In addition you are given:
    - (θ in radians) = (F_PI/180.f) * (θ in degrees)
    - vx = v*cos(θ in radians)
    - vy = v*sin(θ in radians)
    - TOL = 5.0
    - GRAVITY = -9.8

TOL is how close the cannonball needs to come to the castle to demolish it.
GRAVITY is the acceleration due to gravity. Be sure the minus sign stays there.

3. Run this for some combinations of trials and threads. Do timing for each combination. Like we talked about in the Project Notes, run each experiment some number of tries, NUMTRIES, and record just the peak performance.
4. Produce a rectangular table and two graphs. The two graphs need to be:
    1. Performance versus the number of Monte Carlo trials, with the colored lines being the number of OpenMP threads.
    2. Performance versus the number OpenMP threads, with the colored lines being the number of Monte Carlo trials..

(See the Graphing notes to see an example of this and how to get Excel to do most of the work for you.)

5. Chosing one of the runs (the one with the maximum number of trials would be good), tell me what you think the actual probability is.
6. Compute Fp, the Parallel Fraction, for this computation.
7. Given this Fp, what is the maximum Speedup you could ever get, no matter how many cores you use?

## Equations
1. To find out at what time the ball hits y = 0. (returns to the ground level), solve this for t (time):
```
y = 0. = vy*t + 0.5*GRAVITY*t2
or, t * ( vy + 0.5*GRAVITY*t ) = 0.
or, t = 0. and t = -vy / ( 0.5*GRAVITY )
Ignore the t=0. solution -- that's when it started.
```
2. To see how far the ball went horizontally in that time t: x = vx*t
```
If this is less than g, then the ball never even reached the cliff face -- they missed the castle.
```
3. To find out what time the ball gets even with x = g (the cliff face), solve this for t (time):
```
x = g = 0. + vx*t
or, t = g / vx
```
4. To see how far the ball went vertically in that time:
```
y = vy*t + 0.5*GRAVITY*t2
If this is less than h, then the ball was unable to clear the cliff face -- they missed the castle ... again.
```
5. To find out at what time the ball hits y = h (the upper deck), solve this for t (time):
```
y = h = vy*t + 0.5*GRAVITY*t2
or, 0.5*GRAVITY*t2 + vy*t - h = 0.
using the quadratic formula. (Here you thought you were done with this in high school.)
```
6. If you think of this equation as being in the form: At2 + Bt + C = 0., then the two possible values of t are:
```
−B + √   B2 − 4AC 
          2A          
−B - √   B2 − 4AC 
          2A          
```
7. Choose the larger of the two. The larger of the two gives you the time the cannonball reaches y=h on the way down. (The smaller of the two gives you the time the cannonball reaches y=h on the way up, which doesn't help.)
8. To see how far the ball went horizontally in that time use:
```
x = vx*t
If fabs(x - g - d) <= TOL, then the cannonball actually destroyed the castle. Even a blind squirrel finds an acorn every so often...
```

## The Skeleton Program
```
#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

#ifndef F_PI
#define F_PI		(float)M_PI
#endif

// print debugging messages?
#ifndef DEBUG
#define DEBUG		false
#endif

// setting the number of threads to use:
// (this a default value -- it can also be set from the outside by your script)
#ifndef NUMT
#define NUMT		    2
#endif

// setting the number of trials in the monte carlo simulation:
// (this a default value -- it can also be set from the outside by your script)
#ifndef NUMTRIALS
#define NUMTRIALS	50000
#endif

// how many tries to discover the maximum performance:
#ifndef NUMTRIES
#define NUMTRIES	30
#endif

// ranges for the random numbers:
const float GMIN =	10.0;	// ground distance in meters
const float GMAX =	20.0;	// ground distance in meters
const float HMIN =	20.0;	// cliff height in meters
const float HMAX =	30.0;	// cliff height in meters
const float DMIN  =	10.0;	// distance to castle in meters
const float DMAX  =	20.0;	// distance to castle in meters
const float VMIN  =	20.0;	// intial cnnonball velocity in meters / sec
const float VMAX  =	30.0;	// intial cnnonball velocity in meters / sec
const float THMIN = 	70.0;	// cannonball launch angle in degrees
const float THMAX =	80.0;	// cannonball launch angle in degrees

const float GRAVITY =	-9.8;	// acceleraion due to gravity in meters / sec^2
const float TOL = 5.0;		// tolerance in cannonball hitting the castle in meters
				// castle is destroyed if cannonball lands between d-TOL and d+TOL

// function prototypes:
float		Ranf( float, float );
int		Ranf( int, int );
void		TimeOfDaySeed( );

// degrees-to-radians:
inline
float Radians( float degrees )
{
	return (F_PI/180.f) * degrees;
}


// main program:
int
main( int argc, char *argv[ ] )
{
#ifndef _OPENMP
	fprintf( stderr, "No OpenMP support!\n" );
	return 1;
#endif

	TimeOfDaySeed( );		// seed the random number generator

	omp_set_num_threads( NUMT );	// set the number of threads to use in parallelizing the for-loop:`
	
	// better to define these here so that the rand() calls don't get into the thread timing:
	float *vs  = new float [NUMTRIALS];
	float *ths = new float [NUMTRIALS];
	float * gs = new float [NUMTRIALS];
	float * hs = new float [NUMTRIALS];
	float * ds = new float [NUMTRIALS];

	// fill the random-value arrays:
	for( int n = 0; n < NUMTRIALS; n++ )
	{
		vs[n]  = Ranf(  VMIN,  VMAX );
		ths[n] = Ranf( THMIN, THMAX );
 		gs[n]  = Ranf(  GMIN,  GMAX );
 		hs[n]  = Ranf(  HMIN,  HMAX );
 		ds[n]  = Ranf(  DMIN,  DMAX );
	}

	// get ready to record the maximum performance and the probability:
	double maxPerformance = 0.;	// must be declared outside the NUMTRIES loop
	int numHits;			// must be declared outside the NUMTRIES loop

	// looking for the maximum performance:
	for( int tries = 0; tries < NUMTRIES; tries++ )
	{
		double time0 = omp_get_wtime( );

		numHits = 0;

		#pragma omp parallel for ?????
		for( int n = 0; n < NUMTRIALS; n++ )
		{
			// randomize everything:
			float v   = vs[n];
			float thr = Radians( ths[n] );
			float vx  = v * cos(thr);
			float vy  = v * sin(thr);
			float  g  =  gs[n];
			float  h  =  hs[n];
			float  d  =  ds[n];

			// see if the ball doesn't even reach the cliff:`
			float t = ?????
			float x = ?????
			if( x <= g )
			{
				if( DEBUG )	fprintf( stderr, "Ball doesn't even reach the cliff\n" );
			}
			else
			{
				// see if the ball hits the vertical cliff face:
				t = ?????
				float y = ?????
				if( y <= h )
				{
					if( DEBUG )	fprintf( stderr, "Ball hits the cliff face\n" );
				}
				else
				{
					// the ball hits the upper deck:
					// the time solution for this is a quadratic equation of the form:
					// At^2 + Bt + C = 0.
					// where 'A' multiplies time^2
					//       'B' multiplies time
					//       'C' is a constant
					float A = ?????
					float B = ?????
					float C = ?????
					float disc = B*B - 4.f*A*C;	// quadratic formula discriminant

					// ball doesn't go as high as the upper deck:
					// this should "never happen" ... :-)
					if( disc < 0. )
					{
						if( DEBUG )	fprintf( stderr, "Ball doesn't reach the upper deck.\n" );
						exit( 1 );	// something is wrong...
					}

					// successfully hits the ground above the cliff:
					// get the intersection:
					float sqrtdisc = sqrtf( disc );
					float t1 = (-B + sqrtdisc ) / ( 2.f*A );	// time to intersect high ground
					float t2 = (-B - sqrtdisc ) / ( 2.f*A );	// time to intersect high ground

					// only care about the second intersection
					float tmax = t1;
					if( t2 > t1 )
						tmax = t2;

					// how far does the ball land horizontlly from the edge of the cliff?
					float upperDist = vx * tmax  -  g;

					// see if the ball hits the castle:
					if(  fabs( upperDist - d ) ≤ TOL )
					{
						if( DEBUG )  fprintf( stderr, "Hits the castle at upperDist = %8.3f\n", upperDist );
						?????
					}
					else
					{
						if( DEBUG )  fprintf( stderr, "Misses the castle at upperDist = %8.3f\n", upperDist );
					}
				} // if ball clears the cliff face
			} // if ball gets as far as the cliff face
		} // for( # of  monte carlo trials )

		double time1 = omp_get_wtime( );
		double megaTrialsPerSecond = (double)NUMTRIALS / ( time1 - time0 ) / 1000000.;
		if( megaTrialsPerSecond > maxPerformance )
			maxPerformance = megaTrialsPerSecond;
	} // for ( # of timing tries )

	float probability = (float)numHits/(float)( NUMTRIALS );	// just get for the last run

// uncomment this if you want to print output to a ready-to-use CSV file:

// #define CSV
#ifdef CSV
	fprintf(stderr, "%2d , %8d , %6.2lf\n",  NUMT, NUMTRIALS, maxPerformance);
#else
	fprintf(stderr, "%2d threads : %8d trials ; probability = %6.2f%% ; megatrials/sec = %6.2lf\n",
		NUMT, NUMTRIALS, 100.*probability, maxPerformance);
#endif

	return 0;
}
```

For your own information, print out: (1) the number of threads, (2) the number of trials, (3) the probability of destroying the castle, and (4) the MegaTrialsPerSecond.

For creating a ready-to-use CSV file, print out: (1) the number of threads, (2) the number of trials, and (3) the MegaTrialsPerSecond.
Printing this as a single line with commas between the numbers lets you import these lines right into Excel.

## Helper Functions:
To choose a random number between two floats or two ints, use:
```
#include <stdlib.h>

float
Ranf( float low, float high )
{
        float r = (float) rand();               // 0 - RAND_MAX
        float t = r  /  (float) RAND_MAX;       // 0. - 1.

        return   low  +  t * ( high - low );
}

int
Ranf( int ilow, int ihigh )
{
        float low = (float)ilow;
        float high = ceil( (float)ihigh );

        return (int) Ranf(low,high);
}

// call this if you want to force your program to use
// a different random number sequence every time you run it:
void
TimeOfDaySeed( )
{
	time_t now;
	time( &now );

	struct tm n;
	struct tm jan01;
#ifdef WIN32
	localtime_s( &now, &n );
	localtime_s( &now, &jan01 );
#else
	n =     *localtime(&now);
	jan01 = *localtime(&now);
#endif
	jan01.tm_mon  = 0;
	jan01.tm_mday = 1;
	jan01.tm_hour = 0;
	jan01.tm_min  = 0;
	jan01.tm_sec  = 0;

	double seconds = difftime( now, mktime(&jan01) );
	unsigned int seed = (unsigned int)( 1000.*seconds );    // milliseconds
	srand( seed );
}
```

## Turn-In
Turn in your PDF file and your cpp file on Canvas. Go to the Canvas Week #1 or Week #2 modules, scroll down to the Projects, go to the Project #1 row and click on Submit. When you get the Project #1 Assignment page, click on the Start Assignment black button in the upper-right corner. Upload your files.

## Grading:
Feature | Points
-|-
Provide a close estimate of the actual probability | 10
Good graph of performance vs. number of trials | 25
Good graph of performance vs. number of threads | 25
Compute Fp, the Parallel Fraction (show your work) | 20
Compute Smax, the Maximum Speedup (show your work) | 20
Potential Total | 100
