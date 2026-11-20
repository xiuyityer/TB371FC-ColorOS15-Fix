.class public final Ltb371/PlusGatt;
.super Landroid/bluetooth/BluetoothGattCallback;

.field private final owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
.field private step:I

.method public static connect(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;Landroid/bluetooth/BluetoothDevice;)Landroid/bluetooth/BluetoothGatt;
    .locals 8
    move-object v0, p1
    iget-object v1, p0, Lcom/oplus/ipemanager/btadsorb/ble/BleManager;->a:Landroid/content/Context;
    const/4 v2, 0x0
    new-instance v3, Ltb371/PlusGatt;
    invoke-direct {v3, p0}, Ltb371/PlusGatt;-><init>(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;)V
    const/4 v4, 0x2
    const/4 v5, 0x1
    new-instance v6, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v7
    invoke-direct {v6, v7}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    invoke-virtual/range {v0 .. v6}, Landroid/bluetooth/BluetoothDevice;->connectGatt(Landroid/content/Context;ZLandroid/bluetooth/BluetoothGattCallback;IILandroid/os/Handler;)Landroid/bluetooth/BluetoothGatt;
    move-result-object v0
    return-object v0
.end method

.method public static power(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;I)V
    .locals 3
    const-string v0, "ipe_pencil_charging_state"
    if-ltz p1, :unknown
    invoke-static {p1, v0}, La2/a;->a(ILjava/lang/String;)V
    goto :notify
    :unknown
    const/4 v1, 0x0
    invoke-static {v0, v1}, La2/a;->b(Ljava/lang/String;Ljava/lang/String;)V
    :notify
    iget-object v0, p0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->w0:Lcom/oplus/ipemanager/IUIPageControl;
    if-eqz v0, :done
    const/4 v1, 0x1
    if-eq p1, v1, :send
    const/4 v1, 0x0
    :send
    :try_start
    invoke-interface {v0, v1}, Lcom/oplus/ipemanager/IUIPageControl;->notifyChargingState(Z)V
    :try_end
    .catch Landroid/os/RemoteException; {:try_start .. :try_end} :failed
    goto :done
    :failed
    move-exception v2
    :done
    return-void
.end method

.method private current(Landroid/bluetooth/BluetoothGatt;)Z
    .locals 1
    iget-object v0, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    iget-object v0, v0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->tb371Gatt:Landroid/bluetooth/BluetoothGatt;
    if-ne v0, p1, :stale
    const/4 v0, 0x1
    return v0
    :stale
    const/4 v0, 0x0
    return v0
.end method

