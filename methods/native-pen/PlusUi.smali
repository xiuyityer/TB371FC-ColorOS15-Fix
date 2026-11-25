.class public final Ltb371/PlusUi;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final activity:Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;

.method private constructor <init>(Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Ltb371/PlusUi;->activity:Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;
    return-void
.end method

.method private static model(Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;)I
    .locals 2
    if-eqz p0, :no
    iget-object v0, p0, Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;->F:Ljava/lang/String;
    invoke-static {v0}, Lw2/f;->s(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Lenovo Tab Pen Plus"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :check_precision
    const/4 v0, 0x1
    return v0
    :check_precision
    const-string v1, "Lenovo Precision Pen 3"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :no
    const/4 v0, 0x2
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method

.method public static post(Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;)Z
    .locals 2
    iget-object v0, p0, Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;->i:Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;
    invoke-static {v0}, Ltb371/PlusUi;->model(Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;)I
    move-result v0
    if-eqz v0, :done
    new-instance v1, Ltb371/PlusUi;
    invoke-direct {v1, p0}, Ltb371/PlusUi;-><init>(Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;)V
    invoke-virtual {p0, v1}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V
    const/4 v0, 0x1
    :done
    return v0
.end method

.method public run()V
    .locals 1
    iget-object v0, p0, Ltb371/PlusUi;->activity:Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;
    iget-object v0, v0, Lcom/oplus/ipemanager/btadsorb/setting/activity/PencilSettingActivity;->i:Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;
    invoke-static {v0}, Ltb371/PlusUi;->render(Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;)V
    return-void
.end method

.method public static render(Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;)V
    .locals 8
    invoke-static {p0}, Ltb371/PlusUi;->model(Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;)I
    move-result v1
    if-eqz v1, :done
    iget-object v0, p0, Lcom/oplus/ipemanager/btadsorb/setting/fragment/l;->g:Lcom/coui/appcompat/preference/COUIJumpPreference;
    if-eqz v0, :done
    const/4 v2, 0x2
    if-ne v1, v2, :plus
    # The OEM preference can contain a battery value cached for another pen.
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Lcom/coui/appcompat/preference/COUIPreference;->setAssignment(Ljava/lang/CharSequence;)V
    return-void
    :plus
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;
    move-result-object v1
    if-eqz v1, :done
    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    const-string v3, "ipe_pencil_battery_level"
    const/4 v4, -0x1
    invoke-static {v2, v3, v4}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v3
    if-ltz v3, :done
    const/16 v5, 0x64
    if-gt v3, v5, :done
    const/4 v5, 0x1
    new-array v6, v5, [Ljava/lang/Object;
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    const/4 v7, 0x0
    aput-object v3, v6, v7
    sget v3, Lcom/oplus/ipemanager/btadsorb/p;->ipe_device_electric_value:I
    invoke-virtual {v1, v3, v6}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v3
    const-string v6, "ipe_pencil_charging_state"
    invoke-static {v2, v6, v4}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v2
    if-ne v2, v5, :display
    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/res/Configuration;->getLocales()Landroid/os/LocaleList;
    move-result-object v1
    invoke-virtual {v1, v7}, Landroid/os/LocaleList;->get(I)Ljava/util/Locale;
    move-result-object v1
    invoke-virtual {v1}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;
    move-result-object v1
    const-string v2, "zh"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    const-string v2, " · Charging"
    if-eqz v1, :append
    const-string v2, " · \u5145\u7535\u4e2d"
    :append
    invoke-virtual {v3, v2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    :display
    invoke-virtual {v0, v3}, Lcom/coui/appcompat/preference/COUIPreference;->setAssignment(Ljava/lang/CharSequence;)V
    :done
    return-void
.end method
