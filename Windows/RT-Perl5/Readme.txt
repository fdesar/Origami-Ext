RT-Perl5.pp really is the "source" of the Perl runtime for Origami-EXT !

It is built in 32bits upon strawberryperl (http://strawberryperl.com), version
5.30.1 (32 or 64bits : it doesn't matter).

The choice of a 32bits version is to have it run on every systems, even old ones
knowing that the potential slow down on 64bits systems is really insignificant for
its usage.

The main difference with the standard .pp file from Perl::Dist source file are :

  - Cleanup in the Build_Modules section to keep only XML and Win32 needed modules

  - A new Files_and_Dir section to rebuid the architecture, keeping almosy ONLY the
    needed files, removing a lot of modules (even some core ones !) and all of the
    .html and .pod documentation files.

  - Removing the Build_Wix section and all others related to building relocating Perl.


The way to buid it up again is as follow :

  - Download and install strawberry Perl (the non portable version will be
    easier but you'd better not put it in the default c:\strawberry directory)

  - execute portableshell.bat from the Starberry Perl directory to activate Perl
    if you installed the portable version

  - use CPAN to install the Perl::Dist::Strawberry version :
       cpan install Perl::Dist::Strawberry

  - run the buid command :
    perldist_strawberry -restorepoints -working_dir="c:\RT-Perl5_build" -image_dir="C:\RT-Perl5" -job <PATH to the RT-Perl5.pp>\RT-Perl5.pp
 
  - after a looooooooooooong time, you should get in the C:\RT-Perl5_build\ouput a file named RT_Perl5-5.30.1.1.zip :
    this will be the RT-Per5.zip file.

  - save the file somewhere, remove c:\RT-Perl5* directories, uninstall Strawberry Perl distribution if you wish to
    cleanup your system (know that Strawberry Perl and mainly RT-Perl5 & RT-Perl5_build take a huge amount of disk
    space!).

  - That's all, folks.


Note : If you feel lucky, you can remove the -restorepoints option and if you are very confident, you can add the option
       -notest_modules to have the quickest build.

       On the other hand, if you are paranoid and have a lot of time, you can add the option -test_core to deaply test ALL
       modules, even the Perl core ones : in this case, you have your week-end free.

Good luck and enjoy !
