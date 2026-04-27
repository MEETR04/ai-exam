import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'features/invoice/logic/invoice_list_controller.dart';
import 'features/invoice/logic/invoice_form_controller.dart';
import 'features/invoice/logic/storage_service.dart';
import 'logic/dependency_provider.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  // Preserve the native splash until app is ready
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  final storageService = StorageService();
  final listController = InvoiceListController(storageService);
  await listController.loadInvoices();

  final formController = InvoiceFormController();

  // Remove splash once data is ready
  FlutterNativeSplash.remove();

  runApp(
    DependencyProvider(
      listController: listController,
      formController: formController,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: MaterialApp(
            title: 'Invoice Generator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: const MainPage(),
          ),
        );
      },
    );
  }
}
