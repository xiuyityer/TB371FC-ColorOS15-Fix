#!/usr/bin/env python3
"""Build an IPeManager process-only probe; the APK is not installable."""
import hashlib
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from zipfile import ZipFile, ZipInfo, ZIP_STORED

run = Path(__file__).resolve().parent
tools = Path(os.environ['SMALI_TOOLS']).resolve()
java = os.environ.get('JAVA', 'java')
original = run / 'IPeManager.stock.apk'
bridge = '--hid-bridge' in sys.argv[1:]
telemetry = '--plus-telemetry' in sys.argv[1:]
assert not telemetry or bridge
candidate = run / ('IPeManager.plus-telemetry.apk' if telemetry else
                   'IPeManager.hid-bridge.apk' if bridge else 'IPeManager.tab-pen-probe.apk')
assert hashlib.sha256(original.read_bytes()).hexdigest() == 'd4e7b3f0c71b0cd24e8b6abee317302edcaef31916351c8377c31b92afc2752a'


def prepend(root, file, signature, body):
    file = root / file
    source = file.read_text()
    pattern = r'(\.method [^\n]* ' + re.escape(signature) + r'\n    \.registers \d+\n)'
    patched, count = re.subn(pattern, lambda match: match[0] + '\n' + body.strip('\n') + '\n', source)
    assert count == 1, signature
    file.write_text(patched)


def add_hid_bridge(tree):
    root = 'com/oplus/ipemanager/btadsorb/ble/'
    manager = 'L' + root + 'PencilBleManager;'
    filename = tree / (root + 'PencilBleManager.smali')
    fields, methods = (run / 'hid-bridge.methods').read_text().split('\n\n', 1)
    source = filename.read_text()
    assert source.count('# instance fields\n') == 1
    assert source.count('# direct methods\n') == 1
    source = source.replace('# instance fields\n', '# instance fields\n' + fields + '\n')
    source = source.replace('# direct methods\n', methods + '\n# direct methods\n')
    if telemetry:
        (tree / 'tb371').mkdir()
        for helper in ('PlusGatt.smali', 'PlusUi.smali', 'PlusButtons.smali'):
            shutil.copyfile(run / helper, tree / 'tb371' / helper)
        settings = 'com/oplus/ipemanager/btadsorb/setting/'
        ui = tree / (settings + 'fragment/l.smali')
        stock_ui_type = 'Lw2/f;->t(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/PencilType;'
        assert ui.read_text().count(stock_ui_type) == 3
        fragment = 'L' + settings + 'fragment/l;'
        activity = 'L' + settings + 'activity/PencilSettingActivity;'
        control = settings + 'activity/PencilSettingActivity$b.smali'
        patched_ui = ui.read_text().replace(stock_ui_type, stock_ui_type.replace('Lw2/f;->t', 'Ltb371/PlusGatt;->uiType'))
        start = patched_ui.index('.method public final onResume()V')
        end = patched_ui.index('.end method', start)
        resume = patched_ui[start:end]
        assert resume.count('    return-void\n') == 1
        resume = resume.replace('    return-void\n', f'    invoke-static {{p0}}, Ltb371/PlusUi;->render({fragment})V\n    return-void\n')
        ui.write_text(patched_ui[:start] + resume + patched_ui[end:])
        callback = f'''    iget-object v0, p0, {activity[:-1]}$b;->a:{activity}
    invoke-static {{v0}}, Ltb371/PlusUi;->post({activity})Z'''
        prepend(tree, control, 'notifyBatteryLevel(I)V', callback + '''
    move-result v0
    if-eqz v0, :tb371_stock_battery
    return-void
    :tb371_stock_battery''')
        control_file = tree / control
        control_text = control_file.read_text()
        empty = '.method public final notifyChargingState(Z)V\n    .registers 2\n'
        assert control_text.count(empty) == 1
        control_file.write_text(control_text.replace(empty, empty.replace('registers 2', 'registers 3') + callback + '\n'))
        source = source.replace('# instance fields\n', '# instance fields\n.field public tb371Gatt:Landroid/bluetooth/BluetoothGatt;\n', 1)
        anchor = '    :ours\n    iput-object v0, p0, '
        assert source.count(anchor) == 1
        source = source.replace(anchor, f'''    :ours
    iget-object v5, p0, {manager}->tb371Gatt:Landroid/bluetooth/BluetoothGatt;
    if-eqz v5, :tb371_clear_state
    const/4 v6, 0x0
    iput-object v6, p0, {manager}->tb371Gatt:Landroid/bluetooth/BluetoothGatt;
    invoke-virtual {{v5}}, Landroid/bluetooth/BluetoothGatt;->close()V
    :tb371_clear_state
    const/4 v6, -0x1
    invoke-static {{p0, v6}}, Ltb371/PlusGatt;->power({manager}I)V
    iput-object v0, p0, ''')
        anchor = '    move-object v1, v0\n    const-string v5, "bonded Lenovo Tab Pen Plus HID connected"'
        assert source.count(anchor) == 1
        source = source.replace(anchor, f'''    move-object v1, v0
    invoke-static {{p0, v7}}, Ltb371/PlusGatt;->connect({manager}Landroid/bluetooth/BluetoothDevice;)Landroid/bluetooth/BluetoothGatt;
    move-result-object v5
    iput-object v5, p0, {manager}->tb371Gatt:Landroid/bluetooth/BluetoothGatt;
    const-string v5, "bonded Lenovo Tab Pen Plus HID connected"''')
        # The iterator's device register is reused for the OEM state object.
        source = source.replace('    .locals 7\n    const/4 v0, 0x0\n    iget-object v1, p0, '
                                + manager + '->tb371Profile:',
                                '    .locals 8\n    const/4 v7, 0x0\n    const/4 v0, 0x0\n    iget-object v1, p0, '
                                + manager + '->tb371Profile:', 1)
        source = source.replace('    move-result-object v0\n    :publish',
                                '    move-result-object v0\n    move-object v7, v2\n    :publish', 1)
        anchor = '    iput v4, v2, Lcom/oplus/ipemanager/btadsorb/ble/g;->f:I\n'
        assert source.count(anchor) == 1
        source = source.replace(anchor, anchor + '''    const-string v5, "ipe_pencil_connect_state"
    invoke-static {v4, v5}, La2/a;->a(ILjava/lang/String;)V
''')
    source = source.replace('# annotations\n',
                            '.implements Landroid/bluetooth/BluetoothProfile$ServiceListener;\n\n# annotations\n', 1)
    start = source.index('.method public constructor <init>')
    end = source.index('.end method', start)
    ctor = source[start:end]
    assert ctor.count('    return-void\n') == 1
    ctor = ctor.replace('    return-void\n', f'    invoke-direct {{p0}}, {manager}->tb371Start()V\n    return-void\n')
    filename.write_text(source[:start] + ctor + source[end:])
    prepend(tree, root + 'PencilBleManager$1.smali',
            'onReceive(Landroid/content/Context;Landroid/content/Intent;)V', f'''
    if-eqz p2, :tb371_stock_event
    invoke-virtual {{p2}}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "android.bluetooth.input.profile.action.CONNECTION_STATE_CHANGED"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :tb371_refresh
    const-string v1, "android.bluetooth.adapter.action.STATE_CHANGED"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :tb371_stock_event
    :tb371_refresh
    iget-object v0, p0, L{root}PencilBleManager$1;->a:{manager}
    invoke-virtual {{v0}}, {manager}->tb371Refresh()V
    :tb371_stock_event''')


