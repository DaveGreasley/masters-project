#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#ifdef SPEC_WINDOWS 
#define STRCMP(x,y) _stricmp(x,y)
#else
#define STRCMP(x,y) strcasecmp(x,y)
#endif

typedef struct {
  unsigned char y,u,v;
} YUV;

typedef struct {
  unsigned char blue;
  unsigned char green;
  unsigned char red;
} Pixel;

typedef struct {
  unsigned char idlength;
  unsigned char colormaptype;
  unsigned char datatypecode;
  unsigned short colormaporigin;
  unsigned short colormaplength;
  unsigned char colormapdepth;
  unsigned short x_origin;
  unsigned short y_origin;
  unsigned short width;
  unsigned short height;
  unsigned char bitsperpixel;
  unsigned char imagedescriptor;
  Pixel **imagedata;
} TargaImage;

typedef struct {
  char file1[256];
  char file2[256];
  int dumpfile;
  int dumpheader;
  int dumpdiff;
  int avg;
  char diff[256];
  float threshold;
  int maxthresh;
  int * buckets;
  int numbuckets;
} params;

void read_tga_file(const char *, TargaImage *);
void read_yuv_file(const char *, TargaImage *);
void printUsage();
void dump_header(const char *, TargaImage *);
void dump_tga(const char *, TargaImage *);
int computeSSIM(TargaImage *, TargaImage *, TargaImage *, params);
double mean(double*,int);
double variance(double*,double, int);
double covariance(double*,double*,double,double,int);

int main(int argc, char *argv[]) {

  char *findstr, *fname;
  TargaImage *img1, *img2, *imgD;
  int rc, arg, h, w;
  params param;

  /* Initialize the program parameters */
  param.dumpfile = 0;
  param.dumpheader = 0;
  param.dumpdiff = 0;
  param.avg = 0;
  param.maxthresh = 0;
  param.threshold = 0.0;
  param.file1[0] = '\0';
  param.file2[0] = '\0';
  param.buckets = NULL;
  param.numbuckets = 0;
  arg = 1;
  while (arg < argc) {
    if (!STRCMP(argv[arg],"-help")) {
      printUsage();
      exit(0);
    } else if (!STRCMP(argv[arg],"-dumpfile")) {
      param.dumpfile = 1;
    } else if (!STRCMP(argv[arg],"-dumpheader")) {
      param.dumpheader = 1;
    } else if (!STRCMP(argv[arg],"-avg")) {
      param.avg = 1;
    } else if (!STRCMP(argv[arg],"-buckets")) {
      ++arg;
      param.numbuckets = atoi(argv[arg]);
      if (param.numbuckets < 1 || param.numbuckets > 100) {
	printf("Error: The number of buckets must be between 1 and 100.\n");
	printUsage();
        exit(-1);
      }
      param.buckets = (int *) malloc(sizeof(int) * param.numbuckets);
      for (int i=0; i < param.numbuckets; ++i) {
	param.buckets[i] = 0;
      }
    } else if (!STRCMP(argv[arg],"-maxthreshold")) {
      ++arg;
      param.maxthresh = atoi(argv[arg]);
    } else if (!STRCMP(argv[arg],"-diff")) {
      param.dumpdiff = 1;
      ++arg;
      strncpy(param.diff,argv[arg],256);
    } else if (!STRCMP(argv[arg],"-threshold")) {
      ++arg;
      param.threshold = atof(argv[arg]);
      if (param.threshold < 0.0 || param.threshold > 1.0) {
	fprintf(stderr, "Error: threshold must be between 0.0 and 1.0\n");
	printUsage();
	exit(-1);
      }
    } else {
      if (param.file1[0] == '\0') {
	strncpy(param.file1,argv[arg],256);
      } else if (param.file2[0] == '\0') {
	strncpy(param.file2,argv[arg],256);
      } else {
	fprintf(stderr, "Error: More than two files given.\n");
	printUsage();
	exit(-1);
      }
    }
    ++arg;
  }
  if (param.file1[0] == '\0' || param.file2[0] == '\0') {
	fprintf(stderr, "Error: Missing input file name.\n");
	printUsage();
	exit(-1);
  }

  img1 = (TargaImage *) malloc(sizeof(TargaImage));
  img2 = (TargaImage *) malloc(sizeof(TargaImage));
 
  findstr = strstr(param.file1,".tga");
  if ( findstr != NULL) {
    read_tga_file(param.file1,img1);
  } else {
    findstr = strstr(param.file1,".yuv");
    if (findstr != NULL) {
      read_yuv_file(param.file1,img1);
    } else {
      printf("file1 is a unknown file type.\n");
      printUsage();
      exit(1);
    }
  }
  findstr = strstr(param.file2,".tga");
  if ( findstr != NULL) {
    read_tga_file(param.file2,img2);
  } else {
    findstr = strstr(param.file2,".yuv");
    if (findstr != NULL) {
      read_yuv_file(param.file2,img2);
    } else {
      printf("file2 is a unknown file type.\n");
      printUsage();
      exit(1);
    }
  }

  if (param.dumpdiff) {
    imgD = (TargaImage *) malloc(sizeof(TargaImage));
    imgD->idlength=img1->idlength;
    imgD->colormaptype=img1->colormaptype;
    imgD->datatypecode=3;
    imgD->colormaporigin=img1->colormaporigin;
    imgD->colormaplength=img1->colormaplength;
    imgD->colormapdepth=img1->colormapdepth;
    imgD->x_origin=img1->x_origin;
    imgD->y_origin=img1->y_origin;
    imgD->width=img1->width;
    imgD->height=img1->height;
    imgD->bitsperpixel=8;
    imgD->imagedescriptor=img1->imagedescriptor;  
    imgD->imagedata = (Pixel **) malloc(sizeof(Pixel*)*imgD->height);
    for (h=0; h<imgD->height; ++h) {
      imgD->imagedata[h] = (Pixel *) malloc(sizeof(Pixel)*imgD->width);
      for (w=0; w<imgD->width; ++w) {
	imgD->imagedata[h][w].blue = 0;
	imgD->imagedata[h][w].green = 0;
	imgD->imagedata[h][w].red = 255;
      }
    }
  } else {
    imgD = 0;
  }

  if (param.dumpheader) {  
    fname = (char*) malloc(strlen(param.file1)+10);
    strncpy(fname,param.file1,strlen(param.file1));
    strcat(fname,".new.tga");
    dump_header(fname,img1);
    free(fname);
     
    fname = (char*) malloc(strlen(param.file2)+10);
    strncpy(fname,param.file2,strlen(param.file2));
    strcat(fname,".new.tga");
    dump_header(fname,img2);
    free(fname);
  }
  if (param.dumpfile) {
    dump_tga(param.file1,img1);
    dump_tga(param.file2,img2);
  }
  rc = computeSSIM(img1,img2,imgD,param);

  if (param.dumpdiff) {
    dump_tga(param.diff,imgD);
  }
  exit(rc);
}

