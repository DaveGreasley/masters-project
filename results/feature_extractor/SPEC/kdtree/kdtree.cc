/*
 * kdtree.cc
 *
 * Build and seach a k-d tree using the OpenMP task directive.
 *
 * Russ Brown
 */

/* @(#)kdtree.cc	1.28 12/02/08 */

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#if defined(SPEC)
#include "specrand.h"
#endif 

#ifdef SPEC_OMP
#include <omp.h>
#endif

#define DIM (3)
#define DEFAULT_SIZE (100000L)
#define DEFAULT_CUTOFF (10)
#define DEFAULT_MAXDEPTH (2)
/* #define COPY_POINTER */

#define OMP_BUILDKDTREE
#define OMP_BUILDKDTREE_LIMIT 16
//#define OMP_COUNTERS

#ifdef OMP_COUNTERS
long count0[1024];
long count1[1024];
#endif

/***********************************************************************
                            KDNODE
************************************************************************/

/* The class kdnode defines the nodes in the k-d tree. */

class kdnode {
  long long n;
  kdnode *lo, *hi;
#ifdef COPY_POINTER
  int *coord;
#else
  int coord[DIM];
#endif
public:
  kdnode(void);
  kdnode(long long);
  void buildkdtree(long long *, long long *, long long *, long long *,
		   long long *, long long, long long, int **, int);
  void coordkdtree(int **);
  long long sweepkdtree(kdnode *, long long, long long, int, int);
  long long searchkdtree(kdnode *, int, long long, long long, int, int);
};

/* This constructor creates a kdnode and sets its pointers to NULL. */

kdnode::kdnode(void) {

  lo = hi = NULL;
#ifdef OMP_COUNTERS
#pragma omp atomic
  count0[omp_get_thread_num()]++;
#endif
}

/*
 * This constructor creates a kdnode, sets its pointers to NULL,
 * and sets n.
 */

kdnode::kdnode(long long nn) {

  n = nn;
  lo = hi = NULL;
#ifdef OMP_COUNTERS
#pragma omp atomic
  count1[omp_get_thread_num()]++;
#endif
}

/***********************************************************************
                            DOWNHEAP()
************************************************************************/

/*
 * The downheap function from Robert Sedgewick's "Algorithms in C++" p. 152,
 * corrected for the fact that Sedgewick indexes the heap array from 1 to n
 * whereas Java indexes the heap array from 0 to n-1. Note, however, that
 * the heap should be indexed conceptually from 1 to n in order that for
 * any node k the two children are found at nodes 2*k and 2*k+1. Move down
 * the heap, exchanging the node at position k with the larger of its two
 * children if necessary and stopping when the node at k is larger than both
 * children or the bottom of the heap is reached. Note that it is possible
 * for the node at k to have only one child: this case is treated properly.
 * A full exchange is not necessary because the variable 'v' is involved in
 * the exchanges.  The 'while' loop has two exits: one for the case that
 * the bottom of the heap is hit, and another for the case that the heap
 * condition (the parent is greater than or equal to both children) is
 * satisfied somewhere in the interior of the heap.
 *
 * Used by the heapsort function which sorts the index arrays indirectly
 * by comparing components of the Cartesian coordinates.
 *
 * Calling parameters are as follows:
 *
 * a - array of indices into the atomic coordinate array x
 * n - the number of items to be sorted
 * k - the exchange node (or element)
 * x - the atomic coordinate array
 * p - the partition (x, y, z or w) on which sorting occurs
 */

void downheap(long long *a, long long n, long long k, int **x, int p)
{

   long long j, v;

   v = a[k - 1];
   while (k <= n / 2) {
      j = k + k;
      if ((j < n) && (x[a[j - 1]][p] < x[a[j]][p]))
         j++;
      if (x[v][p] >= x[a[j - 1]][p])
         break;
      a[k - 1] = a[j - 1];
      k = j;
   }
   a[k - 1] = v;
}

/***********************************************************************
                            HEAPSORT()
************************************************************************/

