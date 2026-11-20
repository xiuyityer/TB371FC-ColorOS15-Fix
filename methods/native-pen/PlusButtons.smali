.class public final Ltb371/PlusButtons;
.super Ljava/lang/Object;

.method public static dispatch(Landroid/content/Context;[B)V
    .locals 5
    if-eqz p1, :done
    array-length v0, p1
    const/4 v1, 0x2
    if-ne v0, v1, :done
    const/4 v0, 0x0
    aget-byte v0, p1, v0
    if-ne v0, v1, :done
    const/4 v0, 0x1
    aget-byte v1, p1, v0
    if-eq v1, v0, :check_display
    const/16 v2, 0x8
    if-ne v1, v2, :done
    :check_display
    const-class v2, Landroid/os/PowerManager;
    invoke-virtual {p0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/os/PowerManager;
    if-eqz v2, :done
    invoke-virtual {v2}, Landroid/os/PowerManager;->isInteractive()Z
    move-result v2
    if-eqz v2, :done
    const-class v2, Landroid/app/KeyguardManager;
    invoke-virtual {p0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/app/KeyguardManager;
    if-eqz v2, :done
    invoke-virtual {v2}, Landroid/app/KeyguardManager;->isKeyguardLocked()Z
    move-result v2
    if-nez v2, :done
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    const-string v3, "Tb371PlusButton"
    if-ne v1, v0, :long
    const-string v1, "ipe_pencil_double_click"
    invoke-static {v2, v1, v0}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v1
    if-lt v1, v0, :done
    const/4 v0, 0x3
    if-gt v1, v0, :done
    new-instance v0, Landroid/content/Intent;
    const-string v1, "com.oplus.ipemanager.action.PENCIL_DOUBLE_CLICK"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v1, "com.oplus.ipemanager.permission.receiver.DOUBLE_CLICK"
    :try_start
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;Ljava/lang/String;)V
    const-string v0, "short: tool switch sent"
    invoke-static {v3, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :try_end
    :long
    const/4 v0, 0x0
    const-string v1, "ipe_pencil_long_click"
    invoke-static {v2, v1, v0}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v0
    if-nez v0, :try_end
    invoke-static {p0}, Ltb371/PlusButtons;->takeAreaScreenshot(Landroid/content/Context;)V
    :try_end
    .catch Ljava/lang/RuntimeException; {:try_start .. :try_end} :failed
    goto :done
    :failed
    move-exception v0
    const-string v1, "native action failed"
    invoke-static {v3, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :done
    return-void
.end method

.method private static takeAreaScreenshot(Landroid/content/Context;)V
    .locals 6
    invoke-static {p0}, Lcom/oplus/screenshot/OplusLongshotUtils;->getScreenshotManager(Landroid/content/Context;)Lcom/oplus/screenshot/OplusScreenshotManager;
    move-result-object v0
    if-eqz v0, :done
    new-instance v1, Landroid/os/Bundle;
    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;
    move-result-object v2
    invoke-virtual {v2}, Ljava/util/UUID;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "-"
    const-string v4, ""
    invoke-virtual {v2, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v3, "screenshot_relation_id"
    invoke-virtual {v1, v3, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v4
    const-string v2, "screenshot_start_time"
    invoke-virtual {v1, v2, v4, v5}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
    const-string v2, "screenshot_source"
    const-string v3, "AreaScreenshot_OppoPencil"
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v3, 0x0
    const-string v2, "statusbar_visible"
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
    const-string v2, "navigationbar_visible"
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
    const-string v2, "global_action_visible"
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v2
    invoke-virtual {v2}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;
    move-result-object v2
    iget v2, v2, Landroid/content/res/Configuration;->orientation:I
    const/4 v4, 0x2
    if-ne v2, v4, :orientation
    const/4 v3, 0x1
    :orientation
    const-string v2, "screenshot_orientation"
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V
    invoke-virtual {v0, v1}, Lcom/oplus/screenshot/OplusScreenshotManager;->takeScreenshot(Landroid/os/Bundle;)V
    const-string v0, "Tb371PlusButton"
    const-string v1, "long: area screenshot requested"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :done
    return-void
.end method
