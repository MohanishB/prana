import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/my_consultations_cubit.dart';
import '../data/consult_checkout_models.dart';

/// The student's booked consultations, with the button to schedule each one.
class MyConsultationsScreen extends StatelessWidget {
  const MyConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: PranaAppBar(title: l10n.myConsultations, showBack: true),
      body: BlocBuilder<MyConsultationsCubit, MyConsultationsState>(
        builder: (context, state) {
          final Widget body;
          if (state.bookings.isNotEmpty) {
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final booking in state.bookings)
                  _BookingCard(booking: booking),
              ],
            );
          } else if (state.error != null) {
            body = AppErrorView(
              message: state.error!.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<MyConsultationsCubit>().load,
            );
          } else if (!state.loaded) {
            body = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.noBookedConsultations,
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<MyConsultationsCubit>().load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContent(child: body),
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final ConsultationBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final day = DateTime.tryParse(booking.bookedDay);
    final bookedOn =
        day == null ? booking.bookedDay : DateFormat('d MMM y').format(day);
    final url = booking.scheduleUrl;
    final scheduledDay = DateTime.tryParse(booking.scheduledDate ?? '');
    final when = [
      if (booking.scheduledDate != null)
        scheduledDay == null
            ? booking.scheduledDate!
            : DateFormat('d MMM y').format(scheduledDay),
      if (booking.scheduledTime != null) booking.scheduledTime!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: booking.imageUrl == null
                        ? ColoredBox(color: theme.colorScheme.primaryContainer)
                        : Image.network(
                            booking.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: theme.colorScheme.primaryContainer,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.bookedOnDate(bookedOn),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (booking.isScheduled) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.scheduledFor(when),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(booking.paid.formatted, style: theme.textTheme.titleSmall),
              ],
            ),
            if (url != null && !booking.isScheduled) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () => context.pushNamed(
                  RouteNames.consultationSchedule,
                  queryParameters: {'url': url, 'title': booking.title},
                ),
                child: Text(l10n.scheduleNow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
