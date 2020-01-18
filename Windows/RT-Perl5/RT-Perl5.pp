### job description for building strawberry perl

#Available '<..>' macros:
# <package_url>   is placeholder for http://strawberryperl.com/package
# <dist_sharedir> is placeholder for Perl::Dist::Strawberry's distribution sharedir
# <image_dir>     is placeholder for c:\strawberry

{
  app_version     => '5.30.1.1', #BEWARE: do not use '.0.0' in the last two version digits
  bits            => 32,
  beta            => 0,
  app_fullname    => 'Perl5 Runtime for Inkscape',
  app_simplename  => 'RT-Perl5',
  maketool        => 'gmake', # 'dmake' or 'gmake'
  build_job_steps => [
#
#
#  START OF JOB
#
#  ### NEXT STEP ###########################
    {
        plugin  => 'Perl::Dist::Strawberry::Step::BinaryToolsAndLibs',
        install_packages => {
            #tools
            'dmake'         => '<package_url>/kmx/32_tools/32bit_dmake-warn_20170512.zip',
            'pexports'      => '<package_url>/kmx/32_tools/32bit_pexports-0.47-bin_20170426.zip',
            'patch'         => '<package_url>/kmx/32_tools/32bit_patch-2.5.9-7-bin_20100110_UAC.zip',
            #gcc, gmake, gdb & co.
            'gcc-toolchain' => { url=>'<package_url>/kmx/32_gcctoolchain/mingw64-w32-gcc8.3.0_20190316.zip', install_to=>'c' },
            'gcc-license'   => '<package_url>/kmx/32_gcctoolchain/mingw64-w32-gcc8.3.0_20190316-lic.zip',
            #libs
            'bzip2'         => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_bzip2-1.0.6-bin_20190522.zip',
            'db'            => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_db-6.2.38-bin_20190522.zip',
            'expat'         => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_expat-2.2.6-bin_20190522.zip',
            'fontconfig'    => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_fontconfig-2.13.1-bin_20190522.zip',
            'freeglut'      => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_freeglut-3.0.0-bin_20190522.zip',
            'freetype'      => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_freetype-2.10.0-bin_20190522.zip',
            'gdbm'          => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_gdbm-1.18-bin_20190522.zip',
            'giflib'        => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_giflib-5.1.9-bin_20190522.zip',
            'gmp'           => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_gmp-6.1.2-bin_20190522.zip',
            'graphite2'     => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_graphite2-1.3.13-bin_20190522.zip',
            'harfbuzz'      => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_harfbuzz-2.3.1-bin_20190522.zip',
            'jpeg'          => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_jpeg-9c-bin_20190522.zip',
            'libffi'        => '<package_url>/kmx/32_libs/gcc83-2019Q3/32bit_libffi-3.3-rc0-bin_20190718.zip',
            'libgd'         => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libgd-2.2.5-bin_20190522.zip',
            'liblibiconv'   => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libiconv-1.16-bin_20190522.zip',
            'libidn2'       => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libidn2-2.1.1-bin_20190522.zip',
            'liblibpng'     => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libpng-1.6.37-bin_20190522.zip',
            'liblibssh2'    => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libssh2-1.8.2-bin_20190522.zip',
            'libunistring'  => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libunistring-0.9.10-bin_20190522.zip',
            'liblibxml2'    => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libxml2-2.9.9-bin_20190522.zip',
            'liblibXpm'     => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libXpm-3.5.12-bin_20190522.zip',
            'liblibxslt'    => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_libxslt-1.1.33-bin_20190522.zip',
            'mpc'           => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_mpc-1.1.0-bin_20190522.zip',
            'mpfr'          => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_mpfr-4.0.2-bin_20190522.zip',
            'openssl'       => '<package_url>/kmx/32_libs/gcc83-2019Q3/32bit_openssl-1.1.1c-bin_20190728.zip',
            'postgresql'    => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_postgresql-11.3-bin_20190522.zip',
            'readline'      => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_readline-8.0-bin_20190522.zip',
            't1lib'         => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_t1lib-5.1.2-bin_20190522.zip',
            'termcap'       => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_termcap-1.3.1-bin_20190522.zip',
            'tiff'          => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_tiff-4.0.10-bin_20190522.zip',
            'xz'            => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_xz-5.2.4-bin_20190522.zip',
            'zlib'          => '<package_url>/kmx/32_libs/gcc83-2019Q2/32bit_zlib-1.2.11-bin_20190522.zip',
            #special cases
            'libmysql'      => '<package_url>/kmx/32_libs/gcc71-2017Q2/32bit_mysql-5.7.16-bin_20170517.zip',
        },
    },
    ### NEXT STEP ###########################
    {
       plugin => 'Perl::Dist::Strawberry::Step::FilesAndDirs',
       commands => [
         { do=>'removefile', args=>[ '<image_dir>/c/i686-w64-mingw32/lib/libglut.a', '<image_dir>/c/i686-w64-mingw32/lib/libglut32.a' ] }, #XXX-32bit only workaround
         { do=>'movefile',   args=>[ '<image_dir>/c/lib/libdb-6.1.a', '<image_dir>/c/lib/libdb.a' ] }, #XXX ugly hack
         { do=>'removefile', args=>[ '<image_dir>/c/bin/gccbug', '<image_dir>/c/bin/ld.gold.exe', '<image_dir>/c/bin/ld.bfd.exe' ] },
         { do=>'removefile_recursive', args=>[ '<image_dir>/c', qr/.+\.la$/i ] }, # https://rt.cpan.org/Public/Bug/Display.html?id=127184
       ],
    },
    ### NEXT STEP ###########################
    {
        plugin     => 'Perl::Dist::Strawberry::Step::InstallPerlCore',
        url        => 'http://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.30.1.tar.gz',
        cf_email   => 'strawberry-perl@project', #IMPORTANT: keep 'strawberry-perl' before @
        perl_debug => 0,    # can be overridden by --perl_debug=N option
        perl_64bitint => 1, # ignored on 64bit, can be overridden by --perl_64bitint | --noperl_64bitint option
        buildoptextra => '-D__USE_MINGW_ANSI_STDIO',
        patch => { #DST paths are relative to the perl src root
            '<dist_sharedir>/msi/files/perlexe.ico'             => 'win32/perlexe.ico',
            '<dist_sharedir>/perl-5.30/win32_config.gc.tt'      => 'win32/config.gc',
            '<dist_sharedir>/perl-5.30/perlexe.rc.tt'           => 'win32/perlexe.rc',
            '<dist_sharedir>/perl-5.30/win32_config_H.gc'       => 'win32/config_H.gc', # enables gdbm/ndbm/odbm
        },
        license => { #SRC paths are relative to the perl src root
            'Readme'   => '<image_dir>/licenses/perl/Readme',
            'Artistic' => '<image_dir>/licenses/perl/Artistic',
            'Copying'  => '<image_dir>/licenses/perl/Copying',
        },
    },
    ### NEXT STEP ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::UpgradeCpanModules',
        exceptions => [
          # possible 'do' options: ignore_testfailure | skiptest | skip - e.g. 
          #{ do=>'ignore_testfailure', distribution=>'ExtUtils-MakeMaker-6.72' },
          #{ do=>'ignore_testfailure', distribution=>qr/^IPC-Cmd-/ },
          { do=>'ignore_testfailure', distribution=>qr/^Net-Ping-/ }, # 2.72 fails
          { do=>'ignore_testfailure', distribution=>qr/^autodie-/ }, # 2.31 fails FD!
        ]
    },
    ### NEXT STEP ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::InstallModules',
        modules => [
            { module=>'File::Copy::Recursive', ignore_testfailure=>1 },
            qw/Win32API::Registry Win32::TieRegistry Win32::API Win32::Env/,
            qw/ XML-LibXML /,
        ],

    },
    ### NEXT STEP ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::FixShebang',
        shebang => '#!perl',
    },
    ### NEXT STEP ###########################
    {
       plugin => 'Perl::Dist::Strawberry::Step::FilesAndDirs',
       commands => [
         # directories
         { do=>'createdir', args=>[ '<image_dir>/cpan' ] },
         { do=>'createdir', args=>[ '<image_dir>/cpan/sources' ] },
         { do=>'createdir', args=>[ '<image_dir>/win32' ] },
         # templated files
         { do=>'apply_tt', args=>[ '<dist_sharedir>/config-files/CPAN_Config.pm.tt', '<image_dir>/perl/lib/CPAN/Config.pm', {}, 1 ] }, #XXX-temporary empty tt_vars, no_backup=1
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/README.txt.tt', '<image_dir>/README.txt' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/DISTRIBUTIONS.txt.tt', '<image_dir>/DISTRIBUTIONS.txt' ] },
         # fixed files
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/licenses/License.rtf', '<image_dir>/licenses/License.rtf' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/relocation.pl.bat',    '<image_dir>/relocation.pl.bat' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/update_env.pl.bat',    '<image_dir>/update_env.pl.bat' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/cpan.ico',       '<image_dir>/win32/cpan.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/onion.ico',      '<image_dir>/win32/onion.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/perldoc.ico',    '<image_dir>/win32/perldoc.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/perlhelp.ico',   '<image_dir>/win32/perlhelp.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/strawberry.ico', '<image_dir>/win32/strawberry.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/win32.ico',      '<image_dir>/win32/win32.ico' ] },
         { do=>'copyfile', args=>[ '<dist_sharedir>/extra-files/win32/metacpan.ico',   '<image_dir>/win32/metacpan.ico' ] },
         # URLs
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/CPAN Module Search.url.tt',                  '<image_dir>/win32/CPAN Module Search.url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/MetaCPAN Search Engine.url.tt',              '<image_dir>/win32/MetaCPAN Search Engine.url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/Learning Perl (tutorials, examples).url.tt', '<image_dir>/win32/Learning Perl (tutorials, examples).url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/Live Support (chat).url.tt',                 '<image_dir>/win32/Live Support (chat).url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/Perl Documentation.url.tt',                  '<image_dir>/win32/Perl Documentation.url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/Strawberry Perl Release Notes.url.tt',       '<image_dir>/win32/Strawberry Perl Release Notes.url' ] },
         { do=>'apply_tt', args=>[ '<dist_sharedir>/extra-files/win32/Strawberry Perl Website.url.tt',             '<image_dir>/win32/Strawberry Perl Website.url' ] },
         # cleanup (remove unwanted files/dirs)
         { do=>'removefile', args=>[ '<image_dir>/perl/vendor/lib/Crypt/._test.pl', '<image_dir>/perl/vendor/lib/DBD/testme.tmp.pl' ] },
         { do=>'removefile', args=>[ '<image_dir>/perl/bin/nssm_32.exe.bat', '<image_dir>/perl/bin/nssm_64.exe.bat' ] },
         { do=>'removefile_recursive', args=>[ '<image_dir>/perl', qr/.+\.dll\.AA[A-Z]$/i ] },
         { do=>'removedir', args=>[ '<image_dir>/perl/bin/freeglut.dll' ] }, #XXX OpenGL garbage
         # cleanup cpanm related files
         { do=>'removedir', args=>[ '<image_dir>/perl/site/lib/MSWin32-x86-multi-thread-64int' ] },
         { do=>'removedir', args=>[ '<image_dir>/perl/site/lib/MSWin32-x86-multi-thread' ] },
         { do=>'removedir', args=>[ '<image_dir>/perl/site/lib/MSWin32-x64-multi-thread' ] },
       ],
    },
    ### NEXT STEP ###########################
    {
       plugin => 'Perl::Dist::Strawberry::Step::CreateRelocationFile',
       reloc_in  => '<dist_sharedir>/relocation/relocation.txt.initial',
       reloc_out => '<image_dir>/relocation.txt',
    },
    ### NEXT STEP ###########################
    #
    # FD Clean up to get minimal runtime
    #
    # #######################################
    {
       plugin => 'Perl::Dist::Strawberry::Step::FilesAndDirs',
       commands => [
    # Menage dans racine
       # supprime les repertoires autres que c et perl
         { do=>'removedir', args=>[ '<image_dir>/cpan' ] },
         { do=>'removedir', args=>[ '<image_dir>/licenses' ] },
# NEEDED FOR MSI
         { do=>'removedir', args=>[ '<image_dir>/win32' ] },
         { do=>'removefile', args=>[ '<image_dir>/DISTRIBUTIONS.txt',
                                     '<image_dir>/README.txt',
                                     '<image_dir>/relocation.pl.bat',
                                     '<image_dir>/relocation.txt',
                                     '<image_dir>/update_env.pl.bat'
                                   ],
         },
   # supprime dans perl/bin tout sauf les .dll, perl.exe et wperl.exe 
         { do=>'movedir', args=>[ '<image_dir>/perl/bin', '<image_dir>/perl/bin_orig' ] },
         { do=>'createdir', args=>[ '<image_dir>/perl/bin' ] },
         { do=>'smartcopy', args=>[ '<image_dir>/perl/bin_orig/*.dll', '<image_dir>/perl/bin' ] }, 
         { do=>'copyfile',   args=>[ '<image_dir>/perl/bin_orig/perl.exe', '<image_dir>/perl/bin' ] },
         { do=>'copyfile',   args=>[ '<image_dir>/perl/bin_orig/wperl.exe', '<image_dir>/perl/bin' ] },
         { do=>'removedir', args=>[ '<image_dir>/perl/bin_orig' ] },
   # Menage dans c
      # supprimer les repertoires inutiles
         { do=>'removedir', args=>[ '<image_dir>/c/libexec' ] },
         { do=>'removedir', args=>[ '<image_dir>/c/include' ] },
         { do=>'removedir', args=>[ '<image_dir>/c/lib' ] },
         { do=>'removedir', args=>[ '<image_dir>/c/i686-w64-mingw32' ] },
         { do=>'removedir', args=>[ '<image_dir>/c/etc' ] },
      #
      # copier toutes les .dll necessaires de c/bin vers perl/bin et virer le repertoire c
         { do=>'copyfile', args=>[ '<image_dir>/c/bin/libiconv-2_.dll', '<image_dir>/perl/bin/libiconv-2_.dll' ] },
         { do=>'copyfile', args=>[ '<image_dir>/c/bin/liblzma-5_.dll', '<image_dir>/perl/bin/liblzma-5_.dll' ] },
         { do=>'copyfile', args=>[ '<image_dir>/c/bin/libxml2-2_.dll', '<image_dir>/perl/bin/libxml2-2_.dll' ] },
         { do=>'copyfile', args=>[ '<image_dir>/c/bin/zlib1_.dll', '<image_dir>/perl/bin/zlib1_.dll' ] },
         { do=>'removedir', args=>[ '<image_dir>/c' ] },
        
    # Menage dans perl
      # supprime site vide
        { do=>'removedir', args=>[ '<image_dir>/perl/site' ] },
 
      # Renommer /perl/lib en /perl/lib-all et recreer /perl/lib
         { do=>'movedir', args=>[ '<image_dir>/perl/lib', '<image_dir>/perl/lib-all' ] },
         { do=>'createdir', args=>[ '<image_dir>/perl/lib' ] },
#YYY
    # Copie des modules necessaires au RT fichier/fichier
 
      # Directories
 
         #  directory auto
         { do=>'createdir', args=> [ '<image_dir>/perl/lib/auto' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Cwd', '<image_dir>/perl/lib/auto/Cwd' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Encode', '<image_dir>/perl/lib/auto/Encode' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Data', '<image_dir>/perl/lib/auto/Data' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Fcntl', '<image_dir>/perl/lib/auto/Fcntl' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/IO', '<image_dir>/perl/lib/auto/IO' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/List', '<image_dir>/perl/lib/auto/List' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/File', '<image_dir>/perl/lib/auto/File' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Math', '<image_dir>/perl/lib/auto/Math' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/POSIX', '<image_dir>/perl/lib/auto/POSIX' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Storable', '<image_dir>/perl/lib/auto/Storable' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Win32', '<image_dir>/perl/lib/auto/Win32' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/auto/Win32API', '<image_dir>/perl/lib/auto/Win32API' ] },

        # Modules directory
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/CORE', '<image_dir>/perl/lib/CORE' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Data', '<image_dir>/perl/lib/Data' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Encode', '<image_dir>/perl/lib/Encode' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Exporter', '<image_dir>/perl/lib/Exporter' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/File', '<image_dir>/perl/lib/File' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Getopt', '<image_dir>/perl/lib/Getopt' ] },
 
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/IO', '<image_dir>/perl/lib/IO' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/List', '<image_dir>/perl/lib/List' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Math', '<image_dir>/perl/lib/Math' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Scalar', '<image_dir>/perl/lib/Scalar' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Term', '<image_dir>/perl/lib/Term' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/Tie', '<image_dir>/perl/lib/Tie' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/lib-all/warnings', '<image_dir>/perl/lib/warnings' ] },


         # Files
         
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/bigint.pm', '<image_dir>/perl/lib/bigint.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/bignum.pm', '<image_dir>/perl/lib/bignum.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/bytes.pm', '<image_dir>/perl/lib/bytes.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Carp.pm', '<image_dir>/perl/lib/Carp.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Config.pm', '<image_dir>/perl/lib/Config.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Config_git.pl', '<image_dir>/perl/lib/Config_git.pl' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Config_heavy.pl', '<image_dir>/perl/lib/Config_heavy.pl' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/constant.pm', '<image_dir>/perl/lib/constant.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Cwd.pm', '<image_dir>/perl/lib/Cwd.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/DynaLoader.pm', '<image_dir>/perl/lib/DynaLoader.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Encode.pm', '<image_dir>/perl/lib/Encode.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Exporter.pm', '<image_dir>/perl/lib/Exporter.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Fcntl.pm', '<image_dir>/perl/lib/Fcntl.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/feature.pm', '<image_dir>/perl/lib/feature.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/integer.pm', '<image_dir>/perl/lib/integer.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/IO.pm', '<image_dir>/perl/lib/IO.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/lib.pm', '<image_dir>/perl/lib/lib.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/overload.pm', '<image_dir>/perl/lib/overload.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/overloading.pm', '<image_dir>/perl/lib/overloading.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/parent.pm', '<image_dir>/perl/lib/parent.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/perl5db.pl', '<image_dir>/perl/lib/perl5db.pl' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/POSIX.pm', '<image_dir>/perl/lib/POSIX.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/SelectSaver.pm', '<image_dir>/perl/lib/SelectSaver.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Storable.pm', '<image_dir>/perl/lib/Storable.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/strict.pm', '<image_dir>/perl/lib/strict.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Symbol.pm', '<image_dir>/perl/lib/Symbol.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/utf8.pm', '<image_dir>/perl/lib/utf8.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/vars.pm', '<image_dir>/perl/lib/vars.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/warnings.pm', '<image_dir>/perl/lib/warnings.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/Win32.pm', '<image_dir>/perl/lib/Win32.pm' ] },
         { do=>'copyfile', args=> [ '<image_dir>/perl/lib-all/XSLoader.pm', '<image_dir>/perl/lib/XSLoader.pm' ] },

      # Suppression du repertoire /perl/lib-all
        { do=>'removedir', args=>[ '<image_dir>/perl/lib-all' ] },