with tempfile.TemporaryDirectory(dir=run) as folder:
    tmp = Path(folder)
    source = tmp / 'classes2.dex'
    with ZipFile(original) as apk:
        source.write_bytes(apk.read('classes2.dex'))
    tree = tmp / 'smali'
    subprocess.run([java, '-cp', f'{tools}/*', 'org.jf.baksmali.Main', 'disassemble',
                    source, '-a', '35', '-j', '4', '-o', tree], check=True)
    if bridge:
        add_hid_bridge(tree)
    else:
        prepend(tree, 'w2/f.smali', 'J(Landroid/content/Context;Ljava/lang/String;)Z', '''
    const-string v0, "Lenovo Tab Pen Plus"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :tb371_stock_brand
    const-string v0, "C15PenProbe"
    const-string v1, "Lenovo Tab Pen Plus matches pencil brand"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v0, 0x1
    return v0
    :tb371_stock_brand''')
        prepend(tree, 'w2/f.smali', 'l(Ljava/lang/String;)Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;', '''
    const-string v0, "Lenovo Tab Pen Plus"
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :tb371_stock_type
    sget-object v0, Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;->PENCIL:Lcom/oplus/ipemanager/btadsorb/data/IpeDeviceType;
    return-object v0
    :tb371_stock_type''')
        prepend(tree, 'com/oplus/ipemanager/btadsorb/ble/PencilBleManager.smali',
                'k(Landroid/bluetooth/BluetoothGatt;)V', '''
    if-eqz p1, :tb371_stock_discovery
    invoke-virtual/range {p1 .. p1}, Landroid/bluetooth/BluetoothGatt;->getDevice()Landroid/bluetooth/BluetoothDevice;
    move-result-object v0
    if-eqz v0, :tb371_stock_discovery
    invoke-virtual {v0}, Landroid/bluetooth/BluetoothDevice;->getName()Ljava/lang/String;
    move-result-object v0
    const-string v1, "Lenovo Tab Pen Plus"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :tb371_stock_discovery
    const-string v0, "C15PenProbe"
    const-string v1, "Lenovo GATT discovered; OEM initialization skipped"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
    :tb371_stock_discovery''')
    prepend(tree, 'com/oplus/ipemanager/btadsorb/ota/DeviceOtaService.smali',
            'onStartCommand(Landroid/content/Intent;II)I', '''
    const-string v0, "C15PenProbe"
    const-string v1, "Pencil firmware action disabled during probe"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {p0}, Landroid/app/Service;->stopSelf()V
    const/4 v0, 0x2
    return v0''')
    built = tmp / 'patched.dex'
    subprocess.run([java, '-cp', f'{tools}/*', 'org.jf.smali.Main', 'assemble',
                    tree, '-a', '35', '-j', '4', '-o', built], check=True)
    shutil.copyfile(original, candidate)
    with ZipFile(candidate, 'a') as apk:
        old = apk.NameToInfo.pop('classes2.dex')
        apk.filelist.remove(old)
        info = ZipInfo('classes2.dex', old.date_time)
        info.compress_type = ZIP_STORED
        padding = (-(apk.start_dir + 30 + len(info.filename))) % 4
        if padding:
            info.extra = struct.pack('<HH', 0xD935, padding) + b'\0' * padding
        apk.writestr(info, built.read_bytes())
    with ZipFile(original) as stock, ZipFile(candidate) as patch:
        assert patch.testzip() is None
        assert set(stock.namelist()) == set(patch.namelist())
        for item in stock.infolist():
            if item.filename != 'classes2.dex':
                other = patch.getinfo(item.filename)
                assert (other.header_offset, other.CRC) == (item.header_offset, item.CRC)
        info = patch.getinfo('classes2.dex')
        assert (info.header_offset + 30 + len(info.filename) + len(info.extra)) % 4 == 0
print(hashlib.sha256(candidate.read_bytes()).hexdigest(), candidate)
