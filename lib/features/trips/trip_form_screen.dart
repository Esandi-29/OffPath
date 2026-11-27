import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/validators.dart';
import '../../core/widgets/message_view.dart';
import '../../core/widgets/network_photo.dart';
import '../../data/models/destination.dart';
import '../../data/models/trip.dart';
import '../auth/auth_providers.dart';
import '../destination/destination_providers.dart';
import 'trip_format.dart';
import 'trip_providers.dart';

/// New trip (no [tripId]) or Edit trip. [initialDestinationId] pre-selects
/// the destination when opened from "Add to trip" on Destination Details.
class TripFormScreen extends ConsumerWidget {
  const TripFormScreen({super.key, this.tripId, this.initialDestinationId});

  final String? tripId;
  final String? initialDestinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(destinationsProvider);
    final trips = ref.watch(tripsProvider);
    final editing = tripId != null;

    Scaffold message(IconData icon, String title, String text) => Scaffold(
      appBar: AppBar(leading: const _CloseButton()),
      body: MessageView(icon: icon, title: title, message: text),
    );

    // Wait for the destinations (and, when editing, the trip) before
    // building the form, so it starts with the right values.
    if (destinations.hasError || (editing && trips.hasError)) {
      return message(Icons.cloud_off_outlined, "Couldn't load the form",
          'Check your connection and try again.');
    }
    if (!destinations.hasValue || (editing && !trips.hasValue)) {
      return Scaffold(
        appBar: AppBar(leading: const _CloseButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    Trip? existing;
    if (editing) {
      final matches = trips.requireValue.where((trip) => trip.id == tripId);
      if (matches.isEmpty) {
        return message(Icons.luggage_outlined, 'Trip not found',
            'It may have been deleted.');
      }
      existing = matches.first;
    }

    return _TripForm(
      destinations: destinations.requireValue,
      existing: existing,
      initialDestinationId: initialDestinationId,
    );
  }
}

class _TripForm extends ConsumerStatefulWidget {
  const _TripForm({
    required this.destinations,
    required this.existing,
    required this.initialDestinationId,
  });

  final List<Destination> destinations;
  final Trip? existing; // null = new trip
  final String? initialDestinationId;

  @override
  ConsumerState<_TripForm> createState() => _TripFormState();
}

class _TripFormState extends ConsumerState<_TripForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  String? _destinationId;
  DateTimeRange? _dates;

  @override
  void initState() {
    super.initState();
    final trip = widget.existing;
    _title = TextEditingController(text: trip?.title ?? '');
    _notes = TextEditingController(text: trip?.notes ?? '');
    final wanted = trip?.destinationId ?? widget.initialDestinationId;
    // Only pre-select an id that is really in the list.
    _destinationId =
    widget.destinations.any((d) => d.id == wanted) ? wanted : null;
    _dates = trip == null
        ? null
        : DateTimeRange(start: trip.startDate, end: trip.endDate);
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDates(FormFieldState<DateTimeRange> field) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10), // past trips are allowed
      lastDate: DateTime(now.year + 5),
      initialDateRange: field.value,
      helpText: 'Select trip dates',
    );
    if (picked == null) return; // cancelled
    field.didChange(picked);
    _dates = picked;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final destination =
    widget.destinations.firstWhere((d) => d.id == _destinationId);
    final start = DateUtils.dateOnly(_dates!.start);
    final end = DateUtils.dateOnly(_dates!.end);
    final existing = widget.existing;
    final today = DateUtils.dateOnly(DateTime.now());

    final trip = Trip(
      id: existing?.id ?? '',
      title: _title.text.trim(),
      destinationId: destination.id,
      destinationName: destination.name,
      country: destination.country,
      photoUrl: destination.photo.url,
      startDate: start,
      endDate: end,
      notes: _notes.text.trim(),
      // "Did you go?" only makes sense once a trip is over, so moving its
      // dates into the future clears the answer.
      visited: end.isBefore(today) ? existing?.visited : null,
    );

    final repository = ref.read(tripRepositoryProvider);
    if (existing == null) {
      repository.addTrip(uid, trip);
    } else {
      repository.updateTrip(uid, trip);
    }

    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(SnackBar(
      content: Text(existing == null ? 'Trip saved' : 'Trip updated'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const _CloseButton(),
        title: Text(widget.existing == null ? 'New trip' : 'Edit trip'),
      ),
      // Save stays at the bottom of the screen, above the keyboard.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(onPressed: _save, child: const Text('Save trip')),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const _FieldLabel('Trip name', required: true),
            TextFormField(
              controller: _title,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Hill escape',
                counterText: '', // no counter under the name
              ),
              validator: Validators.tripName,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Destination', required: true),
            DropdownButtonFormField<String>(
              initialValue: _destinationId,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Choose a hidden gem'),
              items: [
                for (final destination in widget.destinations)
                  DropdownMenuItem(
                    value: destination.id,
                    child: _DestinationOption(destination: destination),
                  ),
              ],
              onChanged: (id) => _destinationId = id,
              validator: Validators.tripDestination,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Dates', required: true),
            FormField<DateTimeRange>(
              initialValue: _dates,
              validator: (range) =>
                  Validators.tripDates(range?.start, range?.end),
              builder: (field) {
                final range = field.value;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _pickDates(field),
                  child: InputDecorator(
                    isEmpty: range == null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      hintText: 'Select dates',
                      errorText: field.errorText,
                    ),
                    child: Text(range == null
                        ? ''
                        : '${formatTripDates(range.start, range.end)}'
                        ' · ${formatDayCount(_daysIn(range))}'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Notes'),
            TextFormField(
              controller: _notes,
              minLines: 4,
              maxLines: 6,
              maxLength: 500, // shows the "0/500" counter
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Bookings, packing list or reminders…',
                alignLabelWithHint: true,
              ),
              validator: Validators.tripNotes,
            ),
          ],
        ),
      ),
    );
  }

  // Rounds the hours, so a 23-hour daylight-saving day still counts as one.
  static int _daysIn(DateTimeRange range) =>
      (range.duration.inHours / 24).round() + 1;
}

/// Field label with a red * when required, or "(optional)".
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: label,
          style: text.titleSmall,
          children: [
            if (required)
              TextSpan(text: ' *', style: TextStyle(color: scheme.error))
            else
              TextSpan(
                text: ' (optional)',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row in the destination dropdown: thumbnail + "Name, Country".
class _DestinationOption extends StatelessWidget {
  const _DestinationOption({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
            height: 32,
            child: NetworkPhoto(url: destination.photo.url),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${destination.name}, ${destination.country}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Close',
      icon: const Icon(Icons.close),
      onPressed: () => context.pop(),
    );
  }
}