import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ui/models/user.dart';
import 'package:flutter_ui/widgets/app_header.dart';
import 'package:flutter_ui/widgets/featured_carousel.dart';

void main() {
  testWidgets('featured carousel advances when swiped', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FeaturedCarousel())),
    );

    expect(find.text('Satu cerita bisa membuka banyak hal.'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Beri ruang untuk ide yang baik.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('account menu exposes profile and logout actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppHeader())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu akun'));
    await tester.pumpAndSettle();

    expect(find.text('Pengguna'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('user includes avatar URL returned by the API', () {
    final user = User.fromJson({
      'id': 15,
      'name': 'Nadia',
      'email': 'nadia@example.com',
      'profile_image_url': 'https://readlater.test/api/users/15/avatar',
    });

    expect(user.profileImageUrl, 'https://readlater.test/api/users/15/avatar');
  });
}
