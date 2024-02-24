time sh -c '
# Hah! No need for a shebang! Plus it"s timed.
echo The disk you are currently running in need firefox installed into onboot.
echo Do not run as root, but give sudo permissions.

debugger (){
	if [ "$DEBUGING" = "Y" ]; then
		pwd
		read -p "$1" || "debug"
	fi
}

echo "Use ram? (~1gb + website size, if using RAM iso is saved to ~/) Y/n"
read input

if [ "$input" = "Y" ]; then
	DIR=/tmp/isoNewscriptTemp/	
else 
	DIR=/home/tc/hometemp/
fi

echo "TinyCore CD location? (default sr0)"
read isoMount

if [ !$isoMount ]; then
	isoMount=sr0
fi

echo "Skip bootcodes (for beta testing)? (Y/n)"
read skipbootcodes

echo "Debug messages? (Y/n)"
read DEBUGING

debugger "Debug messages on."

echo The temparary directory is $DIR/
read -p "Proceed?"

mount /dev/$isoMount

sudo rm -rf "$DIR/"
mkdir "$DIR/"

echo "cd_location = /mnt/$isoMount/
temp_dir = $DIR/" > $DIR/ezremaster.cfg

remaster.sh $DIR/ezremaster.cfg extractimage 1> /dev/null # Print non-error messages to the void

cd $DIR 
EXTNAME=zExtension
mkdir customExtension/
cd customExtension/
mkdir -m 755 opt
mkdir -pm 755 "./home/tc/.X.d"
cd opt
cp -r /home/tc/website/ ./website/
cd $DIR/customExtension/home/tc/.X.d
echo "firefox --kiosk -new-tab-page \"file:///opt/kiosk/website/index.html\" &" | sudo tee ./startup
cd ..
mkdir -pm 755 "./.mozilla/firefox/kiosk.default"
cd ./.mozilla/firefox
echo "[General]

StartWithLastProfile=1

[Profile0]
Name=kiosk
IsRelative=1
Path=Profiles/kiosk.default" | sudo tee profiles.ini 1> /dev/null
cd kiosk.default
echo -e "user_pref(\"trailhead.firstrun.didSeeAboutWelcome\", true);\nuser_pref(\"browser.startup.homepage_override.mstone\", \"ignore\");\n" | sudo tee prefs.js 1> /dev/null

cd ../../../