/*
 * The heapsort function from Robert Sedgewick's "Algorithms in C++" p. 156,
 * corrected for the fact that Sedgewick indexes the heap array from 1 to n
 * whereas Java indexes the heap array from 0 to n-1. Note, however, that
 * the heap should be indexed conceptually from 1 to n in order that for
 * any node k the two children are found at nodes 2*k and 2*k+1.  In what
 * follows, the 'for' loop heaporders the array in linear time and the
 * 'while' loop exchanges the largest element with the last element then
 * repairs the heap.
 *
 * Calling parameters are as follows:
 *
 * a - array of indices into the atomic coordinate array x
 * n - the number of items to be sorted
 * x - the atomic coordinate array
 * p - the partition (x, y, z or w) on which sorting occurs
 *
 * Used by the nblist function to sort the xn, yn, zn, wn and on arrays.
 */

void heapsort(long long *a, long long n, int **x, int p)
{

   long long k, v;

   for (k = n / 2; k >= 1; k--)
      downheap(a, n, k, x, p);
   while (n > 1) {
      v = a[0];
      a[0] = a[n - 1];
      a[n - 1] = v;
      downheap(a, --n, 1, x, p);
   }
}

/***********************************************************************
                            BUILDKDTREE()
************************************************************************/

/*
 * This method builds kd tree by recursively subdividing the atom
 * number arrays and adding nodes to the tree.  Note that the arrays
 * are permuted cyclically as control moves down the tree in
 * order that sorting occur on x, y, z and (for 4D) w.  The
 * temporary array is provided for the copy and partition operation.
 * Note also that the elements of xn designate the key on which
 * sorting occurs, and that the xn, yn, zn, wn (for 4D) and tn
 * arrays are cyclically permuted in recursive calls to this
 * function in order that the sorting order occur on x, y, z
 * and (for 4D) w.
 *
 * Calling parameters are as follows:
 *
 * xn - x sorted array of atom numbers
 * yn - y sorted array of atom numbers
 * zn - z sorted array of atom numbers
 * wn - w sorted array of atom numbers
 * tn - temporary array for atom numbers
 * start - first element of array 
 * end - last element of array
 * x - atomic coordinate array
 * p - the partition (x, y, z or w) on which sorting occurs
 */

