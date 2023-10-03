import 'package:auto_injector/auto_injector.dart';
import 'package:chat/generated/dsql.dart';
import 'package:chat/services/auth_service.dart';

AutoInjector injector = AutoInjector();

Future<void> init() async {
  final dsql = await DSQL.init();

  injector.addInstance<DSQL>(dsql);

  injector.add<AuthService>(AuthService.new);

  injector.commit();
}
