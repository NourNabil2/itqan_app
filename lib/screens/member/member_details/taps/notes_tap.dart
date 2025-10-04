// ============= Member Notes Widgets - كلاسات منفصلة =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/error_notes_widget.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/loading_notes_widget.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/premium_lock_widget.dart';
import '../widgets/notes/detailes_notes_section.dart';
import '../widgets/notes/general_notes_section.dart';


class MemberNotesTab extends StatelessWidget {
  final Member member;
  final VoidCallback onEditGeneralNotes;
  final VoidCallback onAddDetailedNote;
  final VoidCallback onViewAllNotes;
  final Function(MemberNote) onViewNoteDetails;

  const MemberNotesTab({
    super.key,
    required this.member,
    required this.onEditGeneralNotes,
    required this.onAddDetailedNote,
    required this.onViewAllNotes,
    required this.onViewNoteDetails,
  });


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<MemberNotesProvider>(
      builder: (context, notesProvider, child) {
        if (!notesProvider.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notesProvider.loadMemberNotes(member.id);
          });
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(SizeApp.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                child: GeneralNotesSection(
                  member: member,
                  onEditNotes: onEditGeneralNotes,
                ),
              ),

              SizedBox(height: SizeApp.s20),

              PremiumFeature(
                lockHeight: 400.h,
                lockTitle: l10n.detailedNotes,
                lockDescription: l10n.advancedNotesWithDates,
                lockIcon: Icons.note_alt_outlined,
                child: _buildDetailedNotesContent(notesProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedNotesContent(MemberNotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return const LoadingNotesWidget();
    }

    if (notesProvider.error != null) {
      return ErrorNotesWidget(
        error: notesProvider.error!,
        onRetry: () {
          notesProvider.clearError();
          notesProvider.loadMemberNotes(member.id);
        },
      );
    }

    return DetailedNotesSection(
      notesProvider: notesProvider,
      onAddNote: onAddDetailedNote,
      onViewAll: onViewAllNotes,
      onNoteDetails: onViewNoteDetails,
    );
  }
}