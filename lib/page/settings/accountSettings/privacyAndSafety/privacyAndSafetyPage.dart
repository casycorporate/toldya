import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';
import 'package:bendemistim/model/user.dart';
import 'package:bendemistim/page/settings/widgets/headerWidget.dart';
import 'package:bendemistim/page/settings/widgets/settingsAppbar.dart';
import 'package:bendemistim/page/settings/widgets/settingsRowWidget.dart';
import 'package:bendemistim/state/authState.dart';
import 'package:provider/provider.dart';

class PrivacyAndSaftyPage extends StatelessWidget {
  const PrivacyAndSaftyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SettingsAppBar(
        title: 'Gizlilik ve güvenlik',
        subtitle: user.userName ?? '',
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget('Paylaşımlar'),
          SettingRowWidget(
            "Paylaşımlarınızı koru",
            subtitle:
                'Paylaşımlarınızı yalnızca mevcut takipçileriniz ve ileride onay vereceğiniz kişiler görebilir.',
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Fotoğraf etiketleme",
            subtitle: 'Herkes sizi etiketleyebilir',
          ),
          HeaderWidget(
            'Canlı yayın',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Canlı yayına bağlan",
            subtitle:
                'Açık olduğunda canlı yayın yapabilir ve yorum yapabilirsiniz; kapalı olduğunda diğerleri canlı yayın veya yorum yapamaz.',
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          HeaderWidget(
            'Keşfedilebilirlik ve kişiler',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Keşfedilebilirlik ve kişiler",
            vPadding: 15,
            showDivider: false,
          ),
          SettingRowWidget(
            '',
            subtitle:
                'Bu verilerin sizi diğer kişilerle nasıl eşleştirmek için kullanıldığı hakkında daha fazla bilgi edinin.',
            vPadding: 15,
            showDivider: false,
          ),
          HeaderWidget(
            'Güvenlik',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Hassas içerik barındırabilecek medyayı göster",
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Paylaştığınız medyayı hassas içerik barındırabilir olarak işaretle",
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Engellenen hesaplar",
            showDivider: false,
          ),
          SettingRowWidget(
            "Sessize alınan hesaplar",
            showDivider: false,
          ),
          SettingRowWidget(
            "Sessize alınan kelimeler",
            showDivider: false,
          ),
          HeaderWidget(
            'Konum',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Tam konum",
            subtitle:
                'Kapalı \n\n\nAçık olduğunda Toldya, cihazınızın tam konumunu (GPS bilgisi gibi) toplar, saklar ve kullanır. Bu sayede Toldya deneyiminizi iyileştirir; örneğin daha yerel içerik, reklam ve öneriler sunar.',
          ),
          HeaderWidget(
            'Kişiselleştirme ve veri',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Kişiselleştirme ve veri",
            subtitle: "Tümüne izin ver",
          ),
          SettingRowWidget(
            "Toldya verilerinizi görüntüle",
            subtitle:
                "Profil bilgilerinizi ve hesabınızla ilişkili verileri inceleyin ve düzenleyin.",
          ),
        ],
      ),
    );
  }
}
