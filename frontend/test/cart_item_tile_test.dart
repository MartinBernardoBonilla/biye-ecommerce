import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/cart/presentation/widgets/cart_item_tile.dart';

void main() {
  final testItem = CartItem(
    id: 'prod-1',
    name: 'Remera Azul',
    price: 1500.0,
    quantity: 2,
    imageUrl: '',
    description: 'Remera de algodón',
  );

  Widget buildWidget(CartItem item) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => CartBloc(),
          child: CartItemTile(item: item),
        ),
      ),
    );
  }

  group('CartItemTile — renderizado', () {
    testWidgets('muestra el nombre del producto', (tester) async {
      await tester.pumpWidget(buildWidget(testItem));
      expect(find.text('Remera Azul'), findsOneWidget);
    });

    testWidgets('muestra el precio unitario formateado', (tester) async {
      await tester.pumpWidget(buildWidget(testItem));
      expect(find.text('\$1500.00 c/u'), findsOneWidget);
    });

    testWidgets('muestra la cantidad actual', (tester) async {
      await tester.pumpWidget(buildWidget(testItem));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('muestra el subtotal precio x cantidad', (tester) async {
      await tester.pumpWidget(buildWidget(testItem));
      expect(find.text('\$3000.00'), findsOneWidget);
    });

    testWidgets('muestra los botones + y -', (tester) async {
      await tester.pumpWidget(buildWidget(testItem));
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });

  group('CartItemTile — interacciones', () {
    testWidgets('tap en + incrementa la cantidad en el bloc', (tester) async {
      final bloc = CartBloc();
      // Pre-cargamos el item en el bloc
      bloc.add(AddToCart(testItem));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: CartItemTile(item: testItem),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(bloc.state.items.first.quantity, 3);
      bloc.close();
    });

    testWidgets('tap en - decrementa la cantidad en el bloc', (tester) async {
      final bloc = CartBloc();
      bloc.add(AddToCart(testItem));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: CartItemTile(item: testItem),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(bloc.state.items.first.quantity, 1);
      bloc.close();
    });
  });
}
