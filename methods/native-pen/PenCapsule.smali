.class public final Ltb371/PenCapsule;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private static renderer:Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;
.field private static fluidRequest:Z
.field private static pending:Ltb371/PenCapsule;
.field private final context:Landroid/content/Context;
.field private final device:Landroid/bluetooth/BluetoothDevice;

.method private constructor <init>(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Ltb371/PenCapsule;->context:Landroid/content/Context;
    iput-object p2, p0, Ltb371/PenCapsule;->device:Landroid/bluetooth/BluetoothDevice;
    return-void
.end method

.method public static connection(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    .locals 4
    if-nez p1, :queue
    const/4 v0, 0x0
    sput-object v0, Ltb371/PenCapsule;->pending:Ltb371/PenCapsule;
    return-void
    :queue
    new-instance v0, Ltb371/PenCapsule;
    invoke-direct {v0, p0, p1}, Ltb371/PenCapsule;-><init>(Landroid/content/Context;Landroid/bluetooth/BluetoothDevice;)V
    sput-object v0, Ltb371/PenCapsule;->pending:Ltb371/PenCapsule;
    new-instance v1, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v2
    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    const-wide/16 v2, 0x898
    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    return-void
.end method

.method public static battery(Landroid/bluetooth/BluetoothDevice;I)V
    .locals 2
    sget-object v0, Ltb371/PenCapsule;->pending:Ltb371/PenCapsule;
    if-eqz v0, :done
    iget-object v1, v0, Ltb371/PenCapsule;->device:Landroid/bluetooth/BluetoothDevice;
    invoke-virtual {v1, p0}, Landroid/bluetooth/BluetoothDevice;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :done
    invoke-direct {v0, p1}, Ltb371/PenCapsule;->finish(I)V
    :done
    return-void
.end method

.method public run()V
    .locals 1
    const/4 v0, -0x1
    invoke-direct {p0, v0}, Ltb371/PenCapsule;->finish(I)V
    return-void
.end method

.method private finish(I)V
    .locals 5
    sget-object v0, Ltb371/PenCapsule;->pending:Ltb371/PenCapsule;
    if-ne v0, p0, :done
    const/4 v0, 0x0
    sput-object v0, Ltb371/PenCapsule;->pending:Ltb371/PenCapsule;
    iget-object v0, p0, Ltb371/PenCapsule;->context:Landroid/content/Context;
    iget-object v1, p0, Ltb371/PenCapsule;->device:Landroid/bluetooth/BluetoothDevice;
    invoke-virtual {v1}, Landroid/bluetooth/BluetoothDevice;->getName()Ljava/lang/String;
    move-result-object v1
    sget v2, Lcom/oplus/ipemanager/btadsorb/p;->ipe_connected:I
    invoke-virtual {v0, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;
    move-result-object v2
    if-ltz p1, :show
    const-string v3, " · "
    invoke-virtual {v2, v3}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-static {p1}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v2, v4}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    const-string v3, "%"
    invoke-virtual {v2, v3}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    :show
    const/4 v3, 0x0
    invoke-static {v0, v1, v2, p1, v3}, Ltb371/PenCapsule;->show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;IZ)V
    :done
    return-void
.end method

.method public static charging(Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;I)V
    .locals 5
    iget-object v0, p0, Lcom/oplus/ipemanager/btadsorb/ble/BleManager;->a:Landroid/content/Context;
    const/4 v4, 0x1
    if-ltz p1, :local
    invoke-static {v0}, Lw2/f;->O(Landroid/content/Context;)Z
    move-result v1
    if-eqz v1, :local
    :try_start
    sput-boolean v4, Ltb371/PenCapsule;->fluidRequest:Z
    invoke-virtual {p0, p1}, Lcom/oplus/ipemanager/btadsorb/ble/PencilBleManager;->g0(I)V
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :failed
    const/4 v1, 0x0
    sput-boolean v1, Ltb371/PenCapsule;->fluidRequest:Z
    const-string v1, "Tb371PenCapsule"
    const-string v2, "Precision Pen 3 Fluid Cloud charging card requested"
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
    :failed
    move-exception v1
    const/4 v2, 0x0
    sput-boolean v2, Ltb371/PenCapsule;->fluidRequest:Z
    const-string v2, "Tb371PenCapsule"
    const-string v3, "Fluid Cloud charging card failed"
    invoke-static {v2, v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :local
    const-string v1, "Lenovo Precision Pen 3"
    const-string v2, "Charging"
    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v3
    invoke-virtual {v3}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;
    move-result-object v3
    invoke-virtual {v3}, Landroid/content/res/Configuration;->getLocales()Landroid/os/LocaleList;
    move-result-object v3
    const/4 v4, 0x0
    invoke-virtual {v3, v4}, Landroid/os/LocaleList;->get(I)Ljava/util/Locale;
    move-result-object v3
    invoke-virtual {v3}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;
    move-result-object v3
    const-string v4, "zh"
    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :show
    const-string v2, "充电中"
    :show
    move v3, p1
    const/4 v4, 0x1
    invoke-static {v0, v1, v2, v3, v4}, Ltb371/PenCapsule;->show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;IZ)V
    return-void
.end method

.method public static cardPenPresent()Ljava/lang/Integer;
    .locals 1
    # Only the stock Seedling card being rendered for a verified Lenovo charge uses this value.
    sget-boolean v0, Ltb371/PenCapsule;->fluidRequest:Z
    if-eqz v0, :stock
    const/4 v0, 0x1
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v0
    return-object v0
    :stock
    invoke-static {}, Lw2/f;->w()Ljava/lang/Integer;
    move-result-object v0
    return-object v0
.end method

.method private static show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;IZ)V
    .locals 4
    :try_start
    sget-object v0, Ltb371/PenCapsule;->renderer:Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;
    if-nez v0, :ready
    new-instance v0, Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;
    invoke-direct {v0}, Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;-><init>()V
    sput-object v0, Ltb371/PenCapsule;->renderer:Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;
    :ready
    new-instance v1, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;
    invoke-direct {v1}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;-><init>()V
    const-string v2, "tb371_pen_connected"
    if-eqz p4, :set_id
    const-string v2, "tb371_pen_charging"
    :set_id
    invoke-virtual {v1, v2}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setId(Ljava/lang/String;)V
    invoke-virtual {v1, p2}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setTitle(Ljava/lang/String;)V
    invoke-virtual {v1, p1}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setSummary(Ljava/lang/String;)V
    sget v3, Lcom/oplus/ipemanager/btadsorb/k;->bg_capsule_pencil:I
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-virtual {v1, v3}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setIconResId(Ljava/lang/Integer;)V
    if-ltz p3, :display
    invoke-static {p3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-virtual {v1, v3}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setBatteryLevel(Ljava/lang/Integer;)V
    invoke-static {p4}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;
    move-result-object v3
    invoke-virtual {v1, v3}, Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;->setCharging(Ljava/lang/Boolean;)V
    :display
    invoke-virtual {v0, p0, v1}, Lcom/oplus/baselib/ui/capsule/impl/CapsuleImpl;->addCapsule(Landroid/content/Context;Lcom/oplus/baselib/ui/capsule/impl/model/Capsule;)V
    const-string v0, "Tb371PenCapsule"
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :display_failed
    return-void
    :display_failed
    move-exception v0
    const-string v1, "Tb371PenCapsule"
    const-string v2, "Native pen capsule failed"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method