int computeSSIM(TargaImage * img1, TargaImage * img2, TargaImage * imgD, params param) {

  int i, j, ix, jx, nx, ny, n, height, width, cnt, numbelow;
  double c1, c2, sum;
  double *i1_lumas, *i2_lumas;
  double i1_mean, i2_mean, i1_var, i2_var, covar, ssim;

  c1 = 6.5025;  // k1 = 0.01, L = 255, c1 = (k1 * L)^2
  c2 = 58.5225; // k2 = 0.03, L = 255, c2 = (k2 * L)^2
  sum = 0.0;
  cnt = 0;
  numbelow = 0;
  height = img1->height;
  width = img1->width;
  if (img1->width != img2->width || 
      img1->height != img2->height) {
    fprintf(stderr,"FILE height or width are not the same.\n");
    return -1;
  }
  
  // compute SSIM for this image against the ref image using 8x8 windows
  // and print result for each window
 hgtloop:  for ( i = 0; i < height; i += 8 ) {
  wdtloop:   for ( j = 0; j < width; j += 8 ) {
      nx = ((i + 8) > height) ? (height - i) : 8;
      ny = ((j + 8) > width) ? (width - j) : 8;
      n = 0;
      i1_lumas = (double*) malloc(sizeof(double)*nx*ny);
      i2_lumas = (double*) malloc(sizeof(double)*nx*ny);
      // compute luma value for each pixel
      // luma = 0.299*R + 0.587*G + 0.114*B
      // based on NTSC standard
      for ( ix = 0; ix < nx; ix++ ) {
	for ( jx = 0; jx < ny; jx++ ) {
	  i1_lumas[n] =
	    (0.299*img1->imagedata[i+ix][j+jx].red) +
	    (0.587*img1->imagedata[i+ix][j+jx].green) +
	    (0.114*img1->imagedata[i+ix][j+jx].blue);
	  i2_lumas[n] =
	    (0.299*img2->imagedata[i+ix][j+jx].red) +
	    (0.587*img2->imagedata[i+ix][j+jx].green) +
	    (0.114*img2->imagedata[i+ix][j+jx].blue);
	  n++;
	}
      }
      i1_mean = mean(i1_lumas, n);
      i2_mean = mean(i2_lumas, n);
      i1_var = variance(i1_lumas, i1_mean, n);
      i2_var = variance(i2_lumas, i2_mean, n);
      covar = covariance(i1_lumas, i2_lumas, i1_mean, i2_mean, n);
      ssim = ((2*i1_mean*i2_mean + c1)*(2*covar + c2)) /
	((i1_mean*i1_mean + i2_mean*i2_mean + c1)*(i1_var + i2_var + c2));
      ++cnt;
      if (param.avg) {
        sum+=ssim;
      } else {
	printf("(%d,%d)  SSIM = %10.9f\n", j, i, ssim);
      }
      if (param.numbuckets > 0) {
	int bucket;
	bucket = (int) (ssim*(float)param.numbuckets);
	if (bucket == param.numbuckets) {
	  /* adjust when ssim == 1.0 */
	  bucket =  param.numbuckets-1;
	}
        param.buckets[bucket]++;
      }
      if (param.threshold > 0.0 && ssim < param.threshold) {
	++numbelow;
	if (numbelow > param.maxthresh) {
	  printf("The maximum number of SSIM below the threshold has be reached. Aborting\n");
          free(i1_lumas);
          free(i2_lumas);
	  return -1;
        }
      }
 
      if (param.dumpdiff) {
	for ( ix = 0; ix < nx; ix++ ) {
	  for ( jx = 0; jx < ny; jx++ ) {
	    imgD->imagedata[i+ix][j+jx].red = (255.0*ssim);
	  }
	}
      }

      free(i1_lumas);
      free(i2_lumas);
    }
  }
  if (param.avg) {
    if (cnt > 0) {
       printf("AVG SSIM = %10.9f\n", sum/cnt);
    } else {
      printf("ERROR: Count is zero.\n");
    }
  }
  
  if (param.numbuckets > 0) {
    for (i=0; i < param.numbuckets; ++i) {
      float r1,r2;
      r1 = (((float) i)/(float)param.numbuckets);
      r2 = (((float) i+1)/(float)param.numbuckets);
      printf("%f to %f: %d\n", r1,r2,param.buckets[i]);
    }
  }
  return 0;
}
  

