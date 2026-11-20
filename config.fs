# Android IDs and file capabilities, as on the stock firmware
# (vendor/etc/passwd, vendor/etc/group and etc/fs_config_files of build
# 49845030443200410). The vendor folder lives inside /system on this device,
# so the stock fs_config entries use system/vendor/... paths.

[AID_VENDOR_QTI_DIAG]
value:2901

[AID_VENDOR_QDSS]
value:2902

[AID_VENDOR_RFS]
value:2903

[AID_VENDOR_RFS_SHARED]
value:2904

[AID_VENDOR_ADPL_ODL]
value:2905

[AID_VENDOR_QRTR]
value:2906

[system/vendor/bin/cnss-daemon]
mode: 0755
user: AID_SYSTEM
group: AID_SYSTEM
caps: NET_BIND_SERVICE

[system/vendor/bin/pm-service]
mode: 0755
user: AID_SYSTEM
group: AID_SYSTEM
caps: NET_BIND_SERVICE

[system/vendor/bin/wcnss_filter]
mode: 0755
user: AID_BLUETOOTH
group: AID_BLUETOOTH
caps: BLOCK_SUSPEND
