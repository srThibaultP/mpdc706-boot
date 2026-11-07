setenv bootargs console=ttyS0,115200 console=tty1 root=/dev/mmcblk0p2 rootwait rw panic=10
fatload mmc 0 ${kernel_addr_r} zImage
fatload mmc 0 ${fdt_addr_r} sun8i-a23-inet86dz.dtb
bootz ${kernel_addr_r} - ${fdt_addr_r}
