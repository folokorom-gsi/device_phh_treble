#!/system/bin/sh

[ "$(getprop vold.decrypt)" == "trigger_restart_min_framework" ] && exit 0
if [ -f /vendor/bin/mtkmal ];then
    if [ "$(getprop persist.mtk_ims_support)" == 1 -o "$(getprop persist.mtk_epdg_support)" == 1 ];then
        setprop persist.mtk_ims_support 0
        setprop persist.mtk_epdg_support 0
        reboot
    fi
fi

if getprop ro.vendor.build.fingerprint |grep -q Xiaomi/clover/clover;then
    #FIXME Force enable tap to wake
    chown system system /sys/devices/soc/c177000.i2c/i2c-3/3-0038/fts_gesture_mode
    chmod 0660 /sys/devices/soc/c177000.i2c/i2c-3/3-0038/fts_gesture_mode
    echo "1" > /sys/devices/soc/c177000.i2c/i2c-3/3-0038/fts_gesture_mode
fi

#Clear looping services
sleep 30
getprop | \
    grep restarting | \
    sed -nE -e 's/\[([^]]*).*/\1/g'  -e 's/init.svc.(.*)/\1/p' |
    while read svc ;do
        setprop ctl.stop $svc
    done

if grep -qF android.hardware.boot /vendor/manifest.xml;then
	bootctl mark-boot-successful
fi
