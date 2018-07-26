-E BASH_ENV /usr/share/lmod/lmod/init/bash
-E BASH_FUNC_ml() '() {  eval $($LMOD_DIR/ml_cmd "$@") }'
-E BASH_FUNC_module() '() {  eval $($LMOD_CMD bash "$@");  [ $? = 0 ] && eval $(${LMOD_SETTARG_CMD:-:} -s sh) }'
-E DISPLAY 10.142.0.4:11.0
-E HISTCONTROL ignoredups
-E HISTIGNORE 'opaswitchadmin*:opasaquery*:opaswquery*'
-E HISTSIZE 1000
-E HOME /mnt/storage/home/dg17763
-E HOSTNAME bc4login5.bc4.acrc.priv
-E LANG en_GB.UTF-8
-E LC_ALL C
-E LC_CTYPE POSIX
-E LC_LANG C
-E LD_LIBRARY_PATH /mnt/storage/software/languages/gcc-7.2.0/lib:/mnt/storage/software/languages/gcc-7.2.0/lib64
-E LESSOPEN '||/usr/bin/lesspipe.sh %s'
-E LMOD_CMD /usr/share/lmod/lmod/libexec/lmod
-E LMOD_COLORIZE yes
-E LMOD_DEFAULT_MODULEPATH /mnt/storage/easybuild/modules/local:/mnt/storage/easybuild/modules/all:/etc/modulefiles:/usr/share/modulefiles:/usr/share/Modules/modulefiles:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core
-E LMOD_DIR /usr/share/lmod/lmod/libexec
-E LMOD_FULL_SETTARG_SUPPORT no
-E LMOD_PKG /usr/share/lmod/lmod
-E LMOD_PREPEND_BLOCK normal
-E LMOD_SETTARG_CMD :
-E LMOD_VERSION 6.5.1
-E LMOD_arch x86_64
-E LMOD_sys Linux
-E LOADEDMODULES languages/anaconda3/5.2.0-tflow-1.7:build/gcc-7.2.0:tools/git/2.18.0
-E LOGNAME dg17763
-E LS_COLORS 'rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'
-E MAIL /var/spool/mail/dg17763
-E MANPATH /mnt/storage/software/languages/anaconda/Anaconda3-5.2.0-tflow-1.7/share/man:/usr/share/lmod/lmod/share/man:/usr/local/share/man:/usr/share/man:/opt/ddn/ime/share/man:/opt/ddn/ime/share/man
-E MAN_PATH /mnt/storage/software/languages/gcc-7.2.0/share
-E MODULEPATH /mnt/storage/easybuild/modules/local:/mnt/storage/easybuild/modules/all:/etc/modulefiles:/usr/share/modulefiles:/usr/share/Modules/modulefiles:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core
-E MODULEPATH_ROOT /usr/share/modulefiles
-E MODULESHOME /usr/share/lmod/lmod
-E OLDPWD /mnt/storage/home/dg17763/spec_install/benchspec/OMP2012/358.botsalgn
-E PATH /mnt/storage/home/dg17763/spec_install/bin:/mnt/storage/software/tools/git-2.18.0/bin:/mnt/storage/software/languages/gcc-7.2.0/bin:/mnt/storage/software/languages/anaconda/Anaconda3-5.2.0-tflow-1.7/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lpp/mmfs/bin:/opt/ddn/ime/bin:/mnt/storage/home/dg17763/.local/bin:/mnt/storage/home/dg17763/bin
-E QT_GRAPHICSSYSTEM_CHECKED 1
-E SHELL /bin/bash
-E SPEC /mnt/storage/home/dg17763/spec_install
-E SPECDB_PWD /mnt/storage/home/dg17763/spec_install/benchspec/OMP2012
-E SPECPERLLIB /mnt/storage/home/dg17763/spec_install/bin:/mnt/storage/home/dg17763/spec_install/bin/lib
-E SSH_CLIENT '137.222.103.3 46676 22'
-E SSH_CONNECTION '137.222.103.3 46676 172.26.2.14 22'
-E SSH_TTY /dev/pts/23
-E TERM xterm-256color
-E USER dg17763
-E XDG_RUNTIME_DIR /run/user/346303
-E XDG_SESSION_ID 614757
-E _LMFILES_ /mnt/storage/easybuild/modules/local/languages/anaconda3/5.2.0-tflow-1.7.lua:/mnt/storage/easybuild/modules/all/build/gcc-7.2.0.lua:/mnt/storage/easybuild/modules/local/tools/git/2.18.0.lua
-E _ModuleTable001_ X01vZHVsZVRhYmxlXz17WyJhY3RpdmVTaXplIl09MyxiYXNlTXBhdGhBPXsiL21udC9zdG9yYWdlL2Vhc3lidWlsZC9tb2R1bGVzL2xvY2FsIiwiL21udC9zdG9yYWdlL2Vhc3lidWlsZC9tb2R1bGVzL2FsbCIsIi9ldGMvbW9kdWxlZmlsZXMiLCIvdXNyL3NoYXJlL21vZHVsZWZpbGVzIiwiL3Vzci9zaGFyZS9Nb2R1bGVzL21vZHVsZWZpbGVzIiwiL3Vzci9zaGFyZS9tb2R1bGVmaWxlcy9MaW51eCIsIi91c3Ivc2hhcmUvbW9kdWxlZmlsZXMvQ29yZSIsIi91c3Ivc2hhcmUvbG1vZC9sbW9kL21vZHVsZWZpbGVzL0NvcmUiLH0sWyJjX3JlYnVpbGRUaW1lIl09ZmFsc2UsWyJjX3Nob3J0VGltZSJdPWZhbHNlLGZhbWlseT17fSxpbmFjdGl2ZT17fSxtVD17YnVpbGQ9e1siRk4i
-E _ModuleTable002_ XT0iL21udC9zdG9yYWdlL2Vhc3lidWlsZC9tb2R1bGVzL2FsbC9idWlsZC9nY2MtNy4yLjAubHVhIixbImRlZmF1bHQiXT0wLFsiZnVsbE5hbWUiXT0iYnVpbGQvZ2NjLTcuMi4wIixbImxvYWRPcmRlciJdPTIscHJvcFQ9e30sWyJzaG9ydCJdPSJidWlsZCIsWyJzdGF0dXMiXT0iYWN0aXZlIix9LFsibGFuZ3VhZ2VzL2FuYWNvbmRhMyJdPXtbIkZOIl09Ii9tbnQvc3RvcmFnZS9lYXN5YnVpbGQvbW9kdWxlcy9sb2NhbC9sYW5ndWFnZXMvYW5hY29uZGEzLzUuMi4wLXRmbG93LTEuNy5sdWEiLFsiZGVmYXVsdCJdPTAsWyJmdWxsTmFtZSJdPSJsYW5ndWFnZXMvYW5hY29uZGEzLzUuMi4wLXRmbG93LTEuNyIsWyJsb2FkT3JkZXIiXT0xLHByb3BUPXt9LFsic2hvcnQiXT0ibGFu
-E _ModuleTable003_ Z3VhZ2VzL2FuYWNvbmRhMyIsWyJzdGF0dXMiXT0iYWN0aXZlIix9LFsidG9vbHMvZ2l0Il09e1siRk4iXT0iL21udC9zdG9yYWdlL2Vhc3lidWlsZC9tb2R1bGVzL2xvY2FsL3Rvb2xzL2dpdC8yLjE4LjAubHVhIixbImRlZmF1bHQiXT0wLFsiZnVsbE5hbWUiXT0idG9vbHMvZ2l0LzIuMTguMCIsWyJsb2FkT3JkZXIiXT0zLHByb3BUPXt9LFsic2hvcnQiXT0idG9vbHMvZ2l0IixbInN0YXR1cyJdPSJhY3RpdmUiLH0sfSxtcGF0aEE9eyIvbW50L3N0b3JhZ2UvZWFzeWJ1aWxkL21vZHVsZXMvbG9jYWwiLCIvbW50L3N0b3JhZ2UvZWFzeWJ1aWxkL21vZHVsZXMvYWxsIiwiL2V0Yy9tb2R1bGVmaWxlcyIsIi91c3Ivc2hhcmUvbW9kdWxlZmlsZXMiLCIvdXNyL3NoYXJlL01vZHVs
-E _ModuleTable004_ ZXMvbW9kdWxlZmlsZXMiLCIvdXNyL3NoYXJlL21vZHVsZWZpbGVzL0xpbnV4IiwiL3Vzci9zaGFyZS9tb2R1bGVmaWxlcy9Db3JlIiwiL3Vzci9zaGFyZS9sbW9kL2xtb2QvbW9kdWxlZmlsZXMvQ29yZSIsfSxbInN5c3RlbUJhc2VNUEFUSCJdPSIvbW50L3N0b3JhZ2UvZWFzeWJ1aWxkL21vZHVsZXMvbG9jYWw6L21udC9zdG9yYWdlL2Vhc3lidWlsZC9tb2R1bGVzL2FsbDovZXRjL21vZHVsZWZpbGVzOi91c3Ivc2hhcmUvbW9kdWxlZmlsZXM6L3Vzci9zaGFyZS9Nb2R1bGVzL21vZHVsZWZpbGVzOi91c3Ivc2hhcmUvbW9kdWxlZmlsZXMvTGludXg6L3Vzci9zaGFyZS9tb2R1bGVmaWxlcy9Db3JlOi91c3Ivc2hhcmUvbG1vZC9sbW9kL21vZHVsZWZpbGVzL0NvcmUiLFsidmVy
-E _ModuleTable005_ 'c2lvbiJdPTIsfQ=='
-E _ModuleTable_Sz_ 5
-C /mnt/storage/home/dg17763/spec_install/benchspec/OMP2012/363.swim/run/run_base_train_x.0000
-i swim.in -o swim.out -e swim.err ../run_base_train_x.0000/swim_base.x
