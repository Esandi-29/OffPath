import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/offpath_colors.dart';
import '../../core/widgets/message_view.dart';
import '../../core/widgets/network_photo.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/trip.dart';
import '../auth/auth_providers.dart';
import 'trip_format.dart';
import 'trip_providers.dart';

/// My trips: upcoming trips (including ones happening now) as photo cards,
/// then past trips as compact rows. Opened from Profile.
class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  void _newTrip(BuildContext context) => context.push('/trips/new');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final scheme = Theme.of(context).colorScheme;
    final hasTrips = trips.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My trips')),
      // The empty state has its own button, so the floating one only
      // shows once there are trips.
      floatingActionButton: hasTrips
          ? FloatingActionButton.extended(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        onPressed: () => _newTrip(context),
        icon: const Icon(Icons.add),
        label: const Text('New trip'),
      )
          : null,
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => MessageView(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load your trips",
          message: 'Check your connection and try again.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(tripsProvider),
        ),
        data: (all) => all.isEmpty
            ? _EmptyTrips(onPlan: () => _newTrip(context))
            : _TripList(trips: all),
      ),
    );
  }
}

/// Splits the trips into Upcoming (soonest first) and Past (latest first).
class _TripList extends StatelessWidget {
  const _TripList({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final upcoming = trips
        .where((trip) => trip.statusOn(today) != TripStatus.past)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final past = trips
        .where((trip) => trip.statusOn(today) == TripStatus.past)
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 112), // room for the button
      children: [
        if (upcoming.isNotEmpty) ...[
          const SectionHeader(title: 'Upcoming'),
          const SizedBox(height: 8),
          for (final trip in upcoming)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _UpcomingTripCard(trip: trip, today: today),
            ),
        ],
        if (past.isNotEmpty) ...[
          const SectionHeader(title: 'Past'),
          const SizedBox(height: 8),
          for (final trip in past)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PastTripCard(trip: trip),
            ),
        ],
      ],
    );
  }
}

/// Large card: destination photo with a status chip, then the details.
class _UpcomingTripCard extends StatelessWidget {
  const _UpcomingTripCard({required this.trip, required this.today});

  final Trip trip;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final happeningNow = trip.statusOn(today) == TripStatus.happeningNow;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkPhoto(url: trip.photoUrl),
                Positioned(
                  top: 12,
                  left: 12,
                  child: happeningNow
                      ? const _StatusChip(_ChipKind.happeningNow)
                      : _StatusChip(
                    _ChipKind.countdown,
                    label: formatCountdown(trip.daysUntilStart(today)),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _TripMenu(trip: trip, onPhoto: true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.title, style: text.titleLarge),
                const SizedBox(height: 6),
                _IconLine(icon: Icons.place_outlined, text: trip.place),
                const SizedBox(height: 4),
                _IconLine(
                  icon: Icons.calendar_today_outlined,
                  text: '${formatTripDates(trip.startDate, trip.endDate)}'
                      ' · ${formatDayCount(trip.dayCount)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact row for a trip that has ended.
class _PastTripCard extends StatelessWidget {
  const _PastTripCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 76,
              height: 76,
              child: NetworkPhoto(url: trip.photoUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(
                  trip.visited == true ? _ChipKind.visited : _ChipKind.past,
                ),
                const SizedBox(height: 6),
                Text(
                  trip.title,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _IconLine(
                  icon: Icons.place_outlined,
                  text: '${trip.place} · ${formatTripMonth(trip.startDate)}',
                ),
              ],
            ),
          ),
          _TripMenu(trip: trip),
        ],
      ),
    );
  }
}

enum _TripAction { edit, delete }

/// The ⋮ menu on a trip card: Edit, or Delete (with a confirmation).
class _TripMenu extends ConsumerWidget {
  const _TripMenu({required this.trip, this.onPhoto = false});

  final Trip trip;
  final bool onPhoto; // white circle so it shows on top of the photo

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this trip?'),
        content: Text('"${trip.title}" will be removed from My trips. '
            "This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (delete != true) return; // cancelled, or tapped outside the dialog

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    ref.read(tripRepositoryProvider).deleteTrip(uid, trip.id);
    messenger.showSnackBar(
      SnackBar(content: Text('"${trip.title}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_TripAction>(
      tooltip: 'Trip options',
      icon: Icon(
        Icons.more_vert,
        color: onPhoto ? Colors.black87 : scheme.onSurfaceVariant,
      ),
      style: onPhoto
          ? IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      )
          : null,
      onSelected: (action) {
        switch (action) {
          case _TripAction.edit:
            context.push('/trips/${trip.id}/edit');
          case _TripAction.delete:
            _confirmDelete(context, ref);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _TripAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _TripAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

/// Small grey icon followed by one line of text.
class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

enum _ChipKind { countdown, happeningNow, past, visited }

/// Pill showing where a trip is in time, in the mockup's colours.
class _StatusChip extends StatelessWidget {
  const _StatusChip(this.kind, {this.label = ''});

  final _ChipKind kind;
  final String label; // only used for the countdown

  @override
  Widget build(BuildContext context) {
    final colors = context.offPath;
    final scheme = Theme.of(context).colorScheme;

    final (background, foreground, icon, words) = switch (kind) {
      _ChipKind.countdown =>
      (colors.hiddenGem, colors.onAccent, Icons.schedule, label),
      _ChipKind.happeningNow =>
      (colors.success, colors.onAccent, Icons.luggage_outlined, 'Happening now'),
      _ChipKind.past => (
      scheme.surfaceContainerHighest,
      scheme.onSurfaceVariant,
      Icons.history,
      'Past',
      ),
      _ChipKind.visited =>
      (colors.success, colors.onAccent, Icons.check, 'Visited'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            words,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the user has no trips yet.
class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips({required this.onPlan});

  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(Icons.map_outlined, size: 30, color: scheme.primary),
              ),
              const SizedBox(height: 16),
              Text('Plan your first trip',
                  style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                'Pick a hidden gem and set dates.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPlan,
                  icon: const Icon(Icons.add),
                  label: const Text('Plan a trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}