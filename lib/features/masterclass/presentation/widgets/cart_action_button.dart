import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../core/localization/app_localizations_x.dart';
import '../../bloc/masterclass_cart_cubit.dart';

/// App bar cart icon with the number of masterclasses in the cart.
class CartActionButton extends StatelessWidget {
  const CartActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterclassCartCubit, MasterclassCartState>(
      builder: (context, state) => IconButton(
        tooltip: context.l10n.cart,
        onPressed: () => context.pushNamed(RouteNames.masterclassCart),
        icon: Badge(
          isLabelVisible: state.count > 0,
          label: Text('${state.count}'),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