#Vendor
#     # directory <auto
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/Math', '<image_dir>/perl/lib/auto/Math' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/Win32', '<image_dir>/perl/lib/auto/Win32' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/Win32API', '<image_dir>/perl/lib/auto/Win32API' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/XML/NamespaceSupport', '<image_dir>/perl/lib/auto/XML/NamespaceSupport' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/XML/SAX', '<image_dir>/perl/lib/auto/XML/SAX' ] },

      # Modules directories
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/Math', '<image_dir>/perl/lib/Math' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/File', '<image_dir>/perl/lib/File' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/Win32', '<image_dir>/perl/lib/Win32' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/Win32API', '<image_dir>/perl/lib/Win32API' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/auto/XML/LibXML', '<image_dir>/perl/lib/auto/XML/LibXML' ] },
         { do=>'copydir', args=> [ '<image_dir>/perl/vendor/lib/XML', '<image_dir>/perl/lib/XML' ] },
        { do=>'removedir', args=>[ '<image_dir>/perl/vendor' ] },
# end vendor         
 
      # supprime tous les .pod de perl/lib
        { do=>'removefile_recursive', args=>[ '<image_dir>/perl/lib', qr/.+\.pod$/i ] }, 
        { do=>'removedir', args=>[ '<image_dir>/perl/lib/pods' ] },

       ],
    },
   ### NEXT STEP ###########################
   {
      plugin => 'Perl::Dist::Strawberry::Step::OutputZIP', # no options needed
   },
   
