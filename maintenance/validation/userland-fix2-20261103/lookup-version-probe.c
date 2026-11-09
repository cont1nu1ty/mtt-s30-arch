#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct ext { const char *name; int version; };
struct mesa { struct ext base; const char *version; void *(*create)(int,int,const struct ext **,const struct ext **,void **,void *); };
void *(*screen_creator)(int,int,const struct ext **,const struct ext **,void **,void *);
__attribute__((noinline)) void probe_ready(void) { __asm__ volatile ("" ::: "memory"); }
int main(int argc,char **argv) {
 if(argc != 3 && argc != 4) return 3;
 if(argc == 4 && !dlopen(argv[3],RTLD_NOW|RTLD_LOCAL)){fprintf(stderr,"%s\n",dlerror());return 3;}
 void *lib=dlopen(argv[1],RTLD_NOW|RTLD_LOCAL);
 if(!lib){ fprintf(stderr,"%s\n",dlerror());return 3; }
 const struct ext **(*get)(void)=dlsym(lib,"__driDriverGetExtensions_mtgpu");
 if(!get) return 3;
 const struct ext **driver=get();
 const struct mesa *m=NULL;
 for(int i=0;driver[i];i++) if(!strcmp(driver[i]->name,"DRI_Mesa")) m=(const void *)driver[i];
 if(!m || strcmp(m->version,"23.2.1-1ubuntu3.1~22.04.3")) return 3;
 struct {struct ext base; void *lookup,*validate,*validated;} lookup={{"DRI_IMAGE_LOOKUP",atoi(argv[2])},NULL,NULL,NULL};
 const struct ext *extensions[]={&lookup.base,NULL};
 void *configs=NULL;
 screen_creator=m->create;
 probe_ready();
 /* Only run under the companion debugger: it terminates at the extension
  * gate, BEFORE any screen/DRM initialization or callback is executed. */
 void *screen=screen_creator(0,-1,extensions,driver,&configs,NULL);
 fprintf(stderr,"UNEXPECTED return %p\n",screen);
 return 4;
}