void kdnode::buildkdtree(long long *xn, long long *yn, long long *zn, long long *wn,
			 long long *tn, long long start, long long end, int **x,
			 int p)
{
  long long i, middle, median, lower, upper;

  /* The partition cycles by DIM. */

  p %= DIM;

  /* If only one element is passed to this function, add it to the tree. */

  if (end == start) {
    n = xn[start];
  }

  /*
   * Otherwise, if two elements are passed to this function, determine
   * whether the first element is the low child or the high child.  Or,
   * if neither element is the low child, choose the second element to
   * be the high child.  Allocate a new k-d node and make it one or the
   * other of the children.
   */

  else if (end == start + 1) {

    /* Check whether the first element is the low child. */

    if (x[xn[start]][p] < x[xn[end]][p]) {
      n = xn[end];
      lo = new kdnode(xn[start]);
    }

    /* Check whether the second element is the low child. */

    else if (x[xn[start]][p] > x[xn[end]][p]) {
      n = xn[start];
      lo = new kdnode(xn[end]);
    }

    /* Neither element is the low child so use the second as the high child. */

    else {
      n = xn[start];
      hi = new kdnode(xn[end]);
    }
  }

  /* Otherwise, more than two elements are passed to this function. */

  else {

    /*
     * The middle element of the xn array is taken as the element about
     * which the yn and zn arrays will be partitioned.  However, search
     * lower elements of the xn array to ensure that the p values of the
     * atomic coordinate array that correspond to these elements are indeed
     * less than the median value because they may be equal to it.  This
     * approach is consistent with partitioning between < and >=.
     */

    middle = (start + end) / 2;
    median = x[xn[middle]][p];
    for (i = middle - 1; i >= start; i--) {
      if (x[xn[i]][p] < median) {
	break;
      } else {
	middle = i;
      }
    }

    /* Store the middle element at this k-d node. */

    n = xn[middle];

    /*
     * Scan the yn array in ascending order and compare the p value of
     * each corresponding element of the atomic coordinate array to the
     * median value.  If the p value is less than the median value, copy
     * the element of the yn array into the lower part of the tn array.
     * If the p value is greater than or equal to the median value, copy
     * the element of the yn array into the upper part of the tn array.
     * The lower part of the tn array begins with the start index, and the
     * upper part of the tn array begins one element above the middle index.
     * At the end of this scan and copy operation, the tn array will have
     * been subdivided into three groups: (1) a group of indices beginning
     * with start and continuing up to but not including middle, which indices
     * point to atoms for which the p value is less than the median value;
     * (2) the middle index that has been stored in this node of  the kd tree;
     * and (3) a group of indices beginning one address above middle and
     * continuing up to and including end, which indices point to atoms for
     * which the p value is greater than or equal to the median value.
     *
     * This approach preserves the relative heapsorted order of elements
     * of the atomic coordinate array that correspond to elements of the
     * yn array while those elements are partitioned about the p median
     * that was obtained from the xn array.
     *
     * Note: when scanning the yn array, skip the element (i.e., the atom
     * number) that equals the middle element because that atom number has
     * been stored at this node of the kd-tree.
     */

    lower = start - 1;
    upper = middle;
    for (i = start; i <= end; i++) {
      if (yn[i] != xn[middle]) {
	if (x[yn[i]][p] < median) {
	  tn[++lower] = yn[i];
	} else {
	  tn[++upper] = yn[i];
	}
      }
    }

    /*
     * All elements of the yn array between start and end have been copied
     * and partitioned into the tn array, so the yn array is available for
     * elements of the zn array to be copied and partitioned into the yn
     * array, in the same manner in which elements of the yn array were
     * copied and partitioned into the tn array.
     *
     * This approach preserves the relative heapsorted order of elements
     * of the atomic coordinate array that correspond to elements of the
     * zn array while those elements are partitioned about the p median
     * that was obtained from the xn array.
     *
     * Note: when scanning the zn array, skip the element (i.e., the atom
     * number) that equals the middle element because that atom number has
     * been stored at this node of the kd-tree.
     */

    lower = start - 1;
    upper = middle;
    for (i = start; i <= end; i++) {
      if (zn[i] != xn[middle]) {
	if (x[zn[i]][p] < median) {
	  yn[++lower] = zn[i];
	} else {
	  yn[++upper] = zn[i];
	}
      }
    }

    /* Execute the following region of code if DIM==4. */

    if (DIM == 4) {

      /*
       * All elements of the zn array between start and end have been copied
       * and partitioned into the yn array, so the zn array is available for
       * elements of the wn array to be copied and partitioned into the zn
       * array, in the same manner in which elements of the zn array were
       * copied and partitioned into the yn array.
       *
       * This approach preserves the relative heapsorted order of elements
       * of the atomic coordinate array that correspond to elements of the
       * wn array while those elements are partitioned about the p median
       * that was obtained from the xn array.
       *
       * Note: when scanning the wn array, skip the element (i.e., the atom
       * number) that equals the middle element because that atom number has
       * been stored at this node of the kd-tree.
       */

      lower = start - 1;
      upper = middle;
      for (i = start; i <= end; i++) {
	if (wn[i] != xn[middle]) {
	  if (x[wn[i]][p] < median) {
	    zn[++lower] = wn[i];
	  } else {
	    zn[++upper] = wn[i];
	  }
	}
      }
    }

    /*
     * Recurse down the lo branch of the tree if the lower group of
     * the tn array is non-null.  Note permutation of the xn, yn, zn, wn
     * and tn arrays.  In particular, xn was used for partitioning at
     * this level of the tree.  At one level down the tree, yn (which
     * has been copied into tn) will be used for partitioning.  At two
     * levels down the tree, zn (which has been copied into yn) will
     * be used for partitioning.  If DIM==4, at three levels down the
     * tree wn (which has been copied into zn) will be used for partitoning.
     * At four levels down the tree, xn will be used for partitioning.
     * In this manner, partitioning cycles through xn, yn, zn and wn
     * at successive levels of the tree.
     *
     * Note that for 3D the wn array isn't allocated so don't permute it
     * cyclically along with the other arrays in the recursive call.
     */

    if (lower >= start) {
      lo = new kdnode();
      if (DIM == 4) {
	lo->buildkdtree(tn, yn, zn, xn, wn,
			start, lower, x, p+1);
      } else {
#ifdef OMP_BUILDKDTREE
#ifdef SPEC_OMP
#pragma omp task if (lower - start >= OMP_BUILDKDTREE_LIMIT) \
     shared(tn,yn,xn,wn,zn,x) \
     firstprivate(start,lower,p)
#endif
#endif
       {
	lo->buildkdtree(tn, yn, xn, wn, zn,
			start, lower, x, p+1);
       }
      }
    }

    /*
     * Recurse down the hi branch of the tree if the upper group of
     * the tn array is non-null.  Note permutation of the xn, yn, zn, wn
     * and tn arrays, as explained above for recursion down the lo
     * branch of the tree.
     *
     * Note that for 3D the wn array isn't allocated so don't permute it
     * cyclically along with the other arrays in the recursive call.
     */

    if (upper > middle) {
      hi = new kdnode();
      if (DIM == 4) {
	hi->buildkdtree(tn, yn, zn, xn, wn,
		    middle + 1, end, x, p+1);
      } else {
#ifdef OMP_BUILDKDTREE
#ifdef SPEC_OMP
#pragma omp task if (end - (middle+1) >= OMP_BUILDKDTREE_LIMIT) \
     shared(tn,yn,xn,wn,zn,x) \
     firstprivate(middle,end,p)
#endif
#endif
       {
	hi->buildkdtree(tn, yn, xn, wn, zn,
		    middle + 1, end, x, p+1);
       }
      }
    }
#ifdef OMP_BUILDKDTREE
#ifdef SPEC_OMP
#pragma omp taskwait
#ifdef SPEC_NEED_DUMMY_STATEMENT
    i = 0;
#endif
#endif
#endif
  }
}

