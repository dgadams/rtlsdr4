# RTLSDR4

Docker image for **RTL-SDR v4**, including libraries and binaries compatible with RTL-SDR v1-v4 devices.

- **Base:** Debian Linux  
- **Binaries:** `/usr/local/bin`  
- **Libraries:** `/usr/local/lib`  
- **Source:** [dgadams/rtlsdr4](https://github.com/dgadams/rtlsdr4)
- **Docker Image** [dgadams/rtlsdr4](https://hub.docker.com/r/dgadams/rtlsdr4)

---

## 🐳 Example: Docker Compose

```yaml
name: rtl-tcp
services:
  rtl-tcp:
    image: dgadams/rtlsdr4:latest
    container_name: rtl-tcp
    restart: unless-stopped
    command: "rtl_tcp -d 1 -a 0.0.0.0 -p 1234"
    devices:
      - /dev/bus/usb
    ports:
      - "1234:1234"
```

Connect via:  
```
rtl_tcp://<host-ip>:1234
```

---

## 🧠 Linux Setup (Debian/Ubuntu)
Based on the [official guide](www.rtl-sdr.com/V4/).

### 1. Remove old drivers
```bash
sudo apt purge ^librtlsdr
sudo rm -rvf /usr/{lib,local/lib}/librtlsdr* /usr/{include,local/include}/rtl* /usr/local/bin/rtl_*
```

### 2. Install latest drivers
```bash
sudo apt-get install -y libusb-1.0-0-dev git cmake pkg-config
git clone https://github.com/osmocom/rtl-sdr
cd rtl-sdr && mkdir build && cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make && sudo make install
sudo cp ../rtl-sdr.rules /etc/udev/rules.d/
sudo ldconfig
```

### 3. Blacklist DVB-T drivers
```bash
echo 'blacklist dvb_usb_rtl28xxu' | sudo tee /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
```

Reboot and verify with `lsusb`.

---

## 🧩 Docker USB Access

1. Create rule:
   ```bash
   echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", MODE:="0666", GROUP:="doug"' | sudo tee /etc/udev/rules.d/68-RTL-SDR.rules
   ```
2. Reload:
   ```bash
   sudo udevadm control --reload-rules && sudo udevadm trigger
   ```
3. Test:
   ```bash
   docker run --rm -it --device /dev/bus/usb dgadams/rtlsdr4:latest rtl_test
   ```

---
