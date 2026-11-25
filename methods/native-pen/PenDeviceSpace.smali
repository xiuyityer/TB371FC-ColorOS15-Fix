.class public final Ltb371/PenDeviceSpace;
.super Ljava/lang/Object;

.method private static isLenovo(Ljava/lang/String;)Z
    .locals 1
    const-string v0, "Lenovo Tab Pen Plus"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :done
    const-string v0, "Lenovo Precision Pen 3"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    :done
    return v0
.end method

.method public static kind(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;
    .locals 1
    invoke-static {p0}, Ltb371/PenDeviceSpace;->isLenovo(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :stock
    sget-object v0, Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;->PENCIL:Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;
    return-object v0
    :stock
    invoke-static {p0}, Lw2/f;->k(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;
    move-result-object v0
    return-object v0
.end method

.method public static type(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    .locals 1
    invoke-static {p0}, Lw2/f;->s(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Ltb371/PenDeviceSpace;->isLenovo(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :stock
    sget-object v0, Lcom/oplus/ipemanager/btadsorb/data/PencilType;->SECOND_GENERATION_PENCIL_LITE:Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    return-object v0
    :stock
    invoke-static {p0}, Lw2/f;->t(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    move-result-object v0
    return-object v0
.end method

.method public static model(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    invoke-static {p0}, Lw2/f;->s(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Ltb371/PenDeviceSpace;->isLenovo(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :stock
    # Use the supported card template while keeping the actual Bluetooth name and address.
    const-string v0, "OPN2404"
    return-object v0
    :stock
    invoke-static {p0}, Lw2/f;->p(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public static disconnect(Landroid/content/Context;Ljava/lang/String;)V
    .locals 4
    if-eqz p1, :done
    :try_start
    sget-object v2, Lcom/oplus/mydevices/sdk/DeviceInfoManager;->INSTANCE:Lcom/oplus/mydevices/sdk/DeviceInfoManager;
    invoke-virtual {v2, p1}, Lcom/oplus/mydevices/sdk/DeviceInfoManager;->query(Ljava/lang/String;)Lcom/oplus/mydevices/sdk/device/DeviceInfo;
    move-result-object v3
    if-eqz v3, :done
    invoke-static {}, Landroid/bluetooth/BluetoothAdapter;->getDefaultAdapter()Landroid/bluetooth/BluetoothAdapter;
    move-result-object v0
    if-eqz v0, :done
    invoke-virtual {v0, p1}, Landroid/bluetooth/BluetoothAdapter;->getRemoteDevice(Ljava/lang/String;)Landroid/bluetooth/BluetoothDevice;
    move-result-object v0
    invoke-virtual {v0}, Landroid/bluetooth/BluetoothDevice;->getBondState()I
    move-result v1
    # BOND_NONE removes the card. Preserve a paired card during a Bluetooth service restart.
    const/16 p1, 0xa
    if-ne v1, p1, :offline
    invoke-virtual {v2, v3}, Lcom/oplus/mydevices/sdk/DeviceInfoManager;->remove(Lcom/oplus/mydevices/sdk/device/DeviceInfo;)V
    goto :done
    :offline
    const/4 v1, 0x0
    invoke-static {p0, v0, v1}, Lm2/a;->p(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;Z)V
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :failed
    :done
    return-void
    :failed
    move-exception v0
    const-string v1, "Tb371PenDeviceSpace"
    const-string v2, "Pen disconnect update failed"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method

.method public static connect(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    .locals 3
    :try_start
    const/4 v0, 0x1
    invoke-static {p0, p1, v0}, Lm2/a;->p(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;Z)V
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :failed
    return-void
    :failed
    move-exception v0
    const-string v1, "Tb371PenDeviceSpace"
    const-string v2, "Pen connection update failed"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method

.method public static battery(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    .locals 3
    :try_start
    invoke-static {p0, p1}, Lm2/a;->o(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :failed
    return-void
    :failed
    move-exception v0
    const-string v1, "Tb371PenDeviceSpace"
    const-string v2, "Pen battery update failed"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method