/***********************************************************************
                            COORDKDTREE()
************************************************************************/

/*
 * This method walks the k-d tree and copies to each node either the
 * pointer to the array of (x,y,z,w) coordinates, or the coordinates
 * themselves.
 *
 * Calling parameters are as follows:
 *
 * x - atomic coodinate array
 */

void kdnode::coordkdtree(int **x)

{

#ifdef COPY_POINTER
  coord = x[n];
#else
  for (int i=0; i<DIM; i++) {
    coord[i] = x[n][i];
  }
#endif

  if (hi != NULL) {
    hi->coordkdtree(x);
  }

  if (lo != NULL) {
    lo->coordkdtree(x);
  }
}

/***********************************************************************
                            SEARCHKDTREE()
************************************************************************/

/*
 * This method walks the kd tree and counts the number of points found.
 *
 * Calling parameters are as follows:
 *
 * q - the query kdnode
 * p - the partition (x, y, z or w) on which sorting occurs
 * cut - the cutoff distance
 * cut2 - the cutoff distance
 * depth - the depth in the k-d tree
 * depthmax - the maximum depth before tasks are executed immediately
 */

long long kdnode::searchkdtree(kdnode *q, int p,
			       long long cut, long long cut2,
			       int depth, int depthmax)
{
   long long xij, yij, zij, wij, r2, count, countL, countH;

   /* The partition cycles by DIM. */

   p %= DIM;

   /*
    * Search the high branch of the tree if the atomic coordinate of the
    * query atom plus the cutoff radius is greater than or equal to the
    * atomic coordinate of the kd node atom.  Create a child task, and
    * make all of arguments to this function firstprivate.  Also, the
    * variable countH must be declared shared or else it will be
    * firstprivate and will not receive the return value of searchkdtree().
    * Create the child task immediately instead of putting it on a queue
    * if the depth in the k-d tree exceeds depthmax.
    */

   countH = 0L;
   if ((hi != NULL) && (q->coord[p] + cut >= coord[p])) {
#ifdef SPEC_OMP
#pragma omp task shared(countH) if(depth < depthmax) \
     firstprivate(q, p, cut, cut2, depth, depthmax)
#endif
     {
       countH = hi->searchkdtree(q, p+1, cut, cut2, depth+1, depthmax);
     }
   }

   /*
    * Search the low branch of the tree if the atomic coordinate of the
    * query atom minus the cutoff radius is less than the atomic coordinate
    * of the kd node atom.  Create a child task, and make all of the
    * arguments that were supplied to this function firstprivate.  Also,
    * the variable countL must be declared shared or else it will be
    * firstprivate and will not receive the return value of searchkdtree().
    * Create the child task immediately instead of putting it on a queue
    * if the depth in the k-d tree exceeds depthmax.
    */

   countL = 0L;
   if ((lo != NULL) && (q->coord[p] - cut < coord[p])) {
#ifdef SPEC_OMP
#pragma omp task shared(countL) if(depth < depthmax) \
     firstprivate(q, p, cut, cut2, depth, depthmax)
#endif
     {
       countL = lo->searchkdtree(q, p+1, cut, cut2, depth+1, depthmax);
     }
   }

   /*
    * If the query atom number does not equal the kd tree node atom number,
    * calculate the interatomic distance and, if that distance is less than
    * the cutoff radius, increment the counter.
    */

   count = 0L;
   if (q->n != n) {
      xij = q->coord[0] - coord[0];
      yij = q->coord[1] - coord[1];
      zij = q->coord[2] - coord[2];
      r2 = xij * xij + yij * yij + zij * zij;
      if (DIM == 4) {
         wij = q->coord[3] - coord[3];
         r2 += wij * wij;
      }
      if (r2 < cut2) {
	count++;
      }
   }

   /* Wait for the child tasks to finish before summing the counts. */

#ifdef SPEC_OMP
#pragma omp taskwait
#endif

   return (count + countL + countH);
}

