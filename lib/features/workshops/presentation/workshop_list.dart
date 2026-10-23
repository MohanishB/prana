import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/workshop_date_formatter.dart';
import '../bloc/workshop_cubit.dart';
import '../data/workshop_models.dart';

class WorkshopList extends StatelessWidget {
  const WorkshopList({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) =>
            WorkshopListCubit(context.read<AppDependencies>().workshopRepository)
              ..load(),
        child: const _WorkshopListBody(),
      );
}

class _WorkshopListBody extends StatelessWidget {
  const _WorkshopListBody();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopListCubit, WorkshopListState>(
        builder: (context, state) {
          if (state.loading && state.programs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.error != null && state.programs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Text('Unable to load workshops'),
                TextButton(
                  onPressed: context.read<WorkshopListCubit>().load,
                  child: const Text('Retry'),
                ),
              ]),
            );
          }
          if (state.programs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Text('No workshops enrolled yet.'),
            );
          }
          return Column(
            children: [
              for (final program in state.programs) ...[
                _ProgramCard(
                  program: program,
                  progress: state.progress[program.bookingId],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.loading) const LinearProgressIndicator(),
            ],
          );
        },
      );
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.progress});

  final WorkshopProgram program;
  final int? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final day = program.currentDay;
    final status = day?.displayedState ?? program.status.toLowerCase();
    final active = status == 'open';
    final statusColor = active ? scheme.primary : scheme.onSurfaceVariant;
    final label = day == null
        ? program.status
        : 'Day ${day.number} · ${_statusText(status)}';

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .75)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            RouteNames.workshopDetail,
            pathParameters: {'bookingId': '${program.bookingId}'},
          );
          if (context.mounted) context.read<WorkshopListCubit>().load();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 166,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (program.imageUrl.isNotEmpty)
                    Image.network(
                      program.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          ColoredBox(color: scheme.primaryContainer),
                    )
                  else
                    ColoredBox(color: scheme.primaryContainer),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(active ? Icons.play_circle_fill : Icons.event,
                              color: statusColor, size: 15),
                          const SizedBox(width: 6),
                          Text(label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              )),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    '${program.totalDays}-day workshop · ${program.status}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (day != null && day.heading.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(day.heading, style: theme.textTheme.bodyMedium),
                  ],
                  if (day == null && program.nextUnlock != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      WorkshopDateFormatter.nextDay(
                        program.nextUnlock!.number,
                        program.nextUnlock!.startsAt,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (progress != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress! / 100,
                        minHeight: 7,
                        backgroundColor: scheme.primary.withValues(alpha: .12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$progress% progressed',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(children: [
                    Text('View workshop',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        color: scheme.primary, size: 18),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(String status) => switch (status) {
        'open' => 'Open',
        'watched' => 'Watched',
        'over' || 'missed' => 'Over',
        'locked' => 'Locked',
        _ => status,
      };
}