double mean(double* values, int n) {

  double sum = 0.0;
  int i;
  for ( i = 0; i < n; i++ )
    sum += values[i];
  return sum / (double)n;
}
double variance(double* values,double mean, int n) {

  double sum = 0.0;
  int i;
  for ( i = 0; i < n; i++ )
    sum += (values[i] - mean)*(values[i] - mean);
  return sum / (double)(n - 1);

}
double covariance(double* values1, double* values2, 
		  double mean1, double mean2, int n) {
  double sum = 0.0;
  int i;
  for ( i = 0; i < n; i++ )
    sum += (values1[i] - mean1)*(values2[i] - mean2);
  return sum / (double)(n - 1);
}

// Values in TGA headers are _supposed_ to be little-endian, according to
// v2.0 of the spec.
#define assemble_le_int(src, dest, len)  dest = 0; \
                                      for(i = 0; i < (signed int)len; i++) \
                                        dest |= (src[i] << (i * 8));
void read_tga_file (const char * fname, TargaImage * tga) {

  FILE *fin;
  int h,w,i;
  unsigned char tmpshort[sizeof(unsigned short)];

  /* Open the input tga file */
  if ((fin = fopen(fname,"rb")) == NULL) {
    fprintf(stderr,"File %s open failed\n",fname);
    exit(-1);
  }
  tga->idlength=fgetc(fin);
  tga->colormaptype=fgetc(fin);
  tga->datatypecode=fgetc(fin);
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->colormaporigin, sizeof(unsigned short));
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->colormaplength, sizeof(unsigned short));
  tga->colormapdepth=fgetc(fin);
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->x_origin, sizeof(unsigned short));
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->y_origin, sizeof(unsigned short));
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->width, sizeof(unsigned short));
  fread(tmpshort, sizeof(unsigned short),1,fin);
  assemble_le_int(tmpshort, tga->height, sizeof(unsigned short));
  tga->bitsperpixel=fgetc(fin);
  tga->imagedescriptor=fgetc(fin);

  tga->imagedata = (Pixel **) malloc(sizeof(Pixel*)*tga->height);
  for (h=0; h<tga->height; ++h) {
    tga->imagedata[h] = (Pixel *) malloc(sizeof(Pixel)*tga->width);
    for (w=0; w<tga->width; ++w) {
      tga->imagedata[h][w].blue = fgetc(fin);
      tga->imagedata[h][w].green = fgetc(fin);
      tga->imagedata[h][w].red = fgetc(fin);
    }
  }
  fclose(fin);
}