/***********************************************************************
                            SWEEPKDTREE()
************************************************************************/

/*
 * This method walks the kd tree and, for each point in the tree, counts 
 * the number of points found by the searchkdtree() method.
 *
 * Calling parameters are as follows:
 *
 * r - the root kdnode
 * cut - the cutoff distance
 * cut2 - the cutoff distance
 * depth - the depth in the k-d tree
 * depthmax - the maximum depth before tasks are executed immediately
 */

long long kdnode::sweepkdtree(kdnode *r, long long cut, long long cut2,
			      int depth, int depthmax)
{
  long long count, countL, countH;

  /* Search the kdtree using this kdnode as the query. */

  count = r->searchkdtree(this, 0, cut, cut2, depth, depthmax);

  /* Sweep the hi branch of the kdtree if it exists. */

  countH = 0L;
  if (hi != NULL) {
#ifdef SPEC_OMP
#pragma omp task shared(countH) if(depth < depthmax) \
    firstprivate(r, cut, cut2, depth, depthmax)
#endif
    {
      countH = hi->sweepkdtree(r, cut, cut2, depth, depthmax);
    }
  }

  /* Sweep the lo branch of the kdtree if it exists. */

  countL = 0L;
  if (lo != NULL) {
#ifdef SPEC_OMP
#pragma omp task shared(countL) if(depth < depthmax) \
    firstprivate(r, cut, cut2, depth, depthmax)
#endif
    {
      countL = lo->sweepkdtree(r, cut, cut2, depth, depthmax);
    }
  }

   /* Wait for the child tasks to finish before summing the counts. */

#ifdef SPEC_OMP
#pragma omp taskwait
#endif

  return (count + countL + countH);
}

/***********************************************************************
                            MAIN()
************************************************************************/

/*
 * Create arrays that contain random (x,y,z,w) coordinates, then build and
 * search a k-d tree.
 */

int main(int argc, char **argv)

