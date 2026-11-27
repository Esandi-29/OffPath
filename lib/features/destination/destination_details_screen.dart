import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/offpath_colors.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/hidden_gem_badge.dart';
import '../../core/widgets/message_view.dart';
import '../../core/widgets/network_photo.dart';
import '../../data/models/destination.dart';
import '../../data/models/experience.dart';
import 'destination_providers.dart';

/// Destination Details: a large header photo, then Overview and
/// Experiences tabs. Opened from any card with context.push('/destination/<id>').
class DestinationDetailsScreen extends ConsumerWidget {
  const DestinationDetailsScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(destinationProvider(destinationId));

    return destination.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: MessageView(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load this destination",
          message: 'Check your connection and try again.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(destinationProvider(destinationId)),
        ),
      ),
      data: (destination) => destination == null
          ? Scaffold(
        appBar: AppBar(),
        body: const MessageView(
          icon: Icons.explore_off_outlined,
          title: 'Destination not found',
          message: 'It may have been removed. Go back to keep exploring.',
        ),
      )
          : _DetailsView(destination: destination),
    );
  }
}

/// The loaded screen. NestedScrollView lets the photo header collapse
/// while each tab keeps its own scroll position.
class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final page = Theme.of(context).scaffoldBackgroundColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: _AddToTripBar(destinationId: destination.id),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Tells the tabs how much of them the pinned header covers.
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: 340,
                backgroundColor: page,
                surfaceTintColor: Colors.transparent,
                forceElevated: innerBoxIsScrolled,
                automaticallyImplyLeading: false,
                leading: const _BackCircleButton(),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _HeaderPhoto(destination: destination),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kTextTabBarHeight),
                  child: ColoredBox(
                    color: page,
                    child: const TabBar(
                      tabs: [Tab(text: 'Overview'), Tab(text: 'Experiences')],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(destination: destination),
              _ExperiencesTab(destinationId: destination.id),
            ],
          ),
        ),
      ),
    );
  }
}

/// White back arrow on a dark circle, readable on the photo and on the
/// collapsed bar.
class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton.filled(
        tooltip: 'Back',
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }
}

/// Header photo with name, place, Hidden Gem badge and the photo credit.
class _HeaderPhoto extends StatelessWidget {
  const _HeaderPhoto({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final place = [destination.region, destination.country]
        .where((part) => part.isNotEmpty)
        .join(', ');

    return Stack(
      fit: StackFit.expand,
      children: [
        NetworkPhoto(url: destination.photo.url),
        // Dark fade at the top (back button) and bottom (white text).
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66000000), Color(0x00000000), Color(0xB3000000)],
              stops: [0, 0.35, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: kTextTabBarHeight + 16, // sits just above the tab bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (destination.featured) ...[
                const HiddenGemBadge(),
                const SizedBox(height: 10),
              ],
              Text(
                destination.name,
                style: text.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                place,
                style: text.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              // Required by the photo licences.
              Text(
                destination.photo.credit,
                style: text.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overview tab: category tags, description, why it's a hidden gem,
/// and practical travel info.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return CustomScrollView(
      key: const PageStorageKey('overview'), // remembers the scroll position
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList.list(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in destination.categories)
                    _CategoryTag(categoryId: category),
                ],
              ),
              const SizedBox(height: 16),
              if (destination.shortDescription.isNotEmpty) ...[
                Text(destination.shortDescription, style: text.titleMedium),
                const SizedBox(height: 12),
              ],
              Text(destination.overview, style: text.bodyLarge),
              if (destination.whyHiddenGem.isNotEmpty) ...[
                const SizedBox(height: 24),
                _WhyHiddenGemCard(reason: destination.whyHiddenGem),
              ],
              _TravelInfoCard(info: destination.travelInfo),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small coloured pill for a category, e.g. "Nature" in green.
class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final label = categoryId.isEmpty
        ? ''
        : categoryId[0].toUpperCase() + categoryId.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor(context, categoryId),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: context.offPath.onAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Yellow-tinted card explaining why the place is a hidden gem.
class _WhyHiddenGemCard extends StatelessWidget {
  const _WhyHiddenGemCard({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.offPath;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.hiddenGem.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.hiddenGem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.hiddenGem,
            child: Icon(Icons.star_rounded, size: 18, color: colors.onAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Why it's a hidden gem", style: text.titleSmall),
                const SizedBox(height: 4),
                Text(reason, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Travel info" heading and a grouped card of the filled-in rows.
class _TravelInfoCard extends StatelessWidget {
  const _TravelInfoCard({required this.info});

  final TravelInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // (icon, label, value) — empty values are left out.
    final rows = [
      (Icons.calendar_month_outlined, 'Best time to visit', info.bestTime),
      (Icons.directions_outlined, 'Getting there', info.gettingThere),
      (Icons.translate, 'Language', info.language),
      (Icons.payments_outlined, 'Currency', info.currency),
    ].where((row) => row.$3.isNotEmpty).toList();

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Travel info', style: text.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 56, color: scheme.outlineVariant),
                ListTile(
                  leading: Icon(rows[i].$1, color: scheme.primary),
                  title: Text(
                    rows[i].$2,
                    style: text.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  subtitle: Text(
                    rows[i].$3,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurface),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Experiences tab: the destination's activities, live from Firestore.
class _ExperiencesTab extends ConsumerWidget {
  const _ExperiencesTab({required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiences = ref.watch(experiencesProvider(destinationId));

    return CustomScrollView(
      key: const PageStorageKey('experiences'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        ...experiences.when<List<Widget>>(
          loading: () => [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (error, stackTrace) => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                icon: Icons.cloud_off_outlined,
                title: "Couldn't load experiences",
                message: 'Check your connection and try again.',
                actionLabel: 'Try again',
                onAction: () =>
                    ref.invalidate(experiencesProvider(destinationId)),
              ),
            ),
          ],
          data: (list) => list.isEmpty
              ? [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                icon: Icons.hiking,
                title: 'No experiences yet',
                message: 'Check back soon for things to do here.',
              ),
            ),
          ]
              : [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _ExperienceCard(experience: list[index]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One experience: photo + credit, title, category, duration, description.
class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: NetworkPhoto(url: experience.photo.url),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              experience.photo.credit,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(experience.title, style: text.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CategoryTag(categoryId: experience.category),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule,
                        size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        experience.duration,
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(experience.description, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed bar at the bottom of Details: plan a trip to this destination.
class _AddToTripBar extends StatelessWidget {
  const _AddToTripBar({required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  context.push('/trips/new?destination=$destinationId'),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Add to trip'),
            ),
          ),
        ),
      ),
    );
  }
}