void read_yuv_file (const char * fname, TargaImage * tga) {

  FILE *fin;
  int i,j,h,w,nb,b,r,g;
  unsigned char ** buffer;
  YUV **pixels;
  int i2=0;
  int j2=0;

  /* Assume YUV files WIDTH=1280 HEIGHT=720 */
  
  /* Set default TGA header values */
  tga->idlength=0;
  tga->colormaptype=0;
  tga->datatypecode=2;
  tga->colormaporigin=0;
  tga->colormaplength=0;
  tga->colormapdepth=0;
  tga->x_origin=0;
  tga->y_origin=0;
  tga->width=1280;
  tga->height=720;
  tga->bitsperpixel=24;
  tga->imagedescriptor=0;

  /* Open the input yuv file */
  if ((fin = fopen(fname,"rb")) == NULL) {
    fprintf(stderr,"File %s open failed\n",fname);
    exit(-1);
  }
  
  /* Might update code to allow for variable WxH */

  tga->imagedata = (Pixel **) malloc(sizeof(Pixel*)*tga->height);
  buffer = (unsigned char**) malloc(tga->height*sizeof(unsigned char*));
  pixels = (YUV**) malloc(tga->height*sizeof(YUV*));
  for (h=0; h<tga->height; ++h) {
    tga->imagedata[h] = (Pixel *) malloc(sizeof(Pixel)*tga->width);
    buffer[h] = (unsigned char*) malloc(tga->width*sizeof(unsigned char));
    pixels[h] = (YUV*) malloc(tga->width*sizeof(YUV));
  }

  /* read in the Y */
  for (i=0;i<tga->height;i++) {
    nb = fread(buffer[i],1,tga->width,fin);
    if (nb < (tga->width)) {
      printf("Error reading input.  Tried to read %d, got only %d\n", tga->width,nb);
      exit(1);
    }
  }

  for (i=0;i<tga->height;i++) {
     for (j=0;j<tga->width;j++) {
       pixels[i][j].y = buffer[i][j];
     }
   }

   /* read in the U */
   for (i=0;i<tga->height/2;i++) {
     nb = fread(buffer[i],1,tga->width/2,fin);
     if (nb < (tga->width/2)) {
       printf("Error reading input.  Tried to read %d, got only %d\n", tga->width/2,nb);
       exit(1);
     }
   }
       
   for (i=0;i<tga->height;i++) {
     j2=0;
     for (j=0;j<tga->width;j++) {
       pixels[i][j].u = buffer[i2][j2];
       if (j%2) ++j2;
     }
     if (i%2) ++i2;
   }
   

   /* read in the V */
   for (i=0;i<tga->height/2;i++) {
     nb = fread(buffer[i],1,tga->width/2,fin);
     if (nb < (tga->width/2)) {
       printf("Error reading input.  Tried to read %d, got only %d\n", tga->width/2,nb);
       exit(1);
     }
   }
       
   i2=0;
   for (i=0;i<tga->height;i++) {
     j2=0;
     for (j=0;j<tga->width;j++) {
       pixels[i][j].v = buffer[i2][j2];
       if (j%2) ++j2;
     }
     if (i%2) ++i2;
   }

   h=0;
   for (i=tga->height-1;i>=0;i--) {
     w=0;
     for (j=0;j<tga->width;j++) {
       int b1=1.164*(pixels[i][j].y-16)+2.018*(pixels[i][j].u-128);
       int g1=1.164*(pixels[i][j].y-16)-0.812*(pixels[i][j].v-128)-0.391*(pixels[i][j].u-128);
       int r1=1.164*(pixels[i][j].y-16)+1.596*(pixels[i][j].v-128);
       
       if(b1<16) {
	 b=16;
       } else if(b1>255) {
	 b=255;
       } else {
	 b=b1;
       }          
       if(r1<16) {
	 r=16;
       } else if(r1>255) {
	 r=255;
       } else {
	 r=r1;
       }
       if(g1<16) {
	 g=16;
       } else if(g1>255) {
	 g=255;
       } else {
	 g=g1;
       }
 
       tga->imagedata[h][w].blue = b;
       tga->imagedata[h][w].green = g;
       tga->imagedata[h][w].red = r;
       ++w;
     }
     ++h;
   }
   fclose(fin); 
}