{
  int **xyzw;
  long long i, n, maxdepth, cutoff, cutoff2, count;
  long long *xi, *yi, *zi, *wi, *ti;
  kdnode *root, *query;
  struct timespec startTime, endTime;
  double elapsedTime;

  /* Get the size and cutoff as a command-line arguments or by default. */

  if (argc > 4) {
    fprintf(stderr, "Usage: %s <n> <cutoffdivisor> <maxdepth>\n", argv[0]);
    exit (1);
  }

#if defined(SPEC)
#define KD_RAND_MAX (32767)
#else
#define KD_RAND_MAX (RAND_MAX)
#endif

  if (argc == 1) {
    n = DEFAULT_SIZE;
    cutoff = KD_RAND_MAX/DEFAULT_CUTOFF;
    maxdepth = DEFAULT_MAXDEPTH;
  } else if (argc == 2) {
    n = atol(argv[1]);
    if (n < 0) {
      fprintf(stderr, "main: n must be >= 0!\n");
      exit(1);
    }
    cutoff = KD_RAND_MAX/DEFAULT_CUTOFF;
    maxdepth = DEFAULT_MAXDEPTH;
  } else if (argc == 3){
    n = atol(argv[1]);
    if (n < 0) {
      fprintf(stderr, "main: n must be >= 0!\n");
      exit(1);
    }
    cutoff = atol(argv[2]);
    if (cutoff <= 0) {
      fprintf(stderr, "main: cutoff must be >0!\n");
      exit(1);
    }
    cutoff = KD_RAND_MAX/cutoff;
    maxdepth = DEFAULT_MAXDEPTH;
  } else {
    n = atol(argv[1]);
    if (n < 0) {
      fprintf(stderr, "main: n must be >= 0!\n");
      exit(1);
    }
    cutoff = atol(argv[2]);
    if (cutoff <= 0) {
      fprintf(stderr, "main: cutoff must be >0!\n");
      exit(1);
    }
    cutoff = KD_RAND_MAX/cutoff;
    maxdepth = atoi(argv[3]);
    if (maxdepth < 0) {
      fprintf(stderr, "main: maxdepth must be >= 0!\n");
      exit(1);
    }
  }

   /* Square the cutoff distances for use in searchkdtree. */

   cutoff2 = cutoff * cutoff;

   /*
    * Allocate, initialize and sort the arrays that hold the results of the
    * heapsort on x,y,z,w.  These arrays are used as pointers (via array indices)
    * into the atomic coordinate array x.  Allocate an additional temp array
    * so that the buildkdtree function can cycle through x,y,z.  Also allocate
    * and sort an additional array for the w coordinate if DIM==4, and
    * allocate an array for the ordinal atom number if SORT_ATOM_NUMBERS is
    * defined.
    *
    * The temp array is not sorted.
    */

   
   if ((xi = (long long *) malloc(n * sizeof(long long))) == NULL) {
     fprintf(stderr, "main: error allocating xi array!\n");
     exit(1);
   }

   if ((yi = (long long *) malloc(n * sizeof(long long))) == NULL) {
     fprintf(stderr, "main: error allocating yi array!\n");
     exit(1);
   }

   if ((zi = (long long *) malloc(n * sizeof(long long))) == NULL) {
     fprintf(stderr, "main: error allocating zi array!\n");
     exit(1);
   }

   if ((ti = (long long *) malloc(n * sizeof(long long))) == NULL) {
     fprintf(stderr, "main: error allocating ti array!\n");
     exit(1);
   }

   if (DIM == 4) {
     if ((wi = (long long *) malloc(n * sizeof(long long))) == NULL) {
       fprintf(stderr, "main: error allocating wi array!\n");
       exit(1);
     }
   }

#ifdef SPEC_OMP
#pragma omp parallel for shared(xi,yi,zi,wi) private(i)
#endif
   for (i = 0L; i < n; i++) {
     xi[i] = yi[i] = zi[i] = i;
     if (DIM == 4) {
       wi[i] = i;
     }
   }

   /*
    * Allocate and fill the xyzw array with random numbers.  The entries
    * in the array are x,y,z,w,x,y,z,w... (for DIM==4) or x,y,z,x,y,z...
    * (for DIM==3).
    */

   if ((xyzw = (int **) malloc(n * sizeof(int *))) == NULL) {
     fprintf(stderr, "main: error allocating xyzw array!\n");
     exit(1);
   }

#if defined(SPEC)
   spec_init_genrand((unsigned long) 1830129 );
#endif

#ifdef SPEC_OMP
#pragma omp parallel for shared(xyzw) private (i)
#endif
   for (i=0L; i<n; i++) {
     if ((xyzw[i] = (int *) malloc(DIM*sizeof(int))) == NULL) {
       fprintf(stderr, "main: error allocating xyzw[%lld]\n", i);
       exit(1);
     }
     for (int j=0; j<DIM; j++) {
#if defined(SPEC)
       xyzw[i][j] = -1;
#else
       xyzw[i][j] = -1;
#endif
     }
   }

   for (i=0L; i<n; i++) {
     for (int j=0; j<DIM; j++) {
#if defined(SPEC)
       xyzw[i][j] = (int) (spec_genrand_int32() >> 17);
#else
       xyzw[i][j] = rand();
#endif
     }
   }


   /* Heap sort the index arrays. */

   heapsort(xi, n, xyzw, 0);
   heapsort(yi, n, xyzw, 1);
   heapsort(zi, n, xyzw, 2);

   if (DIM == 4) {
     heapsort(wi, n, xyzw, 3);
   }

   /* Allocate and initialize the root of the k-d tree. */

   root = new kdnode();

   /*
    * Build the k-d tree.  For 3D the wi array is ignored because it wasn't
    * allocated.  See the recursive calls to the buildkdtree function from
    * within that function to verify that arrays that are ignored do not
    * participate in the cyclic permutation of arrays in the recursive calls.
    */

#ifdef OMP_BUILDKDTREE
#ifdef SPEC_OMP
#pragma omp parallel shared(xi,yi,zi,wi,xyzw) firstprivate(n)
#endif
#endif
  {
#ifdef OMP_BUILDKDTREE
#ifdef SPEC_OMP
#pragma omp single
#endif
#endif
   {
   root->buildkdtree(xi, yi, zi, wi, ti, 0L, n-1, xyzw, 0);
   }
  }

   /*
    * For purposes of heapsort() and buildkdtree(), the (x,y,z,w) coordinates
    * were stored in one large 2D array.  In an attempt to minimize memory
    * access as a performance and scalability bottleneck, these coordinates
    * are now copied to each k-d tree node.
    */

   root->coordkdtree(xyzw);

   /* Start the timer. */

#if !defined(SPEC)
  clock_gettime(CLOCK_REALTIME, &startTime);
#endif

   /*
    * Search the kd-tree and count the neighbors for each point.
    * The sweepkdtree() method will create child tasks that will
    * call the searchkdtree() method, that itself will create
    * child tasks.
    */

  count = 0L;
#ifdef SPEC_OMP
#pragma omp parallel shared(count) firstprivate(root, cutoff, cutoff2, maxdepth)
#endif
  {
#pragma omp single
    {
      count += root->sweepkdtree(root, cutoff, cutoff2, 0, maxdepth);
    }
  }

   /* Stop the timer. */

#if !defined(SPEC)
   clock_gettime(CLOCK_REALTIME, &endTime);

   /* Report the elapsed time. */

   elapsedTime = (double)(endTime.tv_sec - startTime.tv_sec) +
     1.0e-9*((double)(endTime.tv_nsec - startTime.tv_nsec));
   fprintf(stderr, "Total time is %10.5f seconds to find %lld points\n",
	   elapsedTime, count);
#else
   elapsedTime = 0.0;
   printf("Total time is %10.5f seconds to find %lld points\n",
	   elapsedTime, count);
#endif

#ifdef OMP_COUNTERS
   fprintf (stderr,"heeleo");
   fprintf(stderr, "count0: ");
   for (i = 0; i < 4; i++)
     fprintf(stderr, " %ld", count0[i]);
   fprintf(stderr, "\n");

   fprintf(stderr, "count1: ");
   for (i = 0; i < 4; i++)
     fprintf(stderr, " %ld", count1[i]);
   fprintf(stderr, "\n");
#endif

   return 0;
}
