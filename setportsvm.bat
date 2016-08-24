FOR /L %%i IN (56000, 1, 56500) DO (
"C:\Program Files\Oracle\VirtualBox\VBoxManage" modifyvm "default" --natpf1 "tcp-port%%i,tcp,,%%i,,%%i"
)