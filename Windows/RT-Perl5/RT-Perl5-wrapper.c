#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <process.h>

#define MAX_SIZE 500

int main(int argc,char *argv[] ) {
  char syspath[MAX_SIZE]="PATH=";
  char perlpath[MAX_SIZE]="";
  char cmd[MAX_SIZE]="";
  char buf[MAX_SIZE]="";
  char *args[argc+1];
  char *tok=NULL;
  DIR  *dir=NULL;
  int  i;

// Determiner le PATH courant qui devrait etre au dela d'Inskcape dans share/extensions/... 

  // On extrait les composantes du PATH courant jusqu'a inclure Inkscape
  // (s'il n'exite pas, on aura un repertoire qui ne contiendra pas Perl5
  //  de toutes facons).
  getcwd(buf, MAX_SIZE);
  tok=strtok(buf, "\\");
  while( tok != NULL) {
    strcat(perlpath, tok);
    strcat(perlpath,"\\");
    if (strcmp(tok, "Inkscape") == 0) {
        break;
    }
    tok=strtok(NULL, "\\");
  }

// Tester si le repertoire existe
// et s'il existe, le rajouter au PATH
// et construire le nom qualidié de l'executable

  if(tok != NULL) { // On a trouvé le répertoire Inkscape
      strcat(perlpath,"Perl5\\bin");
      dir=opendir(perlpath);
      if (dir != NULL) { // Le repertoire Perl5 exite ? Oui, l'ajouter dans PATH
          closedir(dir);
          strcpy(cmd, perlpath);
          strcat(cmd,"\\wperl.exe");
          strcat(syspath, getenv("PATH"));
          strcat(syspath, ";");
          strcat(perlpath, ";");
          strcat(syspath,perlpath);
          putenv(syspath);
      }
  }

  for(i=1;i<argc;++i) {
    args[i]=argv[i];
  }

  args[0]="wperl.exe";
  args[argc]=NULL;

  fclose(stdin);

  if(spawnv(P_OVERLAY, cmd, args)<0) {
    fprintf(stderr,"%s not found: something went wrong with the Origami-Ext intallation.\n",
           perlpath);
  }

}