.method public static uiType(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    .locals 2
    invoke-static {p0}, Lw2/f;->s(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Lenovo Tab Pen Plus"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :stock
    sget-object v0, Lcom/oplus/ipemanager/btadsorb/data/PencilType;->SECOND_GENERATION_PENCIL_LITE:Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    return-object v0
    :stock
    invoke-static {v0}, Lw2/f;->u(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/PencilType;
    move-result-object v0
    return-object v0
.end method

.method private store(Landroid/bluetooth/BluetoothGatt;ILjava/lang/String;)V
    .locals 5
    iget-object v0, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    iget-object v1, v0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->tb371Mac:Ljava/lang/String;
    invoke-virtual {p1}, Landroid/bluetooth/BluetoothGatt;->getDevice()Landroid/bluetooth/BluetoothDevice;
    move-result-object v2
    invoke-virtual {v2}, Landroid/bluetooth/BluetoothDevice;->getAddress()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :done
    iget-object v1, v0, Lcom/oplus/ipemanager/btadsorb/ble/BleManager;->a:Landroid/content/Context;
    packed-switch p2, :steps
    return-void
    :battery
    invoke-static {p3}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v2
    iput v2, v0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->K:I
    const-string v3, "pencil_sp_battery_level"
    invoke-static {v1, v2, v3}, Lt1/a;->f(Landroid/content/Context;ILjava/lang/String;)V
    const-string v3, "ipe_pencil_battery_level"
    invoke-static {v2, v3}, La2/a;->a(ILjava/lang/String;)V
    iget-object v3, v0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->w0:Lcom/oplus/ipemanager/IUIPageControl;
    if-eqz v3, :done
    :try_start
    invoke-interface {v3, v2}, Lcom/oplus/ipemanager/IUIPageControl;->notifyBatteryLevel(I)V
    :try_end
    .catch Landroid/os/RemoteException; {:try_start .. :try_end} :failed
    goto :done
    :failed
    move-exception v4
    goto :done
    :firmware
    const-string v2, "Lenovo Tab Pen Plus"
    const-string v3, "pencil_sp_pencil_type"
    invoke-static {v1, v3, v2}, Lt1/a;->g(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "pencil_sp_fw_version"
    goto :version
    :hardware
    const-string v3, "pencil_sp_hw_version"
    :version
    invoke-static {v1, v3, p3}, Lt1/a;->g(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    :done
    return-void
    :steps
    .packed-switch 0x1
        :battery
        :firmware
        :hardware
    .end packed-switch
.end method

.method public constructor <init>(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;)V
    .locals 0
    invoke-direct {p0}, Landroid/bluetooth/BluetoothGattCallback;-><init>()V
    iput-object p1, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    return-void
.end method

.method public onConnectionStateChange(Landroid/bluetooth/BluetoothGatt;II)V
    .locals 2
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->current(Landroid/bluetooth/BluetoothGatt;)Z
    move-result v0
    if-eqz v0, :done
    const/4 v0, 0x2
    if-ne p3, v0, :check_close
    if-nez p2, :check_close
    invoke-virtual {p1}, Landroid/bluetooth/BluetoothGatt;->discoverServices()Z
    move-result v0
    if-nez v0, :done
    :check_close
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->close(Landroid/bluetooth/BluetoothGatt;)V
    :done
    return-void
.end method

.method private close(Landroid/bluetooth/BluetoothGatt;)V
    .locals 2
    iget-object v0, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    const/4 v1, 0x0
    iput-object v1, v0, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->tb371Gatt:Landroid/bluetooth/BluetoothGatt;
    const/4 v1, -0x1
    invoke-static {v0, v1}, Ltb371/PlusGatt;->power(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;I)V
    invoke-virtual {p1}, Landroid/bluetooth/BluetoothGatt;->close()V
    return-void
.end method

.method public onServicesDiscovered(Landroid/bluetooth/BluetoothGatt;I)V
    .locals 5
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->current(Landroid/bluetooth/BluetoothGatt;)Z
    move-result v0
    if-eqz v0, :done
    if-nez p2, :failed
    invoke-virtual {p1}, Landroid/bluetooth/BluetoothGatt;->getServices()Ljava/util/List;
    move-result-object v0
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v0
    :next
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :read
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/bluetooth/BluetoothGattService;
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattService;->getCharacteristics()Ljava/util/List;
    move-result-object v3
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattService;->getUuid()Ljava/util/UUID;
    move-result-object v1
    invoke-virtual {v1}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Tb371PlusService"
    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v3
    :characteristic
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :next
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/bluetooth/BluetoothGattCharacteristic;
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattCharacteristic;->getProperties()I
    move-result v4
    invoke-static {v4}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattCharacteristic;->getUuid()Ljava/util/UUID;
    move-result-object v1
    invoke-virtual {v1}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, " properties=0x"
    invoke-virtual {v1, v2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v1, v4}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "Tb371PlusChar"
    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :characteristic
    :read
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->readNext(Landroid/bluetooth/BluetoothGatt;)V
    return-void
    :failed
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->close(Landroid/bluetooth/BluetoothGatt;)V
    :done
    return-void
.end method

.method private readNext(Landroid/bluetooth/BluetoothGatt;)V
    .locals 4
    :next
    iget v0, p0, Ltb371/PlusGatt;->step:I
    add-int/lit8 v1, v0, 0x1
    iput v1, p0, Ltb371/PlusGatt;->step:I
    packed-switch v0, :steps
    const/4 v1, 0x6
    if-ne v0, v1, :done
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->listenHid(Landroid/bluetooth/BluetoothGatt;)V
    :done
    return-void
    :battery
    const-string v1, "0000180f-0000-1000-8000-00805f9b34fb"
    const-string v2, "00002a19-0000-1000-8000-00805f9b34fb"
    goto :read
    :firmware
    const-string v1, "0000180a-0000-1000-8000-00805f9b34fb"
    const-string v2, "00002a26-0000-1000-8000-00805f9b34fb"
    goto :read
    :hardware
    const-string v1, "0000180a-0000-1000-8000-00805f9b34fb"
    const-string v2, "00002a27-0000-1000-8000-00805f9b34fb"
    goto :read
    :power
    const-string v1, "0000180f-0000-1000-8000-00805f9b34fb"
    const-string v2, "00002a1a-0000-1000-8000-00805f9b34fb"
    :read
    invoke-static {v1}, Ljava/util/UUID;->fromString(Ljava/lang/String;)Ljava/util/UUID;
    move-result-object v1
    invoke-virtual {p1, v1}, Landroid/bluetooth/BluetoothGatt;->getService(Ljava/util/UUID;)Landroid/bluetooth/BluetoothGattService;
    move-result-object v1
    if-eqz v1, :next
    invoke-static {v2}, Ljava/util/UUID;->fromString(Ljava/lang/String;)Ljava/util/UUID;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/bluetooth/BluetoothGattService;->getCharacteristic(Ljava/util/UUID;)Landroid/bluetooth/BluetoothGattCharacteristic;
    move-result-object v1
    if-eqz v1, :next
    const/4 v2, 0x4
    if-lt v0, v2, :only_read
    invoke-direct {p0, p1, v1}, Ltb371/PlusGatt;->subscribe(Landroid/bluetooth/BluetoothGatt;Landroid/bluetooth/BluetoothGattCharacteristic;)Z
    move-result v2
    if-eqz v2, :next
    return-void
    :only_read
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattCharacteristic;->getProperties()I
    move-result v2
    and-int/lit8 v2, v2, 0x2
    if-eqz v2, :next
    invoke-virtual {p1, v1}, Landroid/bluetooth/BluetoothGatt;->readCharacteristic(Landroid/bluetooth/BluetoothGattCharacteristic;)Z
    move-result v2
    if-eqz v2, :next
    return-void
    :steps
    .packed-switch 0x0
        :battery
        :firmware
        :hardware
        :power
        :battery
        :power
    .end packed-switch
.end method

.method private listenHid(Landroid/bluetooth/BluetoothGatt;)V
    .locals 4
    const-string v0, "00001812-0000-1000-8000-00805f9b34fb"
    invoke-static {v0}, Ljava/util/UUID;->fromString(Ljava/lang/String;)Ljava/util/UUID;
    move-result-object v0
    invoke-virtual {p1, v0}, Landroid/bluetooth/BluetoothGatt;->getService(Ljava/util/UUID;)Landroid/bluetooth/BluetoothGattService;
    move-result-object v0
    if-eqz v0, :done
    invoke-virtual {v0}, Landroid/bluetooth/BluetoothGattService;->getCharacteristics()Ljava/util/List;
    move-result-object v0
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v0
    :next
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :done
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/bluetooth/BluetoothGattCharacteristic;
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattCharacteristic;->getUuid()Ljava/util/UUID;
    move-result-object v2
    invoke-virtual {v2}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "00002a4d-0000-1000-8000-00805f9b34fb"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :next
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothGattCharacteristic;->getProperties()I
    move-result v2
    and-int/lit8 v2, v2, 0x10
    if-eqz v2, :next
    const/4 v2, 0x1
    :try_start
    invoke-virtual {p1, v1, v2}, Landroid/bluetooth/BluetoothGatt;->setCharacteristicNotification(Landroid/bluetooth/BluetoothGattCharacteristic;Z)Z
    move-result v2
    :try_end
    .catch Ljava/lang/SecurityException; {:try_start .. :try_end} :denied
    invoke-static {v2}, Ljava/lang/Boolean;->toString(Z)Ljava/lang/String;
    move-result-object v2
    const-string v3, "Tb371PlusHidListen"
    invoke-static {v3, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :next
    :denied
    move-exception v1
    const-string v2, "Tb371PlusHidListen"
    const-string v3, "HID characteristic registration denied"
    invoke-static {v2, v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :done
    return-void
.end method

.method private subscribe(Landroid/bluetooth/BluetoothGatt;Landroid/bluetooth/BluetoothGattCharacteristic;)Z
    .locals 3
    invoke-virtual {p2}, Landroid/bluetooth/BluetoothGattCharacteristic;->getProperties()I
    move-result v0
    and-int/lit8 v0, v0, 0x10
    if-eqz v0, :fail
    const-string v0, "00002902-0000-1000-8000-00805f9b34fb"
    invoke-static {v0}, Ljava/util/UUID;->fromString(Ljava/lang/String;)Ljava/util/UUID;
    move-result-object v0
    invoke-virtual {p2, v0}, Landroid/bluetooth/BluetoothGattCharacteristic;->getDescriptor(Ljava/util/UUID;)Landroid/bluetooth/BluetoothGattDescriptor;
    move-result-object v0
    if-eqz v0, :fail
    const/4 v1, 0x1
    invoke-virtual {p1, p2, v1}, Landroid/bluetooth/BluetoothGatt;->setCharacteristicNotification(Landroid/bluetooth/BluetoothGattCharacteristic;Z)Z
    move-result v2
    if-eqz v2, :fail
    sget-object v2, Landroid/bluetooth/BluetoothGattDescriptor;->ENABLE_NOTIFICATION_VALUE:[B
    invoke-virtual {p1, v0, v2}, Landroid/bluetooth/BluetoothGatt;->writeDescriptor(Landroid/bluetooth/BluetoothGattDescriptor;[B)I
    move-result v0
    if-nez v0, :fail
    return v1
    :fail
    const-string v0, "Tb371PlusRead"
    const-string v1, "battery service notification unavailable"
    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v0, 0x0
    return v0
.end method

.method public onDescriptorWrite(Landroid/bluetooth/BluetoothGatt;Landroid/bluetooth/BluetoothGattDescriptor;I)V
    .locals 3
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->current(Landroid/bluetooth/BluetoothGatt;)Z
    move-result v0
    if-eqz v0, :done
    invoke-virtual {p2}, Landroid/bluetooth/BluetoothGattDescriptor;->getCharacteristic()Landroid/bluetooth/BluetoothGattCharacteristic;
    move-result-object v0
    invoke-virtual {v0}, Landroid/bluetooth/BluetoothGattCharacteristic;->getUuid()Ljava/util/UUID;
    move-result-object v0
    const-string v1, "Tb371PlusSubscribe"
    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v0
    invoke-static {p3}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v2
    const-string p2, " status="
    invoke-virtual {v0, p2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0, v2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->readNext(Landroid/bluetooth/BluetoothGatt;)V
    :done
    return-void
.end method

.method private updatePower([B)V
    .locals 4
    invoke-static {p1}, Ljava/util/Arrays;->toString([B)Ljava/lang/String;
    move-result-object v0
    const-string v1, "2A1A raw "
    invoke-virtual {v1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Tb371PlusRead"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v1, -0x1
    if-eqz p1, :publish
    array-length v0, p1
    # PICASSO-CD1 V2.27 sends one byte in notifications, three on read.
    const/4 v2, 0x1
    if-eq v0, v2, :decode
    const/4 v2, 0x3
    if-ne v0, v2, :publish
    :decode
    const/4 v0, 0x0
    aget-byte v0, p1, v0
    and-int/lit8 v0, v0, 0x30
    const/16 v2, 0x30
    if-ne v0, v2, :not_charging
    const/4 v1, 0x1
    goto :publish
    :not_charging
    const/16 v2, 0x20
    if-ne v0, v2, :publish
    const/4 v1, 0x0
    :publish
    iget-object v0, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    invoke-static {v0, v1}, Ltb371/PlusGatt;->power(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;I)V
    return-void
.end method

.method private updateBattery(Landroid/bluetooth/BluetoothGatt;[B)V
    .locals 3
    if-eqz p2, :done
    array-length v0, p2
    const/4 v1, 0x1
    if-ne v0, v1, :done
    const/4 v0, 0x0
    aget-byte v0, p2, v0
    and-int/lit16 v0, v0, 0xff
    const/16 v2, 0x64
    if-gt v0, v2, :done
    invoke-static {v0}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v0
    invoke-direct {p0, p1, v1, v0}, Ltb371/PlusGatt;->store(Landroid/bluetooth/BluetoothGatt;ILjava/lang/String;)V
    const-string v1, "Battery %: "
    invoke-virtual {v1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Tb371PlusRead"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :done
    return-void
.end method

.method public onCharacteristicChanged(Landroid/bluetooth/BluetoothGatt;Landroid/bluetooth/BluetoothGattCharacteristic;[B)V
    .locals 2
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->current(Landroid/bluetooth/BluetoothGatt;)Z
    move-result v0
    if-eqz v0, :done
    invoke-virtual {p2}, Landroid/bluetooth/BluetoothGattCharacteristic;->getUuid()Ljava/util/UUID;
    move-result-object v0
    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "00002a19-0000-1000-8000-00805f9b34fb"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :check_power
    invoke-direct {p0, p1, p3}, Ltb371/PlusGatt;->updateBattery(Landroid/bluetooth/BluetoothGatt;[B)V
    goto :done
    :check_power
    const-string v1, "00002a1a-0000-1000-8000-00805f9b34fb"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :hid
    invoke-direct {p0, p3}, Ltb371/PlusGatt;->updatePower([B)V
    goto :done
    :hid
    const-string v1, "00002a4d-0000-1000-8000-00805f9b34fb"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :done
    iget-object v0, p0, Ltb371/PlusGatt;->owner:Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;
    iget-object v0, v0, Lcom/oplus/ipemanager/btadsorb/ble/BleManager;->a:Landroid/content/Context;
    invoke-static {v0, p3}, Ltb371/PlusButtons;->dispatch(Landroid/content/Context;[B)V
    :done
    return-void
.end method

.method public onCharacteristicRead(Landroid/bluetooth/BluetoothGatt;Landroid/bluetooth/BluetoothGattCharacteristic;[BI)V
    .locals 6
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->current(Landroid/bluetooth/BluetoothGatt;)Z
    move-result v0
    if-eqz v0, :done
    if-nez p4, :next
    if-eqz p3, :next
    array-length v0, p3
    if-lez v0, :next
    const-string v1, "Tb371PlusRead"
    iget v2, p0, Ltb371/PlusGatt;->step:I
    move v4, v2
    const/4 v3, 0x4
    if-ne v2, v3, :check_battery
    invoke-direct {p0, p3}, Ltb371/PlusGatt;->updatePower([B)V
    goto :next
    :check_battery
    const/4 v3, 0x1
    if-ne v2, v3, :version
    invoke-direct {p0, p1, p3}, Ltb371/PlusGatt;->updateBattery(Landroid/bluetooth/BluetoothGatt;[B)V
    goto :next
    :version
    const/16 v3, 0x40
    if-gt v0, v3, :next
    new-instance v0, Ljava/lang/String;
    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;
    invoke-direct {v0, p3, v3}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0
    const-string v2, "[ -~]{1,64}"
    invoke-virtual {v0, v2}, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :next
    invoke-virtual {p2}, Landroid/bluetooth/BluetoothGattCharacteristic;->getUuid()Ljava/util/UUID;
    move-result-object v2
    invoke-virtual {v2}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, ": "
    invoke-virtual {v2, v3}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    :log
    invoke-direct {p0, p1, v4, v0}, Ltb371/PlusGatt;->store(Landroid/bluetooth/BluetoothGatt;ILjava/lang/String;)V
    invoke-virtual {v2, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :next
    invoke-direct {p0, p1}, Ltb371/PlusGatt;->readNext(Landroid/bluetooth/BluetoothGatt;)V
    :done
    return-void
.end method