void dump_header(const char * fname, TargaImage * tga) {
  
  fprintf(stderr,"HEADER DUMP FOR %s\n", fname);
  fprintf(stderr,"IDLENGTH=%u\n",tga->idlength);
  fprintf(stderr,"COLORMAPTYPE=%u\n",tga->colormaptype);
  fprintf(stderr,"DATATYPECODE=%u\n",tga->datatypecode);
  fprintf(stderr,"COLORMAPORIGIN=%u\n",tga->colormaporigin);
  fprintf(stderr,"COLORMAPLENGTH=%u\n",tga->colormaplength);
  fprintf(stderr,"COLORMAPDEPTH=%u\n",tga->colormapdepth);
  fprintf(stderr,"X_ORIGIN=%u\n",tga->x_origin);
  fprintf(stderr,"Y_ORIGIN=%u\n",tga->y_origin);
  fprintf(stderr,"WIDTH=%u\n",tga->width);
  fprintf(stderr,"HEIGHT=%u\n",tga->height);
  fprintf(stderr,"BITSPERPIXEL=%u\n",tga->bitsperpixel);
  fprintf(stderr,"IMAGEDESCRIPTOR=%u\n",tga->imagedescriptor);
}

 void dump_tga(const char * fname, TargaImage * tga) {
  
  FILE *fout;
  int i,j;

  /* Open the input tga file */
  if ((fout = fopen(fname,"wb")) == NULL) {
    fprintf(stderr,"File open failed\n");
    exit(-1);
  }
  /* Set the header fields */
  fputc(tga->idlength,fout);
  fputc(tga->colormaptype,fout);
  fputc(tga->datatypecode,fout);                         /* uncompressed RGB */
  fputc(tga->colormaporigin & 0x00FF,fout); 
  fputc((tga->colormaporigin & 0xFF00) / 256,fout); 
  fputc(tga->colormaplength & 0x00FF,fout); 
  fputc((tga->colormaplength & 0xFF00) / 256,fout); 
  fputc(tga->colormapdepth,fout); 
  fputc(tga->x_origin & 0x00FF,fout); 
  fputc((tga->x_origin & 0xFF00) / 256,fout); 
  fputc(tga->y_origin & 0x00FF,fout); 
  fputc((tga->y_origin & 0xFF00) / 256,fout); 
  fputc(tga->width & 0x00FF,fout); 
  fputc((tga->width & 0xFF00) / 256,fout); 
  fputc(tga->height & 0x00FF,fout); 
  fputc((tga->height & 0xFF00) / 256,fout); 
  fputc(tga->bitsperpixel,fout); 
  fputc(tga->imagedescriptor,fout); 
  for (i=0; i<tga->height;i++) {
    for (j=0;j<tga->width;j++) {
      if (tga->datatypecode==2) {
	fputc(tga->imagedata[i][j].blue,fout);
	fputc(tga->imagedata[i][j].green,fout);
      }
      fputc(tga->imagedata[i][j].red,fout);
    }
  }
  fclose(fout);
  
}

void printUsage() {
  printf("Useage: imagevalidator.exe [options] file1 file2 \n");
  printf("Options \n\t-diff <file> \tPrint the differences to a file.\n");
  //  printf("\t-fuzz \tPercentage allowable difference (1-100)\n");
  printf("\t-dumpfile \tDump the input files to TGA format file.\n");
  printf("\t-dumpheader \tDisplay the image file TGA header info to stderr.\n");
  printf("\t-avg \tOnly display the average ssim.\n");
  printf("\t-threshold \tThe minimum ssim value required to pass.\n");
  printf("\t-maxthreshold \tThe number of ssim that are allowed to be below the threshold.\n");
  
}

