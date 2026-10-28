
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/bloc/catalog_refresh_cubit.dart';
import '../../../core/files/downloadable_file.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/utils/workshop_date_formatter.dart';
import '../../../core/widgets/downloadable_file_tile.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/workshop_cubit.dart';
import '../data/workshop_models.dart';

class WorkshopDetailScreen extends StatelessWidget {
 const WorkshopDetailScreen({required this.bookingId,super.key});
 final int bookingId;
 @override
 Widget build(BuildContext context)=>BlocProvider(
  create:(context)=>WorkshopDetailCubit(context.read<AppDependencies>().workshopRepository,bookingId)..load(),
  child:const _DetailBody());
}
class _DetailBody extends StatelessWidget {
 const _DetailBody();
 @override
 Widget build(BuildContext context)=>BlocConsumer<WorkshopDetailCubit,WorkshopDetailState>(
 listenWhen:(a,b)=>a.error!=b.error&&b.error!=null&&b.detail!=null,
 listener:(context,state)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.errorGeneric))),
 builder:(context,state)=>Scaffold(
  appBar:PranaAppBar(title:state.detail?.program.title??'Workshop',showBack:true),
  body:state.detail==null
   ? Center(child:state.loading?const CircularProgressIndicator():Column(mainAxisSize:MainAxisSize.min,children:[
      Text(state.error??'Unable to load workshop'),
      TextButton(onPressed:context.read<WorkshopDetailCubit>().load,child:const Text('Retry')),
     ]))
   : RefreshIndicator(onRefresh:context.read<WorkshopDetailCubit>().load,
     child:ResponsiveContent(child:_DetailContent(detail:state.detail!))),
 ));
}
class _DetailContent extends StatelessWidget {
 const _DetailContent({required this.detail});
 final WorkshopDetail detail;
 @override
 Widget build(BuildContext context){
 final theme=Theme.of(context);
 final deps=context.read<AppDependencies>();
 return DefaultTabController(length:2,child:ListView(padding:const EdgeInsets.symmetric(horizontal:12,vertical:20),children:[
  Row(children:[
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(detail.program.notStarted?context.l10n.programNotStarted.toUpperCase():'DAY ${detail.currentDayNumber} OF ${detail.totalDays}',style:theme.textTheme.labelSmall?.copyWith(color:theme.colorScheme.primary)),
      const SizedBox(height:8),
      Text('Your workshop journey',style:theme.textTheme.titleLarge),
    ])),
    SizedBox(width:72,height:72,child:Stack(fit:StackFit.expand,children:[
     CircularProgressIndicator(value:detail.progressPercent/100,strokeWidth:6,
       backgroundColor:theme.colorScheme.surfaceContainerHighest),
     Center(child:Text('${detail.progressPercent}%',style:theme.textTheme.titleMedium)),
    ])),
  ]),
  const SizedBox(height:16),
  if(detail.program.notStarted)...[
   _StartDayOneCard(),
   const SizedBox(height:16),
  ],
  TabBar(tabs:const [Tab(text:'Daily videos'),Tab(text:'Notes & PDFs')],labelColor:theme.colorScheme.primary),
  SizedBox(height:MediaQuery.sizeOf(context).height*.66,child:TabBarView(children:[
   ListView(padding:const EdgeInsets.symmetric(vertical:12),children:[
    for(final day in detail.days)_DayTile(day:day),
   ]),
   ListView(children:[
     for(final note in detail.notes)
       if(note.available&&(note.downloadUrl.isNotEmpty||note.fileUrl.isNotEmpty))
        DownloadableFileTile(
          file:DownloadableFile(
            id:'workshop_${detail.program.bookingId}_${note.scope}_${note.itemId??0}',
            title:note.title,remoteUrl:note.downloadUrl.isNotEmpty?note.downloadUrl:note.fileUrl,
            folder:'workshop_${detail.program.bookingId}'),
          service:deps.fileDownloadService),
     if(!detail.notes.any((n)=>n.available&&(n.fileUrl.isNotEmpty||n.downloadUrl.isNotEmpty)))
       const Padding(padding:EdgeInsets.all(18),child:Text('No notes available yet.')),
   ]),
  ])),
 ]));
 }
}
/// 7-day program waiting to start: the student opens Day 1 when ready.
class _StartDayOneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.programNotStartedHint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            BlocBuilder<WorkshopDetailCubit, WorkshopDetailState>(
              builder: (context, state) => FilledButton.icon(
                onPressed: state.starting ? null : () => _start(context),
                icon: state.starting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.startDayOne),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<WorkshopDetailCubit>();
    final refresh = context.read<CatalogRefreshCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.startDayOneConfirmTitle),
        content: Text(l10n.startDayOneConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.startDayOne),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await cubit.startDayOne();
    refresh.refresh();
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});

  final WorkshopDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = day.displayedState;
    final playable = day.canPlay && status == 'open';
    final watched = status == 'watched';
    final expired = status == 'over';
    final accent = playable
        ? scheme.primary
        : watched
            ? const Color(0xFF34865B)
            : scheme.onSurfaceVariant;
    final statusLabel = switch (status) {
      'open' => 'Open',
      'locked' => 'Locked',
      'not_started' => context.l10n.programNotStarted,
      'watched' => 'Watched',
      'over' => 'Over',
      _ => status,
    };
    final icon = watched
        ? Icons.check_rounded
        : playable
            ? Icons.play_arrow_rounded
            : expired
                ? Icons.history_rounded
                : Icons.lock_outline_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: playable
              ? scheme.primaryContainer.withValues(alpha: .24)
              : scheme.surfaceContainerLow,
          border: Border.all(
            color: playable
                ? scheme.primary.withValues(alpha: .68)
                : scheme.outlineVariant.withValues(alpha: .8),
            width: playable ? 1.3 : 1,
          ),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 21, color: accent),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${day.number} · ${day.heading}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (playable) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () async {
                    await context.pushNamed(
                      RouteNames.workshopDayVideo,
                      pathParameters: {
                        'bookingId':
                            '${context.read<WorkshopDetailCubit>().bookingId}',
                        'itemId': '${day.itemId}',
                      },
                    );
                    if (context.mounted) {
                      context.read<WorkshopDetailCubit>().load();
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Play Day ${day.number}'),
                ),
              ] else if (status == 'locked' && day.startsAt.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Unlocks ${WorkshopDateFormatter.unlock(day.startsAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
