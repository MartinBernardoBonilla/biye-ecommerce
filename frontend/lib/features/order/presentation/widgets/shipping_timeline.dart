import 'package:flutter/material.dart';
import 'package:biye/features/order/domain/entities/order.dart';

class ShippingTimeline extends StatelessWidget {
  final OrderShipping shipping;

  const ShippingTimeline({super.key, required this.shipping});

  @override
  Widget build(BuildContext context) {
    final tracking = shipping.tracking;

    // Si es retiro por el local, simplificamos la UI drásticamente
    if (shipping.method == 'pickup') {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Retiro por el Local',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tracking.status == 'delivered'
                          ? '¡Tu pedido ya fue retirado!'
                          : 'Listo para retirar en nuestra sucursal.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Definimos los pasos del envío por correo/moto
    final steps = [
      _TimelineStep(
        title: 'Preparando embalaje',
        subtitle: 'El vendedor está armando tu paquete.',
        isActive: true,
        isCompleted: _isStepCompleted('pending_label', tracking.status),
      ),
      _TimelineStep(
        title: 'Listo para despacho',
        subtitle:
            'Esperando recolecta de ${shipping.carrierName ?? "logística"}.',
        isActive: _isStepActive('ready_to_ship', tracking.status),
        isCompleted: _isStepCompleted('ready_to_ship', tracking.status),
      ),
      _TimelineStep(
        title: 'En viaje',
        subtitle: 'El paquete está en camino a tu domicilio.',
        isActive: _isStepActive('in_transit', tracking.status),
        isCompleted: _isStepCompleted('in_transit', tracking.status),
      ),
      _TimelineStep(
        title: 'Entregado',
        subtitle: 'Paquete recibido correctamente.',
        isActive: _isStepActive('delivered', tracking.status),
        isCompleted: _isStepCompleted('delivered', tracking.status),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card de Información del Carrier (Andreani / Moto)
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // ✅ Código corregido:
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Envío vía: ${shipping.carrierName?.toUpperCase() ?? "Personalizado"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tracking.status == 'failed'
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tracking.statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tracking.status == 'failed'
                              ? Colors.red.shade900
                              : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                if (tracking.trackingNumber != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Código de seguimiento: ${tracking.trackingNumber}',
                    style: TextStyle(
                        color: Colors.grey.shade700, fontFamily: 'monospace'),
                  ),
                ],
                if (tracking.labelUrl != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Aquí podrías usar url_launcher en el futuro para abrir el PDF de la etiqueta
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Descargar Etiqueta de Envío'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Render de la línea de tiempo
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.isCompleted
                            ? Colors.green
                            : step.isActive
                                ? Colors.blue
                                : Colors.grey.shade300,
                      ),
                      child: step.isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : step.isActive
                              ? const Icon(Icons.radio_button_checked,
                                  size: 14, color: Colors.white)
                              : null,
                    ),
                    if (index != steps.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: step.isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: step.isActive || step.isCompleted
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Helpers lógicos para encender los circulitos según jerarquía del backend
  bool _isStepActive(String step, String currentStatus) =>
      currentStatus == step;

  bool _isStepCompleted(String step, String currentStatus) {
    final weights = {
      'pending_label': 1,
      'ready_to_ship': 2,
      'in_transit': 3,
      'delivered': 4,
      'failed': 0
    };
    return (weights[currentStatus] ?? 0) >= (weights[step] ?? 0);
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isCompleted;

  _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isCompleted,
  });
}
