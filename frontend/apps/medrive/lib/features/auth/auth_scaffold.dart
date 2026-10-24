import 'package:material_ui/material_ui.dart';
import 'package:medrive_ui/medrive_ui.dart';

/// Kerangka layar masuk/daftar Figma: header merah "Hallo, Selamat Datang" dengan logo sebagai
/// huruf "o", lalu lembar putih bersudut besar berisi form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.showBack = false,
  });

  final String title;
  final Widget child;
  final Widget? footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MedColors.brand,
    body: SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Kembali',
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                  const _Greeting(),
                  const SizedBox(height: 36),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: MedColors.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(MedRadius.sheet),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        MedSpace.xl,
                        MedSpace.xxl,
                        MedSpace.xl,
                        MedSpace.xl,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: MedSpace.xl),
                            child,
                            const Spacer(),
                            if (footer != null) ...[
                              const SizedBox(height: MedSpace.xl),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: 'Hallo, selamat datang di MeDrive',
    child: ExcludeSemantics(
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // const Text(
                //   'Hall',
                //   style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, height: 1),
                // ),
                Image.asset('assets/images/logo_white.png', height: 50),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