echo "/usr/local/bin/Xfbdev -mouse /dev/input/mice,5 -nolisten tcp -I >/dev/null 2>&1 &
export XPID=\$!
waitforX || ! echo failed in waitforX || exit
\"\$DESKTOP\" 2>/tmp/wm_errors &
export WM_PID=\$!
[ -x \$HOME/.setbackground ] && \$HOME/.setbackground
[ -x \$HOME/.mouse_config ] && \$HOME/.mouse_config &
[ \$(which \"\$ICONS\".sh) ] && \${ICONS}.sh &
[ -d \"/usr/local/etc/X.d\" ] && find \"/usr/local/etc/X.d\" -type f -o -type l | sort | while read F; do . \"\$F\"; done
[ -d \"\$HOME/.X.d\" ] && find \"\$HOME/.X.d\" -type f -o -type l | sort | while read F; do . \"\$F\"; done" | tee ./.xsession 1> /dev/null

cd $DIR/customExtension/opt
sudo find . -type f -exec chmod 664 {} +
# Copied from askubuntu.com/a/685738

cd ..
debugger "debug"

sudo chown root:staff *
sudo chmod 775 home 
cd home/tc
debugger "debug"
sudo chown -R tc:staff .
sudo chmod -R 755 .
sudo chmod 700 .xsession
sudo chmod -R 750 .local
sudo chmod 644 .ashrc
sudo chmod 664 .ash_*
sudo chmod 600 .Xauth*

cd $DIR/customExtension
debugger "debug"
sudo mksquashfs ./ "../$EXTNAME.tcz" 2> /dev/null

echo "Made custom extension!"

cd $DIR/image/cde/optional

ALL_DEPS0="squashfs-tools.tcz,liblzma.tcz,lzo.tcz,libzstd.tcz,liblz4.tcz,curl.tcz,ca-certificates.tcz,openssl.tcz,wget.tcz,bzip2.tcz,bzip2-lib.tcz,file.tcz,gtk3.tcz,libepoxy.tcz,at-spi2-atk.tcz,at-spi2-core.tcz,dbus.tcz,expat2.tcz,elogind.tcz,acl.tcz,attr.tcz,libcap.tcz,attr.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,libICE.tcz,libSM.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,atk.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,gdk-pixbuf2.tcz,libtiff.tcz,libjpeg-turbo.tcz,liblzma.tcz,libzstd.tcz,libpng.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,shared-mime-info.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,libxml2.tcz,liblzma.tcz,libXcomposite.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,pango.tcz,cairo.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,fontconfig.tcz,expat2.tcz,freetype.tcz,libpng.tcz,harfbuzz.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,graphite.tcz,bzip2-lib.tcz,pixman.tcz,libpng.tcz,libXrender.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libEGL.tcz,libGL.tcz,libXdamage.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXxf86vm.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libdrm.tcz,libpciaccess.tcz,udev-lib.tcz,libxshmfence.tcz,wayland.tcz,libffi.tcz,expat2.tcz,libxml2.tcz,liblzma.tcz,libGLESv2.tcz,libGL.tcz,libXdamage.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXxf86vm.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libdrm.tcz,libpciaccess.tcz,udev-lib.tcz,libxshmfence.tcz,libXft.tcz,fontconfig.tcz,expat2.tcz,freetype.tcz,libpng.tcz,harfbuzz.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,graphite.tcz,bzip2-lib.tcz,freetype.tcz,libpng.tcz,harfbuzz.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,graphite.tcz,bzip2-lib.tcz,libXrender.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,fribidi.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,libXcursor.tcz,libXrender.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXinerama.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXrandr.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXrender.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXi.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libxkbcommon.tcz,xkeyboard-config.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,wayland-protocols.tcz,wayland.tcz,libffi.tcz,expat2.tcz,libxml2.tcz,liblzma.tcz,libasound.tcz,dbus-glib.tcz,dbus.tcz,expat2.tcz,elogind.tcz,acl.tcz,attr.tcz,libcap.tcz,attr.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,hicolor-icon-theme.tcz,cairo.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,fontconfig.tcz,expat2.tcz,freetype.tcz,libpng.tcz,harfbuzz.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,graphite.tcz,bzip2-lib.tcz,pixman.tcz,libpng.tcz,libXrender.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libEGL.tcz,libGL.tcz,libXdamage.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXxf86vm.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libdrm.tcz,libpciaccess.tcz,udev-lib.tcz,libxshmfence.tcz,wayland.tcz,libffi.tcz,expat2.tcz,libxml2.tcz,liblzma.tcz,libGLESv2.tcz,libGL.tcz,libXdamage.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXxf86vm.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libdrm.tcz,libpciaccess.tcz,udev-lib.tcz,libxshmfence.tcz,gamin.tcz,libGLESv2.tcz,libGL.tcz,libXdamage.tcz,libXfixes.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXxf86vm.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libdrm.tcz,libpciaccess.tcz,udev-lib.tcz,libxshmfence.tcz,gdk-pixbuf2.tcz,libtiff.tcz,libjpeg-turbo.tcz,liblzma.tcz,libzstd.tcz,libpng.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,shared-mime-info.tcz,glib2.tcz,libffi.tcz,pcre21042.tcz,libxml2.tcz,liblzma.tcz,gcc_libs.tcz,ca-certificates.tcz,openssl.tcz,libXt.tcz,libICE.tcz,libSM.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz,libXtst.tcz,libXi.tcz,libXext.tcz,libX11.tcz,libxcb.tcz,libXau.tcz,libXdmcp.tcz"
# Saved in one line to save space. Original is at pastebin.com/raw/aJWvq6Cw

sudo cp -f /etc/sysconfig/tcedir/optional/firefox.tcz* ./

ALL_DEPS0=`echo $ALL_DEPS0 | sed "s!,!\n!g"`

for Z in $ALL_DEPS0; do
	echo $Z
	sudo cp -n /etc/sysconfig/tcedir/optional/$Z* ./
done
# Copied from firefox_getLatest.sh

debugger "Copied firefox"

# Just in case.
sudo cp -n /etc/sysconfig/tcedir/optional/Xfbdev.tcz* ./

echo "Deleting useless extensions."

sudo rm -f ./wbar*
sudo rm -f ./flwm*

echo "Adding website!"

sudo cp -f "$DIR/$EXTNAME.tcz" ./
md5sum "$EXTNAME.tcz" | sudo tee "$EXTNAME.tcz.md5.txt"

echo "Cleaning up!"

sudo rm -f *.dep
sudo chmod 444 *.*

debugger "debug" 

cd ..

sudo chmod 777 *.lst
debugger "debug"

sudo rm -f *.lst
debugger "debug"
sudo touch copy2fs.flg
cd optional
ls -1 *.tcz | sudo tee ../kioskbase.lst 1> /dev/null
cd ..
debugger "ls -1 *.tcz | sudo tee ../kioskbase.lst 1> /dev/null"
sudo chown -c root:root *.*
debugger "sudo chown -c root:root *"
sudo chmod -c 555 k*
debugger "sudo chmod -c 555 k*"
sudo chmod -c 444 c*
debugger "debug"

echo "Added apps!"

if [ "$skipbootcodes" == "Y" ]; then
	echo "Skipping ISOLINUX bootcodes as requested."
else
	cd ../boot/isolinux
	sudo chmod -c 777 isolinux.cfg
	echo -e "DEFAULT corepure64\nLABEL corepure64\nKERNEL /boot/vmlinuz64\nINITRD /boot/corepure64.gz\nAPPEND loglevel=2 cde vga=789 lst=kioskbase.lst showapps norestore desktop=fltk-1.3" > isolinux.cfg
	
	sudo chown -c root:root isolinux.cfg
	sudo chmod -c 444 isolinux.cfg
	
	sudo chmod -Rc 777 f*
	sudo rm -rf f*
	sudo chmod -Rc 777 menu.c32
	sudo rm -f menu.c32

	echo "ISOLINUX bootcodes done!"
fi

time remaster.sh "$DIR/ezremaster.cfg" package
echo "Done!"
echo "ISO saved in"
echo "$DIR"
'