# NO MSI by now...
#
#   ### NEXT STEP ###########################
#   {
#      disable => $ENV{SKIP_MSI_STEP}, ### hack
#      plugin => 'Perl::Dist::Strawberry::Step::OutputMSI',
#      exclude  => [
#          #'dirname\subdir1\subdir2',
#          #'dirname\file.pm',
#          'relocation.pl.bat',
#          'update_env.pl.bat',
#      ],
#      msi_upgrade_code    => '45F906A2-F86E-335B-992F-990E8BEABC13', #BEWARE: fixed value for all 32bit releases (for ever)
#      app_publisher       => 'strawberryperl.com project',
#      url_about           => 'http://strawberryperl.com/',
#      url_help            => 'http://strawberryperl.com/support.html',
#      msi_root_dir        => 'Strawberry',
#      msi_main_icon       => '<dist_sharedir>\msi\files\strawberry.ico',
#      msi_license_rtf     => '<dist_sharedir>\msi\files\License-short.rtf',
#      msi_dialog_bmp      => '<dist_sharedir>\msi\files\StrawberryDialog.bmp',
#      msi_banner_bmp      => '<dist_sharedir>\msi\files\StrawberryBanner.bmp',
#      msi_debug           => 0,
#
#      start_menu => [ # if "description" is missing it will be set to the same value as "name"
#        { type=>'shortcut', name=>'Perl (command line)', icon=>'<dist_sharedir>\msi\files\perlexe.ico', description=>'Quick way to get to the command line in order to use Perl', target=>'[SystemFolder]cmd.exe', workingdir=>'PersonalFolder' },
#        { type=>'shortcut', name=>'Strawberry Perl Release Notes', icon=>'<dist_sharedir>\msi\files\strawberry.ico', target=>'[d_win32]Strawberry Perl Release Notes.url', workingdir=>'d_win32' },
#        { type=>'shortcut', name=>'Strawberry Perl README', target=>'[INSTALLDIR]README.txt', workingdir=>'INSTALLDIR' },
#        { type=>'folder',   name=>'Tools', members=>[
#             { type=>'shortcut', name=>'CPAN Client', icon=>'<dist_sharedir>\msi\files\cpan.ico', target=>'[d_perl_bin]cpan.bat', workingdir=>'d_perl_bin' },
#             { type=>'shortcut', name=>'Create local library areas', icon=>'<dist_sharedir>\msi\files\strawberry.ico', target=>'[d_perl_bin]llw32helper.bat', workingdir=>'d_perl_bin' },
#        ] },
#        { type=>'folder', name=>'Related Websites', members=>[
#             { type=>'shortcut', name=>'CPAN Module Search', icon=>'<dist_sharedir>\msi\files\cpan.ico', target=>'[d_win32]CPAN Module Search.url', workingdir=>'d_win32' },
#             { type=>'shortcut', name=>'MetaCPAN Search Engine', icon=>'<dist_sharedir>\msi\files\metacpan.ico', target=>'[d_win32]MetaCPAN Search Engine.url', workingdir=>'d_win32' },
#             { type=>'shortcut', name=>'Perl Documentation', icon=>'<dist_sharedir>\msi\files\perldoc.ico', target=>'[d_win32]Perl Documentation.url', workingdir=>'d_win32' },
#             { type=>'shortcut', name=>'Strawberry Perl Website', icon=>'<dist_sharedir>\msi\files\strawberry.ico', target=>'[d_win32]Strawberry Perl Website.url', workingdir=>'d_win32' },
#             { type=>'shortcut', name=>'Learning Perl (tutorials, examples)', icon=>'<dist_sharedir>\msi\files\perldoc.ico', target=>'[d_win32]Learning Perl (tutorials, examples).url', workingdir=>'d_win32' },
#             { type=>'shortcut', name=>'Live Support (chat)', icon=>'<dist_sharedir>\msi\files\onion.ico', target=>'[d_win32]Live Support (chat).url', workingdir=>'d_win32' },
#        ] },
#      ],
  ],
}
